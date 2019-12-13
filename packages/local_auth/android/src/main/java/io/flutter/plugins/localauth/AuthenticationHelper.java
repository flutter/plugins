// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
package io.flutter.plugins.localauth;

import android.annotation.SuppressLint;
import android.app.Activity;
import android.app.AlertDialog;
import android.app.Application;
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
import androidx.annotation.NonNull;
import androidx.biometric.BiometricPrompt;
import androidx.fragment.app.FragmentActivity;
import androidx.lifecycle.DefaultLifecycleObserver;
import androidx.lifecycle.Lifecycle;
import androidx.lifecycle.LifecycleOwner;
import io.flutter.plugin.common.MethodCall;
import java.util.concurrent.Executor;

/**
 * Authenticates the user with fingerprint and sends corresponding response back to Flutter.
 *
 * <p>One instance per call is generated to ensure readable separation of executable paths across
 * method calls.
 */
@SuppressWarnings("deprecation")
class AuthenticationHelper extends BiometricPrompt.AuthenticationCallback
    implements Application.ActivityLifecycleCallbacks, DefaultLifecycleObserver {

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

  // This is null when not using v2 embedding;
  private final Lifecycle lifecycle;
  private final FragmentActivity activity;
  private final AuthCompletionHandler completionHandler;
  private final MethodCall call;
  private final BiometricPrompt.PromptInfo promptInfo;
  private final boolean isAuthSticky;
  private final UiThreadExecutor uiThreadExecutor;
  private boolean activityPaused = false;
  private BiometricPrompt biometricPrompt;

  AuthenticationHelper(
      Lifecycle lifecycle,
      FragmentActivity activity,
      MethodCall call,
      AuthCompletionHandler completionHandler) {
    this.lifecycle = lifecycle;
    this.activity = activity;
    this.completionHandler = completionHandler;
    this.call = call;
    this.isAuthSticky = call.argument("stickyAuth");
    this.uiThreadExecutor = new UiThreadExecutor();
    this.promptInfo =
        new BiometricPrompt.PromptInfo.Builder()
            .setDescription((String) call.argument("localizedReason"))
            .setTitle((String) call.argument("signInTitle"))
            .setSubtitle((String) call.argument("fingerprintHint"))
            .setNegativeButtonText((String) call.argument("cancelButton"))
            .setConfirmationRequired((Boolean) call.argument("sensitiveTransaction"))
            .build();
  }

  /** Start the fingerprint listener. */
  void authenticate() {
    if (lifecycle != null) {
      lifecycle.addObserver(this);
    } else {
      activity.getApplication().registerActivityLifecycleCallbacks(this);
    }
    biometricPrompt = new BiometricPrompt(activity, uiThreadExecutor, this);
    biometricPrompt.authenticate(promptInfo);
  }

  /** Cancels the fingerprint authentication. */
  void stopAuthentication() {
    if (biometricPrompt != null) {
      biometricPrompt.cancelAuthentication();
      biometricPrompt = null;
    }
  }

  /** Stops the fingerprint listener. */
  private void stop() {
    if (lifecycle != null) {
      lifecycle.removeObserver(this);
      return;
    }
    activity.getApplication().unregisterActivityLifecycleCallbacks(this);
  }

  @SuppressLint("SwitchIntDef")
  @Override
  public void onAuthenticationError(int errorCode, CharSequence errString) {
    switch (errorCode) {
      case BiometricPrompt.ERROR_NO_DEVICE_CREDENTIAL:
        completionHandler.onError(
            "PasscodeNotSet",
            "Phone not secured by PIN, pattern or password, or SIM is currently locked.");
        break;
      case BiometricPrompt.ERROR_NO_SPACE:
      case BiometricPrompt.ERROR_NO_BIOMETRICS:
        if (call.argument("useErrorDialogs")) {
          showGoToSettingsDialog();
          return;
        }
        completionHandler.onError("NotEnrolled", "No Biometrics enrolled on this device.");
        break;
      case BiometricPrompt.ERROR_HW_UNAVAILABLE:
      case BiometricPrompt.ERROR_HW_NOT_PRESENT:
        completionHandler.onError("NotAvailable", "Biometrics is not available on this device.");
        break;
      case BiometricPrompt.ERROR_LOCKOUT:
        completionHandler.onError(
            "LockedOut",
            "The operation was canceled because the API is locked out due to too many attempts. This occurs after 5 failed attempts, and lasts for 30 seconds.");
        break;
      case BiometricPrompt.ERROR_LOCKOUT_PERMANENT:
        completionHandler.onError(
            "PermanentlyLockedOut",
            "The operation was canceled because ERROR_LOCKOUT occurred too many times. Biometric authentication is disabled until the user unlocks with strong authentication (PIN/Pattern/Password)");
        break;
      case BiometricPrompt.ERROR_CANCELED:
        // If we are doing sticky auth and the activity has been paused,
        // ignore this error. We will start listening again when resumed.
        if (activityPaused && isAuthSticky) {
          return;
        } else {
          completionHandler.onFailure();
        }
        break;
      default:
        completionHandler.onFailure();
    }
    stop();
  }

  @Override
  public void onAuthenticationSucceeded(BiometricPrompt.AuthenticationResult result) {
    completionHandler.onSuccess();
    stop();
  }

  @Override
  public void onAuthenticationFailed() {}

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
      final BiometricPrompt prompt = new BiometricPrompt(activity, uiThreadExecutor, this);
      // When activity is resuming, we cannot show the prompt right away. We need to post it to the
      // UI queue.
      uiThreadExecutor.handler.post(
          new Runnable() {
            @Override
            public void run() {
              prompt.authenticate(promptInfo);
            }
          });
    }
  }

  @Override
  public void onPause(@NonNull LifecycleOwner owner) {
    onActivityPaused(null);
  }

  @Override
  public void onResume(@NonNull LifecycleOwner owner) {
    onActivityResumed(null);
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
            completionHandler.onFailure();
            stop();
            activity.startActivity(new Intent(Settings.ACTION_SECURITY_SETTINGS));
          }
        };
    OnClickListener cancelHandler =
        new OnClickListener() {
          @Override
          public void onClick(DialogInterface dialog, int which) {
            completionHandler.onFailure();
            stop();
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

  @Override
  public void onDestroy(@NonNull LifecycleOwner owner) {}

  @Override
  public void onStop(@NonNull LifecycleOwner owner) {}

  @Override
  public void onStart(@NonNull LifecycleOwner owner) {}

  @Override
  public void onCreate(@NonNull LifecycleOwner owner) {}

  private static class UiThreadExecutor implements Executor {
    final Handler handler = new Handler(Looper.getMainLooper());

    @Override
    public void execute(Runnable command) {
      handler.post(command);
    }
  }
}
