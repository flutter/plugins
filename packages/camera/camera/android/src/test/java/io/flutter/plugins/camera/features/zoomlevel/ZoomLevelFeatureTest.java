// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camera.features.zoomlevel;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertTrue;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.mockStatic;
import static org.mockito.Mockito.times;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import android.graphics.Rect;
import android.hardware.camera2.CaptureRequest;
import io.flutter.plugins.camera.CameraProperties;
import org.junit.After;
import org.junit.Before;
import org.junit.Test;
import org.mockito.MockedStatic;

public class ZoomLevelFeatureTest {
  private MockedStatic<CameraZoom> mockedStaticCameraZoom;
  private CameraProperties mockCameraProperties;
  private CameraZoom mockCameraZoom;

  @Before
  public void before() {
    mockedStaticCameraZoom = mockStatic(CameraZoom.class);
    mockCameraProperties = mock(CameraProperties.class);
    mockCameraZoom = mock(CameraZoom.class);

    mockedStaticCameraZoom.when(() -> CameraZoom.create(any(), any())).thenReturn(mockCameraZoom);
  }

  @After
  public void after() {
    mockedStaticCameraZoom.close();
  }

  @Test
  public void ctor_should_initiaze_camera_zoom_instance() {
    ZoomLevelFeature zoomLevelFeature = new ZoomLevelFeature(mockCameraProperties);

    verify(mockCameraProperties, times(1)).getSensorInfoActiveArraySize();
    verify(mockCameraProperties, times(1)).getScalerAvailableMaxDigitalZoom();
    assertEquals(mockCameraZoom, zoomLevelFeature.getCameraZoom());
  }

  @Test
  public void getDebugName_should_return_the_name_of_the_feature() {
    ZoomLevelFeature zoomLevelFeature = new ZoomLevelFeature(mockCameraProperties);

    assertEquals("ZoomLevelFeature", zoomLevelFeature.getDebugName());
  }

  @Test
  public void getValue_should_return_null_if_not_set() {
    ZoomLevelFeature zoomLevelFeature = new ZoomLevelFeature(mockCameraProperties);

    assertEquals(1.0, (float) zoomLevelFeature.getValue(), 0);
  }

  @Test
  public void getValue_should_echo_setValue() {
    ZoomLevelFeature zoomLevelFeature = new ZoomLevelFeature(mockCameraProperties);

    zoomLevelFeature.setValue(2.3f);

    assertEquals(2.3f, (float) zoomLevelFeature.getValue(), 0);
  }

  @Test
  public void checkIsSupport_returns_true() {
    ZoomLevelFeature zoomLevelFeature = new ZoomLevelFeature(mockCameraProperties);

    assertTrue(zoomLevelFeature.checkIsSupported());
  }

  @Test
  public void updateBuilder_should_set_scalar_crop_region_when_checkIsSupport_is_true() {
    ZoomLevelFeature zoomLevelFeature = new ZoomLevelFeature(mockCameraProperties);
    CaptureRequest.Builder mockBuilder = mock(CaptureRequest.Builder.class);
    Rect mockRect = mock(Rect.class);

    when(mockCameraZoom.computeZoom(1.0f)).thenReturn(mockRect);

    zoomLevelFeature.updateBuilder(mockBuilder);

    verify(mockBuilder, times(1)).set(CaptureRequest.SCALER_CROP_REGION, mockRect);
  }

  @Test
  public void getCameraZoom_should_return_camera_zoom_instance_initialized_in_ctor() {
    ZoomLevelFeature zoomLevelFeature = new ZoomLevelFeature(mockCameraProperties);

    assertEquals(mockCameraZoom, zoomLevelFeature.getCameraZoom());
  }
}
