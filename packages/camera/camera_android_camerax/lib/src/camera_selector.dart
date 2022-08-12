// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'camera_filter.dart';
import 'instance_manager.dart';
import 'java_object.dart';

enum CameraXLensDirection {
  facing_front,
  facing_back,
}

class CameraSelector extends JavaObject {
  CameraSelector({int? lensFacing}) : super.detached() {
    _api.create(this, lensFacing);
  }

  CameraSelector.detached() : super.detached();

  static CameraSelectorHostApiImpl _api = CameraSelectorHostApiImpl();

  /// Selector for default front facing camera.
  static final CameraSelector defaultFrontCamera =
      requireLensFacing(CameraXLensDirection.facing_front);

  /// Selector for default back facing camera.
  static final CameraSelector defaultBackCamera =
      requireLensFacing(CameraXLensDirection.facing_back);

  /// Returns selector with the lens direction specified.
  CameraSelector requireLensFacing(int lensFacing) {
    return _api.requireLensFacingInInstance(
      instanceManager.getIdentifier(this)!,
      lensFacing,
    );
  }

  /// Filters available cameras based on provided [CameraInfo]s.
  List<CameraInfo> filter(List<CameraInfo> cameraInfos) {
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

  CameraSelector requireLensFacingInInstance(
    int instanceId,
    List<CameraInfo> cameraInfos,
  ) async {
    List<int> cameraInfoIds = cameraInfos.map<CameraInfo>(
        (CameraInfo info) => instanceManager.getIdentifier(info)!);
    int cameraSelectorId = await requireLensFacing(instanceId, cameraInfoIds);

    CameraSelector? cameraSelector = instanceManager
        .getInstanceWithWeakReference(cameraSelectorId) as CameraSelector;
    return cameraSelector;
  }

  List<CameraInfo> filterFromInstance(
    int instanceId,
    List<CameraInfo> cameraInfos,
  ) {
    List<int> cameraInfoIds = cameraInfos.map<CameraInfo>(
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
      CameraSelector.detached(lensFacing),
      identifier,
      onCopy: (CameraSelector original) =>
          CameraSelector.detached(
        binaryMessenger: binaryMessenger, //here
        instanceManager: instanceManager,
      ),
    );
  }
}
