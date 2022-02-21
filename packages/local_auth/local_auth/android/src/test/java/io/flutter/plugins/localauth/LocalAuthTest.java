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
import androidx.lifecycle.Lifecycle;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.embedding.engine.dart.DartExecutor;
import io.flutter.embedding.engine.plugins.FlutterPlugin.FlutterPluginBinding;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.embedding.engine.plugins.lifecycle.HiddenLifecycleReference;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import java.util.Collections;
import org.junit.Test;

public class LocalAuthTest {
  @Test
  public void isDeviceSupportedReturnsFalse() {
    final LocalAuthPlugin plugin = new LocalAuthPlugin();
    final MethodChannel.Result mockResult = mock(MethodChannel.Result.class);
    plugin.onMethodCall(new MethodCall("isDeviceSupported", null), mockResult);
    verify(mockResult).success(false);
  }

  @Test
  public void onDetachedFromActivity_ShouldReleaseActivity() {
    final Activity mockActivity = mock(Activity.class);
    final ActivityPluginBinding mockActivityBinding = mock(ActivityPluginBinding.class);
    when(mockActivityBinding.getActivity()).thenReturn(mockActivity);

    Context mockContext = mock(Context.class);
    when(mockActivity.getBaseContext()).thenReturn(mockContext);

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
  public void getAvailableBiometrics_CanCheckBiometricsReturnsFalse() {
    final Activity mockActivity = mock(Activity.class);
    final Lifecycle mockLifecycle = mock(Lifecycle.class);
    final FlutterEngine mockFlutterEngine = mock(FlutterEngine.class);
    final DartExecutor mockDartExecutor = mock(DartExecutor.class);
    final Context mockContext = mock(Context.class);

    final ActivityPluginBinding mockActivityBinding = mock(ActivityPluginBinding.class);
    final HiddenLifecycleReference mockLifecycleReference = mock(HiddenLifecycleReference.class);
    final FlutterPluginBinding mockPluginBinding = mock(FlutterPluginBinding.class);
    final MethodChannel.Result mockResult = mock(MethodChannel.Result.class);

    when(mockActivity.getBaseContext()).thenReturn(mockContext);
    when(mockActivity.getApplicationContext()).thenReturn(mockContext);
    when(mockActivityBinding.getActivity()).thenReturn(mockActivity);
    when(mockActivityBinding.getLifecycle()).thenReturn(mockLifecycleReference);
    when(mockLifecycleReference.getLifecycle()).thenReturn(mockLifecycle);
    when(mockPluginBinding.getFlutterEngine()).thenReturn(mockFlutterEngine);
    when(mockFlutterEngine.getDartExecutor()).thenReturn(mockDartExecutor);

    final LocalAuthPlugin plugin = new LocalAuthPlugin();
    plugin.onAttachedToEngine(mockPluginBinding);
    plugin.onAttachedToActivity(mockActivityBinding);
    plugin.onMethodCall(new MethodCall("getAvailableBiometrics", null), mockResult);
    verify(mockResult).success(Collections.emptyList());
  }
}
