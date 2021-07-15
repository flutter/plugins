// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
package io.flutter.plugins.camera;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertTrue;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyInt;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.mockStatic;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import android.graphics.Rect;
import android.hardware.camera2.CaptureRequest;
import android.hardware.camera2.params.MeteringRectangle;
import android.os.Build;
import android.util.Size;
import io.flutter.plugins.camera.utils.TestUtils;
import org.junit.Before;
import org.junit.Test;
import org.mockito.MockedStatic;
import org.mockito.invocation.InvocationOnMock;
import org.mockito.stubbing.Answer;

public class CameraRegionUtilsTest {

  Size mockCameraBoundaries;

  @Before
  public void setUp() {
    this.mockCameraBoundaries = mock(Size.class);
    when(this.mockCameraBoundaries.getWidth()).thenReturn(100);
    when(this.mockCameraBoundaries.getHeight()).thenReturn(100);
  }

  @Test
  public void
      getCameraBoundaries_should_return_sensor_info_pixel_array_size_when_running_pre_android_p() {
    updateSdkVersion(Build.VERSION_CODES.O_MR1);

    try {
      CameraProperties mockCameraProperties = mock(CameraProperties.class);
      CaptureRequest.Builder mockBuilder = mock(CaptureRequest.Builder.class);
      when(mockCameraProperties.getSensorInfoPixelArraySize()).thenReturn(mockCameraBoundaries);

      Size result = CameraRegionUtils.getCameraBoundaries(mockCameraProperties, mockBuilder);

      assertEquals(mockCameraBoundaries, result);
      verify(mockCameraProperties, never()).getSensorInfoPreCorrectionActiveArraySize();
      verify(mockCameraProperties, never()).getSensorInfoActiveArraySize();
    } finally {
      updateSdkVersion(0);
    }
  }

  @Test
  public void
      getCameraBoundaries_should_return_sensor_info_pixel_array_size_when_distortion_correction_is_null() {
    updateSdkVersion(Build.VERSION_CODES.P);

    try {
      CameraProperties mockCameraProperties = mock(CameraProperties.class);
      CaptureRequest.Builder mockBuilder = mock(CaptureRequest.Builder.class);

      when(mockCameraProperties.getDistortionCorrectionAvailableModes()).thenReturn(null);
      when(mockCameraProperties.getSensorInfoPixelArraySize()).thenReturn(mockCameraBoundaries);

      Size result = CameraRegionUtils.getCameraBoundaries(mockCameraProperties, mockBuilder);

      assertEquals(mockCameraBoundaries, result);
      verify(mockCameraProperties, never()).getSensorInfoPreCorrectionActiveArraySize();
      verify(mockCameraProperties, never()).getSensorInfoActiveArraySize();
    } finally {
      updateSdkVersion(0);
    }
  }

  @Test
  public void
      getCameraBoundaries_should_return_sensor_info_pixel_array_size_when_distortion_correction_is_off() {
    updateSdkVersion(Build.VERSION_CODES.P);

    try {
      CameraProperties mockCameraProperties = mock(CameraProperties.class);
      CaptureRequest.Builder mockBuilder = mock(CaptureRequest.Builder.class);

      when(mockCameraProperties.getDistortionCorrectionAvailableModes())
          .thenReturn(new int[] {CaptureRequest.DISTORTION_CORRECTION_MODE_OFF});
      when(mockCameraProperties.getSensorInfoPixelArraySize()).thenReturn(mockCameraBoundaries);

      Size result = CameraRegionUtils.getCameraBoundaries(mockCameraProperties, mockBuilder);

      assertEquals(mockCameraBoundaries, result);
      verify(mockCameraProperties, never()).getSensorInfoPreCorrectionActiveArraySize();
      verify(mockCameraProperties, never()).getSensorInfoActiveArraySize();
    } finally {
      updateSdkVersion(0);
    }
  }

  @Test
  public void
      getCameraBoundaries_should_return_info_pre_correction_active_array_size_when_distortion_correction_mode_is_set_to_null() {
    updateSdkVersion(Build.VERSION_CODES.P);

    try {
      CameraProperties mockCameraProperties = mock(CameraProperties.class);
      CaptureRequest.Builder mockBuilder = mock(CaptureRequest.Builder.class);
      Rect mockSensorInfoPreCorrectionActiveArraySize = mock(Rect.class);
      when(mockSensorInfoPreCorrectionActiveArraySize.width()).thenReturn(100);
      when(mockSensorInfoPreCorrectionActiveArraySize.height()).thenReturn(100);

      when(mockCameraProperties.getDistortionCorrectionAvailableModes())
          .thenReturn(
              new int[] {
                CaptureRequest.DISTORTION_CORRECTION_MODE_OFF,
                CaptureRequest.DISTORTION_CORRECTION_MODE_FAST
              });
      when(mockBuilder.get(CaptureRequest.DISTORTION_CORRECTION_MODE)).thenReturn(null);
      when(mockCameraProperties.getSensorInfoPreCorrectionActiveArraySize())
          .thenReturn(mockSensorInfoPreCorrectionActiveArraySize);

      try (MockedStatic<CameraRegionUtils.SizeFactory> mockedSizeFactory =
          mockStatic(CameraRegionUtils.SizeFactory.class)) {
        mockedSizeFactory
            .when(() -> CameraRegionUtils.SizeFactory.create(anyInt(), anyInt()))
            .thenAnswer(
                (Answer<Size>)
                    invocation -> {
                      Size mockSize = mock(Size.class);
                      when(mockSize.getWidth()).thenReturn(invocation.getArgument(0));
                      when(mockSize.getHeight()).thenReturn(invocation.getArgument(1));
                      return mockSize;
                    });

        Size result = CameraRegionUtils.getCameraBoundaries(mockCameraProperties, mockBuilder);

        assertEquals(100, result.getWidth());
        assertEquals(100, result.getHeight());
        verify(mockCameraProperties, never()).getSensorInfoPixelArraySize();
        verify(mockCameraProperties, never()).getSensorInfoActiveArraySize();
      }
    } finally {
      updateSdkVersion(0);
    }
  }

  @Test
  public void
      getCameraBoundaries_should_return_info_pre_correction_active_array_size_when_distortion_correction_mode_is_set_to_off() {
    updateSdkVersion(Build.VERSION_CODES.P);

    try {
      CameraProperties mockCameraProperties = mock(CameraProperties.class);
      CaptureRequest.Builder mockBuilder = mock(CaptureRequest.Builder.class);
      Rect mockSensorInfoPreCorrectionActiveArraySize = mock(Rect.class);
      when(mockSensorInfoPreCorrectionActiveArraySize.width()).thenReturn(100);
      when(mockSensorInfoPreCorrectionActiveArraySize.height()).thenReturn(100);

      when(mockCameraProperties.getDistortionCorrectionAvailableModes())
          .thenReturn(
              new int[] {
                CaptureRequest.DISTORTION_CORRECTION_MODE_OFF,
                CaptureRequest.DISTORTION_CORRECTION_MODE_FAST
              });

      when(mockBuilder.get(CaptureRequest.DISTORTION_CORRECTION_MODE))
          .thenReturn(CaptureRequest.DISTORTION_CORRECTION_MODE_OFF);
      when(mockCameraProperties.getSensorInfoPreCorrectionActiveArraySize())
          .thenReturn(mockSensorInfoPreCorrectionActiveArraySize);

      try (MockedStatic<CameraRegionUtils.SizeFactory> mockedSizeFactory =
          mockStatic(CameraRegionUtils.SizeFactory.class)) {
        mockedSizeFactory
            .when(() -> CameraRegionUtils.SizeFactory.create(anyInt(), anyInt()))
            .thenAnswer(
                (Answer<Size>)
                    invocation -> {
                      Size mockSize = mock(Size.class);
                      when(mockSize.getWidth()).thenReturn(invocation.getArgument(0));
                      when(mockSize.getHeight()).thenReturn(invocation.getArgument(1));
                      return mockSize;
                    });

        Size result = CameraRegionUtils.getCameraBoundaries(mockCameraProperties, mockBuilder);

        assertEquals(100, result.getWidth());
        assertEquals(100, result.getHeight());
        verify(mockCameraProperties, never()).getSensorInfoPixelArraySize();
        verify(mockCameraProperties, never()).getSensorInfoActiveArraySize();
      }
    } finally {
      updateSdkVersion(0);
    }
  }

  @Test
  public void
      getCameraBoundaries_should_return_sensor_info_active_array_size_when_distortion_correction_mode_is_set() {
    updateSdkVersion(Build.VERSION_CODES.P);

    try {
      CameraProperties mockCameraProperties = mock(CameraProperties.class);
      CaptureRequest.Builder mockBuilder = mock(CaptureRequest.Builder.class);
      Rect mockSensorInfoActiveArraySize = mock(Rect.class);
      when(mockSensorInfoActiveArraySize.width()).thenReturn(100);
      when(mockSensorInfoActiveArraySize.height()).thenReturn(100);

      when(mockCameraProperties.getDistortionCorrectionAvailableModes())
          .thenReturn(
              new int[] {
                CaptureRequest.DISTORTION_CORRECTION_MODE_OFF,
                CaptureRequest.DISTORTION_CORRECTION_MODE_FAST
              });

      when(mockBuilder.get(CaptureRequest.DISTORTION_CORRECTION_MODE))
          .thenReturn(CaptureRequest.DISTORTION_CORRECTION_MODE_FAST);
      when(mockCameraProperties.getSensorInfoActiveArraySize())
          .thenReturn(mockSensorInfoActiveArraySize);

      try (MockedStatic<CameraRegionUtils.SizeFactory> mockedSizeFactory =
          mockStatic(CameraRegionUtils.SizeFactory.class)) {
        mockedSizeFactory
            .when(() -> CameraRegionUtils.SizeFactory.create(anyInt(), anyInt()))
            .thenAnswer(
                (Answer<Size>)
                    invocation -> {
                      Size mockSize = mock(Size.class);
                      when(mockSize.getWidth()).thenReturn(invocation.getArgument(0));
                      when(mockSize.getHeight()).thenReturn(invocation.getArgument(1));
                      return mockSize;
                    });

        Size result = CameraRegionUtils.getCameraBoundaries(mockCameraProperties, mockBuilder);

        assertEquals(100, result.getWidth());
        assertEquals(100, result.getHeight());
        verify(mockCameraProperties, never()).getSensorInfoPixelArraySize();
        verify(mockCameraProperties, never()).getSensorInfoPreCorrectionActiveArraySize();
      }
    } finally {
      updateSdkVersion(0);
    }
  }

  @Test(expected = AssertionError.class)
  public void getMeteringRectangleForPoint_should_throw_for_x_upper_bound() {
    CameraRegionUtils.convertPointToMeteringRectangle(this.mockCameraBoundaries, 1.5, 0);
  }

  @Test(expected = AssertionError.class)
  public void getMeteringRectangleForPoint_should_throw_for_x_lower_bound() {
    CameraRegionUtils.convertPointToMeteringRectangle(this.mockCameraBoundaries, -0.5, 0);
  }

  @Test(expected = AssertionError.class)
  public void getMeteringRectangleForPoint_should_throw_for_y_upper_bound() {
    CameraRegionUtils.convertPointToMeteringRectangle(this.mockCameraBoundaries, 0, 1.5);
  }

  @Test(expected = AssertionError.class)
  public void getMeteringRectangleForPoint_should_throw_for_y_lower_bound() {
    CameraRegionUtils.convertPointToMeteringRectangle(this.mockCameraBoundaries, 0, -0.5);
  }

  @Test
  public void getMeteringRectangleForPoint_should_return_valid_MeteringRectangle() {
    try (MockedStatic<CameraRegionUtils.MeteringRectangleFactory> mockedMeteringRectangleFactory =
        mockStatic(CameraRegionUtils.MeteringRectangleFactory.class)) {

      mockedMeteringRectangleFactory
          .when(
              () ->
                  CameraRegionUtils.MeteringRectangleFactory.create(
                      anyInt(), anyInt(), anyInt(), anyInt(), anyInt()))
          .thenAnswer(
              new Answer<MeteringRectangle>() {
                @Override
                public MeteringRectangle answer(InvocationOnMock createInvocation)
                    throws Throwable {
                  MeteringRectangle mockMeteringRectangle = mock(MeteringRectangle.class);
                  when(mockMeteringRectangle.getX()).thenReturn(createInvocation.getArgument(0));
                  when(mockMeteringRectangle.getY()).thenReturn(createInvocation.getArgument(1));
                  when(mockMeteringRectangle.getWidth())
                      .thenReturn(createInvocation.getArgument(2));
                  when(mockMeteringRectangle.getHeight())
                      .thenReturn(createInvocation.getArgument(3));
                  when(mockMeteringRectangle.getMeteringWeight())
                      .thenReturn(createInvocation.getArgument(4));
                  when(mockMeteringRectangle.equals(any()))
                      .thenAnswer(
                          new Answer<Boolean>() {
                            @Override
                            public Boolean answer(InvocationOnMock equalsInvocation)
                                throws Throwable {
                              MeteringRectangle otherMockMeteringRectangle =
                                  equalsInvocation.getArgument(0);
                              return mockMeteringRectangle.getX()
                                      == otherMockMeteringRectangle.getX()
                                  && mockMeteringRectangle.getY()
                                      == otherMockMeteringRectangle.getY()
                                  && mockMeteringRectangle.getWidth()
                                      == otherMockMeteringRectangle.getWidth()
                                  && mockMeteringRectangle.getHeight()
                                      == otherMockMeteringRectangle.getHeight()
                                  && mockMeteringRectangle.getMeteringWeight()
                                      == otherMockMeteringRectangle.getMeteringWeight();
                            }
                          });
                  return mockMeteringRectangle;
                }
              });

      MeteringRectangle r;
      // Center
      r = CameraRegionUtils.convertPointToMeteringRectangle(this.mockCameraBoundaries, 0.5, 0.5);
      assertTrue(CameraRegionUtils.MeteringRectangleFactory.create(45, 45, 10, 10, 1).equals(r));

      // Top left
      r = CameraRegionUtils.convertPointToMeteringRectangle(this.mockCameraBoundaries, 0.0, 0.0);
      assertTrue(CameraRegionUtils.MeteringRectangleFactory.create(0, 0, 10, 10, 1).equals(r));

      // Bottom right
      r = CameraRegionUtils.convertPointToMeteringRectangle(this.mockCameraBoundaries, 1.0, 1.0);
      assertTrue(CameraRegionUtils.MeteringRectangleFactory.create(89, 89, 10, 10, 1).equals(r));

      // Top left
      r = CameraRegionUtils.convertPointToMeteringRectangle(this.mockCameraBoundaries, 0.0, 1.0);
      assertTrue(CameraRegionUtils.MeteringRectangleFactory.create(0, 89, 10, 10, 1).equals(r));

      // Top right
      r = CameraRegionUtils.convertPointToMeteringRectangle(this.mockCameraBoundaries, 1.0, 0.0);
      assertTrue(CameraRegionUtils.MeteringRectangleFactory.create(89, 0, 10, 10, 1).equals(r));
    }
  }

  @Test(expected = AssertionError.class)
  public void getMeteringRectangleForPoint_should_throw_for_0_width_boundary() {
    new io.flutter.plugins.camera.CameraRegions(new Size(0, 50));
  }

  @Test(expected = AssertionError.class)
  public void getMeteringRectangleForPoint_should_throw_for_0_height_boundary() {
    new io.flutter.plugins.camera.CameraRegions(new Size(100, 0));
  }

  private static void updateSdkVersion(int version) {
    TestUtils.setFinalStatic(Build.VERSION.class, "SDK_INT", version);
  }
}
