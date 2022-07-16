package io.flutter.plugins.localauth;

import android.annotation.SuppressLint;
import android.app.AlertDialog;
import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.provider.Settings;
import android.view.ContextThemeWrapper;
import android.view.LayoutInflater;
import android.view.View;
import android.widget.TextView;

import androidx.annotation.Nullable;
import androidx.fragment.app.FragmentActivity;

import io.flutter.plugin.common.MethodCall;

/**
 * Provides authentication error handling methods.
 * <p>Commonly methods get {@link io.flutter.plugins.localauth.AuthenticationHelper.AuthCompletionHandler}
 * as parameter and call
 * {@link io.flutter.plugins.localauth.AuthenticationHelper.AuthCompletionHandler#onError}
 * with corresponding error code and error message.
 * </p>
 * <p>Methods may present go to settings dialog if required.
 * </p>
 *
 * @see io.flutter.plugins.localauth.AuthResultErrorCodes
 */
class AuthenticationErrorHandler {
  /**
   * Handling the error when the user's device does not have hardware support for biometrics.
   */
  void handleCredentialsNotAvailableError(
      final FragmentActivity activity,
      boolean canTryUpdateSettings,
      final MethodCall call,
      final AuthenticationHelper.AuthCompletionHandler completionHandler,
      @Nullable final Runnable onStop) {
    boolean useErrorDialogs = call.argument("useErrorDialogs");
    if (canTryUpdateSettings && useErrorDialogs) {
      showGoToSettingsDialog(
          activity,
          (String) call.argument("deviceCredentialsRequired"),
          (String) call.argument("deviceCredentialsSetupDescription"),
          call,
          completionHandler,
          onStop);
      return;
    }
    completionHandler.onError(
        AuthResultErrorCodes.NOT_AVAILABLE, "Security credentials not available.");
    if (onStop != null) {
      onStop.run();
    }
  }

  /**
   * Handling the error when the user has not enrolled any biometrics on the device.
   *
   * @param isDeviceCredentialAllowed {@code true} the error handling can be skipped.
   *                                  In this case the user has other options to authenticate.
   */
  void handleNotEnrolledError(
      final FragmentActivity activity,
      boolean isDeviceCredentialAllowed,
      final MethodCall call,
      final AuthenticationHelper.AuthCompletionHandler completionHandler,
      @Nullable final Runnable onStop) {
    if (isDeviceCredentialAllowed) return;
    if (call.argument("useErrorDialogs")) {
      showGoToSettingsDialog(
          activity,
          (String) call.argument("biometricRequired"),
          (String) call.argument("goToSettingDescription"),
          call,
          completionHandler,
          onStop);
      return;
    }
    completionHandler.onError(
        AuthResultErrorCodes.NOT_ENROLLED, "No Biometrics enrolled on this device.");
    if (onStop != null) {
      onStop.run();
    }
  }

  // Suppress inflateParams lint because dialogs do not need to attach to a parent view.
  @SuppressLint("InflateParams")
  private void showGoToSettingsDialog(
      final FragmentActivity activity,
      String title,
      String descriptionText,
      final MethodCall call,
      final AuthenticationHelper.AuthCompletionHandler completionHandler,
      @Nullable final Runnable onStop) {
    View view = LayoutInflater.from(activity).inflate(R.layout.go_to_setting, null, false);
    TextView message = view.findViewById(R.id.fingerprint_required);
    TextView description = view.findViewById(R.id.go_to_setting_description);
    message.setText(title);
    description.setText(descriptionText);
    Context context = new ContextThemeWrapper(activity, R.style.AlertDialogCustom);
    DialogInterface.OnClickListener goToSettingHandler =
        new DialogInterface.OnClickListener() {
          @Override
          public void onClick(DialogInterface dialog, int which) {
            completionHandler.onFailure();
            if (onStop != null) {
              onStop.run();
            }
            activity.startActivity(new Intent(Settings.ACTION_SECURITY_SETTINGS));
          }
        };
    DialogInterface.OnClickListener cancelHandler =
        new DialogInterface.OnClickListener() {
          @Override
          public void onClick(DialogInterface dialog, int which) {
            completionHandler.onFailure();
            if (onStop != null) {
              onStop.run();
            }
          }
        };
    new AlertDialog.Builder(context)
        .setView(view)
        .setPositiveButton((String) call.argument("goToSetting"), goToSettingHandler)
        .setNegativeButton((String) call.argument("cancelButton"), cancelHandler)
        .setCancelable(false)
        .show();
  }
}
