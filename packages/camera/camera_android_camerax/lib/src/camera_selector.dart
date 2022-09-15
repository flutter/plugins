// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/services.dart';

import 'android_camera_camerax_flutter_api_impls.dart';
import 'camera_info.dart';
import 'camerax_library.pigeon.dart';
import 'instance_manager.dart';
import 'java_object.dart';

/// Selects a camera for use.
///
/// See https://developer.android.com/reference/androidx/camera/core/CameraSelector.
class CameraSelector extends JavaObject {
  /// Creates a [CameraSelector].
  CameraSelector(
      {this.binaryMessenger, this.instanceManager, this.lensFacing})
      : super.detached(
            binaryMessenger: binaryMessenger,
            instanceManager: instanceManager) {
    _api = CameraSelectorHostApiImpl(
      binaryMessenger: binaryMessenger,
      instanceManager: instanceManager,
    );
    AndroidCameraXCameraFlutterApis.instance.ensureSetUp();
    create(lensFacing);
  }

  /// Creates a detached [CameraSelector].
  CameraSelector.detached(
      {this.binaryMessenger, this.instanceManager, this.lensFacing})
      : super.detached(
            binaryMessenger: binaryMessenger,
            instanceManager: instanceManager) {
    _api = CameraSelectorHostApiImpl(
      binaryMessenger: binaryMessenger,
      instanceManager: instanceManager,
    );
    AndroidCameraXCameraFlutterApis.instance.ensureSetUp();
  }

  late final CameraSelectorHostApiImpl _api;

  /// ID for front facing lens.
  static const int LENS_FACING_FRONT = 0;

  /// ID for back facing lens.
  static const int LENS_FACING_BACK = 1;

  /// Selector for default front facing camera.
  static CameraSelector get defaultFrontCamera {
    CameraSelector defaultFrontCameraSelector =
      CameraSelector(lensFacing: LENS_FACING_FRONT);
    return instanceManager.getIdentifier(defaultFrontCameraSelector);
  }

  /// Selector for default back facing camera.
  static CameraSelector get defaultBackCamera {
    CameraSelector defaultBackCameraSelector =
      CameraSelector(lensFacing: LENS_FACING_BACK);
    return instanceManager.getIdentifier(defaultBackCameraSelector);
  }

  /// Receives binary data across the Flutter platform barrier.
  ///
  /// If it is null, the default BinaryMessenger will be used which routes to
  /// the host platform.
  final BinaryMessenger? binaryMessenger;

  /// Maintains instances stored to communicate with native language objects.
  final InstanceManager? instanceManager;

  /// Lens direction of this selector.
  final int? lensFacing;

  /// TODO
  void create(int? lensFacing) {
    _api.createFromInstances(this, lensFacing);
  }
  
  /// Filters available cameras based on provided [CameraInfo]s.
  Future<List<CameraInfo>> filter(List<CameraInfo> cameraInfos) {
    return _api.filterFromInstance(
      this,
      cameraInfos,
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

  /// Creates a [CameraSelector] with the lens direction provided if specified.
  void createFromInstances(int? lensFacing) async {
    int? identifier = instanceManager.getIdentifier(instance);
    identifier ??= instanceManager.addDartCreatedInstance(instance,
        onCopy: (CameraSelector original) {
      return CameraSelector.detached(
          binaryMessenger: binaryMessenger,
          instanceManager: instanceManager,
          lensFacing: original.lensFacing);
    });

    await create(identifer, lensFacing);
  }

  /// Filters a list of [CameraInfo]s based on the [CameraSelector].
  Future<List<CameraInfo>> filterFromInstance(
    CameraSelector instance,
    List<CameraInfo> cameraInfos,
  ) async {
    int? identifier = instanceManager.getIdentifier(instance);
    identifier ??= instanceManager.addDartCreatedInstance(instance,
        onCopy: (CameraSelector original) {
      return CameraSelector.detached(
          binaryMessenger: binaryMessenger,
          instanceManager: instanceManager,
          lensFacing: original.lensFacing);
    });

    final List<int> cameraInfoIds = (cameraInfos.map<int>(
        (CameraInfo info) => instanceManager.getIdentifier(info)!)).toList();
    final List<int?> filteredCameraInfoIds =
        await filter(identifier, cameraInfoIds);
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
      CameraSelector.detached(
          binaryMessenger: binaryMessenger,
          instanceManager: instanceManager,
          lensFacing: lensFacing),
      identifier,
      onCopy: (CameraSelector original) {
        return CameraSelector.detached(
            binaryMessenger: binaryMessenger,
            instanceManager: instanceManager,
            lensFacing: original.lensFacing);
      },
    );
  }
}
