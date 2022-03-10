// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.localauth;

import static org.junit.Assert.assertNotNull;
import static org.junit.Assert.assertNull;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import android.app.Activity;
import android.content.Context;
import android.content.pm.PackageManager;
import android.os.Build;

import androidx.biometric.BiometricManager;
import androidx.lifecycle.Lifecycle;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.embedding.engine.dart.DartExecutor;
import io.flutter.embedding.engine.plugins.FlutterPlugin.FlutterPluginBinding;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.embedding.engine.plugins.lifecycle.HiddenLifecycleReference;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;

import java.util.Collections;

import org.junit.Before;
import org.junit.Test;
import org.mockito.Mock;

public class LocalAuthTest {

  private LocalAuthPlugin plugin;
  @Mock private Context mockContext;
  @Mock private Activity mockActivity;
  @Mock private Lifecycle mockLifecycle;
  @Mock private FlutterEngine mockFlutterEngine;
  @Mock private DartExecutor mockDartExecutor;
  @Mock private ActivityPluginBinding mockActivityBinding;
  @Mock private MethodChannel.Result mockResult;
  @Mock private FlutterPluginBinding mockPluginBinding;

  @Before
  public void setUp() {
    plugin = new LocalAuthPlugin();
    mockContext = mock(Context.class);
    mockActivity = mock(Activity.class);
    mockLifecycle = mock(Lifecycle.class);
    mockFlutterEngine = mock(FlutterEngine.class);
    mockDartExecutor = mock(DartExecutor.class);
    mockActivityBinding = mock(ActivityPluginBinding.class);
    mockResult = mock(MethodChannel.Result.class);
    mockPluginBinding = mock(FlutterPluginBinding.class);

    final HiddenLifecycleReference mockLifecycleReference = mock(HiddenLifecycleReference.class);
    when(mockActivity.getApplicationContext()).thenReturn(mockContext);
    when(mockActivityBinding.getLifecycle()).thenReturn(mockLifecycleReference);
    when(mockLifecycleReference.getLifecycle()).thenReturn(mockLifecycle);
    when(mockActivityBinding.getActivity()).thenReturn(mockActivity);
    when(mockActivity.getBaseContext()).thenReturn(mockContext);
    when(mockPluginBinding.getFlutterEngine()).thenReturn(mockFlutterEngine);
    when(mockFlutterEngine.getDartExecutor()).thenReturn(mockDartExecutor);

    plugin.onAttachedToEngine(mockPluginBinding);
    plugin.onAttachedToActivity(mockActivityBinding);
  }

  @Test
  public void isDeviceSupportedReturnsFalse() {
    plugin.onMethodCall(new MethodCall("isDeviceSupported", null), mockResult);
    verify(mockResult).success(false);
  }

  @Test
  public void onDetachedFromActivity_ShouldReleaseActivity() {

    plugin.onAttachedToEngine(mockPluginBinding);
    plugin.onAttachedToActivity(mockActivityBinding);
    assertNotNull(plugin.getActivity());

    plugin.onDetachedFromActivity();
    assertNull(plugin.getActivity());
  }

  @Test
  public void getAvailableBiometrics_ShouldReturnUndefinedBiometrics() {
    plugin.onMethodCall(new MethodCall("getAvailableBiometrics", null), mockResult);
    verify(mockResult).success(Collections.singletonList("undefined"));
  }

  @Test
  public void getAvailableBiometrics_ShouldReturnEmptyBiometrics() {
    final BiometricManager mockBiometricManager = mock(BiometricManager.class);
    when(mockBiometricManager.canAuthenticate()).thenReturn(BiometricManager.BIOMETRIC_SUCCESS);
    plugin.overrideBiometricManager(mockBiometricManager);
    plugin.onMethodCall(new MethodCall("getAvailableBiometrics", null), mockResult);
    verify(mockResult).success(Collections.emptyList());
  }

  @Test
  public void getAvailableBiometrics_ShouldReturnNoEmptyBiometrics() {
    final BiometricManager mockBiometricManager = mock(BiometricManager.class);
    final PackageManager mockPackageManager = mock(PackageManager.class);

    when(mockBiometricManager.canAuthenticate()).thenReturn(BiometricManager.BIOMETRIC_SUCCESS);
    when(mockActivity.getPackageManager()).thenReturn(mockPackageManager);
    when(mockPackageManager.hasSystemFeature(PackageManager.FEATURE_FINGERPRINT)).thenReturn(true);
    when(mockPackageManager.hasSystemFeature(PackageManager.FEATURE_FACE)).thenReturn(true);

    plugin.overrideSdkInt(Build.VERSION_CODES.M);
    plugin.overrideBiometricManager(mockBiometricManager);
    plugin.onMethodCall(new MethodCall("getAvailableBiometrics", null), mockResult);
    verify(mockResult).success(Collections.singletonList("fingerprint"));
  }
}
