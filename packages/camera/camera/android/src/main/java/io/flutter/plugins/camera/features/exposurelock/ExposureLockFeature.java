// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camera.features.exposurelock;

import android.hardware.camera2.CaptureRequest;
import android.util.Log;
import io.flutter.plugins.camera.CameraProperties;
import io.flutter.plugins.camera.features.CameraFeature;

/**
 * Exposure lock controls whether or not exposure mode is currenty locked or automatically metering.
 */
public class ExposureLockFeature extends CameraFeature<ExposureMode> {
  private ExposureMode currentSetting = ExposureMode.auto;

  public ExposureLockFeature(CameraProperties cameraProperties) {
    super(cameraProperties);
  }

  @Override
  public String getDebugName() {
    return "ExposureLock";
  }

  @Override
  public ExposureMode getValue() {
    return currentSetting;
  }

  @Override
  public void setValue(ExposureMode value) {
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

    Log.i("Camera", "updateExposureLock | currentSetting: " + currentSetting);

    switch (currentSetting) {
      case locked:
        requestBuilder.set(CaptureRequest.CONTROL_AE_LOCK, true);
        break;
      case auto:
      default:
        requestBuilder.set(CaptureRequest.CONTROL_AE_LOCK, false);
        break;
    }
  }
}
