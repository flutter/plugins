// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:camera_platform_interface/camera_platform_interface.dart' show DeviceOrientationChangedEvent;
import 'package:flutter/services.dart';

import 'android_camera_camerax_flutter_api_impls.dart';
import 'camerax_library.pigeon.dart';
import 'instance_manager.dart';
import 'java_object.dart';
import 'use_case.dart';

class SystemServices {
  // TODO(camsim99): Change this to actually handle errors.
  static final StreamController<bool> cameraPermissionsStreamController =
      StreamController<bool>.broadcast();

  static final StreamController<DeviceOrientationChangedEvent> deviceOrientationChangedStreamController =
    StreamController<DeviceOrientationChangedEvent>.broadcast();

  static Future<bool> requestCameraPermissions(bool enableAudio, {BinaryMessenger? binaryMessenger, InstanceManager? instanceManager}) {
    AndroidCameraXCameraFlutterApis.instance.ensureSetUp();
    SystemServicesHostApiImpl api = SystemServicesHostApiImpl(
        binaryMessenger: binaryMessenger, instanceManager: instanceManager);
    
    return api.requestCameraPermissionsFromInstance(enableAudio);
  }

  // static handleCameraPermissionsResult(String resultCode, String resultMessage) {
  //   // TODO(camsim99): Actually handle camera permissions stuff here.
  //   cameraPermissionsStreamController.add(true);
  // }

  static void startListeningForDeviceOrientationChange(bool isFrontFacing, int sensorOrientation, {BinaryMessenger? binaryMessenger, InstanceManager? instanceManager}) {
    AndroidCameraXCameraFlutterApis.instance.ensureSetUp();
    SystemServicesHostApi api = SystemServicesHostApi(
        binaryMessenger: binaryMessenger);
    
    api.startListeningForDeviceOrientationChange(isFrontFacing, sensorOrientation);
  }
}

/// Host API implementation of [SystemServices].
class SystemServicesHostApiImpl extends SystemServicesHostApi {
  /// Creates a [SystemServicesHostApiImpl].
  SystemServicesHostApiImpl(
    {this.binaryMessenger, InstanceManager? instanceManager})
      : super(binaryMessenger: binaryMessenger) {
    this.instanceManager = instanceManager ?? JavaObject.globalInstanceManager;
  }

  /// Receives binary data across the Flutter platform barrier.
  ///
  /// If it is null, the default BinaryMessenger will be used which routes to
  /// the host platform.
  final BinaryMessenger? binaryMessenger;

  /// Maintains instances stored to communicate with native language objects.
  late final InstanceManager instanceManager;
  
  Future<bool> requestCameraPermissionsFromInstance(bool enableAudio) async {
    await requestCameraPermissions(enableAudio);

  try {
      await for (final bool result in SystemServices.cameraPermissionsStreamController.stream) {
        return result;
      }
    } catch (e) {
      return false;
    }
    return false;
  }
}

/// Flutter API implementation of [SystemServices].
class SystemServicesFlutterApiImpl implements SystemServicesFlutterApi {
  /// Constructs a [SystemServicesFlutterApiImpl].
  SystemServicesFlutterApiImpl({
    this.binaryMessenger,
    InstanceManager? instanceManager,
  }) : instanceManager = instanceManager ?? JavaObject.globalInstanceManager;

  /// Receives binary data across the Flutter platform barrier.
  ///
  /// If it is null, the default BinaryMessenger will be used which routes to
  /// the host platform.
  final BinaryMessenger? binaryMessenger;

  /// Maintains instances stored to communicate with native language objects.
  final InstanceManager instanceManager;

  @override
  void onCameraPermissionsRequestResult(String resultCode, String resultMessage) {
    // TODO(camsim99): Actually decode and handle results here
    SystemServices.cameraPermissionsStreamController.add(true);
  }

  @override
  void onDeviceOrientationChanged(String orientation) {
    DeviceOrientation? deviceOrientation = getDeviceOrientation(orientation);
    if (deviceOrientation == null) {
      return;
    }
    SystemServices.deviceOrientationChangedStreamController.add(DeviceOrientationChangedEvent(deviceOrientation!));
  }

  DeviceOrientation? getDeviceOrientation(String orientation) {
    switch(orientation) {
      case 'LANDSCAPE_LEFT':
        return DeviceOrientation.landscapeLeft;
      case 'LANDSCAPE_RIGHT':
        return DeviceOrientation.landscapeRight;
      case 'PORTRAIT_DOWN':
        return DeviceOrientation.portraitDown;
      case 'PORTRAIT_UP':
        return DeviceOrientation.portraitUp;
      default:
        return null;
    }
  }
}
