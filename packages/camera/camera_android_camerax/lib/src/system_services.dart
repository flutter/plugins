// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/services.dart';

import 'android_camera_camerax_flutter_api_impls.dart';
import 'camerax_library.pigeon.dart';
import 'instance_manager.dart';
import 'java_object.dart';
import 'use_case.dart';

class SystemServices {

  static Future<bool> requestCameraPermissions({BinaryMessenger? binaryMessenger, InstanceManager? instanceManager}) {
    SystemServicesHostApi api = SystemServicesHostApiImpl(
        binaryMessenger: binaryMessenger, instanceManager: instanceManager);
    
    return api.requestCameraPermissionsFromInstance();
  }

  static Future<void> startListeningForDeviceOrientationChange({BinaryMessenger? binaryMessenger, InstanceManager? instanceManager}) {
    AndroidCameraXCameraFlutterApis.instance.ensureSetUp();
    SystemServicesHostApi api = SystemServicesHostApiImpl(
        binaryMessenger: binaryMessenger, instanceManager: instanceManager);
    
    api.startListeningForDeviceOrientationChange();
  }
}

/// Host API implementation of [SystemServices].
class SystemServices extends SystemServicesHostApi {
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
    final bool result = await requestCameraPermissions();
    return result;
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
  void onDeviceOrientationChanged(String orientation) {
    print('DEVICE ORIENTATION: $orientation');
  }
}
