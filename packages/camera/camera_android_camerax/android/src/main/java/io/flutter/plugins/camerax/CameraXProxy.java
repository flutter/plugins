// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camerax;

import android.app.Activity;
import android.graphics.SurfaceTexture;
import android.view.Surface;
import androidx.camera.core.CameraSelector;
import androidx.camera.core.Preview;
import io.flutter.plugin.common.BinaryMessenger;

public class CameraXProxy {
  public CameraSelector.Builder createCameraSelectorBuilder() {
    return new CameraSelector.Builder();
  }

  public CameraPermissionsManager createCameraPermissionsManager() {
    return new CameraPermissionsManager();
  }

  public DeviceOrientationManager createDeviceOrientationManager(
      Activity activity,
      Boolean isFrontFacing,
      int sensorOrientation,
      DeviceOrientationManager.DeviceOrientationChangeCallback callback) {
    return new DeviceOrientationManager(activity, isFrontFacing, sensorOrientation, callback);
  }

  public Preview.Builder createPreviewBuilder() {
    return new Preview.Builder();
  }

  public Surface createSurface(SurfaceTexture surfaceTexture) {
    return new Surface(surfaceTexture);
  }

  public SystemServicesFlutterApiImpl createSystemServicesFlutterApi(
      BinaryMessenger binaryMessenger) {
    return new SystemServicesFlutterApiImpl(binaryMessenger);
  }
}
