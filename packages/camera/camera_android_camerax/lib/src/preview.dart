// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/services.dart' show BinaryMessenger;

import 'android_camera_camerax_flutter_api_impls.dart';
import 'camerax_library.pigeon.dart';
import 'instance_manager.dart';
import 'java_object.dart';

/// Use case that provides a camera preview stream for display.
///
/// See https://developer.android.com/reference/androidx/camera/core/Preview.
class Preview extends UseCase {
  /// Creates a [Preview].
  Preview(
      {BinaryMessenger? binaryMessenger,
      InstanceManager? instanceManager,
      this.targetRotation})
      : super(
            binaryMessenger: binaryMessenger,
            instanceManager: instanceManager) {
    _api = PreviewHostApiImpl(
        binaryMessenger: binaryMessenger, instanceManager: instanceManager);
    AndroidCameraXCameraFlutterApis.instance.ensureSetUp();
    _api.createFromInstance(this, targetRotation);
  }

  /// Constructs a [CameraInfo] that is not automatically attached to a native object. 
  Preview.detached(
      {BinaryMessenger? binaryMessenger,
      InstanceManager? instanceManager,
      this.targetRotation})
      : super(
            binaryMessenger: binaryMessenger,
            instanceManager: instanceManager) {
    _api = PreviewHostApiImpl(
        binaryMessenger: binaryMessenger, instanceManager: instanceManager);
    AndroidCameraXCameraFlutterApis.instance.ensureSetUp();
  }

  late final PreviewHostApiImpl _api;

  /// Target rotation of the camera used for the preview stream.
  final int? targetRotation;

  /// [?] Sets surface provider for the preview stream.
  ///
  /// Returns the ID of the FlutterSurfaceTextureEntry used on the back end
  /// used to display the preview stream on a [Texture] of the same ID.
  Future<int> setSurfaceProvider() {
    return _api.setSurfaceProviderFromInstance(this);
  }

  /// Reconfigures the preview stream to have the specified target rotation.
  void setTargetRotation(int targetRotation) {
    _api.setTargetRotationFromInstance(this, targetRotation);
  }
}

/// Host API implementation of [Preview].
class PreviewHostApiImpl extends PreviewHostApi {
  /// Constructs a [PreviewHostApiImpl].
  PreviewHostApiImpl(
      {super.binaryMessenger, InstanceManager? instanceManager}) {
    this.instanceManager = instanceManager ?? JavaObject.globalInstanceManager;
  }

  /// Maintains instances stored to communicate with native language objects.
  late final InstanceManager instanceManager;

  /// Creates a [Preview] with the target rotation provided if specified.
  void createFromInstance(Preview instance, int? targetRotation) {
    int? identifier = instanceManager.getIdentifier(instance);
    identifier ??= instanceManager.addDartCreatedInstance(instance,
        onCopy: (Preview original) {
      return Preview.detached(
          binaryMessenger: binaryMessenger,
          instanceManager: instanceManager,
          targetRotation: original.targetRotation);
    });
  }

  /// Sets the surface provider of the provided [Preview] instance and returns
  /// the ID corresponding to the surface it will provide.
  Future<int> setSurfaceProviderFromInstance(Preview instance) {
    int? identifier = instanceManager.getIdentifier(instance);
    identifier ??= instanceManager.addDartCreatedInstance(instance,
        onCopy: (Preview original) {
      return Preview.detached(
          binaryMessenger: binaryMessenger,
          instanceManager: instanceManager,
          targetRotation: original.targetRotation);
    });

    int surfaceTextureEntryId = await setSurfaceProvider(identifier);
    return surfaceTextureEntryId;
  }

  /// Sets the [Preview]'s target rotation to be that which is specified.
  void setTargetRotationFromInstance(Preview instance, int targetRotation) {
    int? identifier = instanceManager.getIdentifier(instance);
    identifier ??= instanceManager.addDartCreatedInstance(instance,
        onCopy: (Preview original) {
      return Preview.detached(
          binaryMessenger: binaryMessenger,
          instanceManager: instanceManager,
          targetRotation: original.targetRotation);
    });

    setTargetRotation(identifier, targetRotation);
  }

}

/// Flutter API implementation of [Preview].
class PreviewFlutterApiImpl extends PreviewFlutterApi {
  /// Constructs a [PreviewFlutterApiImpl].
  PreviewFlutterApiImpl({
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
      Preview.detached(
          binaryMessenger: binaryMessenger, instanceManager: instanceManager, targetRotation: targetRotation),
      identifier,
      onCopy: (Preview original) {
        return Preview.detached(
            binaryMessenger: binaryMessenger, instanceManager: instanceManager, targetRotation: targetRotation);
      },
    );
  }
}
