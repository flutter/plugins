// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/services.dart' show BinaryMessenger;

import 'android_camera_camerax_flutter_api_impls.dart';
import 'camera_control.dart';
import 'camerax_library.pigeon.dart';
import 'instance_manager.dart';
import 'java_object.dart';

class Camera extends JavaObject {
  /// Constructs a [Camera] that is not automatically attached to a native object. 
    Camera.detached(
      {BinaryMessenger? binaryMessenger,
      InstanceManager? instanceManager})
    : super.detached(
        binaryMessenger: binaryMessenger,
        instanceManager: instanceManager) {
    _api = CameraHostApiImpl(
      binaryMessenger: binaryMessenger, instanceManager: instanceManager);
    AndroidCameraXCameraFlutterApis.instance.ensureSetUp();
   }

  late final CameraHostApiImpl _api;

  /// Get the instance [CameraControl] that controls this instance.
  Future<CameraControl> getCameraControl() {
    return _api.getCameraControlFromInstance(this);
  }
}

/// Host API implementation of [Camera].
class CameraHostApiImpl extends CameraHostApi {
  /// Constructs a [CameraHostApiImpl].
  CameraHostApiImpl(
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

  /// Retrieves instance of [CameraControl] that corresponds to the specified
  /// instance of the [Camera].
  Future<CameraControl> getCameraControlFromInstance(Camera instance) async {
    int? identifier = instanceManager.getIdentifier(instance);
    identifier ??= instanceManager.addDartCreatedInstance(instance,
        onCopy: (Camera original) {
      return Camera.detached(
          binaryMessenger: binaryMessenger,
          instanceManager: instanceManager);
    });

    int cameraControlId = await getCameraControl(identifier);
    return instanceManager.getInstanceWithWeakReference(cameraControlId)! as CameraControl;
  }
}

/// Flutter API implementation of [Camera].
class CameraFlutterApiImpl implements CameraFlutterApi {
  /// Constructs a [CameraSelectorFlutterApiImpl].
  CameraFlutterApiImpl({
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
      Camera.detached(
          binaryMessenger: binaryMessenger,
          instanceManager: instanceManager),
      identifier,
      onCopy: (Camera original) {
        return Camera.detached(
            binaryMessenger: binaryMessenger,
            instanceManager: instanceManager);
      },
    );
  }
}
