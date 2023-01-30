// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:camera_platform_interface/camera_platform_interface.dart';
import 'package:flutter/foundation.dart';

import 'camera_info.dart';
import 'camera_selector.dart';
import 'process_camera_provider.dart';

/// The Android implementation of [CameraPlatform] that uses the CameraX library.
class AndroidCameraCameraX extends CameraPlatform {
  /// Registers this class as the default instance of [CameraPlatform].
  static void registerWith() {
    CameraPlatform.instance = AndroidCameraCameraX();
  }

  ProcessCameraProvider? processCameraProvider;
  CameraSelector? backCameraSelector;
  CameraSelector? frontCameraSelector;


  /// Returns list of all available cameras and their descriptions.
  @override
  Future<List<CameraDescription>> availableCameras() async {
    final List<CameraDescription> cameraDescriptions = <CameraDescription>[];

    processCameraProvider ??= await ProcessCameraProvider.getInstance();
    final List<CameraInfo> cameraInfos =
        await processCameraProvider!.getAvailableCameraInfos();

    backCameraSelector ??= CameraSelector.getDefaultBackCamera();
    frontCameraSelector ??= CameraSelector.getDefaultFrontCamera();

    CameraLensDirection? cameraLensDirection;
    int cameraCount = 0;
    int? cameraSensorOrientation;
    String? cameraName;

    for (final CameraInfo cameraInfo in cameraInfos) {
      // Determine the lens direction by filtering the CameraInfo
      // TODO(gmackall): replace this with call to CameraInfo.getLensFacing when changes containing that method are available
      if ((await backCameraSelector!.filter(<CameraInfo>[cameraInfo]))
          .isNotEmpty) {
        cameraLensDirection = CameraLensDirection.back;
      } else if ((await frontCameraSelector!.filter(<CameraInfo>[cameraInfo]))
          .isNotEmpty) {
        cameraLensDirection = CameraLensDirection.front;
      } else {
        //Skip this CameraInfo as its lens direction is unknown
        continue;
      }

      cameraSensorOrientation = await cameraInfo.getSensorRotationDegrees();
      cameraName = 'Camera $cameraCount';
      cameraCount++;

      cameraDescriptions.add(CameraDescription(
          name: cameraName,
          lensDirection: cameraLensDirection,
          sensorOrientation: cameraSensorOrientation));
    }

    return cameraDescriptions;
  }

  @visibleForTesting
  void setDefaultFrontCameraSelector(CameraSelector frontCameraSelector) {
    this.frontCameraSelector = frontCameraSelector;
  }

  @visibleForTesting
  void setDefaultBackCameraSelector(CameraSelector backCameraSelector) {
    this.backCameraSelector = backCameraSelector;
  }

  @visibleForTesting
  void setProcessCameraProvider(ProcessCameraProvider processCameraProvider) {
    this.processCameraProvider = processCameraProvider;
  }
}