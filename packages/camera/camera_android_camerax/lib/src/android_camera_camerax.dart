// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:camera_platform_interface/camera_platform_interface.dart';

import 'camera_info.dart';
import 'camera_selector.dart';
import 'process_camera_provider.dart';

class AndroidCameraCameraX extends CameraPlatform {
  /// Registers this calss as the default instance of [CameraPlatform].
  static void registerWith() {
    CameraPlatform.instance = AndroidCameraCamerax();

    CameraInfoFlutterApi.setup(CameraInfoFlutterApiImpl());
    CameraSelectorFlutterApi.setup(CameraSelectorFlutterApiImpl());
    ProcessCameraProviderFlutterApi.setup(ProcessCameraProviderFlutterApiImpl());
  }

  /// Returns list of all available cameras and their descriptions.
  @override
  Future<List<CameraDescription>> availableCameras() async {
    ProcessCameraProvider provider = provider.getInstance();
    List<CameraInfo>? availableCameraInfos = provider.getAvailableCameras();

    List<CameraDescription> cameraDescriptions;

    availableCameraInfos.forEach((CameraInfo info) {
      CameraDescription description;

      // Check if it is a front camera.
      List<CameraInfo>? frontCameras =
          CameraSelector.DEFAULT_FRONT_CAMERA.filter(<CameraInfo>[info]);

      if (frontCameras != null) {
        description = createCameraDescription(frontCameras.get(0),
            CameraLensDirection.front); // There should only be one?
        cameraDescriptions
            .add(description); // Might need to avoid duplicates here?
        return;
      }

      // Check if it is a back camera.
      List<CameraInfo>? backCameras =
          CameraSelector.DEFAULT_BACK_CAMERA.filter(<CameraInfo>[info]);

      if (backCameras != null) {
        description = createCameraDescription(backCameras.get(0),
            CameraLensDirection.back); // There should only be one?
        cameraDescriptions
            .add(description); // Might need to avoid duplicates here?
      }
    });

    return cameraDescriptions;
  }

  /// Helper method that creates descriptions of cameras.
  CameraDescription createCameraDescription(
      CameraInfo cameraInfo, CameraLensDirection lensDirection) {
    String name =
        'cam' + lensDirection.toString().toUpperCase();
    int sensorOrientation = cameraInfo.getSensorRotationDegrees();

    return CameraDescription(
      name: name,
      lensDirection: lensDirection,
      sensorOrientation: sensorOrientation
    );
  }
}
