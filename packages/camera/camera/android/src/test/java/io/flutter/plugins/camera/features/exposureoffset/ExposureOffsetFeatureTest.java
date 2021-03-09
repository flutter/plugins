package io.flutter.plugins.camera.features.exposureoffset;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertTrue;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.times;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import android.hardware.camera2.CaptureRequest;
import io.flutter.plugins.camera.CameraProperties;
import org.junit.Test;

public class ExposureOffsetFeatureTest {
  private static final ExposureOffsetValue DEFAULT_EXPOSURE_OFFSET_VALUE = new ExposureOffsetValue(0, 0, 0);

  @Test
  public void getDebugName_should_return_the_name_of_the_feature() {
    CameraProperties mockCameraProperties = mock(CameraProperties.class);
    ExposureOffsetFeature exposureOffsetFeature = new ExposureOffsetFeature(mockCameraProperties);

    assertEquals("ExposureOffsetFeature", exposureOffsetFeature.getDebugName());
  }

  @Test
  public void getValue_should_return_auto_if_not_set() {
    CameraProperties mockCameraProperties = mock(CameraProperties.class);
    ExposureOffsetFeature exposureOffsetFeature = new ExposureOffsetFeature(mockCameraProperties);

    final ExposureOffsetValue actualValue = exposureOffsetFeature.getValue();

    assertEquals(DEFAULT_EXPOSURE_OFFSET_VALUE.min, actualValue.min, 0);
    assertEquals(DEFAULT_EXPOSURE_OFFSET_VALUE.max, actualValue.max, 0);
    assertEquals(DEFAULT_EXPOSURE_OFFSET_VALUE.value, actualValue.value, 0);
  }

  @Test
  public void getValue_should_echo_the_set_value() {
    CameraProperties mockCameraProperties = mock(CameraProperties.class);
    ExposureOffsetFeature exposureOffsetFeature = new ExposureOffsetFeature(mockCameraProperties);
    ExposureOffsetValue expectedValue = new ExposureOffsetValue(1, 2, 4);

    when(mockCameraProperties.getControlAutoExposureCompensationStep()).thenReturn(0.5);

    exposureOffsetFeature.setValue(expectedValue);
    ExposureOffsetValue actualValue = exposureOffsetFeature.getValue();

    assertEquals(expectedValue.min, actualValue.min, 1);
    assertEquals(expectedValue.max, actualValue.max, 2);
    assertEquals(expectedValue.value, actualValue.value, 8);
  }

  @Test
  public void getExposureOffsetStepSize_should_return_the_control_exposure_compensation_step_value() {
    CameraProperties mockCameraProperties = mock(CameraProperties.class);
    ExposureOffsetFeature exposureOffsetFeature = new ExposureOffsetFeature(mockCameraProperties);

    when(mockCameraProperties.getControlAutoExposureCompensationStep()).thenReturn(0.5);

    assertEquals(0.5, exposureOffsetFeature.getExposureOffsetStepSize(), 0);
  }

  @Test
  public void checkIsSupported_should_return_true() {
    CameraProperties mockCameraProperties = mock(CameraProperties.class);
    ExposureOffsetFeature exposureOffsetFeature = new ExposureOffsetFeature(mockCameraProperties);

    assertTrue(exposureOffsetFeature.checkIsSupported());
  }

  @Test
  public void updateBuilder_should_set_control_ae_exposure_compensation_to_offset() {
    CameraProperties mockCameraProperties = mock(CameraProperties.class);
    CaptureRequest.Builder mockBuilder = mock(CaptureRequest.Builder.class);
    ExposureOffsetFeature exposureOffsetFeature = new ExposureOffsetFeature(mockCameraProperties);
    ExposureOffsetValue expectedValue = new ExposureOffsetValue(1, 2, 4);

    when(mockCameraProperties.getControlAutoExposureCompensationStep()).thenReturn(0.5);

    exposureOffsetFeature.setValue(expectedValue);
    exposureOffsetFeature.updateBuilder(mockBuilder);

    verify(mockBuilder, times(1)).set(CaptureRequest.CONTROL_AE_EXPOSURE_COMPENSATION, 8);
  }
}
