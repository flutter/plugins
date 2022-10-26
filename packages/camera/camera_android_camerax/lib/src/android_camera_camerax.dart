// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:camera_platform_interface/camera_platform_interface.dart';

/// The Android implementation of [CameraPlatform] that uses the CameraX library.
class AndroidCameraCameraX extends CameraPlatform {
  /// Registers this class as the default instance of [CameraPlatform].
  static void registerWith() {
    CameraPlatform.instance = AndroidCameraCameraX();
  }

  /// Returns list of all available cameras and their descriptions.
  @override
  Future<List<CameraDescription>> availableCameras() async {
    throw UnimplementedError('availableCameras() is not implemented.');
  }

  /// [?] buildPreview pseudocode
  /// Returns a widget showing a live camera preview.
  @override
  Widget buildPreview(int cameraId) {
    ProcessCameraProvider processCameraProvider = processCameraProvider.getInstance();
    Preview preview = new Preview();
    CameraSelector cameraSelector = new CameraSelector(CameraSelector.LENS_FACING_FRONT);
    
    // [A] //
    int textureId = preview.setSurfaceProvider();

    // Will save as a field since more operations will need this camera
    Camera camera = processCameraProvider.bindToLifecycle(cameraSelector, preview);
    return Texture(textureId: textureId);
  }
}
