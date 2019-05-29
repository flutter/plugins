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
import android.widget.TextView;
import androidx.biometric.BiometricPrompt;
import androidx.core.hardware.fingerprint.FingerprintManagerCompat;
import androidx.fragment.app.FragmentActivity;
import io.flutter.plugin.common.MethodCall;

/**
 * Authenticates the user with fingerprint and sends corresponding response back to Flutter.
 *
 * <p>One instance per call is generated to ensure readable separation of executable paths across
 * method calls.
 */
class AuthenticationHelper extends BiometricPrompt.AuthenticationCallback
    implements Application.ActivityLifecycleCallbacks {

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

  private final FragmentActivity activity;
  private final AuthCompletionHandler completionHandler;
  private final KeyguardManager keyguardManager;
  private final FingerprintManagerCompat fingerprintManager;
  private final MethodCall call;
  private final BiometricPrompt.PromptInfo promptInfo;
  private final boolean isAuthSticky;
  private boolean activityPaused = false;

  public AuthenticationHelper(
      FragmentActivity activity, MethodCall call, AuthCompletionHandler completionHandler) {
    this.activity = activity;
    this.completionHandler = completionHandler;
    this.call = call;
    this.keyguardManager = (KeyguardManager) activity.getSystemService(Context.KEYGUARD_SERVICE);
    this.fingerprintManager = FingerprintManagerCompat.from(activity);
    this.isAuthSticky = call.argument("stickyAuth");
    this.promptInfo =
        new BiometricPrompt.PromptInfo.Builder()
            .setDescription((String) call.argument("localizedReason"))
            .setTitle((String) call.argument("signInTitle"))
            .setSubtitle((String) call.argument("fingerprintHint"))
            .setNegativeButtonText((String) call.argument("cancelButton"))
            .build();
  }

  public void authenticate() {
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

  /** Start the fingerprint listener. */
  private void start() {
    activity.getApplication().registerActivityLifecycleCallbacks(this);
    new BiometricPrompt(activity, activity.getMainExecutor(), this).authenticate(promptInfo);
  }

  /**
   * Stops the fingerprint listener.
   *
   * @param success If the authentication was successful.
   */
  private void stop(boolean success) {
    activity.getApplication().unregisterActivityLifecycleCallbacks(this);
    if (success) {
      completionHandler.onSuccess();
    } else {
      completionHandler.onFailure();
    }
  }

  @Override
  public void onAuthenticationError(int errorCode, CharSequence errString) {
    if (activityPaused && isAuthSticky) {
      return;
    }

    // Either the authentication got cancelled by user or we are not interested
    // in sticky auth, so return failure.
    stop(false);
  }

  @Override
  public void onAuthenticationSucceeded(BiometricPrompt.AuthenticationResult result) {
    stop(true);
  }

  @Override
  public void onAuthenticationFailed() {
    stop(false);
  }

  /**
   * If the activity is paused, we keep track because fingerprint dialog simply returns "User
   * cancelled" when the activity is paused.
   */
  @Override
  public void onActivityPaused(Activity ignored) {
    if (isAuthSticky) {
      activityPaused = true;
    }
  }

  @Override
  public void onActivityResumed(Activity ignored) {
    if (isAuthSticky) {
      activityPaused = false;
      final BiometricPrompt prompt =
          new BiometricPrompt(activity, activity.getMainExecutor(), this);
      // When activity is resuming, we cannot show the prompt right away. We need to post it to the UI queue.
      new Handler(Looper.myLooper())
          .postDelayed(
              new Runnable() {
                @Override
                public void run() {
                  prompt.authenticate(promptInfo);
                }
              },
              100);
    }
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
        .setNegativeButton((String) call.argument("cancelButton"), cancelHandler)
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
