// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camera.types;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertNotNull;
import static org.junit.Assert.assertNull;

import android.hardware.camera2.params.MeteringRectangle;
import android.util.Size;
import org.junit.Before;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.robolectric.RobolectricTestRunner;

@RunWith(RobolectricTestRunner.class)
public class CameraRegionsTest {
  io.flutter.plugins.camera.types.CameraRegions cameraRegions;

  @Before
  public void setUp() {
    this.cameraRegions = new io.flutter.plugins.camera.types.CameraRegions(new Size(100, 100));
  }

  @Test(expected = AssertionError.class)
  public void getMeteringRectangleForPoint_should_throw_for_x_upper_bound() {
    cameraRegions.convertPointToMeteringRectangle(1.5, 0);
  }

  @Test(expected = AssertionError.class)
  public void getMeteringRectangleForPoint_should_throw_for_x_lower_bound() {
    cameraRegions.convertPointToMeteringRectangle(-0.5, 0);
  }

  @Test(expected = AssertionError.class)
  public void getMeteringRectangleForPoint_should_throw_for_y_upper_bound() {
    cameraRegions.convertPointToMeteringRectangle(0, 1.5);
  }

  @Test(expected = AssertionError.class)
  public void getMeteringRectangleForPoint_should_throw_for_y_lower_bound() {
    cameraRegions.convertPointToMeteringRectangle(0, -0.5);
  }

  @Test
  public void getMeteringRectangleForPoint_should_return_valid_MeteringRectangle() {
    MeteringRectangle r;
    // Center
    r = cameraRegions.convertPointToMeteringRectangle(0.5, 0.5);
    assertEquals(new MeteringRectangle(45, 45, 10, 10, 1), r);

    // Top left
    r = cameraRegions.convertPointToMeteringRectangle(0.0, 0.0);
    assertEquals(new MeteringRectangle(0, 0, 10, 10, 1), r);

    // Bottom right
    r = cameraRegions.convertPointToMeteringRectangle(1.0, 1.0);
    assertEquals(new MeteringRectangle(89, 89, 10, 10, 1), r);

    // Top left
    r = cameraRegions.convertPointToMeteringRectangle(0.0, 1.0);
    assertEquals(new MeteringRectangle(0, 89, 10, 10, 1), r);

    // Top right
    r = cameraRegions.convertPointToMeteringRectangle(1.0, 0.0);
    assertEquals(new MeteringRectangle(89, 0, 10, 10, 1), r);
  }

  @Test(expected = AssertionError.class)
  public void constructor_should_throw_for_0_width_boundary() {
    new io.flutter.plugins.camera.CameraRegions(new Size(0, 50));
  }

  @Test(expected = AssertionError.class)
  public void constructor_should_throw_for_0_height_boundary() {
    new io.flutter.plugins.camera.CameraRegions(new Size(100, 0));
  }

  @Test
  public void setAutoExposureMeteringRectangleFromPoint_should_set_aeMeteringRectangle_for_point() {
    cameraRegions.setAutoExposureMeteringRectangleFromPoint(0, 0);
    assertEquals(new MeteringRectangle(0, 0, 10, 10, 1), cameraRegions.getAEMeteringRectangle());
  }

  @Test
  public void resetAutoExposureMeteringRectangle_should_reset_aeMeteringRectangle() {
    io.flutter.plugins.camera.types.CameraRegions cr = new io.flutter.plugins.camera.types.CameraRegions(new Size(100, 50));
    cr.setAutoExposureMeteringRectangleFromPoint(0, 0);
    assertNotNull(cr.getAEMeteringRectangle());
    cr.resetAutoExposureMeteringRectangle();
    assertNull(cr.getAEMeteringRectangle());
  }

  @Test
  public void setAutoFocusMeteringRectangleFromPoint_should_set_afMeteringRectangle_for_point() {
    io.flutter.plugins.camera.types.CameraRegions cr = new io.flutter.plugins.camera.types.CameraRegions(new Size(100, 50));
    cr.setAutoFocusMeteringRectangleFromPoint(0, 0);
    assertEquals(new MeteringRectangle(0, 0, 10, 5, 1), cr.getAFMeteringRectangle());
  }

  @Test
  public void resetAutoFocusMeteringRectangle_should_reset_afMeteringRectangle() {
    io.flutter.plugins.camera.types.CameraRegions cr = new io.flutter.plugins.camera.types.CameraRegions(new Size(100, 50));
    cr.setAutoFocusMeteringRectangleFromPoint(0, 0);
    assertNotNull(cr.getAFMeteringRectangle());
    cr.resetAutoFocusMeteringRectangle();
    assertNull(cr.getAFMeteringRectangle());
  }
}
