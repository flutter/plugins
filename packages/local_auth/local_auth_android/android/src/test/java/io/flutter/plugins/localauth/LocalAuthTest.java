// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.localauth;

import static org.junit.Assert.assertFalse;
import static org.junit.Assert.assertNotNull;
import static org.junit.Assert.assertNull;
import static org.junit.Assert.assertTrue;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyInt;
import static org.mockito.Mockito.doNothing;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.spy;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import android.app.Activity;
import android.app.NativeActivity;
import android.content.Context;
import androidx.biometric.BiometricManager;
import androidx.fragment.app.FragmentActivity;
import androidx.lifecycle.Lifecycle;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.embedding.engine.dart.DartExecutor;
import io.flutter.embedding.engine.plugins.FlutterPlugin.FlutterPluginBinding;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.embedding.engine.plugins.lifecycle.HiddenLifecycleReference;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugins.localauth.AuthenticationHelper.AuthCompletionHandler;
import java.util.ArrayList;
import java.util.Collections;
import java.util.HashMap;
import org.junit.Test;
import org.mockito.ArgumentCaptor;

public class LocalAuthTest {
  @Test
  public void authenticate_returnsErrorWhenAuthInProgress() {
    final LocalAuthPlugin plugin = new LocalAuthPlugin();
    plugin.authInProgress.set(true);
    final MethodChannel.Result mockResult = mock(MethodChannel.Result.class);
    plugin.onMethodCall(new MethodCall("authenticate", null), mockResult);
    verify(mockResult).error("auth_in_progress", "Authentication in progress", null);
  }

  @Test
  public void authenticate_returnsErrorWithNoForegroundActivity() {
    final LocalAuthPlugin plugin = new LocalAuthPlugin();
    final MethodChannel.Result mockResult = mock(MethodChannel.Result.class);
    plugin.onMethodCall(new MethodCall("authenticate", null), mockResult);
    verify(mockResult)
        .error("no_activity", "local_auth plugin requires a foreground activity", null);
  }

  @Test
  public void authenticate_returnsErrorWhenActivityNotFragmentActivity() {
    final LocalAuthPlugin plugin = new LocalAuthPlugin();
    setPluginActivity(plugin, buildMockActivityWithContext(mock(NativeActivity.class)));
    final MethodChannel.Result mockResult = mock(MethodChannel.Result.class);
    plugin.onMethodCall(new MethodCall("authenticate", null), mockResult);
    verify(mockResult)
        .error(
            "no_fragment_activity",
            "local_auth plugin requires activity to be a FragmentActivity.",
            null);
  }

  @Test
  public void authenticate_returnsErrorWhenDeviceNotSupported() {
    final LocalAuthPlugin plugin = new LocalAuthPlugin();
    final MethodChannel.Result mockResult = mock(MethodChannel.Result.class);
    setPluginActivity(plugin, buildMockActivityWithContext(mock(FragmentActivity.class)));
    plugin.onMethodCall(new MethodCall("authenticate", null), mockResult);
    assertFalse(plugin.authInProgress.get());
    verify(mockResult).error("NotAvailable", "Required security features not enabled", null);
  }

  @Test
  public void authenticate_properlyConfiguresBiometricOnlyAuthenticationRequest() {
    final LocalAuthPlugin plugin = spy(new LocalAuthPlugin());
    setPluginActivity(plugin, buildMockActivityWithContext(mock(FragmentActivity.class)));
    when(plugin.isDeviceSupported()).thenReturn(true);

    final BiometricManager mockBiometricManager = mock(BiometricManager.class);
    when(mockBiometricManager.canAuthenticate(BiometricManager.Authenticators.BIOMETRIC_WEAK))
        .thenReturn(BiometricManager.BIOMETRIC_SUCCESS);
    when(mockBiometricManager.canAuthenticate(BiometricManager.Authenticators.DEVICE_CREDENTIAL))
        .thenReturn(BiometricManager.BIOMETRIC_SUCCESS);
    plugin.setBiometricManager(mockBiometricManager);

    ArgumentCaptor<Boolean> allowCredentialsCaptor = ArgumentCaptor.forClass(Boolean.class);
    doNothing()
        .when(plugin)
        .sendAuthenticationRequest(
            any(MethodCall.class),
            any(AuthCompletionHandler.class),
            allowCredentialsCaptor.capture());
    final MethodChannel.Result mockResult = mock(MethodChannel.Result.class);
    HashMap<String, Object> arguments = new HashMap<>();
    arguments.put("biometricOnly", true);

    plugin.onMethodCall(new MethodCall("authenticate", arguments), mockResult);
    assertFalse(allowCredentialsCaptor.getValue());
  }

  @Test
  public void authenticate_properlyConfiguresBiometricAndDeviceCredentialAuthenticationRequest() {
    final LocalAuthPlugin plugin = spy(new LocalAuthPlugin());
    setPluginActivity(plugin, buildMockActivityWithContext(mock(FragmentActivity.class)));
    when(plugin.isDeviceSupported()).thenReturn(true);

    final BiometricManager mockBiometricManager = mock(BiometricManager.class);
    when(mockBiometricManager.canAuthenticate(BiometricManager.Authenticators.BIOMETRIC_WEAK))
        .thenReturn(BiometricManager.BIOMETRIC_SUCCESS);
    when(mockBiometricManager.canAuthenticate(BiometricManager.Authenticators.DEVICE_CREDENTIAL))
        .thenReturn(BiometricManager.BIOMETRIC_SUCCESS);
    plugin.setBiometricManager(mockBiometricManager);

    ArgumentCaptor<Boolean> allowCredentialsCaptor = ArgumentCaptor.forClass(Boolean.class);
    doNothing()
        .when(plugin)
        .sendAuthenticationRequest(
            any(MethodCall.class),
            any(AuthCompletionHandler.class),
            allowCredentialsCaptor.capture());
    final MethodChannel.Result mockResult = mock(MethodChannel.Result.class);
    HashMap<String, Object> arguments = new HashMap<>();
    arguments.put("biometricOnly", false);

    plugin.onMethodCall(new MethodCall("authenticate", arguments), mockResult);
    assertTrue(allowCredentialsCaptor.getValue());
  }

  @Test
  public void authenticate_properlyConfiguresDeviceCredentialOnlyAuthenticationRequest() {
    final LocalAuthPlugin plugin = spy(new LocalAuthPlugin());
    setPluginActivity(plugin, buildMockActivityWithContext(mock(FragmentActivity.class)));
    when(plugin.isDeviceSupported()).thenReturn(true);

    final BiometricManager mockBiometricManager = mock(BiometricManager.class);
    when(mockBiometricManager.canAuthenticate(BiometricManager.Authenticators.BIOMETRIC_WEAK))
        .thenReturn(BiometricManager.BIOMETRIC_ERROR_NONE_ENROLLED);
    when(mockBiometricManager.canAuthenticate(BiometricManager.Authenticators.DEVICE_CREDENTIAL))
        .thenReturn(BiometricManager.BIOMETRIC_SUCCESS);
    plugin.setBiometricManager(mockBiometricManager);

    ArgumentCaptor<Boolean> allowCredentialsCaptor = ArgumentCaptor.forClass(Boolean.class);
    doNothing()
        .when(plugin)
        .sendAuthenticationRequest(
            any(MethodCall.class),
            any(AuthCompletionHandler.class),
            allowCredentialsCaptor.capture());
    final MethodChannel.Result mockResult = mock(MethodChannel.Result.class);
    HashMap<String, Object> arguments = new HashMap<>();
    arguments.put("biometricOnly", false);

    plugin.onMethodCall(new MethodCall("authenticate", arguments), mockResult);
    assertTrue(allowCredentialsCaptor.getValue());
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
    when(mockBiometricManager.canAuthenticate(BiometricManager.Authenticators.BIOMETRIC_WEAK))
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
    when(mockBiometricManager.canAuthenticate(BiometricManager.Authenticators.BIOMETRIC_WEAK))
        .thenReturn(BiometricManager.BIOMETRIC_SUCCESS);
    plugin.setBiometricManager(mockBiometricManager);
    plugin.onMethodCall(new MethodCall("deviceSupportsBiometrics", null), mockResult);
    verify(mockResult).success(true);
  }

  @Test
  public void deviceSupportsBiometrics_returnsFalseForNoBiometricHardware() {
    final LocalAuthPlugin plugin = new LocalAuthPlugin();
    final MethodChannel.Result mockResult = mock(MethodChannel.Result.class);
    final BiometricManager mockBiometricManager = mock(BiometricManager.class);
    when(mockBiometricManager.canAuthenticate(BiometricManager.Authenticators.BIOMETRIC_WEAK))
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
  public void onDetachedFromActivity_ShouldReleaseActivity() {
    final Activity mockActivity = mock(Activity.class);
    final ActivityPluginBinding mockActivityBinding = mock(ActivityPluginBinding.class);
    when(mockActivityBinding.getActivity()).thenReturn(mockActivity);

    Context mockContext = mock(Context.class);
    when(mockActivity.getBaseContext()).thenReturn(mockContext);
    when(mockActivity.getApplicationContext()).thenReturn(mockContext);

    final HiddenLifecycleReference mockLifecycleReference = mock(HiddenLifecycleReference.class);
    when(mockActivityBinding.getLifecycle()).thenReturn(mockLifecycleReference);

    final Lifecycle mockLifecycle = mock(Lifecycle.class);
    when(mockLifecycleReference.getLifecycle()).thenReturn(mockLifecycle);

    final FlutterPluginBinding mockPluginBinding = mock(FlutterPluginBinding.class);
    final FlutterEngine mockFlutterEngine = mock(FlutterEngine.class);
    when(mockPluginBinding.getFlutterEngine()).thenReturn(mockFlutterEngine);

    DartExecutor mockDartExecutor = mock(DartExecutor.class);
    when(mockFlutterEngine.getDartExecutor()).thenReturn(mockDartExecutor);

    final LocalAuthPlugin plugin = new LocalAuthPlugin();
    plugin.onAttachedToEngine(mockPluginBinding);
    plugin.onAttachedToActivity(mockActivityBinding);
    assertNotNull(plugin.getActivity());

    plugin.onDetachedFromActivity();
    assertNull(plugin.getActivity());
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
    final Activity mockActivity = buildMockActivityWithContext(mock(Activity.class));
    when(mockActivity.isFinishing()).thenReturn(true);
    setPluginActivity(plugin, mockActivity);

    plugin.onMethodCall(new MethodCall("getEnrolledBiometrics", null), mockResult);
    verify(mockResult)
        .error("no_activity", "local_auth plugin requires a foreground activity", null);
  }

  @Test
  public void getEnrolledBiometrics_shouldReturnEmptyList_withoutHardwarePresent() {
    final LocalAuthPlugin plugin = new LocalAuthPlugin();
    setPluginActivity(plugin, buildMockActivityWithContext(mock(Activity.class)));
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
    setPluginActivity(plugin, buildMockActivityWithContext(mock(Activity.class)));
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
    setPluginActivity(plugin, buildMockActivityWithContext(mock(Activity.class)));
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
    setPluginActivity(plugin, buildMockActivityWithContext(mock(Activity.class)));
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

  private Activity buildMockActivityWithContext(Activity mockActivity) {
    final Context mockContext = mock(Context.class);
    when(mockActivity.getBaseContext()).thenReturn(mockContext);
    when(mockActivity.getApplicationContext()).thenReturn(mockContext);
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
}
