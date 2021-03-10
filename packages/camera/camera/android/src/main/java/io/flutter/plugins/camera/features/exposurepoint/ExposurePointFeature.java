// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camera.features.exposurepoint;

import android.hardware.camera2.CaptureRequest;
import android.hardware.camera2.params.MeteringRectangle;
import android.util.Log;
import androidx.annotation.NonNull;
import io.flutter.plugins.camera.CameraProperties;
import io.flutter.plugins.camera.features.CameraFeature;
import io.flutter.plugins.camera.features.Point;
import io.flutter.plugins.camera.features.regionboundaries.CameraRegions;
import java.util.concurrent.Callable;

/** Exposure point controls where in the frame exposure metering will come from. */
public class ExposurePointFeature extends CameraFeature<Point> {
  // Used later to always get the correct camera regions instance.
  private final Callable<CameraRegions> getCameraRegions;
  private Point currentSetting = new Point(0.0, 0.0);

  public ExposurePointFeature(
      CameraProperties cameraProperties, Callable<CameraRegions> getCameraRegions) {
    super(cameraProperties);
    this.getCameraRegions = getCameraRegions;
  }

  @Override
  public String getDebugName() {
    return "ExposurePointFeature";
  }

  @Override
  public Point getValue() {
    return currentSetting;
  }

  @Override
  public void setValue(@NonNull Point value) {
    this.currentSetting = value;

    try {
      if (value.x == null || value.y == null) {
        getCameraRegions.call().resetAutoExposureMeteringRectangle();
      } else {
        getCameraRegions.call().setAutoExposureMeteringRectangleFromPoint(value.x, value.y);
      }
    } catch (Exception e) {
      e.printStackTrace();
    }
  }

  // Whether or not this camera can set the exposure point.
  @Override
  public boolean checkIsSupported() {
    Integer supportedRegions = cameraProperties.getControlMaxRegionsAutoExposure();
    return supportedRegions != null && supportedRegions > 0;
  }

  @Override
  public void updateBuilder(CaptureRequest.Builder requestBuilder) {
    if (!checkIsSupported()) {
      return;
    }

    Log.i("Camera", "updateExposurePoint | currentSetting: " + currentSetting);

    MeteringRectangle aeRect;
    try {
      aeRect = getCameraRegions.call().getAEMeteringRectangle();
      requestBuilder.set(
          CaptureRequest.CONTROL_AE_REGIONS,
          aeRect == null ? null : new MeteringRectangle[] {aeRect});
    } catch (Exception e) {
      e.printStackTrace();
    }
  }
}
