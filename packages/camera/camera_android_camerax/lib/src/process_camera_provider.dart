// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/services.dart';

import 'android_camera_camerax_flutter_api_impls.dart';
import 'camera.dart';
import 'camera_info.dart';
import 'camera_selector.dart';
import 'camerax_library.g.dart';
import 'instance_manager.dart';
import 'java_object.dart';
import 'use_case.dart';

/// Provides an object to manage the camera.
///
/// See https://developer.android.com/reference/androidx/camera/lifecycle/ProcessCameraProvider.
class ProcessCameraProvider extends JavaObject {
  /// Creates a detached [ProcessCameraProvider].
  ProcessCameraProvider.detached(
      {BinaryMessenger? binaryMessenger, InstanceManager? instanceManager})
      : super.detached(
            binaryMessenger: binaryMessenger,
            instanceManager: instanceManager) {
    _api = ProcessCameraProviderHostApiImpl(
        binaryMessenger: binaryMessenger, instanceManager: instanceManager);
    AndroidCameraXCameraFlutterApis.instance.ensureSetUp();
  }

  late final ProcessCameraProviderHostApiImpl _api;

  /// Gets an instance of [ProcessCameraProvider].
  static Future<ProcessCameraProvider> getInstance(
      {BinaryMessenger? binaryMessenger, InstanceManager? instanceManager}) {
    AndroidCameraXCameraFlutterApis.instance.ensureSetUp();
    final ProcessCameraProviderHostApiImpl api =
        ProcessCameraProviderHostApiImpl(
            binaryMessenger: binaryMessenger, instanceManager: instanceManager);

    return api.getInstancefromInstances();
  }

  /// Retrieves the cameras available to the device.
  Future<List<CameraInfo>> getAvailableCameraInfos() {
    return _api.getAvailableCameraInfosFromInstances(this);
  }

  /// Binds the specified [UseCase]s to the lifecycle of the camera that it
  /// returns.
  Future<Camera> bindToLifecycle(
      CameraSelector cameraSelector, List<UseCase> useCases) {
    return _api.bindToLifecycleFromInstances(this, cameraSelector, useCases);
  }

  /// Unbinds specified [UseCase]s from the lifecycle of the camera that this
  /// instance tracks.
  void unbind(List<UseCase> useCases) {
    _api.unbindFromInstances(this, useCases);
  }

  /// Unbinds all previously bound [UseCase]s from the lifecycle of the camera
  /// that this tracks.
  void unbindAll() {
    _api.unbindAllFromInstances(this);
  }
}

/// Host API implementation of [ProcessCameraProvider].
class ProcessCameraProviderHostApiImpl extends ProcessCameraProviderHostApi {
  /// Creates a [ProcessCameraProviderHostApiImpl].
  ProcessCameraProviderHostApiImpl(
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

  /// Retrieves an instance of a ProcessCameraProvider from the context of
  /// the FlutterActivity.
  Future<ProcessCameraProvider> getInstancefromInstances() async {
    return instanceManager.getInstanceWithWeakReference(await getInstance())!
        as ProcessCameraProvider;
  }

  /// Gets identifier that the [instanceManager] has set for
  /// the [ProcessCameraProvider] instance.
  int getProcessCameraProviderIdentifier(ProcessCameraProvider instance) {
    final int? identifier = instanceManager.getIdentifier(instance);

    assert(identifier != null,
        'No ProcessCameraProvider has the identifer of that which was requested.');
    return identifier!;
  }

  /// Retrives the list of CameraInfos corresponding to the available cameras.
  Future<List<CameraInfo>> getAvailableCameraInfosFromInstances(
      ProcessCameraProvider instance) async {
    final int identifier = getProcessCameraProviderIdentifier(instance);
    final List<int?> cameraInfos = await getAvailableCameraInfos(identifier);
    return cameraInfos
        .map<CameraInfo>((int? id) =>
            instanceManager.getInstanceWithWeakReference(id!)! as CameraInfo)
        .toList();
  }

  /// Binds the specified [UseCase]s to the lifecycle of the camera which
  /// the provided [ProcessCameraProvider] instance tracks.
  ///
  /// The instance of the camera whose lifecycle the [UseCase]s are bound to
  /// is returned.
  Future<Camera> bindToLifecycleFromInstances(
    ProcessCameraProvider instance,
    CameraSelector cameraSelector,
    List<UseCase> useCases,
  ) async {
    final int identifier = getProcessCameraProviderIdentifier(instance);
    final List<int> useCaseIds = useCases
        .map<int>((UseCase useCase) => instanceManager.getIdentifier(useCase)!)
        .toList();

    final int cameraIdentifier = await bindToLifecycle(
      identifier,
      instanceManager.getIdentifier(cameraSelector)!,
      useCaseIds,
    );
    return instanceManager.getInstanceWithWeakReference(cameraIdentifier)!
        as Camera;
  }

  /// Unbinds specified [UseCase]s from the lifecycle of the camera which the
  /// provided [ProcessCameraProvider] instance tracks.
  void unbindFromInstances(
    ProcessCameraProvider instance,
    List<UseCase> useCases,
  ) {
    final int identifier = getProcessCameraProviderIdentifier(instance);
    final List<int> useCaseIds = useCases
        .map<int>((UseCase useCase) => instanceManager.getIdentifier(useCase)!)
        .toList();

    unbind(identifier, useCaseIds);
  }

  /// Unbinds all previously bound [UseCase]s from the lifecycle of the camera
  /// which the provided [ProcessCameraProvider] instance tracks.
  void unbindAllFromInstances(ProcessCameraProvider instance) {
    final int identifier = getProcessCameraProviderIdentifier(instance);
    unbindAll(identifier);
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
      ProcessCameraProvider.detached(
          binaryMessenger: binaryMessenger, instanceManager: instanceManager),
      identifier,
      onCopy: (ProcessCameraProvider original) {
        return ProcessCameraProvider.detached(
            binaryMessenger: binaryMessenger, instanceManager: instanceManager);
      },
    );
  }
}
