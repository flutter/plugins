// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camera.features.zoomlevel;

import android.graphics.Rect;
import android.hardware.camera2.CaptureRequest;
import android.util.Log;
import io.flutter.plugins.camera.CameraProperties;
import io.flutter.plugins.camera.features.CameraFeature;

/** Exposure offset makes the image brighter or darker. */
public class ZoomLevelFeature extends CameraFeature<Float> {
  private Float currentSetting = CameraZoom.DEFAULT_ZOOM_FACTOR;
  private CameraZoom cameraZoom;

  public ZoomLevelFeature(CameraProperties cameraProperties) {
    super(cameraProperties);
    this.cameraZoom =
        new CameraZoom(
            cameraProperties.getSensorInfoActiveArraySize(),
            cameraProperties.getScalerAvailableMaxDigitalZoom());
  }

  @Override
  public String getDebugName() {
    return "ZoomLevel";
  }

  @Override
  public Float getValue() {
    return currentSetting;
  }

  @Override
  public void setValue(Float value) {
    this.currentSetting = value;
  }

  // Available on all devices.
  @Override
  public boolean checkIsSupported() {
    return true;
  }

  @Override
  public void updateBuilder(CaptureRequest.Builder requestBuilder) {
    if (!checkIsSupported()) {
      return;
    }

    Log.i("Camera", "updateZoomLevel | currentSetting: " + currentSetting);

    final Rect computedZoom = cameraZoom.computeZoom(currentSetting);
    requestBuilder.set(CaptureRequest.SCALER_CROP_REGION, computedZoom);
  }

  public CameraZoom getCameraZoom() {
    return this.cameraZoom;
  }
}
