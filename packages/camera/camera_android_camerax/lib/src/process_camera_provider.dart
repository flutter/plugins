// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/services.dart';

import 'android_camera_camerax_flutter_api_impls.dart';
import 'camera_info.dart';
import 'camerax.pigeon.dart';
import 'instance_manager.dart';
import 'java_object.dart';

/// Provides an object to manage the camera.
///
/// See https://developer.android.com/reference/androidx/camera/lifecycle/ProcessCameraProvider.
class ProcessCameraProvider extends JavaObject {
  /// Creates a detached [ProcessCameraProvider].
  ProcessCameraProvider.detached() : super.detached();

  ProcessCameraProviderHostApiImpl? _api;

  /// Instantiates Host and Flutter APIs for the [ProcessCameraProvider] class.
  void setUpProcessCameraProviderApis(
      BinaryMessenger? binaryMessenger, InstanceManager? instanceManager) {
    _api ??= ProcessCameraProviderHostApiImpl(
      binaryMessenger: binaryMessenger,
      instanceManager: instanceManager,
    );
  }

  /// Gets an instance of [ProcessCameraProvider].
  static Future<ProcessCameraProvider> getInstance(
      {BinaryMessenger? binaryMessenger, InstanceManager? instanceManager}) {
    AndroidCameraXCameraFlutterApis.instance.ensureSetUp();
    // setUpProcessCameraProviderApis(binaryMessenger, instanceManager);
     ProcessCameraProviderHostApiImpl api = ProcessCameraProviderHostApiImpl(
      binaryMessenger: binaryMessenger,
      instanceManager: instanceManager,
    );

    return api.getInstancefromInstances();
  }

  /// Retrieves the cameras available to the device.
  Future<List<CameraInfo>> getAvailableCameraInfos(
      {BinaryMessenger? binaryMessenger, InstanceManager? instanceManager}) {
    setUpProcessCameraProviderApis(binaryMessenger, instanceManager);
    assert(_api != null);

    AndroidCameraXCameraFlutterApis.instance.ensureSetUp();
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
      onCopy: (ProcessCameraProvider original) {return ProcessCameraProvider.detached();},
    );
  }
}
