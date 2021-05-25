// Copyright 2019 The Chromium Authors. All rights reserved.
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
          Log.i("Camera", "[FPS Range Available] is:" + range);

          // There is a bug in the Pixel 4A where it cannot support 60fps modes
          // even though they are reported as supported by `getControlAutoExposureAvailableTargetFpsRanges`.
          // For max device compatibility we will keep FPS under 60 even if they report they are
          // capable of achieving 60 fps.
          // https://issuetracker.google.com/issues/189237151
          if (upper >= 10 && upper < 60) {
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
    Log.i("Camera", "[FPS Range] is:" + currentSetting);
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

    Log.i("Camera", "FpsRangeFeature | currentSetting: " + currentSetting);

    requestBuilder.set(CaptureRequest.CONTROL_AE_TARGET_FPS_RANGE, currentSetting);
  }
}
