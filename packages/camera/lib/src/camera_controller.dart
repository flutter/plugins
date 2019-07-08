// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter/foundation.dart';

import '../support_android_camera.dart';
import 'common/camera_interface.dart';
import 'support_android_camera_configurator.dart';

class CameraController {
  factory CameraController({@required CameraDescription description}) {
    assert(description != null);
    return CameraController._(
      description: description,
      configurator: _createDefaultConfigurator(description),
      api: _getCameraApi(description),
    );
  }

  CameraController._({
    @required this.description,
    @required this.configurator,
    @required this.api,
  })  : assert(description != null),
        assert(configurator != null),
        assert(api != null);

  factory CameraController.customConfigurator({
    @required CameraDescription description,
    @required CameraConfigurator configurator,
  }) {
    return CameraController._(
      description: description,
      configurator: configurator,
      api: _getCameraApi(description),
    );
  }

  final CameraDescription description;
  final CameraConfigurator configurator;
  final CameraApi api;

  static Future<List<CameraDescription>> availableCameras() async {
    final List<CameraDescription> devices = <CameraDescription>[];

    if (defaultTargetPlatform == TargetPlatform.android) {
      final int numCameras = await SupportAndroidCamera.getNumberOfCameras();
      for (int i = 0; i < numCameras; i++) {
        devices.add(await SupportAndroidCamera.getCameraInfo(i));
      }
    } else {
      throw UnimplementedError('$defaultTargetPlatform not supported');
    }

    return devices;
  }

  Future<void> start() => configurator.start();
  Future<void> stop() => configurator.stop();
  Future<void> dispose() => configurator.dispose();

  static CameraConfigurator _createDefaultConfigurator(
    CameraDescription description,
  ) {
    final CameraApi api = _getCameraApi(description);
    switch (api) {
      case CameraApi.android:
        throw UnimplementedError();
      case CameraApi.iOS:
        throw UnimplementedError();
      case CameraApi.supportAndroid:
        return SupportAndroidCameraConfigurator(description);
    }

    return null;
  }

  static CameraApi _getCameraApi(CameraDescription description) {
    if (description is CameraInfo) {
      return CameraApi.supportAndroid;
    }

    throw ArgumentError.value(
      description.runtimeType,
      'description.runtimeType',
      'Failed to get $CameraApi from',
    );
  }
}
