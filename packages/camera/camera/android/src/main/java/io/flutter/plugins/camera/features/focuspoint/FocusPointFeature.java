// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camera.features.focuspoint;

import android.hardware.camera2.CaptureRequest;
import io.flutter.plugins.camera.CameraProperties;
import io.flutter.plugins.camera.features.CameraFeature;
import io.flutter.plugins.camera.features.Point;
import io.flutter.plugins.camera.features.regionboundaries.CameraRegions;
import java.util.concurrent.Callable;

/** Focus point controls where in the frame focus will come from. */
public class FocusPointFeature extends CameraFeature<Point> {
  // Used later to always get the correct camera regions instance.
  private final Callable<CameraRegions> getCameraRegions;
  private Point currentSetting = new Point(0.0, 0.0);

  public FocusPointFeature(
      CameraProperties cameraProperties, Callable<CameraRegions> getCameraRegions) {
    super(cameraProperties);
    this.getCameraRegions = getCameraRegions;
  }

  @Override
  public String getDebugName() {
    return "FocusPointFeature";
  }

  @Override
  public Point getValue() {
    return currentSetting;
  }

  @Override
  public void setValue(Point value) {
    this.currentSetting = value;

    try {
      if (value.x == null || value.y == null) {
        getCameraRegions.call().resetAutoFocusMeteringRectangle();
      } else {
        getCameraRegions.call().setAutoFocusMeteringRectangleFromPoint(value.x, value.y);
      }
    } catch (Exception e) {
      e.printStackTrace();
    }
  }

  // Whether or not this camera can set the exposure point.
  @Override
  public boolean checkIsSupported() {
    Integer supportedRegions = cameraProperties.getControlMaxRegionsAutoFocus();
    return supportedRegions != null && supportedRegions > 0;
  }

  @Override
  public void updateBuilder(CaptureRequest.Builder requestBuilder) {
    // Noop: when setting a focus point there is no need to update the request builder.
  }
}
