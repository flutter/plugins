package io.flutter.plugins.imagepicker;

import static org.junit.Assert.assertTrue;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.verifyZeroInteractions;
import static org.mockito.Mockito.when;

import android.app.Activity;
import android.app.Application;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.PluginRegistry;
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
  private static final String PICK_VIDEO = "pickVideo";

  @Rule public ExpectedException exception = ExpectedException.none();

  @Mock PluginRegistry.Registrar mockRegistrar;
  @Mock Activity mockActivity;
  @Mock Application mockApplication;
  @Mock ImagePickerDelegate mockImagePickerDelegate;
  @Mock MethodChannel.Result mockResult;

  ImagePickerPlugin plugin;

  @Before
  public void setUp() {
    MockitoAnnotations.initMocks(this);
    when(mockRegistrar.context()).thenReturn(mockApplication);

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
    verifyZeroInteractions(mockImagePickerDelegate);
  }

  @Test
  public void onMethodCall_WhenCalledWithUnknownMethod_ThrowsException() {
    exception.expect(IllegalArgumentException.class);
    exception.expectMessage("Unknown method test");
    plugin.onMethodCall(new MethodCall("test", null), mockResult);
    verifyZeroInteractions(mockImagePickerDelegate);
    verifyZeroInteractions(mockResult);
  }

  @Test
  public void onMethodCall_WhenCalledWithUnknownImageSource_ThrowsException() {
    exception.expect(IllegalArgumentException.class);
    exception.expectMessage("Invalid image source: -1");
    plugin.onMethodCall(buildMethodCall(PICK_IMAGE, -1), mockResult);
    verifyZeroInteractions(mockImagePickerDelegate);
    verifyZeroInteractions(mockResult);
  }

  @Test
  public void onMethodCall_WhenSourceIsGallery_InvokesChooseImageFromGallery() {
    MethodCall call = buildMethodCall(PICK_IMAGE, SOURCE_GALLERY);
    plugin.onMethodCall(call, mockResult);
    verify(mockImagePickerDelegate).chooseImageFromGallery(eq(call), any());
    verifyZeroInteractions(mockResult);
  }

  @Test
  public void onMethodCall_WhenSourceIsCamera_InvokesTakeImageWithCamera() {
    MethodCall call = buildMethodCall(PICK_IMAGE, SOURCE_CAMERA);
    plugin.onMethodCall(call, mockResult);
    verify(mockImagePickerDelegate).takeImageWithCamera(eq(call), any());
    verifyZeroInteractions(mockResult);
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

  private MethodCall buildMethodCall(String method, final int source) {
    final Map<String, Object> arguments = new HashMap<>();
    arguments.put("source", source);

    return new MethodCall(method, arguments);
  }
}
