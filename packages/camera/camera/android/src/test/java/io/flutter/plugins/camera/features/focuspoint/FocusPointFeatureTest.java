// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camera.features.focuspoint;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertFalse;
import static org.junit.Assert.assertTrue;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.times;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import io.flutter.plugins.camera.CameraProperties;
import io.flutter.plugins.camera.features.Point;
import io.flutter.plugins.camera.features.regionboundaries.CameraRegions;
import org.junit.Test;

public class FocusPointFeatureTest {
  @Test
  public void getDebugName_should_return_the_name_of_the_feature() {
    CameraProperties mockCameraProperties = mock(CameraProperties.class);
    FocusPointFeature focusPointFeature = new FocusPointFeature(mockCameraProperties, () -> null);

    assertEquals("FocusPointFeature", focusPointFeature.getDebugName());
  }

  @Test
  public void getValue_should_return_default_point_if_not_set() {
    CameraProperties mockCameraProperties = mock(CameraProperties.class);
    FocusPointFeature focusPointFeature = new FocusPointFeature(mockCameraProperties, () -> null);
    Point expectedPoint = new Point(0.0, 0.0);
    Point actualPoint = focusPointFeature.getValue();

    assertEquals(expectedPoint.x, actualPoint.x);
    assertEquals(expectedPoint.y, actualPoint.y);
  }

  @Test
  public void getValue_should_echo_the_set_value() {
    CameraProperties mockCameraProperties = mock(CameraProperties.class);
    CameraRegions mockCameraRegions = mock(CameraRegions.class);
    FocusPointFeature focusPointFeature =
        new FocusPointFeature(mockCameraProperties, () -> mockCameraRegions);
    Point expectedPoint = new Point(0.0, 0.0);

    focusPointFeature.setValue(expectedPoint);
    Point actualPoint = focusPointFeature.getValue();

    assertEquals(expectedPoint, actualPoint);
  }

  @Test
  public void setValue_should_reset_point_when_x_coord_is_null() {
    CameraProperties mockCameraProperties = mock(CameraProperties.class);
    CameraRegions mockCameraRegions = mock(CameraRegions.class);
    FocusPointFeature focusPointFeature =
        new FocusPointFeature(mockCameraProperties, () -> mockCameraRegions);

    focusPointFeature.setValue(new Point(null, 0.0));

    verify(mockCameraRegions, times(1)).resetAutoFocusMeteringRectangle();
  }

  @Test
  public void setValue_should_reset_point_when_y_coord_is_null() {
    CameraProperties mockCameraProperties = mock(CameraProperties.class);
    CameraRegions mockCameraRegions = mock(CameraRegions.class);
    FocusPointFeature focusPointFeature =
        new FocusPointFeature(mockCameraProperties, () -> mockCameraRegions);

    focusPointFeature.setValue(new Point(0.0, null));

    verify(mockCameraRegions, times(1)).resetAutoFocusMeteringRectangle();
  }

  @Test
  public void setValue_should_reset_point_when_valid_coords_are_supplied() {
    CameraProperties mockCameraProperties = mock(CameraProperties.class);
    CameraRegions mockCameraRegions = mock(CameraRegions.class);
    FocusPointFeature focusPointFeature =
        new FocusPointFeature(mockCameraProperties, () -> mockCameraRegions);
    Point point = new Point(0.0, 0.0);

    focusPointFeature.setValue(point);

    verify(mockCameraRegions, times(1)).setAutoFocusMeteringRectangleFromPoint(point.x, point.y);
  }

  @Test
  public void checkIsSupported_should_return_false_when_max_regions_is_null() {
    CameraProperties mockCameraProperties = mock(CameraProperties.class);
    FocusPointFeature focusPointFeature = new FocusPointFeature(mockCameraProperties, () -> null);

    when(mockCameraProperties.getControlMaxRegionsAutoFocus()).thenReturn(null);

    assertFalse(focusPointFeature.checkIsSupported());
  }

  @Test
  public void checkIsSupported_should_return_false_when_max_regions_is_zero() {
    CameraProperties mockCameraProperties = mock(CameraProperties.class);
    FocusPointFeature focusPointFeature = new FocusPointFeature(mockCameraProperties, () -> null);

    when(mockCameraProperties.getControlMaxRegionsAutoFocus()).thenReturn(0);

    assertFalse(focusPointFeature.checkIsSupported());
  }

  @Test
  public void checkIsSupported_should_return_true_when_max_regions_is_bigger_then_zero() {
    CameraProperties mockCameraProperties = mock(CameraProperties.class);
    FocusPointFeature focusPointFeature = new FocusPointFeature(mockCameraProperties, () -> null);

    when(mockCameraProperties.getControlMaxRegionsAutoFocus()).thenReturn(1);

    assertTrue(focusPointFeature.checkIsSupported());
  }
}
