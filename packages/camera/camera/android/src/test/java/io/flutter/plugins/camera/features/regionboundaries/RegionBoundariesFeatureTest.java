package io.flutter.plugins.camera.features.regionboundaries;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertNull;
import static org.junit.Assert.assertTrue;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import android.hardware.camera2.CaptureRequest;
import android.os.Build.VERSION;
import android.os.Build.VERSION_CODES;
import android.util.Size;
import io.flutter.plugins.camera.CameraProperties;
import io.flutter.plugins.camera.utils.TestUtils;
import org.junit.Before;
import org.junit.Test;

public class RegionBoundariesFeatureTest {
  private Size mockSize;

  @Before
  public void before() {
    mockSize = mock(Size.class);

    when(mockSize.getHeight()).thenReturn(640);
    when(mockSize.getWidth()).thenReturn(480);
  }

  @Test
  public void
      ctor_should_initialize_with_sensor_info_pixel_array_size_when_running_pre_android_p() {
    updateSdkVersion(VERSION_CODES.O_MR1);

    try {
      CameraProperties mockCameraProperties = mock(CameraProperties.class);
      CaptureRequest.Builder mockBuilder = mock(CaptureRequest.Builder.class);

      when(mockCameraProperties.getSensorInfoPixelArraySize()).thenReturn(mockSize);

      RegionBoundariesFeature regionBoundariesFeature =
          new RegionBoundariesFeature(mockCameraProperties, mockBuilder);

      assertEquals(mockSize, regionBoundariesFeature.getValue());
      verify(mockCameraProperties, never()).getSensorInfoPreCorrectionActiveArraySize();
      verify(mockCameraProperties, never()).getSensorInfoActiveArraySize();
    } finally {
      updateSdkVersion(0);
    }
  }

  @Test
  public void
      ctor_should_initialize_with_sensor_info_pixel_array_size_when_distortion_correction_is_null() {
    updateSdkVersion(VERSION_CODES.P);

    try {
      CameraProperties mockCameraProperties = mock(CameraProperties.class);
      CaptureRequest.Builder mockBuilder = mock(CaptureRequest.Builder.class);

      when(mockCameraProperties.getDistortionCorrectionAvailableModes()).thenReturn(null);
      when(mockCameraProperties.getSensorInfoPixelArraySize()).thenReturn(mockSize);

      RegionBoundariesFeature regionBoundariesFeature =
          new RegionBoundariesFeature(mockCameraProperties, mockBuilder);

      assertEquals(mockSize, regionBoundariesFeature.getValue());
      verify(mockCameraProperties, never()).getSensorInfoPreCorrectionActiveArraySize();
      verify(mockCameraProperties, never()).getSensorInfoActiveArraySize();
    } finally {
      updateSdkVersion(0);
    }
  }

  @Test
  public void
      ctor_should_initialize_with_sensor_info_pixel_array_size_when_distortion_correction_is_off() {
    updateSdkVersion(VERSION_CODES.P);

    try {
      CameraProperties mockCameraProperties = mock(CameraProperties.class);
      CaptureRequest.Builder mockBuilder = mock(CaptureRequest.Builder.class);

      when(mockCameraProperties.getDistortionCorrectionAvailableModes())
          .thenReturn(new int[] {CaptureRequest.DISTORTION_CORRECTION_MODE_OFF});
      when(mockCameraProperties.getSensorInfoPixelArraySize()).thenReturn(mockSize);

      RegionBoundariesFeature regionBoundariesFeature =
          new RegionBoundariesFeature(mockCameraProperties, mockBuilder);

      assertEquals(mockSize, regionBoundariesFeature.getValue());
      verify(mockCameraProperties, never()).getSensorInfoPreCorrectionActiveArraySize();
      verify(mockCameraProperties, never()).getSensorInfoActiveArraySize();
    } finally {
      updateSdkVersion(0);
    }
  }

  @Test
  public void
      ctor_should_initialize_with_sensor_info_pre_correction_active_array_size_when_distortion_correction_mode_is_set_to_null() {
    updateSdkVersion(VERSION_CODES.P);

    try {
      CameraProperties mockCameraProperties = mock(CameraProperties.class);
      CaptureRequest.Builder mockBuilder = mock(CaptureRequest.Builder.class);

      when(mockCameraProperties.getDistortionCorrectionAvailableModes())
          .thenReturn(
              new int[] {
                CaptureRequest.DISTORTION_CORRECTION_MODE_OFF,
                CaptureRequest.DISTORTION_CORRECTION_MODE_FAST
              });

      when(mockBuilder.get(CaptureRequest.DISTORTION_CORRECTION_MODE)).thenReturn(null);
      when(mockCameraProperties.getSensorInfoPreCorrectionActiveArraySize()).thenReturn(null);

      RegionBoundariesFeature regionBoundariesFeature =
          new RegionBoundariesFeature(mockCameraProperties, mockBuilder);

      assertNull(regionBoundariesFeature.getValue());
      verify(mockCameraProperties, never()).getSensorInfoPixelArraySize();
      verify(mockCameraProperties, never()).getSensorInfoActiveArraySize();
    } finally {
      updateSdkVersion(0);
    }
  }

  @Test
  public void
      ctor_should_initialize_with_sensor_info_pre_correction_active_array_size_when_distortion_correction_mode_is_set_off() {
    updateSdkVersion(VERSION_CODES.P);

    try {
      CameraProperties mockCameraProperties = mock(CameraProperties.class);
      CaptureRequest.Builder mockBuilder = mock(CaptureRequest.Builder.class);

      when(mockCameraProperties.getDistortionCorrectionAvailableModes())
          .thenReturn(
              new int[] {
                CaptureRequest.DISTORTION_CORRECTION_MODE_OFF,
                CaptureRequest.DISTORTION_CORRECTION_MODE_FAST
              });

      when(mockBuilder.get(CaptureRequest.DISTORTION_CORRECTION_MODE))
          .thenReturn(CaptureRequest.DISTORTION_CORRECTION_MODE_OFF);
      when(mockCameraProperties.getSensorInfoPreCorrectionActiveArraySize()).thenReturn(null);

      RegionBoundariesFeature regionBoundariesFeature =
          new RegionBoundariesFeature(mockCameraProperties, mockBuilder);

      assertNull(regionBoundariesFeature.getValue());
      verify(mockCameraProperties, never()).getSensorInfoPixelArraySize();
      verify(mockCameraProperties, never()).getSensorInfoActiveArraySize();
    } finally {
      updateSdkVersion(0);
    }
  }

  @Test
  public void
      ctor_should_initialize_with_sensor_info_active_array_size_when_distortion_correction_mode_is_set() {
    updateSdkVersion(VERSION_CODES.P);

    try {
      CameraProperties mockCameraProperties = mock(CameraProperties.class);
      CaptureRequest.Builder mockBuilder = mock(CaptureRequest.Builder.class);

      when(mockCameraProperties.getDistortionCorrectionAvailableModes())
          .thenReturn(
              new int[] {
                CaptureRequest.DISTORTION_CORRECTION_MODE_OFF,
                CaptureRequest.DISTORTION_CORRECTION_MODE_FAST
              });

      when(mockBuilder.get(CaptureRequest.DISTORTION_CORRECTION_MODE))
          .thenReturn(CaptureRequest.DISTORTION_CORRECTION_MODE_FAST);
      when(mockCameraProperties.getSensorInfoActiveArraySize()).thenReturn(null);

      RegionBoundariesFeature regionBoundariesFeature =
          new RegionBoundariesFeature(mockCameraProperties, mockBuilder);

      assertNull(regionBoundariesFeature.getValue());
      verify(mockCameraProperties, never()).getSensorInfoPixelArraySize();
      verify(mockCameraProperties, never()).getSensorInfoPreCorrectionActiveArraySize();
    } finally {
      updateSdkVersion(0);
    }
  }

  @Test
  public void getDebugName_should_return_the_name_of_the_feature() {
    CameraProperties mockCameraProperties = mock(CameraProperties.class);
    CaptureRequest.Builder mockBuilder = mock(CaptureRequest.Builder.class);
    RegionBoundariesFeature regionBoundariesFeature =
        new RegionBoundariesFeature(mockCameraProperties, mockBuilder);

    assertEquals("RegionBoundariesFeature", regionBoundariesFeature.getDebugName());
  }

  @Test
  public void getValue_should_return_null_if_not_set() {
    CameraProperties mockCameraProperties = mock(CameraProperties.class);
    CaptureRequest.Builder mockBuilder = mock(CaptureRequest.Builder.class);
    RegionBoundariesFeature regionBoundariesFeature =
        new RegionBoundariesFeature(mockCameraProperties, mockBuilder);

    assertNull(regionBoundariesFeature.getValue());
  }

  @Test
  public void getValue_should_echo_setValue() {
    CameraProperties mockCameraProperties = mock(CameraProperties.class);
    CaptureRequest.Builder mockBuilder = mock(CaptureRequest.Builder.class);
    RegionBoundariesFeature regionBoundariesFeature =
        new RegionBoundariesFeature(mockCameraProperties, mockBuilder);

    regionBoundariesFeature.setValue(mockSize);

    assertEquals(mockSize, regionBoundariesFeature.getValue());
  }

  @Test
  public void checkIsSupport_returns_true() {
    CameraProperties mockCameraProperties = mock(CameraProperties.class);
    CaptureRequest.Builder mockBuilder = mock(CaptureRequest.Builder.class);
    RegionBoundariesFeature regionBoundariesFeature =
        new RegionBoundariesFeature(mockCameraProperties, mockBuilder);

    assertTrue(regionBoundariesFeature.checkIsSupported());
  }

  private static void updateSdkVersion(int version) {
    TestUtils.setFinalStatic(VERSION.class,"SDK_INT", version);
  }
}
