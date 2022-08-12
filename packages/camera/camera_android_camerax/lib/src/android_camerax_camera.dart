// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'process_camera_provider.dart';

class AndroidCameraCameraX {
  /// Returns list of all available cameras and their descriptions.
  Future<List<CameraDescription>> availableCameras() {
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

      //Check if it is a back camera.
      List<CameraInfo>? backCameras =
          CameraSelector.DEFAULT_BACK_CAMERA.filter(<CameraInfo>[info]);

      if (backCameras != null) {
        description = createCameraDescription(backCameras.get(0),
            CameraLensDirection.back); // There should only be one?
        cameraDescriptions
            .add(description); // Might need to avoid duplicates here
      }
    });

    return cameraDescriptions;
  }

  /// Helper method that creates descriptions of cameras.
  CameraDescription createCameraDescription(
      CameraInfo cameraInfo, CameraLensDirection lensDirection) {
    String name =
        lensDirection.toString() + '-camera'; //TODO(cs): check actual format
    int sensorOrientation = cameraInfo.getSensorRotationDegrees();

    return CameraDescription(name, lensDirection, sensorOrientation);
  }
}
