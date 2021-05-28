// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camera.features.zoomlevel;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertNotNull;

import android.graphics.Rect;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.robolectric.RobolectricTestRunner;

@RunWith(RobolectricTestRunner.class)
public class ZoomUtilsTest {
  @Test
  public void setZoom_when_sensor_size_equals_zero_should_return_crop_region_of_zero() {
    final Rect sensorSize = new Rect(0, 0, 0, 0);
    final Rect computedZoom = ZoomUtils.computeZoom(18f, sensorSize, 1f, 20f);

    assertNotNull(computedZoom);
    assertEquals(computedZoom.left, 0);
    assertEquals(computedZoom.top, 0);
    assertEquals(computedZoom.right, 0);
    assertEquals(computedZoom.bottom, 0);
  }

  @Test
  public void setZoom_when_sensor_size_is_valid_should_return_crop_region() {
    final Rect sensorSize = new Rect(0, 0, 100, 100);
    final Rect computedZoom = ZoomUtils.computeZoom(18f, sensorSize, 1f, 20f);

    assertNotNull(computedZoom);
    assertEquals(computedZoom.left, 48);
    assertEquals(computedZoom.top, 48);
    assertEquals(computedZoom.right, 52);
    assertEquals(computedZoom.bottom, 52);
  }

  @Test
  public void setZoom_when_zoom_is_greater_then_max_zoom_clamp_to_max_zoom() {
    final Rect sensorSize = new Rect(0, 0, 100, 100);
    final Rect computedZoom = ZoomUtils.computeZoom(25f, sensorSize, 1f, 10f);

    assertNotNull(computedZoom);
    assertEquals(computedZoom.left, 45);
    assertEquals(computedZoom.top, 45);
    assertEquals(computedZoom.right, 55);
    assertEquals(computedZoom.bottom, 55);
  }

  @Test
  public void setZoom_when_zoom_is_smaller_then_min_zoom_clamp_to_min_zoom() {
    final Rect sensorSize = new Rect(0, 0, 100, 100);
    final Rect computedZoom = ZoomUtils.computeZoom(0.5f, sensorSize, 1f, 10f);

    assertNotNull(computedZoom);
    assertEquals(computedZoom.left, 0);
    assertEquals(computedZoom.top, 0);
    assertEquals(computedZoom.right, 100);
    assertEquals(computedZoom.bottom, 100);
  }
}
