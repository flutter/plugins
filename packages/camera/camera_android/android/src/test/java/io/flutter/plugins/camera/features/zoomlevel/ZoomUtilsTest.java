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
  public void setZoomRect_whenSensorSizeEqualsZeroShouldReturnCropRegionOfZero() {
    final Rect sensorSize = new Rect(0, 0, 0, 0);
    final Rect computedZoom = ZoomUtils.computeZoomRect(18f, sensorSize, 1f, 20f);

    assertNotNull(computedZoom);
    assertEquals(computedZoom.left, 0);
    assertEquals(computedZoom.top, 0);
    assertEquals(computedZoom.right, 0);
    assertEquals(computedZoom.bottom, 0);
  }

  @Test
  public void setZoomRect_whenSensorSizeIsValidShouldReturnCropRegion() {
    final Rect sensorSize = new Rect(0, 0, 100, 100);
    final Rect computedZoom = ZoomUtils.computeZoomRect(18f, sensorSize, 1f, 20f);

    assertNotNull(computedZoom);
    assertEquals(computedZoom.left, 48);
    assertEquals(computedZoom.top, 48);
    assertEquals(computedZoom.right, 52);
    assertEquals(computedZoom.bottom, 52);
  }

  @Test
  public void setZoomRect_whenZoomIsGreaterThenMaxZoomClampToMaxZoom() {
    final Rect sensorSize = new Rect(0, 0, 100, 100);
    final Rect computedZoom = ZoomUtils.computeZoomRect(25f, sensorSize, 1f, 10f);

    assertNotNull(computedZoom);
    assertEquals(computedZoom.left, 45);
    assertEquals(computedZoom.top, 45);
    assertEquals(computedZoom.right, 55);
    assertEquals(computedZoom.bottom, 55);
  }

  @Test
  public void setZoomRect_whenZoomIsSmallerThenMinZoomClampToMinZoom() {
    final Rect sensorSize = new Rect(0, 0, 100, 100);
    final Rect computedZoom = ZoomUtils.computeZoomRect(0.5f, sensorSize, 1f, 10f);

    assertNotNull(computedZoom);
    assertEquals(computedZoom.left, 0);
    assertEquals(computedZoom.top, 0);
    assertEquals(computedZoom.right, 100);
    assertEquals(computedZoom.bottom, 100);
  }

  @Test
  public void setZoomRatio_whenNewZoomGreaterThanMaxZoomClampToMaxZoom() {
    final Float computedZoom = ZoomUtils.computeZoomRatio(21f, 1f, 20f);
    assertNotNull(computedZoom);
    assertEquals(computedZoom, 20f, 0.0f);
  }

  @Test
  public void setZoomRatio_whenNewZoomLesserThanMinZoomClampToMinZoom() {
    final Float computedZoom = ZoomUtils.computeZoomRatio(0.7f, 1f, 20f);
    assertNotNull(computedZoom);
    assertEquals(computedZoom, 1f, 0.0f);
  }

  @Test
  public void setZoomRatio_whenNewZoomValidReturnNewZoom() {
    final Float computedZoom = ZoomUtils.computeZoomRatio(2.0f, 1f, 20f);
    assertNotNull(computedZoom);
    assertEquals(computedZoom, 2.0f, 0.0f);
  }
}
