// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:camera_platform_interface/camera_platform_interface.dart';

import 'camera_info.dart';
import 'camera_selector.dart';
import 'camerax.pigeon.dart';
import 'process_camera_provider.dart';

/// The Android implementation of [CameraPlatform] that uses the CameraX library.
class AndroidCameraCameraX extends CameraPlatform {
  /// Registers this calss as the default instance of [CameraPlatform].
  static void registerWith() {
    CameraPlatform.instance = AndroidCameraCameraX();

    CameraInfoFlutterApi.setup(CameraInfoFlutterApiImpl());
    CameraSelectorFlutterApi.setup(CameraSelectorFlutterApiImpl());
    ProcessCameraProviderFlutterApi.setup(
        ProcessCameraProviderFlutterApiImpl());
  }

  /// Returns list of all available cameras and their descriptions.
  @override
  Future<List<CameraDescription>> availableCameras() async {
    final ProcessCameraProvider provider =
        await ProcessCameraProvider.getInstance();
    final List<CameraInfo> availableCameraInfos =
        await provider.getAvailableCameras();
    final List<CameraDescription> cameraDescriptions = <CameraDescription>[];

    if (availableCameraInfos == null) {
      return cameraDescriptions;
    }

    for (final CameraInfo info in availableCameraInfos) {
      CameraDescription description;

      // Check if it is a front camera.      
      CameraSelector.defaultFrontCamera.then((CameraSelector frontCameras) {
        List<CameraInfo> frontCamerasFiltered = frontCameras.filter(<CameraInfo>[info]);
        if (frontCamerasFiltered != null) {
          description = createCameraDescription(frontCamerasFiltered[0],
              CameraLensDirection.front); // There should only be one?
          cameraDescriptions
              .add(description); // Might need to avoid duplicates here?
          return;
        }
      });

      // Check if it is a back camera.
      CameraSelector.defaultBackCamera.then((CameraSelector backCameras) { 
        List<CameraInfo> backCamerasFiltered = backCameras.filter(<CameraInfo>[info]);
        if (backCamerasFiltered != null) {
          description = createCameraDescription(backCamerasFiltered[0],
              CameraLensDirection.back); // There should only be one?
          cameraDescriptions
              .add(description); // Might need to avoid duplicates here?
        }
      });
    }

    return cameraDescriptions;
  }

  /// Helper method that creates descriptions of cameras.
  CameraDescription createCameraDescription(
      CameraInfo cameraInfo, CameraLensDirection lensDirection) {
    final String name = 'cam ${lensDirection.toString().toUpperCase()}';
    final int sensorOrientation = await cameraInfo.getSensorRotationDegrees();

    return CameraDescription(
        name: name,
        lensDirection: lensDirection,
        sensorOrientation: sensorOrientation);
  }
}
