// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter/foundation.dart';

import 'common/camera_interface.dart';

/// Controls a device camera.
///
/// Use [CameraController.availableCameras] to get a list of available cameras.
///
/// This class is used as a simple interface that works for Android and iOS. To
/// access device/API specific features see [SupportAndroidCamera].
///
/// Depending on device/API, you may only be able to open one CameraController
/// at a time. Make sure to call [dispose] when access to the camera is no
/// longer needed.
class CameraController {
  /// Default constructor.
  ///
  /// This will choose the best [CameraConfigurator] for the current device.
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

  /// Constructor for defining your own [CameraConfigurator].
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

  /// Details for the camera this controller accesses.
  final CameraDescription description;

  /// The configurator used to control the camera.
  final CameraConfigurator configurator;

  /// The api used for this camera.
  final CameraApi api;

  /// Retrieves a list of available cameras for the current device.
  ///
  /// This will choose the best [CameraAPI] for the current device.
  static Future<List<CameraDescription>> availableCameras() async {
    throw UnimplementedError('$defaultTargetPlatform not supported');
  }

  /// Starts processing for the camera.
  Future<void> start() => configurator.start();

  /// Stops all processing for the camera.
  Future<void> stop() => configurator.stop();

  /// Deallocate all resources and disables further use of the camera.
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
        throw UnimplementedError();
    }

    return null;
  }

  static CameraApi _getCameraApi(CameraDescription description) {
    throw ArgumentError.value(
      description.runtimeType,
      'description.runtimeType',
      'Failed to get $CameraApi from',
    );
  }
}
