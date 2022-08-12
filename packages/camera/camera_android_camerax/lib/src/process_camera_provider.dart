// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'instance_manager.dart';
import 'java_object.dart';

class ProcessCameraProvider extends JavaObject {
  ProcessCameraProvider.detached({super.binaryMessenger, super.instanceManager})
      : _api = ProcessCameraProviderHostApiImpl(
          binaryMessenger: binaryMessenger,
          instanceManager: instanceManager,
        ),
        super.detached();

  static final ProcessCameraProviderHostApiImpl _api;

  static Future<ProcessCameraProvider> getInstance(
      {BinaryMessenger? binaryMessenger, InstanceManager? instanceManager}) {
    ProcessCameraProviderFlutterApi.setup(ProcessCameraProviderFlutterApiImpl(
        binaryMessenger: binaryMessenger, instanceManager: instanceMananger));

    return ProcessCameraProviderHostApiImpl(
      binaryMessenger: binaryMessenger,
      instanceManager: instanceManager,
    ).getInstancefromInstances();
  }

  Future<List<CameraProvider>> getAvailableCameras() {
    return _api.getAvailableCamerasFromIntances();
  }
}

class ProcessCameraProviderHostApiImpl extends ProcessCameraProviderHostApi {
  ProcessCameraProviderHostApiImpl({
    this.binaryMessenger,
    InstanceManager? instanceManager,
  })  : instanceManager = instanceManager ?? JavaObject.globalInstanceManager,
        super(binaryMessenger: binaryMessenger);

  final BinaryMessenger? binaryMessenger;

  final InstanceManager instanceManager;

  // Retrieves an instance of a ProcessCameraProvider from the context of
  // the FlutterActivity.
  Future<ProcessCameraProvider> getInstancefromInstances() async {
    return instanceManager.getInstance(await getInstance());
  }

  // Retrives the list of CameraInfos corresponding to the available cameras.
  List<CameraInfo> getAvailableCamerasFromIntances() async {
    List<int> cameraInfos = await getAvailableCameras();

    return cameraInfos.map<CameraInfo>((int id) =>
        instanceManager.getInstanceWithWeakReference(id) as CameraInfo);
  }
}

class ProcessCameraProviderFlutterApiImpl
    implements ProcessCameraProviderFlutterApi {
  /// Constructs a [ProcessCameraProviderFlutterApiImpl].
  ProcessCameraProviderFlutterApiImpl({
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
      ProcessCameraProvider.detached(),
      identifier,
      onCopy: (ProcessCameraProvider original) =>
          ProcessCameraProvider.detached(
        binaryMessenger: binaryMessenger,
        instanceManager: instanceManager,
      ),
    );
  }
}
