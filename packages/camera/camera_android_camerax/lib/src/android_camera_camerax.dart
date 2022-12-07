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
  CameraSelector? cameraSelector;
  ProcessCameraProvider? processCameraProvider;
  int? cameraId;
  ResolutionPreset? targetResolutionPreset;
  Future<Camera>? camera;
  CameraDescription? cameraDescription;

  /// Registers this class as the default instance of [CameraPlatform].
  static void registerWith() {
    CameraPlatform.instance = AndroidCameraCameraX();
  }

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
    processCameraProvider = await ProcessCameraProvider.getInstance();

    // Set target resolution.
    List<int>? targetResolution;
    if (targetResolutionPreset != null) {
      targetResolution = getTargetResolution(targetResolutionPreset!);

      if (targetResolution[0] > 1920 && targetResolution[1] > 1080) {
        preview = Preview();
      } else {
        preview = Preview(
            targetWidth: targetResolution[0],
            targetHeight: targetResolution[1]);
      }
    } else {
      preview = Preview();
    }

    targetResolutionPreset = resolutionPreset;
    cameraDescription = cameraDescription;

    // Determine lens direction.
    int? lensFacing = getCameraSelectorLens(cameraDescription!.lensDirection);
    // TODO(camsim99): Throw error if external camera is attempted to be used.
    cameraSelector = CameraSelector(lensFacing: lensFacing!);

    // Set target rotation.
    // TODO(camsim99): can actually do this in constructor
    int targetRotation =
        getTargetRotation(cameraDescription!.sensorOrientation);
    preview!.setTargetRotation(targetRotation);

    camera = await processCameraProvider!
        .bindToLifecycle(cameraSelector!, <UseCase>[preview!]);

    return preview!.setSurfaceProvider();
  }

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

  /// Pause the active preview on the current frame for the selected camera.
  @override
  Future<void> pausePreview(int cameraId) async {
    processCameraProvider!.unbind(<UseCase>[preview!]);
  }

  /// Resume the paused preview for the selected camera.
  @override
  Future<void> resumePreview(int cameraId) async {
    Camera camera = await processCameraProvider!
        .bindToLifecycle(cameraSelector!, <UseCase>[preview!]);
  }

  /// Returns a widget showing a live camera preview.
  @override
  Widget buildPreview(int cameraId) {
    return Texture(textureId: cameraId);
  }

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

  List<int> getTargetResolution(ResolutionPreset resolution) {
    switch (resolution) {
      case ResolutionPreset.low:
        return <int>[320, 240];
      case ResolutionPreset.medium:
        return <int>[720, 480]; // can depend on device orientation?
      case ResolutionPreset.high:
        return <int>[1280, 720];
      case ResolutionPreset.veryHigh:
        return <int>[1920, 1080];
      case ResolutionPreset.ultraHigh:
        return <int>[3840, 2160];
      case ResolutionPreset.max:
        return <int>[
          1920,
          1080
        ]; // the highest resolution CameraX supports for Preview. TODO(camsim99): Will actually need to retrieve this with https://developer.android.com/reference/android/hardware/camera2/params/StreamConfigurationMap#getOutputSizes(int)
    }
  }
}
