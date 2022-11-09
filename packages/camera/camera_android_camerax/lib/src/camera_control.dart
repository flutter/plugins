// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/services.dart' show BinaryMessenger;

import 'android_camera_camerax_flutter_api_impls.dart';
import 'camerax_library.pigeon.dart';
import 'instance_manager.dart';
import 'java_object.dart';

class CameraControl extends JavaObject {
  /// Constructs a [Camera] that is not automatically attached to a native object. 
    CameraControl.detached(
      {BinaryMessenger? binaryMessenger,
      InstanceManager? instanceManager})
    : super.detached(
        binaryMessenger: binaryMessenger,
        instanceManager: instanceManager) {
    _api = CameraControlHostApiImpl(
      binaryMessenger: binaryMessenger, instanceManager: instanceManager);
    AndroidCameraXCameraFlutterApis.instance.ensureSetUp();
   }

  late final CameraControlHostApiImpl _api;

  /// Sets the zoom ratio of the [Camera] this instance corresponds to.
  void setZoomRatio(int ratio) {
    return _api.setZoomRatioFromInstance(this, ratio);
  }
}

/// Host API implementation of [CameraControl].
class CameraControlHostApiImpl extends CameraControlHostApi {
  /// Constructs a [CameraHostApiImpl].
  CameraControlHostApiImpl(
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

  /// Waits for the specified zoom ratio to be set by the camera.
  void setZoomRatioFromInstance(CameraControl instance, int ratio) {
    int? identifier = instanceManager.getIdentifier(instance);
    identifier ??= instanceManager.addDartCreatedInstance(instance,
        onCopy: (CameraControl original) {
      return CameraControl.detached(
          binaryMessenger: binaryMessenger,
          instanceManager: instanceManager);
    });

    setZoomRatio(identifier, ratio);
  }
}

/// Flutter API implementation of [CameraControl].
class CameraControlFlutterApiImpl implements CameraControlFlutterApi {
  /// Constructs a [CameraSelectorFlutterApiImpl].
  CameraControlFlutterApiImpl({
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
      CameraControl.detached(
          binaryMessenger: binaryMessenger,
          instanceManager: instanceManager),
      identifier,
      onCopy: (CameraControl original) {
        return CameraControl.detached(
            binaryMessenger: binaryMessenger,
            instanceManager: instanceManager);
      },
    );
  }
}
