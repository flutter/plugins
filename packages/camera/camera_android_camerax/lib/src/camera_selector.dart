// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

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

  CameraSelector.detached():
      : super.detached();
    
  static CameraSelectorHostApiImpl _api = CameraSelectorHostApiImpl();

  /// Selector for default front facing camera.
  final static CameraSelector defaultFrontCamera =
    requireLensFacing(CameraXLensDirection.facing_front);

  /// Selector for default back facing camera.
  final static CameraSelector defaultBackCamera =
    requireLensFacing(CameraXLensDirection.facing_back);

  /// Filters available cameras based on provided [CameraInfo]s.
  List<CameraInfo> filter(List<CameraInfo> cameraInfos) {
     _api.filterFromInstance(
       instanceManager.getIdentifier(this)!,
       cameraInfos,
    );
  }

  /// Returns selector with the lens direction specified.
  CameraSelector requireLensFacing(int lensFacing) {
    _api.requireLensFacingFromInstance(
      instanceManager.getIdentifier(this)!,
      lensFacing,
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

  CameraSelector requireLensFacingFromInstance(
    int instanceId,
    List<CameraInfo> cameraInfos,
  ) async {
    List<int> cameraInfoIds =
      cameraInfos
        .map<CameraInfo>((CameraInfo info) => instanceManager.getIdentifier(info)!);
        cameraInfos.map<CameraInfo>((int id) => instanceManager.getInstanceWithWeakReference(id));
    int cameraSelectorId = await requireLensFacing(instanceId, cameraInfoIds);
    
    CameraSelector? cameraSelector =
      instanceManager
        .getInstanceWithWeakReference(cameraSelectorId) as CameraSelector;
    return cameraSelector;
  }

  List<CameraInfo> filterFromInstance(
    int instanceId,
    List<CameraInfo> cameraInfos,
  ) {
    List<int> cameraInfoIds = cameraIn
    List<int> filteredCameraInfoIds = await filter(instanceId, cameraInfoIds);
    return 
      filteredCameraInfoIds
        .map<CameraInfo>((int id) => instanceManager.getInstanceWithWeakReference(id) as CameraInfo);
  }
}
