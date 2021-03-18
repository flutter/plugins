// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camera.features.sensororientation;

import android.app.Activity;
import android.hardware.camera2.CameraMetadata;
import android.hardware.camera2.CaptureRequest;
import androidx.annotation.NonNull;
import io.flutter.embedding.engine.systemchannels.PlatformChannel;
import io.flutter.plugins.camera.CameraProperties;
import io.flutter.plugins.camera.DartMessenger;
import io.flutter.plugins.camera.features.CameraFeature;

public class SensorOrientationFeature extends CameraFeature<Integer> {
  private Integer currentSetting = 0;
  private final DeviceOrientationManager deviceOrientationListener;
  private PlatformChannel.DeviceOrientation lockedCaptureOrientation;

  public SensorOrientationFeature(
      @NonNull CameraProperties cameraProperties,
      @NonNull Activity activity,
      @NonNull DartMessenger dartMessenger) {
    super(cameraProperties);
    setValue(cameraProperties.getSensorOrientation());

    boolean isFrontFacing = cameraProperties.getLensFacing() == CameraMetadata.LENS_FACING_FRONT;
    deviceOrientationListener =
        DeviceOrientationManager.create(activity, dartMessenger, isFrontFacing, currentSetting);
    deviceOrientationListener.start();
  }

  @Override
  public String getDebugName() {
    return "SensorOrientationFeature";
  }

  @Override
  public Integer getValue() {
    return currentSetting;
  }

  @Override
  public void setValue(Integer value) {
    this.currentSetting = value;
  }

  @Override
  public boolean checkIsSupported() {
    return true;
  }

  @Override
  public void updateBuilder(CaptureRequest.Builder requestBuilder) {
    // Noop: when setting the sensor orientation there is no need to update the request builder.
  }

  public DeviceOrientationManager getDeviceOrientationManager() {
    return this.deviceOrientationListener;
  }

  public void lockCaptureOrientation(PlatformChannel.DeviceOrientation orientation) {
    this.lockedCaptureOrientation = orientation;
  }

  public void unlockCaptureOrientation() {
    this.lockedCaptureOrientation = null;
  }

  public PlatformChannel.DeviceOrientation getLockedCaptureOrientation() {
    return this.lockedCaptureOrientation;
  }
}
