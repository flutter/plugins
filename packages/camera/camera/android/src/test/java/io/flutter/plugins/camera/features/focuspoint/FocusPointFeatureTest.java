// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camera.features.focuspoint;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertFalse;
import static org.junit.Assert.assertNull;
import static org.junit.Assert.assertTrue;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.isNull;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.times;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import android.hardware.camera2.CaptureRequest;
import android.hardware.camera2.params.MeteringRectangle;
import android.util.Size;
import io.flutter.plugins.camera.CameraProperties;
import io.flutter.plugins.camera.CameraRegionUtils;
import io.flutter.plugins.camera.features.Point;
import org.junit.Before;
import org.junit.Test;
import org.mockito.MockedStatic;
import org.mockito.Mockito;

public class FocusPointFeatureTest {

  Size mockCameraBoundaries;

  @Before
  public void setUp() {
    this.mockCameraBoundaries = mock(Size.class);
    when(this.mockCameraBoundaries.getWidth()).thenReturn(100);
    when(this.mockCameraBoundaries.getHeight()).thenReturn(100);
  }

  @Test
  public void getDebugName_should_return_the_name_of_the_feature() {
    CameraProperties mockCameraProperties = mock(CameraProperties.class);
    CameraRegionUtils mockCameraRegions = mock(CameraRegionUtils.class);
    FocusPointFeature focusPointFeature = new FocusPointFeature(mockCameraProperties);

    assertEquals("FocusPointFeature", focusPointFeature.getDebugName());
  }

  @Test
  public void getValue_should_return_null_if_not_set() {
    CameraProperties mockCameraProperties = mock(CameraProperties.class);
    FocusPointFeature focusPointFeature = new FocusPointFeature(mockCameraProperties);
    Point actualPoint = focusPointFeature.getValue();
    assertNull(focusPointFeature.getValue());
  }

  @Test
  public void getValue_should_echo_the_set_value() {
    CameraProperties mockCameraProperties = mock(CameraProperties.class);
    FocusPointFeature focusPointFeature = new FocusPointFeature(mockCameraProperties);
    focusPointFeature.setCameraBoundaries(this.mockCameraBoundaries);
    Point expectedPoint = new Point(0.0, 0.0);

    focusPointFeature.setValue(expectedPoint);
    Point actualPoint = focusPointFeature.getValue();

    assertEquals(expectedPoint, actualPoint);
  }

  @Test
  public void setValue_should_reset_point_when_x_coord_is_null() {
    CameraProperties mockCameraProperties = mock(CameraProperties.class);
    FocusPointFeature focusPointFeature = new FocusPointFeature(mockCameraProperties);
    focusPointFeature.setCameraBoundaries(this.mockCameraBoundaries);

    focusPointFeature.setValue(new Point(null, 0.0));

    assertNull(focusPointFeature.getValue());
  }

  @Test
  public void setValue_should_reset_point_when_y_coord_is_null() {
    CameraProperties mockCameraProperties = mock(CameraProperties.class);
    FocusPointFeature focusPointFeature = new FocusPointFeature(mockCameraProperties);
    focusPointFeature.setCameraBoundaries(this.mockCameraBoundaries);

    focusPointFeature.setValue(new Point(0.0, null));

    assertNull(focusPointFeature.getValue());
  }

  @Test
  public void setValue_should_set_point_when_valid_coords_are_supplied() {
    CameraProperties mockCameraProperties = mock(CameraProperties.class);
    FocusPointFeature focusPointFeature = new FocusPointFeature(mockCameraProperties);
    focusPointFeature.setCameraBoundaries(this.mockCameraBoundaries);
    Point point = new Point(0.0, 0.0);

    focusPointFeature.setValue(point);

    assertEquals(point, focusPointFeature.getValue());
  }

  @Test
  public void
      setValue_should_determine_metering_rectangle_when_valid_boundaries_and_coords_are_supplied() {
    CameraProperties mockCameraProperties = mock(CameraProperties.class);
    when(mockCameraProperties.getControlMaxRegionsAutoFocus()).thenReturn(1);
    FocusPointFeature focusPointFeature = new FocusPointFeature(mockCameraProperties);
    Size mockedCameraBoundaries = mock(Size.class);
    focusPointFeature.setCameraBoundaries(mockedCameraBoundaries);

    try (MockedStatic<CameraRegionUtils> mockedCameraRegionUtils =
        Mockito.mockStatic(CameraRegionUtils.class)) {

      focusPointFeature.setValue(new Point(0.5, 0.5));

      mockedCameraRegionUtils.verify(
          () -> CameraRegionUtils.convertPointToMeteringRectangle(mockedCameraBoundaries, 0.5, 0.5),
          times(1));
    }
  }

  @Test(expected = AssertionError.class)
  public void setValue_should_throw_assertion_error_when_no_valid_boundaries_are_set() {
    CameraProperties mockCameraProperties = mock(CameraProperties.class);
    when(mockCameraProperties.getControlMaxRegionsAutoFocus()).thenReturn(1);
    FocusPointFeature focusPointFeature = new FocusPointFeature(mockCameraProperties);

    try (MockedStatic<CameraRegionUtils> mockedCameraRegionUtils =
        Mockito.mockStatic(CameraRegionUtils.class)) {
      focusPointFeature.setValue(new Point(0.5, 0.5));
    }
  }

  @Test
  public void setValue_should_not_determine_metering_rectangle_when_null_coords_are_set() {
    CameraProperties mockCameraProperties = mock(CameraProperties.class);
    when(mockCameraProperties.getControlMaxRegionsAutoFocus()).thenReturn(1);
    FocusPointFeature focusPointFeature = new FocusPointFeature(mockCameraProperties);
    Size mockedCameraBoundaries = mock(Size.class);
    focusPointFeature.setCameraBoundaries(mockedCameraBoundaries);

    try (MockedStatic<CameraRegionUtils> mockedCameraRegionUtils =
        Mockito.mockStatic(CameraRegionUtils.class)) {

      focusPointFeature.setValue(null);
      focusPointFeature.setValue(new Point(null, 0.5));
      focusPointFeature.setValue(new Point(0.5, null));

      mockedCameraRegionUtils.verifyNoInteractions();
    }
  }

  @Test
  public void
      setCameraBoundaries_should_determine_metering_rectangle_when_valid_boundaries_and_coords_are_supplied() {
    CameraProperties mockCameraProperties = mock(CameraProperties.class);
    when(mockCameraProperties.getControlMaxRegionsAutoFocus()).thenReturn(1);
    FocusPointFeature focusPointFeature = new FocusPointFeature(mockCameraProperties);
    focusPointFeature.setCameraBoundaries(this.mockCameraBoundaries);
    focusPointFeature.setValue(new Point(0.5, 0.5));
    Size mockedCameraBoundaries = mock(Size.class);

    try (MockedStatic<CameraRegionUtils> mockedCameraRegionUtils =
        Mockito.mockStatic(CameraRegionUtils.class)) {

      focusPointFeature.setCameraBoundaries(mockedCameraBoundaries);

      mockedCameraRegionUtils.verify(
          () -> CameraRegionUtils.convertPointToMeteringRectangle(mockedCameraBoundaries, 0.5, 0.5),
          times(1));
    }
  }

  @Test
  public void checkIsSupported_should_return_false_when_max_regions_is_null() {
    CameraProperties mockCameraProperties = mock(CameraProperties.class);
    FocusPointFeature focusPointFeature = new FocusPointFeature(mockCameraProperties);
    focusPointFeature.setCameraBoundaries(new Size(100, 100));

    when(mockCameraProperties.getControlMaxRegionsAutoFocus()).thenReturn(null);

    assertFalse(focusPointFeature.checkIsSupported());
  }

  @Test
  public void checkIsSupported_should_return_false_when_max_regions_is_zero() {
    CameraProperties mockCameraProperties = mock(CameraProperties.class);
    FocusPointFeature focusPointFeature = new FocusPointFeature(mockCameraProperties);
    focusPointFeature.setCameraBoundaries(new Size(100, 100));

    when(mockCameraProperties.getControlMaxRegionsAutoFocus()).thenReturn(0);

    assertFalse(focusPointFeature.checkIsSupported());
  }

  @Test
  public void checkIsSupported_should_return_true_when_max_regions_is_bigger_then_zero() {
    CameraProperties mockCameraProperties = mock(CameraProperties.class);
    FocusPointFeature focusPointFeature = new FocusPointFeature(mockCameraProperties);
    focusPointFeature.setCameraBoundaries(new Size(100, 100));

    when(mockCameraProperties.getControlMaxRegionsAutoFocus()).thenReturn(1);

    assertTrue(focusPointFeature.checkIsSupported());
  }

  @Test
  public void updateBuilder_should_return_when_checkIsSupported_is_false() {
    CameraProperties mockCameraProperties = mock(CameraProperties.class);
    CaptureRequest.Builder mockCaptureRequestBuilder = mock(CaptureRequest.Builder.class);
    FocusPointFeature focusPointFeature = new FocusPointFeature(mockCameraProperties);

    when(mockCameraProperties.getControlMaxRegionsAutoFocus()).thenReturn(0);

    focusPointFeature.updateBuilder(mockCaptureRequestBuilder);

    verify(mockCaptureRequestBuilder, never()).set(any(), any());
  }

  @Test
  public void
      updateBuilder_should_set_metering_rectangle_when_valid_boundaries_and_coords_are_supplied() {
    CameraProperties mockCameraProperties = mock(CameraProperties.class);
    when(mockCameraProperties.getControlMaxRegionsAutoFocus()).thenReturn(1);
    CaptureRequest.Builder mockCaptureRequestBuilder = mock(CaptureRequest.Builder.class);
    FocusPointFeature focusPointFeature = new FocusPointFeature(mockCameraProperties);
    Size mockedCameraBoundaries = mock(Size.class);
    MeteringRectangle mockedMeteringRectangle = mock(MeteringRectangle.class);

    try (MockedStatic<CameraRegionUtils> mockedCameraRegionUtils =
        Mockito.mockStatic(CameraRegionUtils.class)) {
      mockedCameraRegionUtils
          .when(
              () ->
                  CameraRegionUtils.convertPointToMeteringRectangle(
                      mockedCameraBoundaries, 0.5, 0.5))
          .thenReturn(mockedMeteringRectangle);
      focusPointFeature.setCameraBoundaries(mockedCameraBoundaries);
      focusPointFeature.setValue(new Point(0.5, 0.5));

      focusPointFeature.updateBuilder(mockCaptureRequestBuilder);
    }

    verify(mockCaptureRequestBuilder, times(1))
        .set(CaptureRequest.CONTROL_AE_REGIONS, new MeteringRectangle[] {mockedMeteringRectangle});
  }

  @Test
  public void
      updateBuilder_should_not_set_metering_rectangle_when_no_valid_boundaries_are_supplied() {
    CameraProperties mockCameraProperties = mock(CameraProperties.class);
    when(mockCameraProperties.getControlMaxRegionsAutoFocus()).thenReturn(1);
    CaptureRequest.Builder mockCaptureRequestBuilder = mock(CaptureRequest.Builder.class);
    FocusPointFeature focusPointFeature = new FocusPointFeature(mockCameraProperties);
    MeteringRectangle mockedMeteringRectangle = mock(MeteringRectangle.class);

    focusPointFeature.updateBuilder(mockCaptureRequestBuilder);

    verify(mockCaptureRequestBuilder, times(1)).set(any(), isNull());
  }

  @Test
  public void updateBuilder_should_not_set_metering_rectangle_when_no_valid_coords_are_supplied() {
    CameraProperties mockCameraProperties = mock(CameraProperties.class);
    when(mockCameraProperties.getControlMaxRegionsAutoFocus()).thenReturn(1);
    CaptureRequest.Builder mockCaptureRequestBuilder = mock(CaptureRequest.Builder.class);
    FocusPointFeature focusPointFeature = new FocusPointFeature(mockCameraProperties);
    focusPointFeature.setCameraBoundaries(this.mockCameraBoundaries);

    focusPointFeature.setValue(null);
    focusPointFeature.updateBuilder(mockCaptureRequestBuilder);
    focusPointFeature.setValue(new Point(0d, null));
    focusPointFeature.updateBuilder(mockCaptureRequestBuilder);
    focusPointFeature.setValue(new Point(null, 0d));
    focusPointFeature.updateBuilder(mockCaptureRequestBuilder);
    verify(mockCaptureRequestBuilder, times(3)).set(any(), isNull());
  }
}
