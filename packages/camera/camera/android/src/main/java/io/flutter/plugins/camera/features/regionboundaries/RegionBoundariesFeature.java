// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camera.features.regionboundaries;

import android.annotation.TargetApi;
import android.hardware.camera2.CaptureRequest;
import android.os.Build;
import android.util.Size;
import io.flutter.plugins.camera.CameraProperties;
import io.flutter.plugins.camera.features.CameraFeature;
import java.util.Arrays;

/**
 * Holds the current region boundaries. When this is created, you must provide a
 * CaptureRequestBuilder for which we can read the distortion correction settings from.
 */
public class RegionBoundariesFeature extends CameraFeature<Size> {
  private final CameraRegions cameraRegions;
  private Size currentSetting;

  public RegionBoundariesFeature(
      CameraProperties cameraProperties, CaptureRequest.Builder requestBuilder) {
    super(cameraProperties);

    // No distortion correction support
    if (android.os.Build.VERSION.SDK_INT < Build.VERSION_CODES.P
        || !supportsDistortionCorrection()) {
      setValue(cameraProperties.getSensorInfoPixelArraySize());
    } else {
      // Get the current distortion correction mode
      Integer distortionCorrectionMode = requestBuilder.get(CaptureRequest.DISTORTION_CORRECTION_MODE);

      // Return the correct boundaries depending on the mode
      android.graphics.Rect rect;
      if (distortionCorrectionMode == null
          || distortionCorrectionMode == CaptureRequest.DISTORTION_CORRECTION_MODE_OFF) {
        rect = cameraProperties.getSensorInfoPreCorrectionActiveArraySize();
      } else {
        rect = cameraProperties.getSensorInfoActiveArraySize();
      }

      // Set new region size
      setValue(rect == null ? null : new Size(rect.width(), rect.height()));
    }

    // Create new camera regions using new size
    cameraRegions = new CameraRegions(currentSetting);
  }

  @Override
  public String getDebugName() {
    return "RegionBoundariesFeature";
  }

  @Override
  public Size getValue() {
    return currentSetting;
  }

  @Override
  public void setValue(Size value) {
    this.currentSetting = value;
  }

  // Available on all devices.
  @Override
  public boolean checkIsSupported() {
    return true;
  }

  @Override
  public void updateBuilder(CaptureRequest.Builder requestBuilder) {
    // Noop: when setting a region boundaries there is no need to update the request builder.
  }

  @TargetApi(Build.VERSION_CODES.P)
  private boolean supportsDistortionCorrection() {
    int[] availableDistortionCorrectionModes =
        cameraProperties.getDistortionCorrectionAvailableModes();
    if (availableDistortionCorrectionModes == null) availableDistortionCorrectionModes = new int[0];
    long nonOffModesSupported =
        Arrays.stream(availableDistortionCorrectionModes)
            .filter((value) -> value != CaptureRequest.DISTORTION_CORRECTION_MODE_OFF)
            .count();
    return nonOffModesSupported > 0;
  }

  public CameraRegions getCameraRegions() {
    return this.cameraRegions;
  }
}
