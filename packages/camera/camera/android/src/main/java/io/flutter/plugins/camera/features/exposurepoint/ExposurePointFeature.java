// Copyright 2013 The Flutter Authors. All rights reserved.
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
import io.flutter.plugins.camera.types.CameraRegions;

/** Exposure point controls where in the frame exposure metering will come from. */
public class ExposurePointFeature extends CameraFeature<Point> {

  private final CameraRegions cameraRegions;
  private Point currentSetting = new Point(0.0, 0.0);

  /**
   * Creates a new instance of the {@link ExposurePointFeature}.
   *
   * @param cameraProperties Collection of the characteristics for the current camera device.
   * @param cameraRegions Utility class to assist in calculating exposure boundaries.
   */
  public ExposurePointFeature(CameraProperties cameraProperties, CameraRegions cameraRegions) {
    super(cameraProperties);
    this.cameraRegions = cameraRegions;
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

    if (value.x == null || value.y == null) {
      cameraRegions.resetAutoExposureMeteringRectangle();
    } else {
      cameraRegions.setAutoExposureMeteringRectangleFromPoint(value.x, value.y);
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

    MeteringRectangle aeRect = null;
    try {
      aeRect = cameraRegions.getAEMeteringRectangle();
    } catch (Exception e) {
      Log.w("Camera", "Unable to retrieve the Auto Exposure metering rectangle.", e);
    }

    requestBuilder.set(
        CaptureRequest.CONTROL_AE_REGIONS,
        aeRect == null ? null : new MeteringRectangle[] {aeRect});
  }
}
