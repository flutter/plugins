// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camera.features.zoomlevel;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertFalse;
import static org.junit.Assert.assertNotNull;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyFloat;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.mockStatic;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.times;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import android.graphics.Rect;
import android.hardware.camera2.CaptureRequest;
import android.os.Build;
import io.flutter.plugins.camera.CameraProperties;
import java.lang.reflect.Field;
import java.lang.reflect.Modifier;
import org.junit.After;
import org.junit.Before;
import org.junit.Test;
import org.mockito.MockedStatic;

public class ZoomLevelFeatureTest {
  private MockedStatic<ZoomUtils> mockedStaticCameraZoom;
  private CameraProperties mockCameraProperties;
  private ZoomUtils mockCameraZoom;
  private Rect mockZoomArea;
  private Rect mockSensorArray;

  @Before
  public void before() {
    mockedStaticCameraZoom = mockStatic(ZoomUtils.class);
    mockCameraProperties = mock(CameraProperties.class);
    mockCameraZoom = mock(ZoomUtils.class);
    mockZoomArea = mock(Rect.class);
    mockSensorArray = mock(Rect.class);

    mockedStaticCameraZoom
        .when(() -> ZoomUtils.computeZoomRect(anyFloat(), any(), anyFloat(), anyFloat()))
        .thenReturn(mockZoomArea);
  }

  @After
  public void after() {
    mockedStaticCameraZoom.close();
  }

  @Test
  public void ctor_whenParametersAreValid() {
    when(mockCameraProperties.getSensorInfoActiveArraySize()).thenReturn(mockSensorArray);
    when(mockCameraProperties.getScalerAvailableMaxDigitalZoom()).thenReturn(42f);

    final ZoomLevelFeature zoomLevelFeature = new ZoomLevelFeature(mockCameraProperties);

    verify(mockCameraProperties, times(1)).getSensorInfoActiveArraySize();
    verify(mockCameraProperties, times(1)).getScalerAvailableMaxDigitalZoom();
    assertNotNull(zoomLevelFeature);
    assertEquals(42f, zoomLevelFeature.getMaximumZoomLevel(), 0);
  }

  @Test
  public void ctor_whenSensorSizeIsNull() {
    when(mockCameraProperties.getSensorInfoActiveArraySize()).thenReturn(null);
    when(mockCameraProperties.getScalerAvailableMaxDigitalZoom()).thenReturn(42f);

    final ZoomLevelFeature zoomLevelFeature = new ZoomLevelFeature(mockCameraProperties);

    verify(mockCameraProperties, times(1)).getSensorInfoActiveArraySize();
    verify(mockCameraProperties, never()).getScalerAvailableMaxDigitalZoom();
    assertNotNull(zoomLevelFeature);
    assertFalse(zoomLevelFeature.checkIsSupported());
    assertEquals(zoomLevelFeature.getMaximumZoomLevel(), 1.0f, 0);
  }

  @Test
  public void ctor_whenMaxZoomIsNull() {
    when(mockCameraProperties.getSensorInfoActiveArraySize()).thenReturn(mockSensorArray);
    when(mockCameraProperties.getScalerAvailableMaxDigitalZoom()).thenReturn(null);

    final ZoomLevelFeature zoomLevelFeature = new ZoomLevelFeature(mockCameraProperties);

    verify(mockCameraProperties, times(1)).getSensorInfoActiveArraySize();
    verify(mockCameraProperties, times(1)).getScalerAvailableMaxDigitalZoom();
    assertNotNull(zoomLevelFeature);
    assertFalse(zoomLevelFeature.checkIsSupported());
    assertEquals(zoomLevelFeature.getMaximumZoomLevel(), 1.0f, 0);
  }

  @Test
  public void ctor_whenMaxZoomIsSmallerThenDefaultZoomFactor() {
    when(mockCameraProperties.getSensorInfoActiveArraySize()).thenReturn(mockSensorArray);
    when(mockCameraProperties.getScalerAvailableMaxDigitalZoom()).thenReturn(0.5f);

    final ZoomLevelFeature zoomLevelFeature = new ZoomLevelFeature(mockCameraProperties);

    verify(mockCameraProperties, times(1)).getSensorInfoActiveArraySize();
    verify(mockCameraProperties, times(1)).getScalerAvailableMaxDigitalZoom();
    assertNotNull(zoomLevelFeature);
    assertFalse(zoomLevelFeature.checkIsSupported());
    assertEquals(zoomLevelFeature.getMaximumZoomLevel(), 1.0f, 0);
  }

  @Test
  public void getDebugName_shouldReturnTheNameOfTheFeature() {
    ZoomLevelFeature zoomLevelFeature = new ZoomLevelFeature(mockCameraProperties);

    assertEquals("ZoomLevelFeature", zoomLevelFeature.getDebugName());
  }

  @Test
  public void getValue_shouldReturnNullIfNotSet() {
    ZoomLevelFeature zoomLevelFeature = new ZoomLevelFeature(mockCameraProperties);

    assertEquals(1.0, (float) zoomLevelFeature.getValue(), 0);
  }

  @Test
  public void getValue_shouldEchoSetValue() {
    ZoomLevelFeature zoomLevelFeature = new ZoomLevelFeature(mockCameraProperties);

    zoomLevelFeature.setValue(2.3f);

    assertEquals(2.3f, (float) zoomLevelFeature.getValue(), 0);
  }

  @Test
  public void checkIsSupport_returnsFalseByDefault() {
    ZoomLevelFeature zoomLevelFeature = new ZoomLevelFeature(mockCameraProperties);

    assertFalse(zoomLevelFeature.checkIsSupported());
  }

  @Test
  public void updateBuilder_shouldSetScalarCropRegionWhenCheckIsSupportIsTrue() {
    when(mockCameraProperties.getSensorInfoActiveArraySize()).thenReturn(mockSensorArray);
    when(mockCameraProperties.getScalerAvailableMaxDigitalZoom()).thenReturn(42f);

    ZoomLevelFeature zoomLevelFeature = new ZoomLevelFeature(mockCameraProperties);
    CaptureRequest.Builder mockBuilder = mock(CaptureRequest.Builder.class);

    zoomLevelFeature.updateBuilder(mockBuilder);

    verify(mockBuilder, times(1)).set(CaptureRequest.SCALER_CROP_REGION, mockZoomArea);
  }

  @Test
  public void updateBuilder_shouldControlZoomRatioWhenCheckIsSupportIsTrue() throws Exception {
    setSdkVersion(Build.VERSION_CODES.R);
    when(mockCameraProperties.getSensorInfoActiveArraySize()).thenReturn(mockSensorArray);
    when(mockCameraProperties.getScalerMaxZoomRatio()).thenReturn(42f);
    when(mockCameraProperties.getScalerMinZoomRatio()).thenReturn(1.0f);

    ZoomLevelFeature zoomLevelFeature = new ZoomLevelFeature(mockCameraProperties);

    CaptureRequest.Builder mockBuilder = mock(CaptureRequest.Builder.class);

    zoomLevelFeature.updateBuilder(mockBuilder);

    verify(mockBuilder, times(1)).set(CaptureRequest.CONTROL_ZOOM_RATIO, 0.0f);
  }

  @Test
  public void getMinimumZoomLevel() {
    ZoomLevelFeature zoomLevelFeature = new ZoomLevelFeature(mockCameraProperties);

    assertEquals(1.0f, zoomLevelFeature.getMinimumZoomLevel(), 0);
  }

  @Test
  public void getMaximumZoomLevel() {
    when(mockCameraProperties.getSensorInfoActiveArraySize()).thenReturn(mockSensorArray);
    when(mockCameraProperties.getScalerAvailableMaxDigitalZoom()).thenReturn(42f);

    ZoomLevelFeature zoomLevelFeature = new ZoomLevelFeature(mockCameraProperties);

    assertEquals(42f, zoomLevelFeature.getMaximumZoomLevel(), 0);
  }

  @Test
  public void checkZoomLevelFeature_callsMaxDigitalZoomOnAndroidQ() throws Exception {
    setSdkVersion(Build.VERSION_CODES.Q);

    when(mockCameraProperties.getSensorInfoActiveArraySize()).thenReturn(mockSensorArray);

    new ZoomLevelFeature(mockCameraProperties);

    verify(mockCameraProperties, times(0)).getScalerMaxZoomRatio();
    verify(mockCameraProperties, times(0)).getScalerMinZoomRatio();
    verify(mockCameraProperties, times(1)).getScalerAvailableMaxDigitalZoom();
  }

  @Test
  public void checkZoomLevelFeature_callsScalarMaxZoomRatioOnAndroidR() throws Exception {
    setSdkVersion(Build.VERSION_CODES.R);
    when(mockCameraProperties.getSensorInfoActiveArraySize()).thenReturn(mockSensorArray);

    new ZoomLevelFeature(mockCameraProperties);

    verify(mockCameraProperties, times(1)).getScalerMaxZoomRatio();
    verify(mockCameraProperties, times(1)).getScalerMinZoomRatio();
    verify(mockCameraProperties, times(0)).getScalerAvailableMaxDigitalZoom();
  }

  static void setSdkVersion(int sdkVersion) throws Exception {
    Field sdkInt = Build.VERSION.class.getField("SDK_INT");
    sdkInt.setAccessible(true);
    Field modifiersField = Field.class.getDeclaredField("modifiers");
    modifiersField.setAccessible(true);
    modifiersField.setInt(sdkInt, sdkInt.getModifiers() & ~Modifier.FINAL);
    sdkInt.set(null, sdkVersion);
  }
}
