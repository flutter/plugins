package io.flutter.plugins.imagepicker;

import static org.junit.Assert.assertTrue;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.verifyZeroInteractions;
import static org.mockito.Mockito.when;

import android.app.Activity;
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

  @Rule public ExpectedException exception = ExpectedException.none();

  @Mock PluginRegistry.Registrar mockRegistrar;
  @Mock Activity mockActivity;
  @Mock ImagePickerDelegate mockImagePickerDelegate;
  @Mock MethodChannel.Result mockResult;

  ImagePickerPlugin plugin;

  @Before
  public void setUp() {
    MockitoAnnotations.initMocks(this);

    plugin = new ImagePickerPlugin(mockRegistrar, mockImagePickerDelegate);
  }

  @Test
  public void onMethodCall_WhenActivityIsNull_FinishesWithForegroundActivityRequiredError() {
    when(mockRegistrar.activity()).thenReturn(null);
    MethodCall call = buildMethodCall(SOURCE_GALLERY);

    plugin.onMethodCall(call, mockResult);

    verify(mockResult)
        .error("no_activity", "image_picker plugin requires a foreground activity.", null);
    verifyZeroInteractions(mockImagePickerDelegate);
  }

  @Test
  public void onMethodCall_WhenCalledWithUnknownMethod_ThrowsException() {
    when(mockRegistrar.activity()).thenReturn(mockActivity);
    exception.expect(IllegalArgumentException.class);
    exception.expectMessage("Unknown method test");

    plugin.onMethodCall(new MethodCall("test", null), mockResult);

    verifyZeroInteractions(mockImagePickerDelegate);
    verifyZeroInteractions(mockResult);
  }

  @Test
  public void onMethodCall_WhenCalledWithUnknownImageSource_ThrowsException() {
    when(mockRegistrar.activity()).thenReturn(mockActivity);
    exception.expect(IllegalArgumentException.class);
    exception.expectMessage("Invalid image source: -1");

    plugin.onMethodCall(buildMethodCall(-1), mockResult);

    verifyZeroInteractions(mockImagePickerDelegate);
    verifyZeroInteractions(mockResult);
  }

  @Test
  public void onMethodCall_WhenSourceIsGallery_InvokesChooseImageFromGallery() {
    when(mockRegistrar.activity()).thenReturn(mockActivity);
    MethodCall call = buildMethodCall(SOURCE_GALLERY);

    plugin.onMethodCall(call, mockResult);

    verify(mockImagePickerDelegate).chooseImageFromGallery(call, mockResult);
    verifyZeroInteractions(mockResult);
  }

  @Test
  public void onMethodCall_WhenSourceIsCamera_InvokesTakeImageWithCamera() {
    when(mockRegistrar.activity()).thenReturn(mockActivity);
    MethodCall call = buildMethodCall(SOURCE_CAMERA);

    plugin.onMethodCall(call, mockResult);

    verify(mockImagePickerDelegate).takeImageWithCamera(call, mockResult);
    verifyZeroInteractions(mockResult);
  }

  @Test
  public void onResiter_WhenAcitivityIsNull_ShouldNotCrash() {
    when(mockRegistrar.activity()).thenReturn(null);
    ImagePickerPlugin.registerWith((mockRegistrar));
    assertTrue(
        "No exception thrown when ImagePickerPlugin.registerWith ran with activity = null", true);
  }

  private MethodCall buildMethodCall(final int source) {
    final Map<String, Object> arguments = new HashMap<>();
    arguments.put("source", source);

    return new MethodCall("pickImage", arguments);
  }
}
