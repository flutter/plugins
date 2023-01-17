// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:camera_platform_interface/camera_platform_interface.dart'
    show CameraException, DeviceOrientationChangedEvent;
import 'package:flutter/services.dart';

import 'android_camera_camerax_flutter_api_impls.dart';
import 'camerax_library.pigeon.dart';
import 'instance_manager.dart';
import 'java_object.dart';

/// Utility class that offers access to Android system services needed for
/// camera usage.
class SystemServices {
  /// Stream that emits the device orientation whenever it is changed/
  ///
  /// Values may start being added to the stream once
  /// `startListeningForDeviceOrientationChange(...)` is called.
  static final StreamController<DeviceOrientationChangedEvent>
      deviceOrientationChangedStreamController =
      StreamController<DeviceOrientationChangedEvent>.broadcast();

  /// Requests permission to access the camera and audio if specified.
  static Future<void> requestCameraPermissions(bool enableAudio,
      {BinaryMessenger? binaryMessenger}) {
    SystemServicesHostApiImpl api =
        SystemServicesHostApiImpl(binaryMessenger: binaryMessenger);

    return api.requestCameraPermissions(enableAudio);
  }

  /// Requests that [deviceOrientationChangedStreamController] start
  /// emitting values for any change in device orientation.
  static void startListeningForDeviceOrientationChange(
      bool isFrontFacing, int sensorOrientation,
      {BinaryMessenger? binaryMessenger}) {
    AndroidCameraXCameraFlutterApis.instance.ensureSetUp();
    SystemServicesHostApi api =
        SystemServicesHostApi(binaryMessenger: binaryMessenger);

    api.startListeningForDeviceOrientationChange(
        isFrontFacing, sensorOrientation);
  }
}

/// Host API implementation of [SystemServices].
class SystemServicesHostApiImpl extends SystemServicesHostApi {
  /// Creates a [SystemServicesHostApiImpl].
  SystemServicesHostApiImpl({this.binaryMessenger})
      : super(binaryMessenger: binaryMessenger) {}

  /// Receives binary data across the Flutter platform barrier.
  ///
  /// If it is null, the default BinaryMessenger will be used which routes to
  /// the host platform.
  final BinaryMessenger? binaryMessenger;

  /// Requests permission to access the camera and audio if specified.
  ///
  /// Will complete normally if permissions are successfully granted; otherwise,
  /// will throw a [CameraException].
  Future<void> requestCameraPermissions(bool enableAudio) async {
    CameraPermissionsErrorData? error =
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

  @override
  void onDeviceOrientationChanged(String orientation) {
    DeviceOrientation deviceOrientation =
        deserializeDeviceOrientation(orientation);
    if (deviceOrientation == null) {
      return;
    }
    SystemServices.deviceOrientationChangedStreamController
        .add(DeviceOrientationChangedEvent(deviceOrientation!));
  }

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
