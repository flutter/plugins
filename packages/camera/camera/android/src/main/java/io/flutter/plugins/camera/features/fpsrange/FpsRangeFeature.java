// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camera.features.fpsrange;

import android.hardware.camera2.CaptureRequest;
import android.util.Log;
import android.util.Range;
import io.flutter.plugins.camera.CameraProperties;
import io.flutter.plugins.camera.features.CameraFeature;

public class FpsRangeFeature extends CameraFeature<Range<Integer>> {
  private Range<Integer> currentSetting;

  public FpsRangeFeature(CameraProperties cameraProperties) {
    super(cameraProperties);

    Log.i("Camera", "getAvailableFpsRange");

    try {
      Range<Integer>[] ranges = cameraProperties.getControlAutoExposureAvailableTargetFpsRanges();

      if (ranges != null) {
        for (Range<Integer> range : ranges) {
          int upper = range.getUpper();
          if (upper >= 10) {
            if (currentSetting == null || upper > currentSetting.getUpper()) {
              currentSetting = range;
            }
          }
        }
      }
    } catch (Exception e) {
      // TODO: maybe just send a dart error back
      //            pictureCaptureRequest.error("cameraAccess", e.getMessage(), null);
    }
  }

  @Override
  public String getDebugName() {
    return "FpsRangeFeature";
  }

  @Override
  public Range<Integer> getValue() {
    return currentSetting;
  }

  @Override
  public void setValue(Range<Integer> value) {
    this.currentSetting = value;
  }

  // Always supported
  @Override
  public boolean checkIsSupported() {
    return true;
  }

  @Override
  public void updateBuilder(CaptureRequest.Builder requestBuilder) {
    if (!checkIsSupported()) {
      return;
    }

    requestBuilder.set(CaptureRequest.CONTROL_AE_TARGET_FPS_RANGE, currentSetting);
  }
}
