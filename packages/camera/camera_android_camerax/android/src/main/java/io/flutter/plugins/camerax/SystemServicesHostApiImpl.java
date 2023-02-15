// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camerax;

import android.app.Activity;
import androidx.annotation.VisibleForTesting;
import io.flutter.embedding.engine.systemchannels.PlatformChannel.DeviceOrientation;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugins.camerax.CameraPermissionsManager.PermissionsRegistry;
import io.flutter.plugins.camerax.GeneratedCameraXLibrary.CameraPermissionsErrorData;
import io.flutter.plugins.camerax.GeneratedCameraXLibrary.Result;
import io.flutter.plugins.camerax.GeneratedCameraXLibrary.SystemServicesHostApi;

public class SystemServicesHostApiImpl implements SystemServicesHostApi {
  private final BinaryMessenger binaryMessenger;
  private final InstanceManager instanceManager;

  @VisibleForTesting public CameraXProxy cameraXProxy = new CameraXProxy();
  @VisibleForTesting public DeviceOrientationManager deviceOrientationManager;
  @VisibleForTesting public SystemServicesFlutterApiImpl systemServicesFlutterApi;

  private Activity activity;
  private PermissionsRegistry permissionsRegistry;

  public SystemServicesHostApiImpl(
      BinaryMessenger binaryMessenger, InstanceManager instanceManager) {
    this.binaryMessenger = binaryMessenger;
    this.instanceManager = instanceManager;
    this.systemServicesFlutterApi = new SystemServicesFlutterApiImpl(binaryMessenger);
  }

  public void setActivity(Activity activity) {
    this.activity = activity;
  }

  public void setPermissionsRegistry(PermissionsRegistry permissionsRegistry) {
    this.permissionsRegistry = permissionsRegistry;
  }

  /**
   * Requests camera permissions using an instance of a {@link CameraPermissionsManager}.
   *
   * <p>Will result with {@code null} if permissions were approved or there were no errors;
   * otherwise, it will result with the error data explaining what went wrong.
   */
  @Override
  public void requestCameraPermissions(
      Boolean enableAudio, Result<CameraPermissionsErrorData> result) {
    CameraPermissionsManager cameraPermissionsManager =
        cameraXProxy.createCameraPermissionsManager();
    cameraPermissionsManager.requestPermissions(
        activity,
        permissionsRegistry,
        enableAudio,
        (String errorCode, String description) -> {
          if (errorCode == null) {
            result.success(null);
          } else {
            // If permissions are ongoing or denied, error data will be sent to be handled.
            CameraPermissionsErrorData errorData =
                new CameraPermissionsErrorData.Builder()
                    .setErrorCode(errorCode)
                    .setDescription(description)
                    .build();
            result.success(errorData);
          }
        });
  }

  /**
   * Starts listening for device orientation changes using an instace of a {@link
   * DeviceOrientationManager}.
   *
   * <p>Whenever a change in device orientation is detected by the {@code DeviceOrientationManager},
   * the {@link SystemServicesFlutterApi} will be used to notify the Dart side.
   */
  @Override
  public void startListeningForDeviceOrientationChange(
      Boolean isFrontFacing, Long sensorOrientation) {
    deviceOrientationManager =
        cameraXProxy.createDeviceOrientationManager(
            activity,
            isFrontFacing,
            sensorOrientation.intValue(),
            (DeviceOrientation newOrientation) -> {
              systemServicesFlutterApi.sendDeviceOrientationChangedEvent(
                  serializeDeviceOrientation(newOrientation), reply -> {});
            });
    deviceOrientationManager.start();
  }

  /** Serializes {@code DeviceOrientation} into a String that the Dart side is able to recognize. */
  String serializeDeviceOrientation(DeviceOrientation orientation) {
    return orientation.toString();
  }

  /**
   * Tells the {@code deviceOrientationManager} to stop listening for orientation updates.
   *
   * <p>Has no effect if the {@code deviceOrientationManager} was never created to listen for device
   * orientation updates.
   */
  @Override
  public void stopListeningForDeviceOrientationChange() {
    if (deviceOrientationManager != null) {
      deviceOrientationManager.stop();
    }
  }
}
