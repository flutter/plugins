package io.flutter.plugins.camera.features.fpsrange;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertTrue;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import android.hardware.camera2.CaptureRequest;
import android.util.Range;
import io.flutter.plugins.camera.CameraProperties;
import org.junit.Test;

public class FpsRangeFeatureTest {
  @Test
  public void ctor_should_initialize_fps_range_with_highest_upper_value_from_range_array() {
    FpsRangeFeature fpsRangeFeature = createTestInstance();
    assertEquals(13, (int) fpsRangeFeature.getValue().getUpper());
  }

  @Test
  public void getDebugName_should_return_the_name_of_the_feature() {
    FpsRangeFeature fpsRangeFeature = createTestInstance();
    assertEquals("FpsRangeFeature", fpsRangeFeature.getDebugName());
  }

  @Test
  public void getValue_should_return_highest_upper_range_if_not_set() {
    CameraProperties mockCameraProperties = mock(CameraProperties.class);
    FpsRangeFeature fpsRangeFeature = createTestInstance();

    assertEquals(13, (int)fpsRangeFeature.getValue().getUpper());
  }

  @Test
  public void getValue_should_echo_the_set_value() {
    CameraProperties mockCameraProperties = mock(CameraProperties.class);
    FpsRangeFeature fpsRangeFeature = new FpsRangeFeature(mockCameraProperties);
    @SuppressWarnings("unchecked")
    Range<Integer> expectedValue = mock(Range.class);

    fpsRangeFeature.setValue(expectedValue);
    Range<Integer> actualValue = fpsRangeFeature.getValue();

    assertEquals(expectedValue, actualValue);
  }

  @Test
  public void checkIsSupported_should_return_true() {
    FpsRangeFeature fpsRangeFeature = createTestInstance();
    assertTrue(fpsRangeFeature.checkIsSupported());
  }

  @Test
  @SuppressWarnings("unchecked")
  public void updateBuilder_should_set_ae_target_fps_range() {
    CaptureRequest.Builder mockBuilder = mock(CaptureRequest.Builder.class);
    FpsRangeFeature fpsRangeFeature = createTestInstance();

    fpsRangeFeature.updateBuilder(mockBuilder);

    verify(mockBuilder).set(eq(CaptureRequest.CONTROL_AE_TARGET_FPS_RANGE), any(Range.class));
  }

  private static FpsRangeFeature createTestInstance() {
    @SuppressWarnings("unchecked")
    Range<Integer> rangeOne = mock(Range.class);
    @SuppressWarnings("unchecked")
    Range<Integer> rangeTwo = mock(Range.class);
    @SuppressWarnings("unchecked")
    Range<Integer> rangeThree = mock(Range.class);

    when(rangeOne.getUpper()).thenReturn(11);
    when(rangeTwo.getUpper()).thenReturn(12);
    when(rangeThree.getUpper()).thenReturn(13);

    @SuppressWarnings("unchecked")
    Range<Integer>[] ranges = new Range[] { rangeOne, rangeTwo, rangeThree };

    CameraProperties cameraProperties = mock(CameraProperties.class);

    when(cameraProperties.getControlAutoExposureAvailableTargetFpsRanges()).thenReturn(ranges);

    return new FpsRangeFeature(cameraProperties);
  }
}
