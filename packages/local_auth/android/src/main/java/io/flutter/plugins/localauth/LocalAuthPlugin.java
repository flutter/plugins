// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.localauth;

import static android.app.Activity.RESULT_OK;
import static android.content.Context.KEYGUARD_SERVICE;

import android.app.Activity;
import android.app.KeyguardManager;
import android.content.Context;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.hardware.fingerprint.FingerprintManager;
import android.os.Build;
import androidx.annotation.NonNull;
import androidx.biometric.BiometricManager;
import androidx.fragment.app.FragmentActivity;
import androidx.lifecycle.Lifecycle;
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.embedding.engine.plugins.lifecycle.FlutterLifecycleAdapter;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry;
import io.flutter.plugin.common.PluginRegistry.Registrar;
import io.flutter.plugins.localauth.AuthenticationHelper.AuthCompletionHandler;
import java.util.ArrayList;
import java.util.concurrent.atomic.AtomicBoolean;

/**
 * Flutter plugin providing access to local authentication.
 *
 * <p>Instantiate this in an add to app scenario to gracefully handle activity and context changes.
 */
@SuppressWarnings("deprecation")
public class LocalAuthPlugin implements MethodCallHandler, FlutterPlugin, ActivityAware {
  private static final String CHANNEL_NAME = "plugins.flutter.io/local_auth";
  private static final int LOCK_REQUEST_CODE = 221;
  private Activity activity;
  private final AtomicBoolean authInProgress = new AtomicBoolean(false);
  private AuthenticationHelper authHelper;

  // These are null when not using v2 embedding.
  private MethodChannel channel;
  private Lifecycle lifecycle;
  private BiometricManager biometricManager;
  private FingerprintManager fingerprintManager;
  private KeyguardManager keyguardManager;
  private Result lockRequestResult;
  private final PluginRegistry.ActivityResultListener resultListener =
      new PluginRegistry.ActivityResultListener() {
        @Override
        public boolean onActivityResult(int requestCode, int resultCode, Intent data) {
          if (requestCode == LOCK_REQUEST_CODE) {
            if (resultCode == RESULT_OK && lockRequestResult != null) {
              authenticateSuccess(lockRequestResult);
            } else {
              authenticateFail(lockRequestResult);
            }
            lockRequestResult = null;
          }
          return false;
        }
      };

  /**
   * Registers a plugin with the v1 embedding api {@code io.flutter.plugin.common}.
   *
   * <p>Calling this will register the plugin with the passed registrar. However, plugins
   * initialized this way won't react to changes in activity or context.
   *
   * @param registrar attaches this plugin's {@link
   *     io.flutter.plugin.common.MethodChannel.MethodCallHandler} to the registrar's {@link
   *     io.flutter.plugin.common.BinaryMessenger}.
   */
  @SuppressWarnings("deprecation")
  public static void registerWith(Registrar registrar) {
    final MethodChannel channel = new MethodChannel(registrar.messenger(), CHANNEL_NAME);
    final LocalAuthPlugin plugin = new LocalAuthPlugin();
    plugin.activity = registrar.activity();
    channel.setMethodCallHandler(plugin);
    registrar.addActivityResultListener(plugin.resultListener);
  }

  /**
   * Default constructor for LocalAuthPlugin.
   *
   * <p>Use this constructor when adding this plugin to an app with v2 embedding.
   */
  public LocalAuthPlugin() {}

  @Override
  public void onMethodCall(MethodCall call, @NonNull final Result result) {
    switch (call.method) {
      case "authenticate":
        authenticate(call, result);
        break;
      case "getAvailableBiometrics":
        getAvailableBiometrics(result);
        break;
      case "isDeviceSupported":
        isDeviceSupported(result);
        break;
      case "stopAuthentication":
        stopAuthentication(result);
        break;
      default:
        result.notImplemented();
        break;
    }
  }

  /*
   * Starts authentication process
   */
  private void authenticate(MethodCall call, final Result result) {
    if (authInProgress.get()) {
      result.error("auth_in_progress", "Authentication in progress", null);
      return;
    }

    if (activity == null || activity.isFinishing()) {
      result.error("no_activity", "local_auth plugin requires a foreground activity", null);
      return;
    }

    if (!(activity instanceof FragmentActivity)) {
      result.error(
          "no_fragment_activity",
          "local_auth plugin requires activity to be a FragmentActivity.",
          null);
      return;
    }

    if (!isDeviceSupported()) {
      authInProgress.set(false);
      result.error("NotAvailable", "Required security features not enabled", null);
      return;
    }

    authInProgress.set(true);
    AuthCompletionHandler completionHandler =
        new AuthCompletionHandler() {
          @Override
          public void onSuccess() {
            authenticateSuccess(result);
          }

          @Override
          public void onFailure() {
            authenticateFail(result);
          }

          @Override
          public void onError(String code, String error) {
            if (authInProgress.compareAndSet(true, false)) {
              result.error(code, error, null);
            }
          }
        };

    // if is biometricOnly try biometric prompt - might not work
    boolean isBiometricOnly = call.argument("biometricOnly");
    if (isBiometricOnly) {
      if (!canAuthenticateWithBiometrics()) {
        if (!hasBiometricHardware()) {
          completionHandler.onError("NoHardware", "No biometric hardware found");
        }
        completionHandler.onError("NotEnrolled", "No biometrics enrolled on this device.");
        return;
      }
      authHelper =
          new AuthenticationHelper(
              lifecycle, (FragmentActivity) activity, call, completionHandler, false);
      authHelper.authenticate();
      return;
    }

    // API 29 and above
    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
      authHelper =
          new AuthenticationHelper(
              lifecycle, (FragmentActivity) activity, call, completionHandler, true);
      authHelper.authenticate();
      return;
    }

    // API 23 - 28 with fingerprint
    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M && fingerprintManager != null) {
      if (fingerprintManager.hasEnrolledFingerprints()) {
        authHelper =
            new AuthenticationHelper(
                lifecycle, (FragmentActivity) activity, call, completionHandler, false);
        authHelper.authenticate();
        return;
      }
    }

    // API 23 or higher with device credentials
    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M
        && keyguardManager != null
        && keyguardManager.isDeviceSecure()) {
      String title = call.argument("signInTitle");
      String reason = call.argument("localizedReason");
      Intent authIntent = keyguardManager.createConfirmDeviceCredentialIntent(title, reason);

      // save result for async response
      lockRequestResult = result;
      activity.startActivityForResult(authIntent, LOCK_REQUEST_CODE);
      return;
    }

    // Unable to authenticate
    result.error("NotSupported", "This device does not support required security features", null);
  }

  private void authenticateSuccess(Result result) {
    if (authInProgress.compareAndSet(true, false)) {
      result.success(true);
    }
  }

  private void authenticateFail(Result result) {
    if (authInProgress.compareAndSet(true, false)) {
      result.success(false);
    }
  }

  /*
   * Stops the authentication if in progress.
   */
  private void stopAuthentication(Result result) {
    try {
      if (authHelper != null && authInProgress.get()) {
        authHelper.stopAuthentication();
        authHelper = null;
      }
      authInProgress.set(false);
      result.success(true);
    } catch (Exception e) {
      result.success(false);
    }
  }

  /*
   * Returns biometric types available on device
   */
  private void getAvailableBiometrics(final Result result) {
    try {
      if (activity == null || activity.isFinishing()) {
        result.error("no_activity", "local_auth plugin requires a foreground activity", null);
        return;
      }
      ArrayList<String> biometrics = getAvailableBiometrics();
      result.success(biometrics);
    } catch (Exception e) {
      result.error("no_biometrics_available", e.getMessage(), null);
    }
  }

  private ArrayList<String> getAvailableBiometrics() {
    ArrayList<String> biometrics = new ArrayList<>();
    if (activity == null || activity.isFinishing()) {
      return biometrics;
    }
    PackageManager packageManager = activity.getPackageManager();
    if (Build.VERSION.SDK_INT >= 23) {
      if (packageManager.hasSystemFeature(PackageManager.FEATURE_FINGERPRINT)) {
        biometrics.add("fingerprint");
      }
    }
    if (Build.VERSION.SDK_INT >= 29) {
      if (packageManager.hasSystemFeature(PackageManager.FEATURE_FACE)) {
        biometrics.add("face");
      }
      if (packageManager.hasSystemFeature(PackageManager.FEATURE_IRIS)) {
        biometrics.add("iris");
      }
    }

    return biometrics;
  }

  private boolean isDeviceSupported() {
    if (keyguardManager == null) return false;
    return (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M && keyguardManager.isDeviceSecure());
  }

  private boolean canAuthenticateWithBiometrics() {
    if (biometricManager == null) return false;
    return biometricManager.canAuthenticate() == BiometricManager.BIOMETRIC_SUCCESS;
  }

  private boolean hasBiometricHardware() {
    if (biometricManager == null) return false;
    return biometricManager.canAuthenticate() != BiometricManager.BIOMETRIC_ERROR_NO_HARDWARE;
  }

  private void isDeviceSupported(Result result) {
    result.success(isDeviceSupported());
  }

  @Override
  public void onAttachedToEngine(FlutterPluginBinding binding) {
    channel = new MethodChannel(binding.getFlutterEngine().getDartExecutor(), CHANNEL_NAME);
    channel.setMethodCallHandler(this);
  }

  @Override
  public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {}

  private void setServicesFromActivity(Activity activity) {
    if (activity == null) return;
    this.activity = activity;
    Context context = activity.getBaseContext();
    biometricManager = BiometricManager.from(activity);
    keyguardManager = (KeyguardManager) context.getSystemService(KEYGUARD_SERVICE);
    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
      fingerprintManager =
          (FingerprintManager) context.getSystemService(Context.FINGERPRINT_SERVICE);
    }
  }

  @Override
  public void onAttachedToActivity(ActivityPluginBinding binding) {
    binding.addActivityResultListener(resultListener);
    setServicesFromActivity(binding.getActivity());
    lifecycle = FlutterLifecycleAdapter.getActivityLifecycle(binding);
    channel.setMethodCallHandler(this);
  }

  @Override
  public void onDetachedFromActivityForConfigChanges() {
    lifecycle = null;
  }

  @Override
  public void onReattachedToActivityForConfigChanges(ActivityPluginBinding binding) {
    binding.addActivityResultListener(resultListener);
    setServicesFromActivity(binding.getActivity());
    lifecycle = FlutterLifecycleAdapter.getActivityLifecycle(binding);
  }

  @Override
  public void onDetachedFromActivity() {
    lifecycle = null;
    channel.setMethodCallHandler(null);
  }
}
