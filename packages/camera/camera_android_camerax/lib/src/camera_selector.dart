// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/services.dart';

import 'camera_info.dart';
import 'camerax.pigeon.dart';
import 'instance_manager.dart';
import 'java_object.dart';

/// Selects a camera for use.
class CameraSelector extends JavaObject {
  /// Creates a [CameraSelector].
  CameraSelector.detached(
    {this.binaryMessenger, this.instanceManager, this.lensFacing})
       : super.detached(binaryMessenger: binaryMessenger, instanceManager: instanceManager) {
    setUpApis(binaryMessenger, instanceManager);  
  }

  /// Sends binary data across the Flutter platform barrier.
  late final BinaryMessenger? binaryMessenger;

  /// Maintains instances store to communicate with native language objects.
  late final InstanceManager? instanceManager;

  static CameraSelectorHostApiImpl? _api;

  static CameraSelectorFlutterApiImpl? _flutterApi;

  /// ID for back facing lens.
  static const int LENS_FACING_BACK = 1;

  /// ID for front facing lens.
  static const int LENS_FACING_FRONT = 0;

  /// Lens direction of this selector.
  final int? lensFacing;

  static void setUpApis(BinaryMessenger? binaryMessenger, InstanceManager? instanceManager) {
    if (_flutterApi == null) {
      _flutterApi = CameraSelectorFlutterApiImpl(
        binaryMessenger: binaryMessenger, instanceManager: instanceManager);
      CameraSelectorFlutterApi.setup(_flutterApi);
    }

    if (_api == null) {
      _api = CameraSelectorHostApiImpl(
      binaryMessenger: binaryMessenger,
      instanceManager: instanceManager,
      );
    }
  }

  /// Selector for default front facing camera.
  static final Future<CameraSelector> defaultFrontCamera =
      CameraSelector.detached().requireLensFacing(LENS_FACING_FRONT);

  /// Selector for default back facing camera.
  static final Future<CameraSelector> defaultBackCamera =
      CameraSelector.detached().requireLensFacing(LENS_FACING_BACK);

  /// Returns selector with the lens direction specified.
  Future<CameraSelector> requireLensFacing(int lensFacing) {
    setUpApis(binaryMessenger, instanceManager);
    return _api!.requireLensFacingInInstance(lensFacing);
  }

  /// Filters available cameras based on provided [CameraInfo]s.
  Future<List<CameraInfo>> filter(List<CameraInfo> cameraInfoIds) {
    setUpApis(binaryMessenger, instanceManager);
    return _api!.filterFromInstance(
      this,
      cameraInfoIds,
    );
  }
}

/// Host API implementation of [CameraSelector].
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

  /// Modifies a [CameraSelector] to have the lens direction specified.
  Future<CameraSelector> requireLensFacingInInstance(int lensFacing) async {
    final int cameraSelectorId = await requireLensFacing(lensFacing);
    final CameraSelector? cameraSelector =
      instanceManager
        .getInstanceWithWeakReference(cameraSelectorId) as CameraSelector?;

    return cameraSelector!;
  }

  /// Filters a list of [CameraInfo]s based on the [CameraSelector].
  Future<List<CameraInfo>> filterFromInstance(
    CameraSelector instance,
    List<CameraInfo> cameraInfos,
  ) async {
    int? instanceId = instanceManager.getIdentifier(instance);
    if (instanceId == null) {
      instanceId = instanceManager.addDartCreatedInstance(instance);
    } 
    final List<int> cameraInfoIds = (cameraInfos.map<int>(
        (CameraInfo info) => instanceManager.getIdentifier(info)!)).toList();
    final List<int?> filteredCameraInfoIds =
        await filter(instanceId!, cameraInfoIds);
    if (filteredCameraInfoIds.isEmpty) {
      return <CameraInfo>[];
    }
    return (filteredCameraInfoIds.map<CameraInfo>((int? id) =>
            instanceManager.getInstanceWithWeakReference(id!)! as CameraInfo))
        .toList();
  }
}

/// Flutter API implementation of [CameraSelector].
class CameraSelectorFlutterApiImpl implements CameraSelectorFlutterApi {
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
    );
  }
}
