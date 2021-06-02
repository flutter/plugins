// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camera.types;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertNull;
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

public class CameraRegionsFactoryTest {
  private Size mockSize;

  @Before
  public void before() {
    mockSize = mock(Size.class);

    when(mockSize.getHeight()).thenReturn(640);
    when(mockSize.getWidth()).thenReturn(480);
  }

  @Test
  public void
      create_should_initialize_with_sensor_info_pixel_array_size_when_running_pre_android_p() {
    updateSdkVersion(VERSION_CODES.O_MR1);

    try {
      CameraProperties mockCameraProperties = mock(CameraProperties.class);
      CaptureRequest.Builder mockBuilder = mock(CaptureRequest.Builder.class);

      when(mockCameraProperties.getSensorInfoPixelArraySize()).thenReturn(mockSize);

      CameraRegions cameraRegions = CameraRegions.Factory.create(mockCameraProperties, mockBuilder);

      assertEquals(mockSize, cameraRegions.getBoundaries());
      verify(mockCameraProperties, never()).getSensorInfoPreCorrectionActiveArraySize();
      verify(mockCameraProperties, never()).getSensorInfoActiveArraySize();
    } finally {
      updateSdkVersion(0);
    }
  }

  @Test
  public void
      create_should_initialize_with_sensor_info_pixel_array_size_when_distortion_correction_is_null() {
    updateSdkVersion(VERSION_CODES.P);

    try {
      CameraProperties mockCameraProperties = mock(CameraProperties.class);
      CaptureRequest.Builder mockBuilder = mock(CaptureRequest.Builder.class);

      when(mockCameraProperties.getDistortionCorrectionAvailableModes()).thenReturn(null);
      when(mockCameraProperties.getSensorInfoPixelArraySize()).thenReturn(mockSize);

      CameraRegions cameraRegions = CameraRegions.Factory.create(mockCameraProperties, mockBuilder);

      assertEquals(mockSize, cameraRegions.getBoundaries());
      verify(mockCameraProperties, never()).getSensorInfoPreCorrectionActiveArraySize();
      verify(mockCameraProperties, never()).getSensorInfoActiveArraySize();
    } finally {
      updateSdkVersion(0);
    }
  }

  @Test
  public void
      create_should_initialize_with_sensor_info_pixel_array_size_when_distortion_correction_is_off() {
    updateSdkVersion(VERSION_CODES.P);

    try {
      CameraProperties mockCameraProperties = mock(CameraProperties.class);
      CaptureRequest.Builder mockBuilder = mock(CaptureRequest.Builder.class);

      when(mockCameraProperties.getDistortionCorrectionAvailableModes())
          .thenReturn(new int[] {CaptureRequest.DISTORTION_CORRECTION_MODE_OFF});
      when(mockCameraProperties.getSensorInfoPixelArraySize()).thenReturn(mockSize);

      CameraRegions cameraRegions = CameraRegions.Factory.create(mockCameraProperties, mockBuilder);

      assertEquals(mockSize, cameraRegions.getBoundaries());
      verify(mockCameraProperties, never()).getSensorInfoPreCorrectionActiveArraySize();
      verify(mockCameraProperties, never()).getSensorInfoActiveArraySize();
    } finally {
      updateSdkVersion(0);
    }
  }

  @Test
  public void
      create_should_initialize_with_sensor_info_pre_correction_active_array_size_when_distortion_correction_mode_is_set_to_null() {
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

      CameraRegions cameraRegions = CameraRegions.Factory.create(mockCameraProperties, mockBuilder);

      assertNull(cameraRegions.getBoundaries());
      verify(mockCameraProperties, never()).getSensorInfoPixelArraySize();
      verify(mockCameraProperties, never()).getSensorInfoActiveArraySize();
    } finally {
      updateSdkVersion(0);
    }
  }

  @Test
  public void
      create_should_initialize_with_sensor_info_pre_correction_active_array_size_when_distortion_correction_mode_is_set_off() {
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

      CameraRegions cameraRegions = CameraRegions.Factory.create(mockCameraProperties, mockBuilder);

      assertNull(cameraRegions.getBoundaries());
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

      CameraRegions cameraRegions = CameraRegions.Factory.create(mockCameraProperties, mockBuilder);

      assertNull(cameraRegions.getBoundaries());
      verify(mockCameraProperties, never()).getSensorInfoPixelArraySize();
      verify(mockCameraProperties, never()).getSensorInfoPreCorrectionActiveArraySize();
    } finally {
      updateSdkVersion(0);
    }
  }

  @Test
  public void getBoundaries_should_return_null_if_not_set() {
    CameraProperties mockCameraProperties = mock(CameraProperties.class);
    CaptureRequest.Builder mockBuilder = mock(CaptureRequest.Builder.class);
    CameraRegions cameraRegions = CameraRegions.Factory.create(mockCameraProperties, mockBuilder);

    assertNull(cameraRegions.getBoundaries());
  }

  private static void updateSdkVersion(int version) {
    TestUtils.setFinalStatic(VERSION.class, "SDK_INT", version);
  }
}
