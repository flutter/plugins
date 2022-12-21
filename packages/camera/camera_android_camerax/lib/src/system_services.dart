// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

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

  static Future<bool> requestCameraPermissions({BinaryMessenger? binaryMessenger, InstanceManager? instanceManager}) {
    AndroidCameraXCameraFlutterApis.instance.ensureSetUp();
    SystemServicesHostApiImpl api = SystemServicesHostApiImpl(
        binaryMessenger: binaryMessenger, instanceManager: instanceManager);
    
    return api.requestCameraPermissionsFromInstance();
  }

  // static handleCameraPermissionsResult(String resultCode, String resultMessage) {
  //   // TODO(camsim99): Actually handle camera permissions stuff here.
  //   cameraPermissionsStreamController.add(true);
  // }

  static void startListeningForDeviceOrientationChange({BinaryMessenger? binaryMessenger, InstanceManager? instanceManager}) {
    AndroidCameraXCameraFlutterApis.instance.ensureSetUp();
    SystemServicesHostApi api = SystemServicesHostApi(
        binaryMessenger: binaryMessenger);
    
    api.startListeningForDeviceOrientationChange();
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
  
  Future<bool> requestCameraPermissionsFromInstance() async {
    await requestCameraPermissions();

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
    // SystemServices.handleCameraPermissionsResult(resultCode, resultMessage);
    SystemServices.cameraPermissionsStreamController.add(true);
  }

  @override
  void onDeviceOrientationChanged(String orientation) {
    print('DEVICE ORIENTATION: $orientation');
  }
}
