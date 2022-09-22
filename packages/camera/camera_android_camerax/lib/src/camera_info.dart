// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/services.dart' show BinaryMessenger;

import 'android_camera_camerax_flutter_api_impls.dart';
import 'camerax_library.pigeon.dart';
import 'instance_manager.dart';
import 'java_object.dart';

/// Represents the metadata of a camera.
///
/// See https://developer.android.com/reference/androidx/camera/core/CameraInfo.
class CameraInfo extends JavaObject {
  /// Constructs a [CameraInfo] that is not automatically attached to a native object.
  CameraInfo.detached(
      {BinaryMessenger? binaryMessenger, InstanceManager? instanceManager})
      : super.detached(
            binaryMessenger: binaryMessenger,
            instanceManager: instanceManager) {
    _api = CameraInfoHostApiImpl(
      binaryMessenger: binaryMessenger,
      instanceManager: instanceManager,
    );
    AndroidCameraXCameraFlutterApis.instance.ensureSetUp();
  }

  late final CameraInfoHostApiImpl _api;

  /// Gets sensor orientation degrees of camera.
  Future<int> getSensorRotationDegrees() =>
      _api.getSensorRotationDegreesFromInstance(this);
}

/// Host API implementation of [CameraInfo].
class CameraInfoHostApiImpl extends CameraInfoHostApi {
  /// Constructs a [CameraInfoHostApiImpl].
  CameraInfoHostApiImpl({
    this.binaryMessenger,
    InstanceManager? instanceManager,
  })  : instanceManager = instanceManager ?? JavaObject.globalInstanceManager,
        super(binaryMessenger: binaryMessenger);

  /// Sends binary data across the Flutter platform barrier.
  ///
  /// If it is null, the default BinaryMessenger will be used which routes to
  /// the host platform.
  final BinaryMessenger? binaryMessenger;

  /// Maintains instances stored to communicate with native language objects.
  final InstanceManager instanceManager;

  /// Gets sensor orientation degrees of [CameraInfo].
  Future<int> getSensorRotationDegreesFromInstance(CameraInfo instance) async {
    final int sensorRotationDegrees = await getSensorRotationDegrees(
        instanceManager.getIdentifier(instance)!);
    return sensorRotationDegrees;
  }
}

/// Flutter API implementation of [CameraInfo].
class CameraInfoFlutterApiImpl extends CameraInfoFlutterApi {
  /// Constructs a [CameraInfoFlutterApiImpl].
  CameraInfoFlutterApiImpl({
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
  void create(int identifier) {
    instanceManager.addHostCreatedInstance(
      CameraInfo.detached(
          binaryMessenger: binaryMessenger, instanceManager: instanceManager),
      identifier,
      onCopy: (CameraInfo original) {
        return CameraInfo.detached(
            binaryMessenger: binaryMessenger, instanceManager: instanceManager);
      },
    );
  }
}
