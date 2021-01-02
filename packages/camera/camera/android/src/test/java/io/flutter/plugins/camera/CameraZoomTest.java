package io.flutter.plugins.camera;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertFalse;
import static org.junit.Assert.assertNotNull;
import static org.junit.Assert.assertNull;
import static org.junit.Assert.assertTrue;

import android.graphics.Rect;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.robolectric.RobolectricTestRunner;

@RunWith(RobolectricTestRunner.class)
public class CameraZoomTest {

  @Test
  public void ctor_when_parameters_are_valid() {
    final Rect sensorSize = new Rect(0, 0, 0, 0);
    final Float maxZoom = 4.0f;
    final CameraZoom cameraZoom = new CameraZoom(sensorSize, maxZoom);

    assertNotNull(cameraZoom);
    assertTrue(cameraZoom.hasSupport);
    assertEquals(4.0f, cameraZoom.maxZoom, 0);
    assertEquals(1.0f, CameraZoom.DEFAULT_ZOOM_FACTOR, 0);
  }

  @Test
  public void ctor_when_sensor_size_is_null() {
    final Rect sensorSize = null;
    final Float maxZoom = 4.0f;
    final CameraZoom cameraZoom = new CameraZoom(sensorSize, maxZoom);

    assertNotNull(cameraZoom);
    assertFalse(cameraZoom.hasSupport);
    assertEquals(cameraZoom.maxZoom, 1.0f, 0);
  }

  @Test
  public void ctor_when_max_zoom_is_null() {
    final Rect sensorSize = new Rect(0, 0, 0, 0);
    final Float maxZoom = null;
    final CameraZoom cameraZoom = new CameraZoom(sensorSize, maxZoom);

    assertNotNull(cameraZoom);
    assertFalse(cameraZoom.hasSupport);
    assertEquals(cameraZoom.maxZoom, 1.0f, 0);
  }

  @Test
  public void ctor_when_max_zoom_is_smaller_then_default_zoom_factor() {
    final Rect sensorSize = new Rect(0, 0, 0, 0);
    final Float maxZoom = 0.5f;
    final CameraZoom cameraZoom = new CameraZoom(sensorSize, maxZoom);

    assertNotNull(cameraZoom);
    assertFalse(cameraZoom.hasSupport);
    assertEquals(cameraZoom.maxZoom, 1.0f, 0);
  }

  @Test
  public void setZoom_when_no_support_should_not_set_scaler_crop_region() {
    final CameraZoom cameraZoom = new CameraZoom(null, null);
    final Rect computedZoom = cameraZoom.computeZoom(2f);

    assertNull(computedZoom);
  }

  @Test
  public void setZoom_when_sensor_size_equals_zero_should_return_crop_region_of_zero() {
    final Rect sensorSize = new Rect(0, 0, 0, 0);
    final CameraZoom cameraZoom = new CameraZoom(sensorSize, 20f);
    final Rect computedZoom = cameraZoom.computeZoom(18f);

    assertNotNull(computedZoom);
    assertEquals(computedZoom.left, 0);
    assertEquals(computedZoom.top, 0);
    assertEquals(computedZoom.right, 0);
    assertEquals(computedZoom.bottom, 0);
  }

  @Test
  public void setZoom_when_sensor_size_is_valid_should_return_crop_region() {
    final Rect sensorSize = new Rect(0, 0, 100, 100);
    final CameraZoom cameraZoom = new CameraZoom(sensorSize, 20f);
    final Rect computedZoom = cameraZoom.computeZoom(18f);

    assertNotNull(computedZoom);
    assertEquals(computedZoom.left, 48);
    assertEquals(computedZoom.top, 48);
    assertEquals(computedZoom.right, 52);
    assertEquals(computedZoom.bottom, 52);
  }

  @Test
  public void setZoom_when_zoom_is_greater_then_max_zoom_clamp_to_max_zoom() {
    final Rect sensorSize = new Rect(0, 0, 100, 100);
    final CameraZoom cameraZoom = new CameraZoom(sensorSize, 10f);
    final Rect computedZoom = cameraZoom.computeZoom(25f);

    assertNotNull(computedZoom);
    assertEquals(computedZoom.left, 45);
    assertEquals(computedZoom.top, 45);
    assertEquals(computedZoom.right, 55);
    assertEquals(computedZoom.bottom, 55);
  }

  @Test
  public void setZoom_when_zoom_is_smaller_then_min_zoom_clamp_to_min_zoom() {
    final Rect sensorSize = new Rect(0, 0, 100, 100);
    final CameraZoom cameraZoom = new CameraZoom(sensorSize, 10f);
    final Rect computedZoom = cameraZoom.computeZoom(0.5f);

    assertNotNull(computedZoom);
    assertEquals(computedZoom.left, 0);
    assertEquals(computedZoom.top, 0);
    assertEquals(computedZoom.right, 100);
    assertEquals(computedZoom.bottom, 100);
  }
}
