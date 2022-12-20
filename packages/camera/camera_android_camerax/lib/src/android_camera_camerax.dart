// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:camera_platform_interface/camera_platform_interface.dart';
import 'package:flutter/widgets.dart';

import 'camera.dart';
import 'camera_selector.dart';
import 'preview.dart';
import 'process_camera_provider.dart';
import 'surface.dart';
import 'use_case.dart';

/// The Android implementation of [CameraPlatform] that uses the CameraX library.
class AndroidCameraCameraX extends CameraPlatform {
  Preview? preview;
  ProcessCameraProvider? processCameraProvider;
  int? cameraId;
  ResolutionPreset? targetResolutionPreset;

  Camera? _camera;
  CameraDescription? _cameraDescription;
  CameraSelector? _cameraSelector;
  ImageFormatGroup? _imageFormatGroup;

  /// Registers this class as the default instance of [CameraPlatform].
  static void registerWith() {
    CameraPlatform.instance = AndroidCameraCameraX();
  }

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

  Stream<CameraEvent> _cameraEvents(int cameraId) =>
      cameraEventStreamController.stream
          .where((CameraEvent event) => event.cameraId == cameraId);

  /// The controller we need to broadcast the different events coming
  /// from handleMethodCall, specific to general device events.
  ///
  /// It is a `broadcast` because multiple controllers will connect to
  /// different stream views of this Controller.
  late final StreamController<DeviceEvent> _deviceEventStreamController =
      StreamController<DeviceEvent>.broadcast();

  /// Returns list of all available cameras and their descriptions.
  @override
  Future<List<CameraDescription>> availableCameras() async {
    throw UnimplementedError('availableCameras() is not implemented.');
  }

  /// Creates an unititialized camera instance and returns the cameraId.
  @override
  Future<int> createCamera(
    CameraDescription cameraDescription,
    ResolutionPreset? resolutionPreset, {
    bool enableAudio = false,
  }) async {
    // TODO(camism99): Request permissions here.

    _cameraDescription = cameraDescription;
    processCameraProvider = await ProcessCameraProvider.getInstance();

    // Create Preview to set surface provider and gain access to Flutter
    // surface texture ID.
    int targetRotation = getTargetRotation(cameraDescription.sensorOrientation);
    Map<String?, int?>? targetResolution = getTargetPreviewResolution(resolutionPreset);
    preview = Preview(targetRotation: targetRotation, targetResolution: targetResolution);
    int flutterSurfaceTextureId = await preview!.setSurfaceProvider();

    return flutterSurfaceTextureId;
  }

  /// Initializes the camera on the device.
  @override
  Future<void> initializeCamera(
    int cameraId, {
    ImageFormatGroup imageFormatGroup = ImageFormatGroup.unknown,
  }) async {
    // TODO(camsim99): Determine how to use imageFormatGroup.
    _imageFormatGroup = imageFormatGroup;

    onCameraInitialized(cameraId).first.then((CameraInitializedEvent value) {
      completer.complete();
    });

    // Values set for testing purposes.
    // TODO(camisim99): Determine each of these values dynamically.
    assert(preview != null);
    // TODO(camsim99): Change this list to a map with keys and values.
    List<int?> previewResolutionInfo = await preview!.getResolutionInfo();
    double previewWidth = previewResolutionInfo[0]!;
    double previewHeight = previewResolutionInfo[1]!;
    ExposureMode exposureMode = ExposureMode.auto;
    FocusMode focusMode = FocusMode.auto;
    bool exposurePointSupported = false;
    bool focusPointSupported = false;

    cameraEventStreamController.add(CameraInitializedEvent(
      cameraId,
      previewWidth,
      previewHeight,
      exposureMode,
      exposurePointSupported,
      focusMode,
      focusPointSupported
    ));
  }

  /// Pause the active preview on the current frame for the selected camera.
  @override
  Future<void> pausePreview(int cameraId) async {
    processCameraProvider!.unbind(<UseCase>[preview!]);
  }

  /// Resume the paused preview for the selected camera.
  @override
  Future<void> resumePreview(int cameraId) async {
    Camera camera = await processCameraProvider!
        .bindToLifecycle(_cameraSelector!, <UseCase>[preview!]);
  }

  /// Returns a widget showing a live camera preview.
  @override
  Widget buildPreview(int cameraId) {
    return FutureBuilder<void>(
      future: bindPreviewToLifecycle(),
      builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.none:
          case ConnectionState.waiting:
          case ConnectionState.active:
            // TODO(camsim99): Determine what loading state should be.
            return const Text('Loading camera preview...');
          case ConnectionState.done:
              return Texture(textureId: cameraId);
        }
      }
    );
  }

  // Callback methods:

  @override
  Stream<CameraInitializedEvent> onCameraInitialized(int cameraId) {
    return _cameraEvents(cameraId).whereType<CameraInitializedEvent>();
  }

  @override
  Stream<DeviceOrientationChangedEvent> onDeviceOrientationChanged() {
    return _deviceEventStreamController.stream
        .whereType<DeviceOrientationChangedEvent>();
  }

  Future<void> bindPreviewToLifecycle() async {
    int? lensFacing = getCameraSelectorLens(_cameraDescription!.lensDirection);
    _cameraSelector = CameraSelector(lensFacing: lensFacing!);
    _camera = await processCameraProvider!.bindToLifecycle(_cameraSelector!, <UseCase>[preview!]);
  }

  // Helper methods for camera configurations exposed to Flutter apps:

  int? getCameraSelectorLens(CameraLensDirection lensDirection) {
    switch (lensDirection) {
      case CameraLensDirection.front:
        return CameraSelector.LENS_FACING_FRONT;
      case CameraLensDirection.back:
        return CameraSelector.LENS_FACING_BACK;
      case CameraLensDirection.external:
        return null;
    }
  }

  // Returns target rotation mapping between Android Surface rotation keys and the rotation
  // in degrees.
  int getTargetRotation(int sensorOrientation) {
    switch (sensorOrientation) {
      case 90:
        return Surface.ROTATION_90;
      case 180:
        return Surface.ROTATION_180;
      case 270:
        return Surface.ROTATION_270;
      case 0:
      default:
        return Surface.ROTATION_0;
    }
  }

  // Returns resolution mapping between Android resolution specification and ResolutionPreset values
  // for camera preview.
  Map<String?, int?>? getTargetPreviewResolution(ResolutionPreset? resolution) {
    if (resolution == null) {
      return null;
    }
    
    // TODO(camsim99): Define constants for resolution height/width keys.
    switch (resolution) {
      case ResolutionPreset.low:
        return <String?, int?>{
          'width': 320,
          'height': 240,
        };
      case ResolutionPreset.medium:
        return <String?, int?>{
          'width': 720,
          'height': 480,
        };
      case ResolutionPreset.high:
        return <String?, int?>{
          'width': 1280,
          'height': 720,
        };
      case ResolutionPreset.veryHigh:
        return <String?, int?>{
          'width': 1920,
          'height': 1080,
        };
      case ResolutionPreset.ultraHigh:
        return <String?, int?>{
          'width': 3840,
          'height': 2160,
        };
      case ResolutionPreset.max:
        // TODO(camsim99): Determine if this is a behavior match.
        // See https://developer.android.com/training/camerax/configuration#automatic-resolution.
        return null;
    }
  }
}
