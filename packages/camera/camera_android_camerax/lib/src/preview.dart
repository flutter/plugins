// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/services.dart' show BinaryMessenger;

import 'camerax_library.g.dart';
import 'instance_manager.dart';
import 'java_object.dart';
import 'use_case.dart';

/// Use case that provides a camera preview stream for display.
///
/// See https://developer.android.com/reference/androidx/camera/core/Preview.
class Preview extends UseCase {
  /// Creates a [Preview].
  Preview(
      {BinaryMessenger? binaryMessenger,
      InstanceManager? instanceManager,
      this.targetRotation,
      this.targetResolution})
      : super.detached(
            binaryMessenger: binaryMessenger,
            instanceManager: instanceManager) {
    _api = PreviewHostApiImpl(
        binaryMessenger: binaryMessenger, instanceManager: instanceManager);
    _api.createFromInstance(this, targetRotation, targetResolution);
  }

  /// Constructs a [Preview] that is not automatically attached to a native object.
  Preview.detached(
      {BinaryMessenger? binaryMessenger,
      InstanceManager? instanceManager,
      this.targetRotation,
      this.targetResolution})
      : super.detached(
            binaryMessenger: binaryMessenger,
            instanceManager: instanceManager) {
    _api = PreviewHostApiImpl(
        binaryMessenger: binaryMessenger, instanceManager: instanceManager);
  }

  late final PreviewHostApiImpl _api;

  /// Target rotation of the camera used for the preview stream.
  final int? targetRotation;

  /// Target resolution of the camera preview stream.
  final ResolutionInfo? targetResolution;

  /// Sets the surface provider for the preview stream.
  ///
  /// Returns the ID of the FlutterSurfaceTextureEntry used on the native end
  /// used to display the preview stream on a [Texture] of the same ID.
  Future<int> setSurfaceProvider() {
    return _api.setSurfaceProviderFromInstance(this);
  }

  /// Releases Flutter surface texture used to provide a surface for the preview
  /// stream.
  void releaseFlutterSurfaceTexture() {
    _api.releaseFlutterSurfaceTextureFromInstance();
  }

  /// Retrieves the selected resolution information of this [Preview].
  Future<ResolutionInfo> getResolutionInfo() {
    return _api.getResolutionInfoFromInstance(this);
  }
}

/// Host API implementation of [Preview].
class PreviewHostApiImpl extends PreviewHostApi {
  /// Constructs a [PreviewHostApiImpl].
  PreviewHostApiImpl({this.binaryMessenger, InstanceManager? instanceManager}) {
    this.instanceManager = instanceManager ?? JavaObject.globalInstanceManager;
  }

  /// Receives binary data across the Flutter platform barrier.
  ///
  /// If it is null, the default BinaryMessenger will be used which routes to
  /// the host platform.
  final BinaryMessenger? binaryMessenger;

  /// Maintains instances stored to communicate with native language objects.
  late final InstanceManager instanceManager;

  /// Creates a [Preview] with the target rotation provided if specified.
  void createFromInstance(
      Preview instance, int? targetRotation, ResolutionInfo? targetResolution) {
    final int identifier = instanceManager.addDartCreatedInstance(instance,
        onCopy: (Preview original) {
      return Preview.detached(
          binaryMessenger: binaryMessenger,
          instanceManager: instanceManager,
          targetRotation: original.targetRotation);
    });
    create(identifier, targetRotation, targetResolution);
  }

  /// Sets the surface provider of the specified [Preview] instance and returns
  /// the ID corresponding to the surface it will provide.
  Future<int> setSurfaceProviderFromInstance(Preview instance) async {
    final int? identifier = instanceManager.getIdentifier(instance);
    assert(identifier != null,
        'No Preview has the identifer of that requested to set the surface provider on.');

    final int surfaceTextureEntryId = await setSurfaceProvider(identifier!);
    return surfaceTextureEntryId;
  }

  /// Releases Flutter surface texture used to provide a surface for the preview
  /// stream if a surface provider was set for a [Preview] instance.
  void releaseFlutterSurfaceTextureFromInstance() {
    releaseFlutterSurfaceTexture();
  }

  /// Gets the resolution information of the specified [Preview] instance.
  Future<ResolutionInfo> getResolutionInfoFromInstance(Preview instance) async {
    final int? identifier = instanceManager.getIdentifier(instance);
    assert(identifier != null,
        'No Preview has the identifer of that requested to get the resolution information for.');

    final ResolutionInfo resolutionInfo = await getResolutionInfo(identifier!);
    return resolutionInfo;
  }
}
