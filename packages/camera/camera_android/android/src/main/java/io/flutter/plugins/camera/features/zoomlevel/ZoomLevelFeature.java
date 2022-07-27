// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camera.features.zoomlevel;

import android.graphics.Rect;
import android.hardware.camera2.CaptureRequest;
import android.os.Build;
import io.flutter.plugins.camera.CameraProperties;
import io.flutter.plugins.camera.features.CameraFeature;

/** Controls the zoom configuration on the {@link android.hardware.camera2} API. */
public class ZoomLevelFeature extends CameraFeature<Float> {
  private final boolean hasSupport;
  private final Rect sensorArraySize;
  private Float currentSetting = 1.0f;
  private Float minimumZoomLevel = currentSetting;
  private Float maximumZoomLevel;

  /**
   * Creates a new instance of the {@link ZoomLevelFeature}.
   *
   * @param cameraProperties Collection of characteristics for the current camera device.
   */
  public ZoomLevelFeature(CameraProperties cameraProperties) {
    super(cameraProperties);

    sensorArraySize = cameraProperties.getSensorInfoActiveArraySize();

    if (sensorArraySize == null) {
      maximumZoomLevel = minimumZoomLevel;
      hasSupport = false;
      return;
    }

    if (Build.VERSION.SDK_INT > Build.VERSION_CODES.R) {
      minimumZoomLevel = cameraProperties.getScalerMinZoomRatio();
      maximumZoomLevel = cameraProperties.getScalerMaxZoomRatio();
    } else {
      minimumZoomLevel = 1.0f;
      Float maxDigitalZoom = cameraProperties.getScalerAvailableMaxDigitalZoom();
      maximumZoomLevel =
          ((maxDigitalZoom == null) || (maxDigitalZoom < minimumZoomLevel))
              ? minimumZoomLevel
              : maxDigitalZoom;
    }

    hasSupport = (Float.compare(maximumZoomLevel, minimumZoomLevel) > 0);
  }

  @Override
  public String getDebugName() {
    return "ZoomLevelFeature";
  }

  @Override
  public Float getValue() {
    return currentSetting;
  }

  @Override
  public void setValue(Float value) {
    currentSetting = value;
  }

  @Override
  public boolean checkIsSupported() {
    return hasSupport;
  }

  @Override
  public void updateBuilder(CaptureRequest.Builder requestBuilder) {
    if (!checkIsSupported()) {
      return;
    }
    if (Build.VERSION.SDK_INT > Build.VERSION_CODES.R) {
      requestBuilder.set(
          CaptureRequest.CONTROL_ZOOM_RATIO,
          ZoomUtils.computeZoomRatio(currentSetting, minimumZoomLevel, maximumZoomLevel));
    } else {
      final Rect computedZoom =
          ZoomUtils.computeZoomRect(
              currentSetting, sensorArraySize, minimumZoomLevel, maximumZoomLevel);
      requestBuilder.set(CaptureRequest.SCALER_CROP_REGION, computedZoom);
    }
  }

  /**
   * Gets the minimum supported zoom level.
   *
   * @return The minimum zoom level.
   */
  public float getMinimumZoomLevel() {
    return minimumZoomLevel;
  }

  /**
   * Gets the maximum supported zoom level.
   *
   * @return The maximum zoom level.
   */
  public float getMaximumZoomLevel() {
    return maximumZoomLevel;
  }
}
