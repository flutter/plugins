// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:camera_platform_interface/camera_platform_interface.dart'
    show CameraException, DeviceOrientationChangedEvent;
import 'package:flutter/services.dart';

import 'android_camera_camerax_flutter_api_impls.dart';
import 'camerax_library.pigeon.dart';

// Ignoring lint indicating this class only contains static members
// as this class is a wrapper for various Android system services.
// ignore_for_file: avoid_classes_with_only_static_members

/// Utility class that offers access to Android system services needed for
/// camera usage.
class SystemServices {
  /// Stream that emits the device orientation whenever it is changed.
  ///
  /// Values may start being added to the stream once
  /// `startListeningForDeviceOrientationChange(...)` is called.
  static final StreamController<DeviceOrientationChangedEvent>
      deviceOrientationChangedStreamController =
      StreamController<DeviceOrientationChangedEvent>.broadcast();

  /// Requests permission to access the camera and audio if specified.
  static Future<void> requestCameraPermissions(bool enableAudio,
      {BinaryMessenger? binaryMessenger}) {
    final SystemServicesHostApiImpl api =
        SystemServicesHostApiImpl(binaryMessenger: binaryMessenger);

    return api.sendCameraPermissionsRequest(enableAudio);
  }

  /// Requests that [deviceOrientationChangedStreamController] start
  /// emitting values for any change in device orientation.
  static void startListeningForDeviceOrientationChange(
      bool isFrontFacing, int sensorOrientation,
      {BinaryMessenger? binaryMessenger}) {
    AndroidCameraXCameraFlutterApis.instance.ensureSetUp();
    final SystemServicesHostApi api =
        SystemServicesHostApi(binaryMessenger: binaryMessenger);

    api.startListeningForDeviceOrientationChange(
        isFrontFacing, sensorOrientation);
  }

  /// Stops the [deviceOrientationChangedStreamController] from emitting values
  /// for changes in device orientation.
  static void stopListeningForDeviceOrientationChange(
      {BinaryMessenger? binaryMessenger}) {
    final SystemServicesHostApi api =
        SystemServicesHostApi(binaryMessenger: binaryMessenger);

    api.stopListeningForDeviceOrientationChange();
  }
}

/// Host API implementation of [SystemServices].
class SystemServicesHostApiImpl extends SystemServicesHostApi {
  /// Creates a [SystemServicesHostApiImpl].
  SystemServicesHostApiImpl({this.binaryMessenger})
      : super(binaryMessenger: binaryMessenger);

  /// Receives binary data across the Flutter platform barrier.
  ///
  /// If it is null, the default BinaryMessenger will be used which routes to
  /// the host platform.
  final BinaryMessenger? binaryMessenger;

  /// Requests permission to access the camera and audio if specified.
  ///
  /// Will complete normally if permissions are successfully granted; otherwise,
  /// will throw a [CameraException].
  Future<void> sendCameraPermissionsRequest(bool enableAudio) async {
    final CameraPermissionsErrorData? error =
        await requestCameraPermissions(enableAudio);

    if (error != null) {
      throw CameraException(
        error.errorCode,
        error.description,
      );
    }
  }
}

/// Flutter API implementation of [SystemServices].
class SystemServicesFlutterApiImpl implements SystemServicesFlutterApi {
  /// Constructs a [SystemServicesFlutterApiImpl].
  SystemServicesFlutterApiImpl({
    this.binaryMessenger,
  });

  /// Receives binary data across the Flutter platform barrier.
  ///
  /// If it is null, the default BinaryMessenger will be used which routes to
  /// the host platform.
  final BinaryMessenger? binaryMessenger;

  /// Callback method for any changes in device orientation.
  ///
  /// Will only be called if
  /// `SystemServices.startListeningForDeviceOrientationChange(...)` was called
  /// to start listening for device orientation updates.
  @override
  void onDeviceOrientationChanged(String orientation) {
    final DeviceOrientation deviceOrientation =
        deserializeDeviceOrientation(orientation);
    if (deviceOrientation == null) {
      return;
    }
    SystemServices.deviceOrientationChangedStreamController
        .add(DeviceOrientationChangedEvent(deviceOrientation));
  }

  /// Deserializes device orientation in [String] format into a
  /// [DeviceOrientation].
  DeviceOrientation deserializeDeviceOrientation(String orientation) {
    switch (orientation) {
      case 'LANDSCAPE_LEFT':
        return DeviceOrientation.landscapeLeft;
      case 'LANDSCAPE_RIGHT':
        return DeviceOrientation.landscapeRight;
      case 'PORTRAIT_DOWN':
        return DeviceOrientation.portraitDown;
      case 'PORTRAIT_UP':
        return DeviceOrientation.portraitUp;
      default:
        throw ArgumentError(
            '"$orientation" is not a valid DeviceOrientation value');
    }
  }
}
