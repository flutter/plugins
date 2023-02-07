// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:camera_platform_interface/camera_platform_interface.dart';
import 'package:flutter/widgets.dart';
import 'package:stream_transform/stream_transform.dart';

import 'camera.dart';
import 'camera_selector.dart';
import 'camerax_library.g.dart';
import 'preview.dart';
import 'process_camera_provider.dart';
import 'surface.dart';
import 'system_services.dart';
import 'use_case.dart';

/// The Android implementation of [CameraPlatform] that uses the CameraX library.
class AndroidCameraCameraX extends CameraPlatform {
  /// Registers this class as the default instance of [CameraPlatform].
  static void registerWith() {
    CameraPlatform.instance = AndroidCameraCameraX();
  }

  // Objects used to access camera functionality:

  /// The [ProcessCameraProvider] instance used to access camera functionality.
  ProcessCameraProvider? processCameraProvider;

  /// The [Camera] instance returned by the [processCameraProvider] when a [UseCase] is
  /// bound to the lifecycle of the camera it manages.
  Camera? camera;
  
  // Use cases to configure and bind to ProcessCameraProvider instance:

  /// The [Preview] instance that can be instantiated adn configured to present
  /// a live camera preview.
  Preview? preview;

  // Objects used for camera configuration:
  CameraSelector? _cameraSelector;

  /// The controller we need to broadcast the different events coming
  /// from handleMethodCall, specific to camera events.
  ///
  /// It is a `broadcast` because multiple controllers will connect to
  /// different stream views of this Controller.
  /// This is only exposed for test purposes. It shouldn't be used by clients of
  /// the plugin as it may break or change at any time.
  @visibleForTesting
  final StreamController<CameraEvent> cameraEventStreamController =
      StreamController<CameraEvent>.broadcast();

  /// The stream of camera events.
  Stream<CameraEvent> _cameraEvents(int cameraId) =>
      cameraEventStreamController.stream
          .where((CameraEvent event) => event.cameraId == cameraId);

  // Implementation of Flutter camera platform interface (CameraPlatform):

  /// Returns list of all available cameras and their descriptions.
  @override
  Future<List<CameraDescription>> availableCameras() async {
    throw UnimplementedError('availableCameras() is not implemented.');
  }

  /// Creates an uninitialized camera instance and returns the cameraId.
  ///
  /// In the CameraX library, cameras are accessed by combining [UseCase]s
  /// to an instance of a [ProcessCameraProvider]. Thus, to create an
  /// unitialized camera instance, this method retrieves a
  /// [ProcessCameraProvider] instance.
  ///
  /// To return the cameraID, which represents the ID of the surface texture
  /// that a camera preview can be drawn to, a [Preview] instance is configured
  /// and bound to the [ProcessCameraProvider] instance.
  @override
  Future<int> createCamera(
    CameraDescription cameraDescription,
    ResolutionPreset? resolutionPreset, {
    bool enableAudio = false,
  }) async {
    // Must obtatin proper permissions before attempts to access a camera.
    await SystemServices.requestCameraPermissions(enableAudio);

    // Start listening for device orientation changes preceding camera creation.
    final int cameraSelectorLensDirection = _getCameraSelectorLensDirection(cameraDescription.lensDirection);
    final bool cameraIsFrontFacing = cameraSelectorLensDirection == CameraSelector.LENS_FACING_FRONT;
    _cameraSelector = CameraSelector(lensFacing: cameraSelectorLensDirection);
    SystemServices.startListeningForDeviceOrientationChange(cameraIsFrontFacing, cameraDescription.sensorOrientation);

    // Retrieve a ProcessCameraProvider instance.
    // TODO(camsim99): Always get a new one?
    processCameraProvider = await ProcessCameraProvider.getInstance();

    // Configure Preview instance and bind to ProcessCameraProvider.
    final int targetRotation = _getTargetRotation(cameraDescription.sensorOrientation);
    final ResolutionInfo? targetResolution = _getTargetResolutionForPreview(resolutionPreset);
    preview = Preview(targetRotation: targetRotation, targetResolution: targetResolution);
    final int flutterSurfaceTextureId = await preview!.setSurfaceProvider();
  
    return flutterSurfaceTextureId;
  }

  /// Initializes the camera on the device.
  ///
  /// [imageFormatGroup] is used to specify the image formatting used.
  /// On Android this defaults to ImageFormat.YUV_420_888 and applies only to
  /// the image stream.
  @override
  Future<void> initializeCamera(
    int cameraId, {
    ImageFormatGroup imageFormatGroup = ImageFormatGroup.unknown,
  }) async {
    // TODO(camsim99): Use imageFormatGroup to configure ImageAnalysis use case
    // for image streaming.

    // Configure CameraInitializedEvent to send as representation of a
    // configured camera:

    // Retrieve preview resolution.
    assert (
      preview != null,
      'Preview instance not found. Please call the "createCamera" method before calling "initializeCamera"',
    );
    await _bindPreviewToLifecycle();
    final ResolutionInfo previewResolutionInfo = await preview!.getResolutionInfo();
    _unbindPreviewFromLifecycle();

    // Retrieve exposure and focus mode configurations:
    
    // TODO(camsim99): Implement support for retrieving exposure mode configuration.
    const ExposureMode exposureMode = ExposureMode.auto;
    const bool exposurePointSupported = false;

    // TODO(camsim99): Implement support for retrieving focus mode configuration.
    const FocusMode focusMode = FocusMode.auto;
    const bool focusPointSupported = false;

    cameraEventStreamController.add(
      CameraInitializedEvent(
        cameraId,
        previewResolutionInfo.width.toDouble(),
        previewResolutionInfo.height.toDouble(),
        exposureMode,
        exposurePointSupported,
        focusMode,
        focusPointSupported)
    );  
  }

  /// Releases the resources of the accessed camera.
  @override
  Future<void> dispose(int cameraId) async {
    preview?.releaseFlutterSurfaceTexture();
    processCameraProvider?.unbindAll();
  }

  /// Callback method for the initialization of a camera.
  @override
  Stream<CameraInitializedEvent> onCameraInitialized(int cameraId) {
    return _cameraEvents(cameraId).whereType<CameraInitializedEvent>();
  }

  /// Callback method for native camera errors.
  @override
  Stream<CameraErrorEvent> onCameraError(int cameraId) {
    return SystemServices
      .cameraErrorStreamController
      .stream
      .map<CameraErrorEvent>((String errorDescription) {
        return CameraErrorEvent(cameraId, errorDescription);
      });
  }

  /// Callback method for changes in device orientation.
  @override
  Stream<DeviceOrientationChangedEvent> onDeviceOrientationChanged() {
    return SystemServices.deviceOrientationChangedStreamController.stream;
  }

  /// Pause the active preview on the current frame for the selected camera.
  @override
  Future<void> pausePreview(int cameraId) async {
    // TODO(camsim99): Determine whether or not to track if preview is paused or not. Or really how to manage preview and binding.
    _unbindPreviewFromLifecycle();
  }

  /// Resume the paused preview for the selected camera.
  @override
  Future<void> resumePreview(int cameraId) async {
    _bindPreviewToLifecycle();
  }

  /// Returns a widget showing a live camera preview.
  @override
  Widget buildPreview(int cameraId) {
    return FutureBuilder<void>(
      future: _bindPreviewToLifecycle(),
      builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.none:
          case ConnectionState.waiting:
          case ConnectionState.active:
            // Do nothing while waiting for preview to be bound to lifecyle.
            return const SizedBox.shrink();
          case ConnectionState.done:
            return Texture(textureId: cameraId);
        }
      }
    );
  }

  // Methods for binding UseCases to the lifecycle of the camera controlled
  // by a ProcessCameraProvider instance:

  /// Binds [Preview] instance to the camera lifecycle controlled by the
  /// [processCameraProvider].
  Future<void> _bindPreviewToLifecycle() async {
    assert(processCameraProvider != null);
    assert(_cameraSelector != null);

    camera = await processCameraProvider!.bindToLifecycle(_cameraSelector!, <UseCase>[preview!]);
  }

  /// Unbinds [Preview] instance to camera lifecycle controlled by the
  /// [processCameraProvider].
  void _unbindPreviewFromLifecycle() {
    if (preview == null) {
      return;
    }

    assert(processCameraProvider != null);
    processCameraProvider!.unbind(<UseCase>[preview!]);
  }

  // Methods for mapping Flutter camera constants to CameraX constants:

  /// Returns [CameraSelector] lens direction that maps to specified
  /// [CameraLensDirection].
  int _getCameraSelectorLensDirection(CameraLensDirection lensDirection) {
    switch (lensDirection) {
      case CameraLensDirection.front:
        return CameraSelector.LENS_FACING_FRONT;
      case CameraLensDirection.back:
        return CameraSelector.LENS_FACING_BACK;
      case CameraLensDirection.external:
        return CameraSelector.EXTERNAL;
    }
  }

  /// Returns [Surface] target rotation constant that maps to specified sensor
  /// orientation.
  int _getTargetRotation(int sensorOrientation) {
    switch (sensorOrientation) {
      case 90:
        return Surface.ROTATION_90;
      case 180:
        return Surface.ROTATION_180;
      case 270:
        return Surface.ROTATION_270;
      case 0:
        return Surface.ROTATION_0;
      default:
        throw ArgumentError(
          '"$sensorOrientation" is not a valid sensor orientation value');
    }    
  }

  /// Returns [ResolutionInfo] that maps to the specified resolution preset for
  /// a camera preview.
  ResolutionInfo? _getTargetResolutionForPreview(ResolutionPreset? resolution) {  
    // TODO(camsim99): Implement resolution configuration.
    return null;
  }
}
