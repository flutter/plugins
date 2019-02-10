// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.localauth;

import android.annotation.SuppressLint;
import android.app.Activity;
import android.app.AlertDialog;
import android.app.Application;
import android.app.KeyguardManager;
import android.content.Context;
import android.content.DialogInterface;
import android.content.DialogInterface.OnClickListener;
import android.content.Intent;
import android.os.Bundle;
import android.os.Handler;
import android.os.Looper;
import android.provider.Settings;
import android.view.ContextThemeWrapper;
import android.view.LayoutInflater;
import android.view.View;
import android.widget.ImageView;
import android.widget.TextView;
import androidx.core.content.ContextCompat;
import androidx.core.hardware.fingerprint.FingerprintManagerCompat;
import androidx.core.os.CancellationSignal;
import io.flutter.plugin.common.MethodCall;

/**
 * Authenticates the user with fingerprint and sends corresponding response back to Flutter.
 *
 * <p>One instance per call is generated to ensure readable separation of executable paths across
 * method calls.
 */
class AuthenticationHelper extends FingerprintManagerCompat.AuthenticationCallback
    implements Application.ActivityLifecycleCallbacks {

  /** How long will the fp dialog be delayed to dismiss. */
  private static final long DISMISS_AFTER_MS = 300;

  private static final String CANCEL_BUTTON = "cancelButton";

  /** Captures the state of the fingerprint dialog. */
  private enum DialogState {
    SUCCESS,
    FAILURE
  }

  /** The callback that handles the result of this authentication process. */
  interface AuthCompletionHandler {

    /** Called when authentication was successful. */
    void onSuccess();

    /**
     * Called when authentication failed due to user. For instance, when user cancels the auth or
     * quits the app.
     */
    void onFailure();

    /**
     * Called when authentication fails due to non-user related problems such as system errors,
     * phone not having a FP reader etc.
     *
     * @param code The error code to be returned to Flutter app.
     * @param error The description of the error.
     */
    void onError(String code, String error);
  }

  private final Activity activity;
  private final AuthCompletionHandler completionHandler;
  private final KeyguardManager keyguardManager;
  private final FingerprintManagerCompat fingerprintManager;
  private final MethodCall call;

  /**
   * The prominent UI element during this transaction. It is used to communicate the state of
   * authentication to the user.
   */
  private AlertDialog fingerprintDialog;

  private CancellationSignal cancellationSignal;

  AuthenticationHelper(
      Activity activity, MethodCall call, AuthCompletionHandler completionHandler) {
    this.activity = activity;
    this.completionHandler = completionHandler;
    this.call = call;
    this.keyguardManager = (KeyguardManager) activity.getSystemService(Context.KEYGUARD_SERVICE);
    this.fingerprintManager = FingerprintManagerCompat.from(activity);
  }

  void authenticate() {
    if (fingerprintManager.isHardwareDetected()) {
      if (keyguardManager.isKeyguardSecure() && fingerprintManager.hasEnrolledFingerprints()) {
        start();
      } else {
        if (call.argument("useErrorDialogs")) {
          showGoToSettingsDialog();
        } else if (!keyguardManager.isKeyguardSecure()) {
          completionHandler.onError(
              "PasscodeNotSet",
              "Phone not secured by PIN, pattern or password, or SIM is currently locked.");
        } else {
          completionHandler.onError("NotEnrolled", "No fingerprint enrolled on this device.");
        }
      }
    } else {
      completionHandler.onError("NotAvailable", "Fingerprint is not available on this device.");
    }
  }

  private void start() {
    activity.getApplication().registerActivityLifecycleCallbacks(this);
    resume();
  }

  private void resume() {
    cancellationSignal = new CancellationSignal();
    showFingerprintDialog();
    fingerprintManager.authenticate(null, 0, cancellationSignal, this, null);
  }

  private void pause() {
    if (cancellationSignal != null) {
      cancellationSignal.cancel();
    }
    if (fingerprintDialog != null && fingerprintDialog.isShowing()) {
      fingerprintDialog.dismiss();
    }
  }

  /**
   * Stops the fingerprint listener and dismisses the fingerprint dialog.
   *
   * @param success If the authentication was successful.
   */
  private void stop(boolean success) {
    pause();
    activity.getApplication().unregisterActivityLifecycleCallbacks(this);
    if (success) {
      completionHandler.onSuccess();
    } else {
      completionHandler.onFailure();
    }
  }

  /**
   * If the activity is paused or stopped, we have to stop listening for fingerprint. Otherwise,
   * user can still interact with fp reader in the background.. Sigh..
   */
  @Override
  public void onActivityPaused(Activity activity) {
    if (call.argument("stickyAuth")) {
      pause();
    } else {
      stop(false);
    }
  }

  @Override
  public void onActivityResumed(Activity activity) {
    if (call.argument("stickyAuth")) {
      resume();
    }
  }

  @Override
  public void onAuthenticationError(int errMsgId, CharSequence errString) {
    updateFingerprintDialog(DialogState.FAILURE, errString.toString());
  }

  @Override
  public void onAuthenticationHelp(int helpMsgId, CharSequence helpString) {
    updateFingerprintDialog(DialogState.FAILURE, helpString.toString());
  }

  @Override
  public void onAuthenticationFailed() {
    updateFingerprintDialog(
        DialogState.FAILURE, (String) call.argument("fingerprintNotRecognized"));
  }

  @Override
  public void onAuthenticationSucceeded(FingerprintManagerCompat.AuthenticationResult result) {
    updateFingerprintDialog(DialogState.SUCCESS, (String) call.argument("fingerprintSuccess"));
    new Handler(Looper.myLooper())
        .postDelayed(
            new Runnable() {
              @Override
              public void run() {
                stop(true);
              }
            },
            DISMISS_AFTER_MS);
  }

  private void updateFingerprintDialog(DialogState state, String message) {
    if (cancellationSignal.isCanceled() || !fingerprintDialog.isShowing()) {
      return;
    }
    TextView resultInfo = (TextView) fingerprintDialog.findViewById(R.id.fingerprint_status);
    ImageView icon = (ImageView) fingerprintDialog.findViewById(R.id.fingerprint_icon);
    switch (state) {
      case FAILURE:
        icon.setImageResource(R.drawable.fingerprint_warning_icon);
        resultInfo.setTextColor(ContextCompat.getColor(activity, R.color.warning_color));
        break;
      case SUCCESS:
        icon.setImageResource(R.drawable.fingerprint_success_icon);
        resultInfo.setTextColor(ContextCompat.getColor(activity, R.color.success_color));
        break;
    }
    resultInfo.setText(message);
  }

  // Suppress inflateParams lint because dialogs do not need to attach to a parent view.
  @SuppressLint("InflateParams")
  private void showFingerprintDialog() {
    View view = LayoutInflater.from(activity).inflate(R.layout.scan_fp, null, false);
    TextView fpDescription = (TextView) view.findViewById(R.id.fingerprint_description);
    TextView title = (TextView) view.findViewById(R.id.fingerprint_signin);
    TextView status = (TextView) view.findViewById(R.id.fingerprint_status);
    fpDescription.setText((String) call.argument("localizedReason"));
    title.setText((String) call.argument("signInTitle"));
    status.setText((String) call.argument("fingerprintHint"));
    Context context = new ContextThemeWrapper(activity, R.style.AlertDialogCustom);
    OnClickListener cancelHandler =
        new OnClickListener() {
          @Override
          public void onClick(DialogInterface dialog, int which) {
            stop(false);
          }
        };
    fingerprintDialog =
        new AlertDialog.Builder(context)
            .setView(view)
            .setNegativeButton((String) call.argument(CANCEL_BUTTON), cancelHandler)
            .setCancelable(false)
            .show();
  }

  // Suppress inflateParams lint because dialogs do not need to attach to a parent view.
  @SuppressLint("InflateParams")
  private void showGoToSettingsDialog() {
    View view = LayoutInflater.from(activity).inflate(R.layout.go_to_setting, null, false);
    TextView message = (TextView) view.findViewById(R.id.fingerprint_required);
    TextView description = (TextView) view.findViewById(R.id.go_to_setting_description);
    message.setText((String) call.argument("fingerprintRequired"));
    description.setText((String) call.argument("goToSettingDescription"));
    Context context = new ContextThemeWrapper(activity, R.style.AlertDialogCustom);
    OnClickListener goToSettingHandler =
        new OnClickListener() {
          @Override
          public void onClick(DialogInterface dialog, int which) {
            stop(false);
            activity.startActivity(new Intent(Settings.ACTION_SECURITY_SETTINGS));
          }
        };
    OnClickListener cancelHandler =
        new OnClickListener() {
          @Override
          public void onClick(DialogInterface dialog, int which) {
            stop(false);
          }
        };
    new AlertDialog.Builder(context)
        .setView(view)
        .setPositiveButton((String) call.argument("goToSetting"), goToSettingHandler)
        .setNegativeButton((String) call.argument(CANCEL_BUTTON), cancelHandler)
        .setCancelable(false)
        .show();
  }

  // Unused methods for activity lifecycle.

  @Override
  public void onActivityCreated(Activity activity, Bundle bundle) {}

  @Override
  public void onActivityStarted(Activity activity) {}

  @Override
  public void onActivityStopped(Activity activity) {}

  @Override
  public void onActivitySaveInstanceState(Activity activity, Bundle bundle) {}

  @Override
  public void onActivityDestroyed(Activity activity) {}
}
