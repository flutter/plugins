// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camerax;

import android.app.Activity;
import android.graphics.SurfaceTexture;
import android.view.Surface;
import androidx.annotation.NonNull;
import androidx.camera.core.CameraSelector;
import androidx.camera.core.Preview;
import io.flutter.plugin.common.BinaryMessenger;

/** Utility class used to create CameraX-related objects primarily for testing purposes. */
public class CameraXProxy {
  public CameraSelector.Builder createCameraSelectorBuilder() {
    return new CameraSelector.Builder();
  }

  public CameraPermissionsManager createCameraPermissionsManager() {
    return new CameraPermissionsManager();
  }

  public DeviceOrientationManager createDeviceOrientationManager(
      @NonNull Activity activity,
      @NonNull Boolean isFrontFacing,
      @NonNull int sensorOrientation,
      @NonNull DeviceOrientationManager.DeviceOrientationChangeCallback callback) {
    return new DeviceOrientationManager(activity, isFrontFacing, sensorOrientation, callback);
  }

  public Preview.Builder createPreviewBuilder() {
    return new Preview.Builder();
  }

  public Surface createSurface(@NonNull SurfaceTexture surfaceTexture) {
    return new Surface(surfaceTexture);
  }

  /**
   * Creates an instance of the {@code SystemServicesFlutterApiImpl}.
   *
   * <p>Included in this class to utilize the callback methods it provides, e.g. {@code
   * onCameraError(String)}.
   */
  public SystemServicesFlutterApiImpl createSystemServicesFlutterApiImpl(
      @NonNull BinaryMessenger binaryMessenger) {
    return new SystemServicesFlutterApiImpl(binaryMessenger);
  }
}
