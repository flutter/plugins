package io.flutter.plugins.camera.features.flash;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertFalse;
import static org.junit.Assert.assertTrue;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.times;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import android.hardware.camera2.CaptureRequest;
import io.flutter.plugins.camera.CameraProperties;
import org.junit.Test;

public class FlashFeatureTest {
  @Test
  public void getDebugName_should_return_the_name_of_the_feature() {
    CameraProperties mockCameraProperties = mock(CameraProperties.class);
    FlashFeature flashFeature = new FlashFeature(mockCameraProperties);

    assertEquals("FlashFeature", flashFeature.getDebugName());
  }

  @Test
  public void getValue_should_return_auto_if_not_set() {
    CameraProperties mockCameraProperties = mock(CameraProperties.class);
    FlashFeature flashFeature = new FlashFeature(mockCameraProperties);

    assertEquals(FlashMode.auto, flashFeature.getValue());
  }

  @Test
  public void getValue_should_echo_the_set_value() {
    CameraProperties mockCameraProperties = mock(CameraProperties.class);
    FlashFeature flashFeature = new FlashFeature(mockCameraProperties);
    FlashMode expectedValue = FlashMode.torch;

    flashFeature.setValue(expectedValue);
    FlashMode actualValue = flashFeature.getValue();

    assertEquals(expectedValue, actualValue);
  }

  @Test
  public void checkIsSupported_should_return_false_when_flash_info_available_is_null() {
    CameraProperties mockCameraProperties = mock(CameraProperties.class);
    FlashFeature flashFeature = new FlashFeature(mockCameraProperties);

    when(mockCameraProperties.getFlashInfoAvailable()).thenReturn(null);

    assertFalse(flashFeature.checkIsSupported());
  }

  @Test
  public void checkIsSupported_should_return_false_when_flash_info_available_is_false() {
    CameraProperties mockCameraProperties = mock(CameraProperties.class);
    FlashFeature flashFeature = new FlashFeature(mockCameraProperties);

    when(mockCameraProperties.getFlashInfoAvailable()).thenReturn(false);

    assertFalse(flashFeature.checkIsSupported());
  }

  @Test
  public void checkIsSupported_should_return_true_when_flash_info_available_is_true() {
    CameraProperties mockCameraProperties = mock(CameraProperties.class);
    FlashFeature flashFeature = new FlashFeature(mockCameraProperties);

    when(mockCameraProperties.getFlashInfoAvailable()).thenReturn(true);

    assertTrue(flashFeature.checkIsSupported());
  }

  @Test
  public void updateBuilder_should_return_when_checkIsSupported_is_false() {
    CameraProperties mockCameraProperties = mock(CameraProperties.class);
    CaptureRequest.Builder mockBuilder = mock(CaptureRequest.Builder.class);
    FlashFeature flashFeature = new FlashFeature(mockCameraProperties);

    when(mockCameraProperties.getFlashInfoAvailable()).thenReturn(false);

    flashFeature.updateBuilder(mockBuilder);

    verify(mockBuilder, never()).set(any(), any());
  }

  @Test
  public void updateBuilder_should_set_ae_mode_and_flash_mode_when_flash_mode_is_off() {
    CameraProperties mockCameraProperties = mock(CameraProperties.class);
    CaptureRequest.Builder mockBuilder = mock(CaptureRequest.Builder.class);
    FlashFeature flashFeature = new FlashFeature(mockCameraProperties);

    when(mockCameraProperties.getFlashInfoAvailable()).thenReturn(true);

    flashFeature.setValue(FlashMode.off);
    flashFeature.updateBuilder(mockBuilder);

    verify(mockBuilder, times(1))
        .set(CaptureRequest.CONTROL_AE_MODE, CaptureRequest.CONTROL_AE_MODE_ON);
    verify(mockBuilder, times(1)).set(CaptureRequest.FLASH_MODE, CaptureRequest.FLASH_MODE_OFF);
  }

  @Test
  public void updateBuilder_should_set_ae_mode_and_flash_mode_when_flash_mode_is_always() {
    CameraProperties mockCameraProperties = mock(CameraProperties.class);
    CaptureRequest.Builder mockBuilder = mock(CaptureRequest.Builder.class);
    FlashFeature flashFeature = new FlashFeature(mockCameraProperties);

    when(mockCameraProperties.getFlashInfoAvailable()).thenReturn(true);

    flashFeature.setValue(FlashMode.always);
    flashFeature.updateBuilder(mockBuilder);

    verify(mockBuilder, times(1))
        .set(CaptureRequest.CONTROL_AE_MODE, CaptureRequest.CONTROL_AE_MODE_ON_ALWAYS_FLASH);
    verify(mockBuilder, times(1)).set(CaptureRequest.FLASH_MODE, CaptureRequest.FLASH_MODE_OFF);
  }

  @Test
  public void updateBuilder_should_set_ae_mode_and_flash_mode_when_flash_mode_is_torch() {
    CameraProperties mockCameraProperties = mock(CameraProperties.class);
    CaptureRequest.Builder mockBuilder = mock(CaptureRequest.Builder.class);
    FlashFeature flashFeature = new FlashFeature(mockCameraProperties);

    when(mockCameraProperties.getFlashInfoAvailable()).thenReturn(true);

    flashFeature.setValue(FlashMode.torch);
    flashFeature.updateBuilder(mockBuilder);

    verify(mockBuilder, times(1))
        .set(CaptureRequest.CONTROL_AE_MODE, CaptureRequest.CONTROL_AE_MODE_ON);
    verify(mockBuilder, times(1)).set(CaptureRequest.FLASH_MODE, CaptureRequest.FLASH_MODE_TORCH);
  }

  @Test
  public void updateBuilder_should_set_ae_mode_and_flash_mode_when_flash_mode_is_auto() {
    CameraProperties mockCameraProperties = mock(CameraProperties.class);
    CaptureRequest.Builder mockBuilder = mock(CaptureRequest.Builder.class);
    FlashFeature flashFeature = new FlashFeature(mockCameraProperties);

    when(mockCameraProperties.getFlashInfoAvailable()).thenReturn(true);

    flashFeature.setValue(FlashMode.auto);
    flashFeature.updateBuilder(mockBuilder);

    verify(mockBuilder, times(1))
        .set(CaptureRequest.CONTROL_AE_MODE, CaptureRequest.CONTROL_AE_MODE_ON_AUTO_FLASH);
    verify(mockBuilder, times(1)).set(CaptureRequest.FLASH_MODE, CaptureRequest.FLASH_MODE_OFF);
  }
}
