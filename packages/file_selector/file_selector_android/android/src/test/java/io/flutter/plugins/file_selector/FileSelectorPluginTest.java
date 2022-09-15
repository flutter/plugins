// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.file_selector;

import static io.flutter.plugins.file_selector.FileSelectorPlugin.METHOD_GET_DIRECTORY_PATH;
import static io.flutter.plugins.file_selector.TestHelpers.buildMethodCall;
import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertNotNull;
import static org.junit.Assert.assertNull;
import static org.junit.Assert.assertThrows;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.verifyNoInteractions;
import static org.mockito.Mockito.when;

import android.app.Activity;
import android.app.Application;
import androidx.lifecycle.Lifecycle;
import io.flutter.embedding.engine.plugins.FlutterPlugin.FlutterPluginBinding;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.embedding.engine.plugins.lifecycle.HiddenLifecycleReference;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import org.junit.Before;
import org.junit.Test;
import org.mockito.Mock;
import org.mockito.MockitoAnnotations;

public class FileSelectorPluginTest {
  @Mock io.flutter.plugin.common.PluginRegistry.Registrar mockRegistrar;

  @Mock ActivityPluginBinding mockActivityBinding;
  @Mock FlutterPluginBinding mockPluginBinding;

  @Mock Activity mockActivity;
  @Mock Application mockApplication;
  @Mock FileSelectorDelegate mockFileSelectorDelegate;
  @Mock MethodChannel.Result mockResult;

  FileSelectorPlugin plugin;

  @Before
  public void setUp() {
    MockitoAnnotations.openMocks(this);
    when(mockRegistrar.context()).thenReturn(mockApplication);
    when(mockActivityBinding.getActivity()).thenReturn(mockActivity);
    when(mockPluginBinding.getApplicationContext()).thenReturn(mockApplication);
    plugin = new FileSelectorPlugin(mockFileSelectorDelegate, mockActivity);
  }

  @Test
  public void onMethodCall_WhenActivityIsNull_FinishesWithForegroundActivityRequiredError() {
    MethodCall call = buildMethodCall(METHOD_GET_DIRECTORY_PATH);
    FileSelectorPlugin fileSelectorPluginWithNullActivity =
        new FileSelectorPlugin(mockFileSelectorDelegate, null);
    fileSelectorPluginWithNullActivity.onMethodCall(call, mockResult);
    verify(mockResult)
        .error("no_activity", "file_selector plugin requires a foreground activity.", null);
    verifyNoInteractions(mockFileSelectorDelegate);
  }

  @Test
  public void onMethodCall_WhenCalledWithUnknownMethod_ThrowsException() {
    String method = "unknown_test_method";

    IllegalArgumentException exception =
        assertThrows(
            IllegalArgumentException.class,
            () -> plugin.onMethodCall(new MethodCall(method, null), mockResult));
    assertEquals("Unknown method " + method, exception.getMessage());
    verifyNoInteractions(mockFileSelectorDelegate);
    verifyNoInteractions(mockResult);
  }

  @Test
  public void
      onMethodCall_GetDirectoryPath_WhenCalledWithoutInitialDirectory_InvokesRootSourceFolder() {
    MethodCall call = buildMethodCall(METHOD_GET_DIRECTORY_PATH, null, null);
    plugin.onMethodCall(call, mockResult);
    verify(mockFileSelectorDelegate).getDirectoryPath(eq(call), any());
    verifyNoInteractions(mockResult);
  }

  @Test
  public void onMethodCall_GetDirectoryPath_WhenCalledWithInitialDirectory_InvokesSourceFolder() {
    MethodCall call = buildMethodCall(METHOD_GET_DIRECTORY_PATH, "Documents", null);
    plugin.onMethodCall(call, mockResult);
    verify(mockFileSelectorDelegate).getDirectoryPath(eq(call), any());
    verifyNoInteractions(mockResult);
  }

  @Test
  public void onDetachedFromActivity_ShouldReleaseActivityState() {
    final BinaryMessenger mockBinaryMessenger = mock(BinaryMessenger.class);
    when(mockPluginBinding.getBinaryMessenger()).thenReturn(mockBinaryMessenger);

    final HiddenLifecycleReference mockLifecycleReference = mock(HiddenLifecycleReference.class);
    when(mockActivityBinding.getLifecycle()).thenReturn(mockLifecycleReference);

    final Lifecycle mockLifecycle = mock(Lifecycle.class);
    when(mockLifecycleReference.getLifecycle()).thenReturn(mockLifecycle);

    plugin.onAttachedToEngine(mockPluginBinding);
    plugin.onAttachedToActivity(mockActivityBinding);
    assertNotNull(plugin.getActivityState());

    plugin.onDetachedFromActivity();
    assertNull(plugin.getActivityState());
  }
}
