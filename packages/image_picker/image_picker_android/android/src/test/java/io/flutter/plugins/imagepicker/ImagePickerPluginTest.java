// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.imagepicker;

import static org.hamcrest.core.IsEqual.equalTo;
import static org.junit.Assert.assertNotNull;
import static org.junit.Assert.assertNull;
import static org.junit.Assert.assertThat;
import static org.junit.Assert.assertTrue;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.times;
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
import java.io.File;
import java.util.HashMap;
import java.util.Map;
import org.junit.Before;
import org.junit.Rule;
import org.junit.Test;
import org.junit.rules.ExpectedException;
import org.mockito.Mock;
import org.mockito.MockitoAnnotations;

public class ImagePickerPluginTest {
  private static final int SOURCE_CAMERA = 0;
  private static final int SOURCE_GALLERY = 1;
  private static final String PICK_IMAGE = "pickImage";
  private static final String PICK_MULTI_IMAGE = "pickMultiImage";
  private static final String PICK_VIDEO = "pickVideo";

  @Rule public ExpectedException exception = ExpectedException.none();

  @SuppressWarnings("deprecation")
  @Mock
  io.flutter.plugin.common.PluginRegistry.Registrar mockRegistrar;

  @Mock ActivityPluginBinding mockActivityBinding;
  @Mock FlutterPluginBinding mockPluginBinding;

  @Mock Activity mockActivity;
  @Mock Application mockApplication;
  @Mock ImagePickerDelegate mockImagePickerDelegate;
  @Mock MethodChannel.Result mockResult;

  ImagePickerPlugin plugin;

  @Before
  public void setUp() {
    MockitoAnnotations.initMocks(this);
    when(mockRegistrar.context()).thenReturn(mockApplication);
    when(mockActivityBinding.getActivity()).thenReturn(mockActivity);
    when(mockPluginBinding.getApplicationContext()).thenReturn(mockApplication);
    plugin = new ImagePickerPlugin(mockImagePickerDelegate, mockActivity);
  }

  @Test
  public void onMethodCall_WhenActivityIsNull_FinishesWithForegroundActivityRequiredError() {
    MethodCall call = buildMethodCall(PICK_IMAGE, SOURCE_GALLERY);
    ImagePickerPlugin imagePickerPluginWithNullActivity =
        new ImagePickerPlugin(mockImagePickerDelegate, null);
    imagePickerPluginWithNullActivity.onMethodCall(call, mockResult);
    verify(mockResult)
        .error("no_activity", "image_picker plugin requires a foreground activity.", null);
    verifyNoInteractions(mockImagePickerDelegate);
  }

  @Test
  public void onMethodCall_WhenCalledWithUnknownMethod_ThrowsException() {
    exception.expect(IllegalArgumentException.class);
    exception.expectMessage("Unknown method test");
    plugin.onMethodCall(new MethodCall("test", null), mockResult);
    verifyNoInteractions(mockImagePickerDelegate);
    verifyNoInteractions(mockResult);
  }

  @Test
  public void onMethodCall_WhenCalledWithUnknownImageSource_ThrowsException() {
    exception.expect(IllegalArgumentException.class);
    exception.expectMessage("Invalid image source: -1");
    plugin.onMethodCall(buildMethodCall(PICK_IMAGE, -1), mockResult);
    verifyNoInteractions(mockImagePickerDelegate);
    verifyNoInteractions(mockResult);
  }

  @Test
  public void onMethodCall_WhenSourceIsGallery_InvokesChooseImageFromGallery() {
    MethodCall call = buildMethodCall(PICK_IMAGE, SOURCE_GALLERY);
    plugin.onMethodCall(call, mockResult);
    verify(mockImagePickerDelegate).chooseImageFromGallery(eq(call), any());
    verifyNoInteractions(mockResult);
  }

  @Test
  public void onMethodCall_InvokesChooseMultiImageFromGallery() {
    MethodCall call = buildMethodCall(PICK_MULTI_IMAGE);
    plugin.onMethodCall(call, mockResult);
    verify(mockImagePickerDelegate).chooseMultiImageFromGallery(eq(call), any());
    verifyNoInteractions(mockResult);
  }

  @Test
  public void onMethodCall_WhenSourceIsCamera_InvokesTakeImageWithCamera() {
    MethodCall call = buildMethodCall(PICK_IMAGE, SOURCE_CAMERA);
    plugin.onMethodCall(call, mockResult);
    verify(mockImagePickerDelegate).takeImageWithCamera(eq(call), any());
    verifyNoInteractions(mockResult);
  }

  @Test
  public void onMethodCall_PickingImage_WhenSourceIsCamera_InvokesTakeImageWithCamera_RearCamera() {
    MethodCall call = buildMethodCall(PICK_IMAGE, SOURCE_CAMERA);
    HashMap<String, Object> arguments = (HashMap<String, Object>) call.arguments;
    arguments.put("cameraDevice", 0);
    plugin.onMethodCall(call, mockResult);
    verify(mockImagePickerDelegate).setCameraDevice(eq(CameraDevice.REAR));
  }

  @Test
  public void
      onMethodCall_PickingImage_WhenSourceIsCamera_InvokesTakeImageWithCamera_FrontCamera() {
    MethodCall call = buildMethodCall(PICK_IMAGE, SOURCE_CAMERA);
    HashMap<String, Object> arguments = (HashMap<String, Object>) call.arguments;
    arguments.put("cameraDevice", 1);
    plugin.onMethodCall(call, mockResult);
    verify(mockImagePickerDelegate).setCameraDevice(eq(CameraDevice.FRONT));
  }

  @Test
  public void onMethodCall_PickingVideo_WhenSourceIsCamera_InvokesTakeImageWithCamera_RearCamera() {
    MethodCall call = buildMethodCall(PICK_IMAGE, SOURCE_CAMERA);
    HashMap<String, Object> arguments = (HashMap<String, Object>) call.arguments;
    arguments.put("cameraDevice", 0);
    plugin.onMethodCall(call, mockResult);
    verify(mockImagePickerDelegate).setCameraDevice(eq(CameraDevice.REAR));
  }

  @Test
  public void
      onMethodCall_PickingVideo_WhenSourceIsCamera_InvokesTakeImageWithCamera_FrontCamera() {
    MethodCall call = buildMethodCall(PICK_IMAGE, SOURCE_CAMERA);
    HashMap<String, Object> arguments = (HashMap<String, Object>) call.arguments;
    arguments.put("cameraDevice", 1);
    plugin.onMethodCall(call, mockResult);
    verify(mockImagePickerDelegate).setCameraDevice(eq(CameraDevice.FRONT));
  }

  @Test
  public void onResiter_WhenAcitivityIsNull_ShouldNotCrash() {
    when(mockRegistrar.activity()).thenReturn(null);
    ImagePickerPlugin.registerWith((mockRegistrar));
    assertTrue(
        "No exception thrown when ImagePickerPlugin.registerWith ran with activity = null", true);
  }

  @Test
  public void onConstructor_WhenContextTypeIsActivity_ShouldNotCrash() {
    new ImagePickerPlugin(mockImagePickerDelegate, mockActivity);
    assertTrue(
        "No exception thrown when ImagePickerPlugin() ran with context instanceof Activity", true);
  }

  @Test
  public void constructDelegate_ShouldUseInternalCacheDirectory() {
    File mockDirectory = new File("/mockpath");
    when(mockActivity.getCacheDir()).thenReturn(mockDirectory);

    ImagePickerDelegate delegate = plugin.constructDelegate(mockActivity);

    verify(mockActivity, times(1)).getCacheDir();
    assertThat(
        "Delegate uses cache directory for storing camera captures",
        delegate.externalFilesDirectory,
        equalTo(mockDirectory));
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

  private MethodCall buildMethodCall(String method, final int source) {
    final Map<String, Object> arguments = new HashMap<>();
    arguments.put("source", source);

    return new MethodCall(method, arguments);
  }

  private MethodCall buildMethodCall(String method) {
    return new MethodCall(method, null);
  }
}
