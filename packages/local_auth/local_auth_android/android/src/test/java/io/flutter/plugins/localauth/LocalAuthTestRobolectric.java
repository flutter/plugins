// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.localauth;

import static androidx.biometric.BiometricManager.Authenticators.BIOMETRIC_STRONG;
import static androidx.biometric.BiometricManager.Authenticators.BIOMETRIC_WEAK;
import static androidx.biometric.BiometricManager.Authenticators.DEVICE_CREDENTIAL;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyInt;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.ArgumentMatchers.isNotNull;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.mockStatic;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import android.app.Activity;
import android.app.KeyguardManager;
import android.content.Context;
import android.content.Intent;
import android.hardware.fingerprint.FingerprintManager;
import android.os.Build;
import androidx.biometric.BiometricManager;
import androidx.fragment.app.FragmentActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.embedding.engine.dart.DartExecutor;
import io.flutter.embedding.engine.plugins.FlutterPlugin.FlutterPluginBinding;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.embedding.engine.plugins.lifecycle.HiddenLifecycleReference;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugins.localauth.utils.TestUtils;
import java.util.ArrayList;
import java.util.Collections;
import java.util.HashMap;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.mockito.AdditionalMatchers;
import org.mockito.MockedStatic;
import org.robolectric.RobolectricTestRunner;

@RunWith(RobolectricTestRunner.class)
public class LocalAuthTestRobolectric {

  @Test
  public void authenticate_resultsInErrorWhenInProgress() {
    final LocalAuthPlugin plugin = new LocalAuthPlugin();
    plugin.setAuthInProgress(true);
    final MethodChannel.Result mockResult = mock(MethodChannel.Result.class);
    plugin.onMethodCall(new MethodCall("authenticate", null), mockResult);
    verify(mockResult).error("auth_in_progress", "Authentication in progress", null);
  }

  @Test
  public void authenticate_resultsInErrorOnNullActivity() {
    final LocalAuthPlugin plugin = new LocalAuthPlugin();
    final MethodChannel.Result mockResult = mock(MethodChannel.Result.class);
    plugin.onMethodCall(new MethodCall("authenticate", null), mockResult);
    verify(mockResult)
        .error("no_activity", "local_auth plugin requires a foreground activity", null);
  }

  @Test
  public void authenticate_resultsInErrorOnFinishingActivity() {
    final LocalAuthPlugin plugin = new LocalAuthPlugin();
    Activity activity = buildMockActivityy();
    when(activity.isFinishing()).thenReturn(true);
    setPluginActivity(plugin, activity);
    final MethodChannel.Result mockResult = mock(MethodChannel.Result.class);
    plugin.onMethodCall(new MethodCall("authenticate", null), mockResult);
    verify(mockResult)
        .error("no_activity", "local_auth plugin requires a foreground activity", null);
  }

  @Test
  public void authenticate_resultsInErrorOnNonFragmentActivity() {
    final LocalAuthPlugin plugin = new LocalAuthPlugin();
    Activity activity = buildMockActivityy();
    setPluginActivity(plugin, activity);
    final MethodChannel.Result mockResult = mock(MethodChannel.Result.class);
    plugin.onMethodCall(new MethodCall("authenticate", null), mockResult);
    verify(mockResult)
        .error(
            "no_fragment_activity",
            "local_auth plugin requires activity to be a FragmentActivity.",
            null);
  }

  @Test
  public void authenticate_resultsInErrorOnNonSupportedDevice() {
    // Without keyguard manager.
    final LocalAuthPlugin plugin = new LocalAuthPlugin();
    setPluginActivity(plugin, buildMockFragmentActivity());
    MethodChannel.Result mockResult = mock(MethodChannel.Result.class);
    plugin.onMethodCall(new MethodCall("authenticate", null), mockResult);
    verify(mockResult).error("NotAvailable", "Required security features not enabled", null);

    // On API 22 and below.
    setPluginActivity(plugin, buildMockFragmentActivityWithKeyguardManager(true));
    TestUtils.setFinalStatic(Build.VERSION.class, "SDK_INT", Build.VERSION_CODES.LOLLIPOP_MR1);
    mockResult = mock(MethodChannel.Result.class);
    plugin.onMethodCall(new MethodCall("authenticate", null), mockResult);
    verify(mockResult).error("NotAvailable", "Required security features not enabled", null);

    // On insecure keyguard manager.
    setPluginActivity(plugin, buildMockFragmentActivityWithKeyguardManager(false));
    TestUtils.setFinalStatic(Build.VERSION.class, "SDK_INT", Build.VERSION_CODES.M);
    mockResult = mock(MethodChannel.Result.class);
    plugin.onMethodCall(new MethodCall("authenticate", null), mockResult);
    verify(mockResult).error("NotAvailable", "Required security features not enabled", null);
  }

  @Test
  public void authenticate_strongBiometricsIgnoredBelowAPI30() {
    final LocalAuthPlugin plugin = new LocalAuthPlugin();
    Activity activity = buildMockFragmentActivityWithKeyguardManager(true);
    setPluginActivity(plugin, activity);
    // Set API 29.
    TestUtils.setFinalStatic(Build.VERSION.class, "SDK_INT", Build.VERSION_CODES.Q);

    try (MockedStatic<AuthenticationHelperFactory> mockedAuthenticationHelperFactory =
        mockStatic(AuthenticationHelperFactory.class)) {
      mockAuthenticationHelper(mockedAuthenticationHelperFactory);
      final MethodChannel.Result mockResult = mock(MethodChannel.Result.class);
      // Call authenticate.
      plugin.onMethodCall(
          new MethodCall(
              "authenticate",
              new HashMap<String, Object>() {
                {
                  put("strongBiometricsOnly", true);
                  put("biometricOnly", false);
                }
              }),
          mockResult);
      // Verify auth helper is never called with only strong biometrics.
      mockedAuthenticationHelperFactory.verify(
          () ->
              AuthenticationHelperFactory.create(
                  any(),
                  any(),
                  any(),
                  any(),
                  AdditionalMatchers.aryEq(
                      new int[] {
                        BIOMETRIC_STRONG,
                      })),
          never());
    }
  }

  @Test
  public void authenticate_withStrongBiometricsOnly_shouldReturnError_whenNoHardware() {
    final LocalAuthPlugin plugin = new LocalAuthPlugin();
    Activity activity = buildMockFragmentActivityWithKeyguardManager(true);
    setPluginActivity(plugin, activity);
    // Set API 30.
    TestUtils.setFinalStatic(Build.VERSION.class, "SDK_INT", Build.VERSION_CODES.R);
    // No strong biometric hardware present.
    final BiometricManager mockBiometricManager = mock(BiometricManager.class);
    when(mockBiometricManager.canAuthenticate(BIOMETRIC_STRONG))
        .thenReturn(BiometricManager.BIOMETRIC_ERROR_NO_HARDWARE);
    plugin.setBiometricManager(mockBiometricManager);

    try (MockedStatic<AuthenticationHelperFactory> mockedAuthenticationHelperFactory =
        mockStatic(AuthenticationHelperFactory.class)) {
      mockAuthenticationHelper(mockedAuthenticationHelperFactory);
      final MethodChannel.Result mockResult = mock(MethodChannel.Result.class);
      // Call authenticate.
      plugin.onMethodCall(
          new MethodCall(
              "authenticate",
              new HashMap<String, Object>() {
                {
                  put("strongBiometricsOnly", true);
                }
              }),
          mockResult);

      verify(mockResult).error("NoHardware", "No strong biometric hardware found", null);
    }
  }

  @Test
  public void authenticate_withStrongBiometricsOnly_shouldReturnError_whenNoHardwareEnrolled() {
    final LocalAuthPlugin plugin = new LocalAuthPlugin();
    Activity activity = buildMockFragmentActivityWithKeyguardManager(true);
    setPluginActivity(plugin, activity);
    // Set API 30.
    TestUtils.setFinalStatic(Build.VERSION.class, "SDK_INT", Build.VERSION_CODES.R);
    // No strong biometric hardware enrolled.
    final BiometricManager mockBiometricManager = mock(BiometricManager.class);
    when(mockBiometricManager.canAuthenticate(BIOMETRIC_STRONG))
        .thenReturn(BiometricManager.BIOMETRIC_ERROR_NONE_ENROLLED);
    plugin.setBiometricManager(mockBiometricManager);

    try (MockedStatic<AuthenticationHelperFactory> mockedAuthenticationHelperFactory =
        mockStatic(AuthenticationHelperFactory.class)) {
      mockAuthenticationHelper(mockedAuthenticationHelperFactory);
      final MethodChannel.Result mockResult = mock(MethodChannel.Result.class);
      // Call authenticate.
      plugin.onMethodCall(
          new MethodCall(
              "authenticate",
              new HashMap<String, Object>() {
                {
                  put("strongBiometricsOnly", true);
                }
              }),
          mockResult);

      verify(mockResult)
          .error("NotEnrolled", "No strong biometrics enrolled on this device.", null);
    }
  }

  @Test
  public void authenticate_canLimitToStrongBiometrics() {
    final LocalAuthPlugin plugin = new LocalAuthPlugin();
    Activity activity = buildMockFragmentActivityWithKeyguardManager(true);
    setPluginActivity(plugin, activity);
    // Set API 30.
    TestUtils.setFinalStatic(Build.VERSION.class, "SDK_INT", Build.VERSION_CODES.R);
    // Set correct hardware present.
    final BiometricManager mockBiometricManager = mock(BiometricManager.class);
    when(mockBiometricManager.canAuthenticate(BIOMETRIC_STRONG))
        .thenReturn(BiometricManager.BIOMETRIC_SUCCESS);
    plugin.setBiometricManager(mockBiometricManager);

    try (MockedStatic<AuthenticationHelperFactory> mockedAuthenticationHelperFactory =
        mockStatic(AuthenticationHelperFactory.class)) {
      mockAuthenticationHelper(mockedAuthenticationHelperFactory);
      final MethodChannel.Result mockResult = mock(MethodChannel.Result.class);
      // Call authenticate.
      plugin.onMethodCall(
          new MethodCall(
              "authenticate",
              new HashMap<String, Object>() {
                {
                  put("strongBiometricsOnly", true);
                }
              }),
          mockResult);
      // Verify auth helper is called with only strong biometrics.
      mockedAuthenticationHelperFactory.verify(
          () ->
              AuthenticationHelperFactory.create(
                  any(),
                  any(),
                  any(),
                  any(),
                  AdditionalMatchers.aryEq(
                      new int[] {
                        BIOMETRIC_STRONG,
                      })));
    }
  }

  @Test
  public void authenticate_withBiometricsOnly_shouldReturnError_whenNoHardware() {
    final LocalAuthPlugin plugin = new LocalAuthPlugin();
    Activity activity = buildMockFragmentActivityWithKeyguardManager(true);
    setPluginActivity(plugin, activity);
    // No strong biometric hardware present.
    final BiometricManager mockBiometricManager = mock(BiometricManager.class);
    when(mockBiometricManager.canAuthenticate())
        .thenReturn(BiometricManager.BIOMETRIC_ERROR_NO_HARDWARE);
    plugin.setBiometricManager(mockBiometricManager);

    try (MockedStatic<AuthenticationHelperFactory> mockedAuthenticationHelperFactory =
        mockStatic(AuthenticationHelperFactory.class)) {
      mockAuthenticationHelper(mockedAuthenticationHelperFactory);
      final MethodChannel.Result mockResult = mock(MethodChannel.Result.class);
      // Call authenticate.
      plugin.onMethodCall(
          new MethodCall(
              "authenticate",
              new HashMap<String, Object>() {
                {
                  put("strongBiometricsOnly", false);
                  put("biometricOnly", true);
                }
              }),
          mockResult);

      verify(mockResult).error("NoHardware", "No biometric hardware found", null);
    }
  }

  @Test
  public void authenticate_withBiometricsOnly_shouldReturnError_whenNoHardwareEnrolled() {
    final LocalAuthPlugin plugin = new LocalAuthPlugin();
    Activity activity = buildMockFragmentActivityWithKeyguardManager(true);
    setPluginActivity(plugin, activity);
    // No strong biometric hardware enrolled.
    final BiometricManager mockBiometricManager = mock(BiometricManager.class);
    when(mockBiometricManager.canAuthenticate())
        .thenReturn(BiometricManager.BIOMETRIC_ERROR_NONE_ENROLLED);
    plugin.setBiometricManager(mockBiometricManager);

    try (MockedStatic<AuthenticationHelperFactory> mockedAuthenticationHelperFactory =
        mockStatic(AuthenticationHelperFactory.class)) {
      mockAuthenticationHelper(mockedAuthenticationHelperFactory);
      final MethodChannel.Result mockResult = mock(MethodChannel.Result.class);
      // Call authenticate.
      plugin.onMethodCall(
          new MethodCall(
              "authenticate",
              new HashMap<String, Object>() {
                {
                  put("strongBiometricsOnly", false);
                  put("biometricOnly", true);
                }
              }),
          mockResult);

      verify(mockResult).error("NotEnrolled", "No biometrics enrolled on this device.", null);
    }
  }

  @Test
  public void authenticate_canLimitToBiometric() {
    final LocalAuthPlugin plugin = new LocalAuthPlugin();
    Activity activity = buildMockFragmentActivityWithKeyguardManager(true);
    setPluginActivity(plugin, activity);
    // Set correct hardware present.
    final BiometricManager mockBiometricManager = mock(BiometricManager.class);
    when(mockBiometricManager.canAuthenticate()).thenReturn(BiometricManager.BIOMETRIC_SUCCESS);
    plugin.setBiometricManager(mockBiometricManager);

    try (MockedStatic<AuthenticationHelperFactory> mockedAuthenticationHelperFactory =
        mockStatic(AuthenticationHelperFactory.class)) {
      mockAuthenticationHelper(mockedAuthenticationHelperFactory);
      final MethodChannel.Result mockResult = mock(MethodChannel.Result.class);
      // Call authenticate.
      plugin.onMethodCall(
          new MethodCall(
              "authenticate",
              new HashMap<String, Object>() {
                {
                  put("strongBiometricsOnly", false);
                  put("biometricOnly", true);
                }
              }),
          mockResult);
      // Verify auth helper is called with only biometrics.
      mockedAuthenticationHelperFactory.verify(
          () ->
              AuthenticationHelperFactory.create(
                  any(),
                  any(),
                  any(),
                  any(),
                  AdditionalMatchers.aryEq(
                      new int[] {
                        BIOMETRIC_WEAK, BIOMETRIC_STRONG,
                      })));
    }
  }

  @Test
  public void authenticate_onAPI29AndAbove() {
    final LocalAuthPlugin plugin = new LocalAuthPlugin();
    Activity activity = buildMockFragmentActivityWithKeyguardManager(true);
    setPluginActivity(plugin, activity);
    // Set API 23.
    TestUtils.setFinalStatic(Build.VERSION.class, "SDK_INT", Build.VERSION_CODES.Q);
    // Set correct hardware present.
    final BiometricManager mockBiometricManager = mock(BiometricManager.class);
    when(mockBiometricManager.canAuthenticate()).thenReturn(BiometricManager.BIOMETRIC_SUCCESS);
    plugin.setBiometricManager(mockBiometricManager);

    try (MockedStatic<AuthenticationHelperFactory> mockedAuthenticationHelperFactory =
        mockStatic(AuthenticationHelperFactory.class)) {
      mockAuthenticationHelper(mockedAuthenticationHelperFactory);
      final MethodChannel.Result mockResult = mock(MethodChannel.Result.class);
      // Call authenticate.
      plugin.onMethodCall(
          new MethodCall(
              "authenticate",
              new HashMap<String, Object>() {
                {
                  put("strongBiometricsOnly", false);
                  put("biometricOnly", false);
                }
              }),
          mockResult);
      // Verify auth helper is called.
      mockedAuthenticationHelperFactory.verify(
          () ->
              AuthenticationHelperFactory.create(
                  any(),
                  any(),
                  any(),
                  any(),
                  AdditionalMatchers.aryEq(
                      new int[] {
                        DEVICE_CREDENTIAL, BIOMETRIC_WEAK, BIOMETRIC_STRONG,
                      })));
    }
  }

  @Test
  public void authenticate_onAPI23To28_withNoHardware() {
    final LocalAuthPlugin plugin = new LocalAuthPlugin();
    Activity activity = buildMockFragmentActivityWithKeyguardManager(true);
    setPluginActivity(plugin, activity);
    // Set API 23.
    TestUtils.setFinalStatic(Build.VERSION.class, "SDK_INT", Build.VERSION_CODES.M);
    try (MockedStatic<AuthenticationHelperFactory> mockedAuthenticationHelperFactory =
        mockStatic(AuthenticationHelperFactory.class)) {
      mockAuthenticationHelper(mockedAuthenticationHelperFactory);
      final MethodChannel.Result mockResult = mock(MethodChannel.Result.class);
      // Call authenticate.
      plugin.onMethodCall(
          new MethodCall(
              "authenticate",
              new HashMap<String, Object>() {
                {
                  put("strongBiometricsOnly", false);
                  put("biometricOnly", false);
                }
              }),
          mockResult);
      // Verify auth helper is called with only biometrics.
      mockedAuthenticationHelperFactory.verify(
          () -> AuthenticationHelperFactory.create(any(), any(), any(), any(), any()), never());
    }
    // Verify activity started for device credential authentication.
    verify(activity).startActivityForResult(isNotNull(), eq(221));
  }

  @Test
  public void authenticate_onAPI23To28_withNoHardwareEnrolled() {
    final LocalAuthPlugin plugin = new LocalAuthPlugin();
    Activity activity =
        buildMockFragmentActivityWithKeyguardManagerAndFingerprintManager(true, false);
    setPluginActivity(plugin, activity);
    // Set API 23.
    TestUtils.setFinalStatic(Build.VERSION.class, "SDK_INT", Build.VERSION_CODES.M);

    try (MockedStatic<AuthenticationHelperFactory> mockedAuthenticationHelperFactory =
        mockStatic(AuthenticationHelperFactory.class)) {
      mockAuthenticationHelper(mockedAuthenticationHelperFactory);
      final MethodChannel.Result mockResult = mock(MethodChannel.Result.class);
      // Call authenticate.
      plugin.onMethodCall(
          new MethodCall(
              "authenticate",
              new HashMap<String, Object>() {
                {
                  put("strongBiometricsOnly", false);
                  put("biometricOnly", false);
                }
              }),
          mockResult);
      // Verify auth helper is called with only biometrics.
      mockedAuthenticationHelperFactory.verify(
          () -> AuthenticationHelperFactory.create(any(), any(), any(), any(), any()), never());
    }
    // Verify activity started for device credential authentication.
    verify(activity).startActivityForResult(isNotNull(), eq(221));
  }

  @Test
  public void authenticate_onAPI23To28() {
    final LocalAuthPlugin plugin = new LocalAuthPlugin();
    Activity activity =
        buildMockFragmentActivityWithKeyguardManagerAndFingerprintManager(true, true);
    setPluginActivity(plugin, activity);
    // Set API 23.
    TestUtils.setFinalStatic(Build.VERSION.class, "SDK_INT", Build.VERSION_CODES.M);

    try (MockedStatic<AuthenticationHelperFactory> mockedAuthenticationHelperFactory =
        mockStatic(AuthenticationHelperFactory.class)) {
      mockAuthenticationHelper(mockedAuthenticationHelperFactory);
      final MethodChannel.Result mockResult = mock(MethodChannel.Result.class);
      // Call authenticate.
      plugin.onMethodCall(
          new MethodCall(
              "authenticate",
              new HashMap<String, Object>() {
                {
                  put("strongBiometricsOnly", false);
                  put("biometricOnly", false);
                }
              }),
          mockResult);
      // Verify auth helper is called with only biometrics.
      mockedAuthenticationHelperFactory.verify(
          () ->
              AuthenticationHelperFactory.create(
                  any(),
                  any(),
                  any(),
                  any(),
                  AdditionalMatchers.aryEq(
                      new int[] {
                        BIOMETRIC_WEAK, BIOMETRIC_STRONG,
                      })));
    }
  }

  @Test
  public void isDeviceSupportedReturnsFalse() {
    final LocalAuthPlugin plugin = new LocalAuthPlugin();
    final MethodChannel.Result mockResult = mock(MethodChannel.Result.class);
    plugin.onMethodCall(new MethodCall("isDeviceSupported", null), mockResult);
    verify(mockResult).success(false);
  }

  @Test
  public void deviceSupportsBiometrics_returnsTrueForPresentNonEnrolledBiometrics() {
    final LocalAuthPlugin plugin = new LocalAuthPlugin();
    final MethodChannel.Result mockResult = mock(MethodChannel.Result.class);
    final BiometricManager mockBiometricManager = mock(BiometricManager.class);
    when(mockBiometricManager.canAuthenticate())
        .thenReturn(BiometricManager.BIOMETRIC_ERROR_NONE_ENROLLED);
    plugin.setBiometricManager(mockBiometricManager);
    plugin.onMethodCall(new MethodCall("deviceSupportsBiometrics", null), mockResult);
    verify(mockResult).success(true);
  }

  @Test
  public void deviceSupportsBiometrics_returnsTrueForPresentEnrolledBiometrics() {
    final LocalAuthPlugin plugin = new LocalAuthPlugin();
    final MethodChannel.Result mockResult = mock(MethodChannel.Result.class);
    final BiometricManager mockBiometricManager = mock(BiometricManager.class);
    when(mockBiometricManager.canAuthenticate()).thenReturn(BiometricManager.BIOMETRIC_SUCCESS);
    plugin.setBiometricManager(mockBiometricManager);
    plugin.onMethodCall(new MethodCall("deviceSupportsBiometrics", null), mockResult);
    verify(mockResult).success(true);
  }

  @Test
  public void deviceSupportsBiometrics_returnsFalseForNoBiometricHardware() {
    final LocalAuthPlugin plugin = new LocalAuthPlugin();
    final MethodChannel.Result mockResult = mock(MethodChannel.Result.class);
    final BiometricManager mockBiometricManager = mock(BiometricManager.class);
    when(mockBiometricManager.canAuthenticate())
        .thenReturn(BiometricManager.BIOMETRIC_ERROR_NO_HARDWARE);
    plugin.setBiometricManager(mockBiometricManager);
    plugin.onMethodCall(new MethodCall("deviceSupportsBiometrics", null), mockResult);
    verify(mockResult).success(false);
  }

  @Test
  public void deviceSupportsBiometrics_returnsFalseForNullBiometricManager() {
    final LocalAuthPlugin plugin = new LocalAuthPlugin();
    final MethodChannel.Result mockResult = mock(MethodChannel.Result.class);
    plugin.setBiometricManager(null);
    plugin.onMethodCall(new MethodCall("deviceSupportsBiometrics", null), mockResult);
    verify(mockResult).success(false);
  }

  @Test
  public void getEnrolledBiometrics_shouldReturnError_whenNoActivity() {
    final LocalAuthPlugin plugin = new LocalAuthPlugin();
    final MethodChannel.Result mockResult = mock(MethodChannel.Result.class);

    plugin.onMethodCall(new MethodCall("getEnrolledBiometrics", null), mockResult);
    verify(mockResult)
        .error("no_activity", "local_auth plugin requires a foreground activity", null);
  }

  @Test
  public void getEnrolledBiometrics_shouldReturnError_whenFinishingActivity() {
    final LocalAuthPlugin plugin = new LocalAuthPlugin();
    final MethodChannel.Result mockResult = mock(MethodChannel.Result.class);
    final Activity mockActivity = buildMockActivityy();
    when(mockActivity.isFinishing()).thenReturn(true);
    setPluginActivity(plugin, mockActivity);

    plugin.onMethodCall(new MethodCall("getEnrolledBiometrics", null), mockResult);
    verify(mockResult)
        .error("no_activity", "local_auth plugin requires a foreground activity", null);
  }

  @Test
  public void getEnrolledBiometrics_shouldReturnEmptyList_withoutHardwarePresent() {
    final LocalAuthPlugin plugin = new LocalAuthPlugin();
    setPluginActivity(plugin, buildMockActivityy());
    final MethodChannel.Result mockResult = mock(MethodChannel.Result.class);
    final BiometricManager mockBiometricManager = mock(BiometricManager.class);
    when(mockBiometricManager.canAuthenticate(anyInt()))
        .thenReturn(BiometricManager.BIOMETRIC_ERROR_NO_HARDWARE);
    plugin.setBiometricManager(mockBiometricManager);

    plugin.onMethodCall(new MethodCall("getEnrolledBiometrics", null), mockResult);
    verify(mockResult).success(Collections.emptyList());
  }

  @Test
  public void getEnrolledBiometrics_shouldReturnEmptyList_withNoMethodsEnrolled() {
    final LocalAuthPlugin plugin = new LocalAuthPlugin();
    setPluginActivity(plugin, buildMockActivityy());
    final MethodChannel.Result mockResult = mock(MethodChannel.Result.class);
    final BiometricManager mockBiometricManager = mock(BiometricManager.class);
    when(mockBiometricManager.canAuthenticate(anyInt()))
        .thenReturn(BiometricManager.BIOMETRIC_ERROR_NONE_ENROLLED);
    plugin.setBiometricManager(mockBiometricManager);

    plugin.onMethodCall(new MethodCall("getEnrolledBiometrics", null), mockResult);
    verify(mockResult).success(Collections.emptyList());
  }

  @Test
  public void getEnrolledBiometrics_shouldOnlyAddEnrolledBiometrics() {
    final LocalAuthPlugin plugin = new LocalAuthPlugin();
    setPluginActivity(plugin, buildMockActivityy());
    final MethodChannel.Result mockResult = mock(MethodChannel.Result.class);
    final BiometricManager mockBiometricManager = mock(BiometricManager.class);
    when(mockBiometricManager.canAuthenticate(BiometricManager.Authenticators.BIOMETRIC_WEAK))
        .thenReturn(BiometricManager.BIOMETRIC_SUCCESS);
    when(mockBiometricManager.canAuthenticate(BiometricManager.Authenticators.BIOMETRIC_STRONG))
        .thenReturn(BiometricManager.BIOMETRIC_ERROR_NONE_ENROLLED);
    plugin.setBiometricManager(mockBiometricManager);

    plugin.onMethodCall(new MethodCall("getEnrolledBiometrics", null), mockResult);
    verify(mockResult)
        .success(
            new ArrayList<String>() {
              {
                add("weak");
              }
            });
  }

  @Test
  public void getEnrolledBiometrics_shouldAddStrongBiometrics() {
    final LocalAuthPlugin plugin = new LocalAuthPlugin();
    setPluginActivity(plugin, buildMockActivityy());
    final MethodChannel.Result mockResult = mock(MethodChannel.Result.class);
    final BiometricManager mockBiometricManager = mock(BiometricManager.class);
    when(mockBiometricManager.canAuthenticate(BiometricManager.Authenticators.BIOMETRIC_WEAK))
        .thenReturn(BiometricManager.BIOMETRIC_SUCCESS);
    when(mockBiometricManager.canAuthenticate(BiometricManager.Authenticators.BIOMETRIC_STRONG))
        .thenReturn(BiometricManager.BIOMETRIC_SUCCESS);
    plugin.setBiometricManager(mockBiometricManager);

    plugin.onMethodCall(new MethodCall("getEnrolledBiometrics", null), mockResult);
    verify(mockResult)
        .success(
            new ArrayList<String>() {
              {
                add("weak");
                add("strong");
              }
            });
  }

  private Activity buildMockActivityy() {
    Activity mockActivity = mock(Activity.class);
    final Context mockContext = mock(Context.class);
    when(mockActivity.getBaseContext()).thenReturn(mockContext);
    when(mockActivity.getApplicationContext()).thenReturn(mockContext);
    return mockActivity;
  }

  private Activity buildMockFragmentActivity() {
    Activity mockActivity = mock(FragmentActivity.class);
    final Context mockContext = mock(Context.class);
    when(mockActivity.getBaseContext()).thenReturn(mockContext);
    when(mockActivity.getApplicationContext()).thenReturn(mockContext);
    return mockActivity;
  }

  private Activity buildMockFragmentActivityWithKeyguardManager(boolean secure) {
    Activity mockActivity = mock(FragmentActivity.class);
    final Context mockContext = mock(Context.class);
    when(mockActivity.getBaseContext()).thenReturn(mockContext);
    when(mockActivity.getApplicationContext()).thenReturn(mockContext);
    final KeyguardManager mockKeyguardManager = mock(KeyguardManager.class);
    when(mockKeyguardManager.isDeviceSecure()).thenReturn(secure);
    final Intent mockDeviceCredentialIntent = mock(Intent.class);
    when(mockKeyguardManager.createConfirmDeviceCredentialIntent(any(), any()))
        .thenReturn(mockDeviceCredentialIntent);
    when(mockContext.getSystemService(Context.KEYGUARD_SERVICE)).thenReturn(mockKeyguardManager);
    return mockActivity;
  }

  private Activity buildMockFragmentActivityWithKeyguardManagerAndFingerprintManager(
      boolean secure, boolean enrolledFingerprints) {
    Activity mockActivity = mock(FragmentActivity.class);
    final Context mockContext = mock(Context.class);
    when(mockActivity.getBaseContext()).thenReturn(mockContext);
    when(mockActivity.getApplicationContext()).thenReturn(mockContext);
    final FingerprintManager mockFingerprintManager = mock(FingerprintManager.class);
    when(mockFingerprintManager.hasEnrolledFingerprints()).thenReturn(enrolledFingerprints);
    when(mockContext.getSystemService(Context.FINGERPRINT_SERVICE))
        .thenReturn(mockFingerprintManager);
    final KeyguardManager mockKeyguardManager = mock(KeyguardManager.class);
    when(mockKeyguardManager.isDeviceSecure()).thenReturn(secure);
    final Intent mockDeviceCredentialIntent = mock(Intent.class);
    when(mockKeyguardManager.createConfirmDeviceCredentialIntent(any(), any()))
        .thenReturn(mockDeviceCredentialIntent);
    when(mockContext.getSystemService(Context.KEYGUARD_SERVICE)).thenReturn(mockKeyguardManager);
    return mockActivity;
  }

  private void setPluginActivity(LocalAuthPlugin plugin, Activity activity) {
    final HiddenLifecycleReference mockLifecycleReference = mock(HiddenLifecycleReference.class);
    final FlutterPluginBinding mockPluginBinding = mock(FlutterPluginBinding.class);
    final ActivityPluginBinding mockActivityBinding = mock(ActivityPluginBinding.class);
    final FlutterEngine mockFlutterEngine = mock(FlutterEngine.class);
    final DartExecutor mockDartExecutor = mock(DartExecutor.class);
    when(mockPluginBinding.getFlutterEngine()).thenReturn(mockFlutterEngine);
    when(mockFlutterEngine.getDartExecutor()).thenReturn(mockDartExecutor);
    when(mockActivityBinding.getActivity()).thenReturn(activity);
    when(mockActivityBinding.getLifecycle()).thenReturn(mockLifecycleReference);
    plugin.onAttachedToEngine(mockPluginBinding);
    plugin.onAttachedToActivity(mockActivityBinding);
  }

  private void mockAuthenticationHelper(MockedStatic<AuthenticationHelperFactory> factory) {
    factory
        .when(
            new MockedStatic.Verification() {
              @Override
              public void apply() throws Throwable {
                AuthenticationHelperFactory.create(any(), any(), any(), any(), any());
              }
            })
        .thenReturn(mock(AuthenticationHelper.class));
  }
}
