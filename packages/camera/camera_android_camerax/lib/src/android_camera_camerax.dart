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

    //TODO(cs): link these to the actual Flutter Apis that are used?
    // CameraInfoFlutterApi.setup(CameraInfoFlutterApiImpl());
    // CameraSelectorFlutterApi.setup(CameraSelectorFlutterApiImpl());
    // ProcessCameraProviderFlutterApi.setup(
    //     ProcessCameraProviderFlutterApiImpl());
  }

  /// Returns list of all available cameras and their descriptions.
  @override
  Future<List<CameraDescription>> availableCameras() async {
    final ProcessCameraProvider provider =
        await ProcessCameraProvider.getInstance();
    final List<CameraInfo> availableCameraInfos =
        await provider.getAvailableCameraInfos();
    final List<CameraDescription> cameraDescriptions = <CameraDescription>[];

    if (availableCameraInfos == null) {
      return cameraDescriptions;
    }

    final CameraSelector defaultFromCameraSelector =
        await CameraSelector.defaultFrontCamera;
    final CameraSelector defaultBackCameraSelector =
        await CameraSelector.defaultBackCamera;

    for (final CameraInfo info in availableCameraInfos) {
      // Check if it is a front camera.
      final List<CameraInfo> frontCamerasFiltered =
          await defaultFromCameraSelector.filter(<CameraInfo>[info]);
      if (frontCamerasFiltered != null) {
        final CameraDescription description = await createCameraDescription(
            frontCamerasFiltered[0],
            CameraLensDirection.front); // There should only be one?
        cameraDescriptions
            .add(description); // Might need to avoid duplicates here?
        break;
      }

      // Check if it is a back camera.
      final List<CameraInfo> backCamerasFiltered =
          await defaultBackCameraSelector.filter(<CameraInfo>[info]);
      if (backCamerasFiltered != null) {
        final CameraDescription description = await createCameraDescription(
            backCamerasFiltered[0],
            CameraLensDirection.back); // There should only be one?
        cameraDescriptions
            .add(description); // Might need to avoid duplicates here?
      }
    }

    return cameraDescriptions;
  }

  /// Helper method that creates descriptions of cameras.
  Future<CameraDescription> createCameraDescription(
      CameraInfo cameraInfo, CameraLensDirection lensDirection) async {
    final String name = 'cam ${lensDirection.toString().toUpperCase()}';
    final int sensorOrientation = await cameraInfo.getSensorRotationDegrees();

    return CameraDescription(
        name: name,
        lensDirection: lensDirection,
        sensorOrientation: sensorOrientation);
  }
}
