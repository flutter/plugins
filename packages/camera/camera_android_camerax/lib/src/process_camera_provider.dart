// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/services.dart';

import 'camera_info.dart';
import 'camerax.pigeon.dart';
import 'instance_manager.dart';
import 'java_object.dart';

/// Provides an object to manage the camera.
class ProcessCameraProvider extends JavaObject {
  /// Creates a [ProcessCameraProvider].
  ProcessCameraProvider({super.binaryMessenger, super.instanceManager})
      : binaryMessenger = binaryMessenger,
        instanceManager = instanceManager,
        super.detached();

  /// Creates a detached [ProcessCameraProvider].
  ProcessCameraProvider.detached({super.binaryMessenger, super.instanceManager})
      : super.detached();

  ProcessCameraProviderHostApiImpl? _api;

  /// Sends binary data across the Flutter platform barrier.
  BinaryMessenger? binaryMessenger;

  /// Maintains instances store to communicate with native language objects.
  InstanceManager? instanceManager;

  /// Gets an instance of [ProcessCameraProvider].
  static Future<ProcessCameraProvider> getInstance(
      {BinaryMessenger? binaryMessenger, InstanceManager? instanceManager}) {
    ProcessCameraProviderFlutterApi.setup(ProcessCameraProviderFlutterApiImpl(
        binaryMessenger: binaryMessenger, instanceManager: instanceManager));

    return ProcessCameraProviderHostApiImpl(
      binaryMessenger: binaryMessenger,
      instanceManager: instanceManager,
    ).getInstancefromInstances();
  }

  /// Retrieves the cameras available to the device.
  Future<List<CameraInfo>> getAvailableCameraInfos() {
    _api = ProcessCameraProviderHostApiImpl(
      binaryMessenger: binaryMessenger,
      instanceManager: instanceManager,
    );
    print("calling getAvailableCameraInfos");
    return _api!.getAvailableCameraInfosFromInstances(
        JavaObject.globalInstanceManager.getIdentifier(this)!);
  }
}

/// Host API implementation of [ProcessCameraProvider].
class ProcessCameraProviderHostApiImpl extends ProcessCameraProviderHostApi {
  /// Creates a [ProcessCameraProviderHostApiImpl].
  ProcessCameraProviderHostApiImpl({
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

  /// Retrieves an instance of a ProcessCameraProvider from the context of
  /// the FlutterActivity.
  Future<ProcessCameraProvider> getInstancefromInstances() async {
    return instanceManager.getInstanceWithWeakReference(await getInstance())!
        as ProcessCameraProvider;
  }

  /// Retrives the list of CameraInfos corresponding to the available cameras.
  Future<List<CameraInfo>> getAvailableCameraInfosFromInstances(
      int instanceId) async {
    final List<int?> cameraInfos = await getAvailableCameraInfos(instanceId);
    print(cameraInfos);
    return (cameraInfos.map<CameraInfo>((int? id) =>
            instanceManager.getInstanceWithWeakReference(id!)! as CameraInfo))
        .toList();
  }
}

/// Flutter API Implementation of [ProcessCameraProvider].
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
