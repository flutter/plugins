// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camera.features.exposurepoint;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertFalse;
import static org.junit.Assert.assertTrue;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.times;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import android.hardware.camera2.CaptureRequest;
import android.hardware.camera2.params.MeteringRectangle;
import io.flutter.plugins.camera.CameraProperties;
import io.flutter.plugins.camera.features.Point;
import io.flutter.plugins.camera.features.regionboundaries.CameraRegions;
import org.junit.Test;

public class ExposurePointFeatureTest {
  @Test
  public void getDebugName_should_return_the_name_of_the_feature() {
    CameraProperties mockCameraProperties = mock(CameraProperties.class);
    ExposurePointFeature exposurePointFeature =
        new ExposurePointFeature(mockCameraProperties, () -> null);

    assertEquals("ExposurePointFeature", exposurePointFeature.getDebugName());
  }

  @Test
  public void getValue_should_return_default_point_if_not_set() {
    CameraProperties mockCameraProperties = mock(CameraProperties.class);
    ExposurePointFeature exposurePointFeature =
        new ExposurePointFeature(mockCameraProperties, () -> null);
    Point expectedPoint = new Point(0.0, 0.0);
    Point actualPoint = exposurePointFeature.getValue();

    assertEquals(expectedPoint.x, actualPoint.x);
    assertEquals(expectedPoint.y, actualPoint.y);
  }

  @Test
  public void getValue_should_echo_the_set_value() {
    CameraProperties mockCameraProperties = mock(CameraProperties.class);
    CameraRegions mockCameraRegions = mock(CameraRegions.class);
    ExposurePointFeature exposurePointFeature =
        new ExposurePointFeature(mockCameraProperties, () -> mockCameraRegions);
    Point expectedPoint = new Point(0.0, 0.0);

    exposurePointFeature.setValue(expectedPoint);
    Point actualPoint = exposurePointFeature.getValue();

    assertEquals(expectedPoint, actualPoint);
  }

  @Test
  public void setValue_should_reset_point_when_x_coord_is_null() {
    CameraProperties mockCameraProperties = mock(CameraProperties.class);
    CameraRegions mockCameraRegions = mock(CameraRegions.class);
    ExposurePointFeature exposurePointFeature =
        new ExposurePointFeature(mockCameraProperties, () -> mockCameraRegions);

    exposurePointFeature.setValue(new Point(null, 0.0));

    verify(mockCameraRegions, times(1)).resetAutoExposureMeteringRectangle();
  }

  @Test
  public void setValue_should_reset_point_when_y_coord_is_null() {
    CameraProperties mockCameraProperties = mock(CameraProperties.class);
    CameraRegions mockCameraRegions = mock(CameraRegions.class);
    ExposurePointFeature exposurePointFeature =
        new ExposurePointFeature(mockCameraProperties, () -> mockCameraRegions);

    exposurePointFeature.setValue(new Point(0.0, null));

    verify(mockCameraRegions, times(1)).resetAutoExposureMeteringRectangle();
  }

  @Test
  public void setValue_should_reset_point_when_valid_coords_are_supplied() {
    CameraProperties mockCameraProperties = mock(CameraProperties.class);
    CameraRegions mockCameraRegions = mock(CameraRegions.class);
    ExposurePointFeature exposurePointFeature =
        new ExposurePointFeature(mockCameraProperties, () -> mockCameraRegions);
    Point point = new Point(0.0, 0.0);

    exposurePointFeature.setValue(point);

    verify(mockCameraRegions, times(1)).setAutoExposureMeteringRectangleFromPoint(point.x, point.y);
  }

  @Test
  public void checkIsSupported_should_return_false_when_max_regions_is_null() {
    CameraProperties mockCameraProperties = mock(CameraProperties.class);
    ExposurePointFeature exposurePointFeature =
        new ExposurePointFeature(mockCameraProperties, () -> null);

    when(mockCameraProperties.getControlMaxRegionsAutoExposure()).thenReturn(null);

    assertFalse(exposurePointFeature.checkIsSupported());
  }

  @Test
  public void checkIsSupported_should_return_false_when_max_regions_is_zero() {
    CameraProperties mockCameraProperties = mock(CameraProperties.class);
    ExposurePointFeature exposurePointFeature =
        new ExposurePointFeature(mockCameraProperties, () -> null);

    when(mockCameraProperties.getControlMaxRegionsAutoExposure()).thenReturn(0);

    assertFalse(exposurePointFeature.checkIsSupported());
  }

  @Test
  public void checkIsSupported_should_return_true_when_max_regions_is_bigger_then_zero() {
    CameraProperties mockCameraProperties = mock(CameraProperties.class);
    ExposurePointFeature exposurePointFeature =
        new ExposurePointFeature(mockCameraProperties, () -> null);

    when(mockCameraProperties.getControlMaxRegionsAutoExposure()).thenReturn(1);

    assertTrue(exposurePointFeature.checkIsSupported());
  }

  @Test
  public void updateBuilder_should_return_when_checkIsSupported_is_false() {
    CameraProperties mockCameraProperties = mock(CameraProperties.class);
    CameraRegions mockCameraRegions = mock(CameraRegions.class);
    ExposurePointFeature exposurePointFeature =
        new ExposurePointFeature(mockCameraProperties, () -> mockCameraRegions);

    when(mockCameraProperties.getControlMaxRegionsAutoExposure()).thenReturn(0);

    exposurePointFeature.updateBuilder(null);

    verify(mockCameraRegions, never()).getAEMeteringRectangle();
  }

  @Test
  public void updateBuilder_should_set_ae_regions_to_null_when_ae_metering_rectangle_is_null() {
    CameraProperties mockCameraProperties = mock(CameraProperties.class);
    CameraRegions mockCameraRegions = mock(CameraRegions.class);
    CaptureRequest.Builder mockBuilder = mock(CaptureRequest.Builder.class);
    ExposurePointFeature exposurePointFeature =
        new ExposurePointFeature(mockCameraProperties, () -> mockCameraRegions);

    when(mockCameraProperties.getControlMaxRegionsAutoExposure()).thenReturn(1);
    when(mockCameraRegions.getAEMeteringRectangle()).thenReturn(null);

    exposurePointFeature.updateBuilder(mockBuilder);

    verify(mockBuilder, times(1)).set(CaptureRequest.CONTROL_AE_REGIONS, null);
  }

  @Test
  public void updateBuilder_should_set_ae_regions_with_metering_rectangle() {
    CameraProperties mockCameraProperties = mock(CameraProperties.class);
    CameraRegions mockCameraRegions = mock(CameraRegions.class);
    CaptureRequest.Builder mockBuilder = mock(CaptureRequest.Builder.class);
    ExposurePointFeature exposurePointFeature =
        new ExposurePointFeature(mockCameraProperties, () -> mockCameraRegions);
    MeteringRectangle meteringRectangle = new MeteringRectangle(0, 0, 0, 0, 0);

    when(mockCameraProperties.getControlMaxRegionsAutoExposure()).thenReturn(1);
    when(mockCameraRegions.getAEMeteringRectangle()).thenReturn(meteringRectangle);

    exposurePointFeature.updateBuilder(mockBuilder);

    verify(mockBuilder, times(1))
        .set(eq(CaptureRequest.CONTROL_AE_REGIONS), any(MeteringRectangle[].class));
  }

  @Test
  public void updateBuilder_should_silently_fail_when_exception_occurs() {
    CameraProperties mockCameraProperties = mock(CameraProperties.class);
    CameraRegions mockCameraRegions = mock(CameraRegions.class);
    CaptureRequest.Builder mockBuilder = mock(CaptureRequest.Builder.class);
    ExposurePointFeature exposurePointFeature =
        new ExposurePointFeature(mockCameraProperties, () -> mockCameraRegions);
    MeteringRectangle meteringRectangle = new MeteringRectangle(0, 0, 0, 0, 0);

    when(mockCameraProperties.getControlMaxRegionsAutoExposure()).thenReturn(1);
    when(mockCameraRegions.getAEMeteringRectangle()).thenThrow(new IllegalArgumentException());

    exposurePointFeature.updateBuilder(mockBuilder);

    verify(mockBuilder, never()).set(any(), any());
  }
}
