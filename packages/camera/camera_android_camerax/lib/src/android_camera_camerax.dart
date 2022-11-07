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
import 'use_case.dart';

/// The Android implementation of [CameraPlatform] that uses the CameraX library.
class AndroidCameraCameraX extends CameraPlatform {
  
  Preview? preview;
  CameraSelector? cameraSelector;
  ProcessCameraProvider? processCameraProvider;
  int? cameraId;

  /// Registers this class as the default instance of [CameraPlatform].
  static void registerWith() {
    CameraPlatform.instance = AndroidCameraCameraX();
  }

  /// Returns list of all available cameras and their descriptions.
  @override
  Future<List<CameraDescription>> availableCameras() async {
    throw UnimplementedError('availableCameras() is not implemented.');
  }

  /// Creates an unititialized camera instance adn returns the cameraId
  /// in theory! [?]
  @override
  Future<int> createCamera(
    CameraDescription cameraDescription,
    ResolutionPreset? resolutionPreset, {
    bool enableAudio = false,
  }) async {
    processCameraProvider = await ProcessCameraProvider.getInstance();
    preview = Preview();
    cameraSelector = CameraSelector(lensFacing: CameraSelector.LENS_FACING_FRONT);
    
    // Will save as a field since more operations will need this camera
    Camera camera = await processCameraProvider!.bindToLifecycle(cameraSelector!, <UseCase>[preview!]);

    // cameraId = await 
    return preview!.setSurfaceProvider();
    // return cameraId;
  }

  /// Returns a widget showing a live camera preview.
  @override
  Widget buildPreview(int cameraId) {
    return Texture(textureId: cameraId);
  }
}
