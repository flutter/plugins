// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/services.dart';

import 'camera_info.dart';
import 'camerax.pigeon.dart';
import 'instance_manager.dart';
import 'java_object.dart';

class CameraSelector extends JavaObject {
  CameraSelector({
    super.binaryMessenger,
    super.instanceManager,
    int? lensFacing}) :
    super.detached(),
    _api = CameraSelectorHostApiImpl(
      binaryMessenger: binaryMessenger,
      instanceManager: instanceManager,
    );
    // _api.create(this, lensFacing); // ???
  // }

  CameraSelector.detached() : super.detached();

  final BinaryMessenger? binaryMessenger;

  final InstanceManager instanceManager;

  static late final CameraSelectorHostApiImpl _api;

  static final int LENS_FACING_BACK = 1;
  /// Selector for default front facing camera.
  static final CameraSelector defaultFrontCamera =
    CameraSelector().requireLensFacing(LENS_FACING_BACK);

  static final int LENS_FACING_FRONT = 0;
  /// Selector for default back facing camera.
  static final CameraSelector defaultBackCamera =
    CameraSelector().requireLensFacing(LENS_FACING_FRONT);

  /// Returns selector with the lens direction specified.
  Future<CameraSelector> requireLensFacing(int lensFacing) {
    CameraSelectorFlutterApi.setup(
      CameraSelectorFlutterApiImpl(
        binaryMessenger: binaryMessenger,
        instanceManager: instanceManager,
      )
    );
    return _api.requireLensFacingInInstance(
      instanceManager.getIdentifier(this)!,
      lensFacing,
    );
  }

  /// Filters available cameras based on provided [CameraInfo]s.
  Future<List<CameraInfo>> filter(List<CameraInfo> cameraInfos) {
    return _api.filterFromInstance(
      instanceManager.getIdentifier(this)!,
      cameraInfos,
    );
  }
}

class CameraSelectorHostApiImpl extends CameraSelectorHostApi {
  /// Constructs a [CameraSelectorHostApiImpl].
  CameraSelectorHostApiImpl({
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

  Future<CameraSelector> requireLensFacingInInstance(
    int instanceId,
    int lensFacing,
  ) async {
    int cameraSelectorId = await requireLensFacing(instanceId, lensFacing);

    CameraSelector? cameraSelector = instanceManager
        .getInstanceWithWeakReference(cameraSelectorId) as CameraSelector;
    return cameraSelector;
  }

  Future<List<CameraInfo>> filterFromInstance(
    int instanceId,
    List<CameraInfo> cameraInfos,
  ) async {
    List<int> cameraInfoIds = cameraInfos.map<int>(
        (CameraInfo info) => instanceManager.getIdentifier(info)!);
    List<int> filteredCameraInfoIds = await filter(instanceId, cameraInfoIds);
    return filteredCameraInfoIds.map<CameraInfo>((int id) =>
        instanceManager.getInstanceWithWeakReference(id) as CameraInfo);
  }
}

class CameraSelectorFlutterApiImpl
    implements CameraSelectorFlutterApi {
  /// Constructs a [CameraSelectorFlutterApiImpl].
  CameraSelectorFlutterApiImpl({
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
  void create(int identifier, int? lensFacing) {
    instanceManager.addHostCreatedInstance(
      CameraSelector.detached(lensFacing: lensFacing),
      identifier,
      onCopy: (CameraSelector original) =>
          CameraSelector.detached(
            binaryMessenger: binaryMessenger,
            instanceManager: instanceManager,
            lensFacing: lensFacing,
      ),
    );
  }
}
