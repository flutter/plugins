package io.flutter.plugins.camera.features.autofocus;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertFalse;
import static org.junit.Assert.assertTrue;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.times;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import android.hardware.camera2.CameraCharacteristics;
import android.hardware.camera2.CaptureRequest;
import io.flutter.plugins.camera.CameraProperties;
import org.junit.Test;

public class AutoFocusFeatureTest {
  private static final int[] FOCUS_MODES_ONLY_OFF = new int[] { CameraCharacteristics.CONTROL_AF_MODE_OFF };
  private static final int[] FOCUS_MODES = new int[] { CameraCharacteristics.CONTROL_AF_MODE_OFF, CameraCharacteristics.CONTROL_AF_MODE_AUTO };

  @Test
  public void getDebugName_should_return_the_name_of_the_feature() {
    CameraProperties mockCameraProperties = mock(CameraProperties.class);
    AutoFocusFeature autoFocusFeature = new AutoFocusFeature(mockCameraProperties, false);

    assertEquals("AutoFocusFeature", autoFocusFeature.getDebugName());
  }

  @Test
  public void getValue_should_return_auto_if_not_set() {
    CameraProperties mockCameraProperties = mock(CameraProperties.class);
    AutoFocusFeature autoFocusFeature = new AutoFocusFeature(mockCameraProperties, false);

    assertEquals(FocusMode.auto, autoFocusFeature.getValue());
  }

  @Test
  public void getValue_should_echo_the_set_value() {
    CameraProperties mockCameraProperties = mock(CameraProperties.class);
    AutoFocusFeature autoFocusFeature = new AutoFocusFeature(mockCameraProperties, false);
    FocusMode expectedValue = FocusMode.locked;

    autoFocusFeature.setValue(expectedValue);
    FocusMode actualValue = autoFocusFeature.getValue();

    assertEquals(expectedValue, actualValue);
  }

  @Test
  public void checkIsSupported_should_return_false_when_minimum_focus_distance_is_zero() {
    CameraProperties mockCameraProperties = mock(CameraProperties.class);
    AutoFocusFeature autoFocusFeature = new AutoFocusFeature(mockCameraProperties, false);

    when(mockCameraProperties.getControlAutoFocusAvailableModes()).thenReturn(FOCUS_MODES);
    when(mockCameraProperties.getLensInfoMinimumFocusDistance()).thenReturn(0.0F);

    assertFalse(autoFocusFeature.checkIsSupported());
  }

  @Test
  public void checkIsSupported_should_return_false_when_minimum_focus_distance_is_null() {
    CameraProperties mockCameraProperties = mock(CameraProperties.class);
    AutoFocusFeature autoFocusFeature = new AutoFocusFeature(mockCameraProperties, false);

    when(mockCameraProperties.getControlAutoFocusAvailableModes()).thenReturn(FOCUS_MODES);
    when(mockCameraProperties.getLensInfoMinimumFocusDistance()).thenReturn(null);

    assertFalse(autoFocusFeature.checkIsSupported());
  }

  @Test
  public void checkIsSupport_should_return_false_when_no_focus_modes_are_available() {
    CameraProperties mockCameraProperties = mock(CameraProperties.class);
    AutoFocusFeature autoFocusFeature = new AutoFocusFeature(mockCameraProperties, false);

    when(mockCameraProperties.getControlAutoFocusAvailableModes()).thenReturn(new int[] {});
    when(mockCameraProperties.getLensInfoMinimumFocusDistance()).thenReturn(1.0F);

    assertFalse(autoFocusFeature.checkIsSupported());
  }

  @Test
  public void checkIsSupport_should_return_false_when_only_focus_off_is_available() {
    CameraProperties mockCameraProperties = mock(CameraProperties.class);
    AutoFocusFeature autoFocusFeature = new AutoFocusFeature(mockCameraProperties, false);

    when(mockCameraProperties.getControlAutoFocusAvailableModes()).thenReturn(FOCUS_MODES_ONLY_OFF);
    when(mockCameraProperties.getLensInfoMinimumFocusDistance()).thenReturn(1.0F);

    assertFalse(autoFocusFeature.checkIsSupported());
  }

  @Test
  public void checkIsSupport_should_return_true_when_only_multiple_focus_modes_are_available() {
    CameraProperties mockCameraProperties = mock(CameraProperties.class);
    AutoFocusFeature autoFocusFeature = new AutoFocusFeature(mockCameraProperties, false);

    when(mockCameraProperties.getControlAutoFocusAvailableModes()).thenReturn(FOCUS_MODES);
    when(mockCameraProperties.getLensInfoMinimumFocusDistance()).thenReturn(1.0F);

    assertTrue(autoFocusFeature.checkIsSupported());
  }

  @Test
  public void updateBuilder_should_return_when_checkIsSupported_is_false() {
    CameraProperties mockCameraProperties = mock(CameraProperties.class);
    CaptureRequest.Builder mockBuilder = mock(CaptureRequest.Builder.class);
    AutoFocusFeature autoFocusFeature = new AutoFocusFeature(mockCameraProperties, false);

    when(mockCameraProperties.getControlAutoFocusAvailableModes()).thenReturn(FOCUS_MODES);
    when(mockCameraProperties.getLensInfoMinimumFocusDistance()).thenReturn(0.0F);

    autoFocusFeature.updateBuilder(mockBuilder);

    verify(mockBuilder, never()).set(any(), any());
  }

  @Test
  public void updateBuilder_should_set_control_mode_to_auto_when_focus_is_locked() {
    CameraProperties mockCameraProperties = mock(CameraProperties.class);
    CaptureRequest.Builder mockBuilder = mock(CaptureRequest.Builder.class);
    AutoFocusFeature autoFocusFeature = new AutoFocusFeature(mockCameraProperties, false);

    when(mockCameraProperties.getControlAutoFocusAvailableModes()).thenReturn(FOCUS_MODES);
    when(mockCameraProperties.getLensInfoMinimumFocusDistance()).thenReturn(1.0F);

    autoFocusFeature.setValue(FocusMode.locked);
    autoFocusFeature.updateBuilder(mockBuilder);

    verify(mockBuilder, times(1)).set(CaptureRequest.CONTROL_AF_MODE, CaptureRequest.CONTROL_AF_MODE_AUTO);
  }

  @Test
  public void updateBuilder_should_set_control_mode_to_continuous_video_when_focus_is_auto_and_recording_video() {
    CameraProperties mockCameraProperties = mock(CameraProperties.class);
    CaptureRequest.Builder mockBuilder = mock(CaptureRequest.Builder.class);
    AutoFocusFeature autoFocusFeature = new AutoFocusFeature(mockCameraProperties, true);

    when(mockCameraProperties.getControlAutoFocusAvailableModes()).thenReturn(FOCUS_MODES);
    when(mockCameraProperties.getLensInfoMinimumFocusDistance()).thenReturn(1.0F);

    autoFocusFeature.setValue(FocusMode.auto);
    autoFocusFeature.updateBuilder(mockBuilder);

    verify(mockBuilder, times(1)).set(CaptureRequest.CONTROL_AF_MODE, CaptureRequest.CONTROL_AF_MODE_CONTINUOUS_VIDEO);
  }

  @Test
  public void updateBuilder_should_set_control_mode_to_continuous_video_when_focus_is_auto_and_not_recording_video() {
    CameraProperties mockCameraProperties = mock(CameraProperties.class);
    CaptureRequest.Builder mockBuilder = mock(CaptureRequest.Builder.class);
    AutoFocusFeature autoFocusFeature = new AutoFocusFeature(mockCameraProperties, false);

    when(mockCameraProperties.getControlAutoFocusAvailableModes()).thenReturn(FOCUS_MODES);
    when(mockCameraProperties.getLensInfoMinimumFocusDistance()).thenReturn(1.0F);

    autoFocusFeature.setValue(FocusMode.auto);
    autoFocusFeature.updateBuilder(mockBuilder);

    verify(mockBuilder, times(1)).set(CaptureRequest.CONTROL_AF_MODE, CaptureRequest.CONTROL_AF_MODE_CONTINUOUS_PICTURE);
  }
}
