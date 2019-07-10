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
/// This class is used as a simple interface that works for Android and iOS.
///
/// When using iOS, simultaneously calling [start] on two [CameraController]s
/// will throw a [PlatformException].
///
/// When using Android, simultaneously calling [start] on two
/// [CameraController]s may throw a [PlatformException] depending on the
/// hardware resources of the device.
class CameraController {
  /// Default constructor.
  ///
  /// Use [CameraController.availableCameras] to get a list of available
  /// cameras.
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
  ///
  /// Use [CameraController.availableCameras] to get a list of available
  /// cameras.
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

  /// Configurator used to control the camera.
  final CameraConfigurator configurator;

  /// Api used by the [configurator].
  final CameraApi api;

  /// Retrieves a list of available cameras for the current device.
  ///
  /// This will choose the best [CameraAPI] for the current device.
  static Future<List<CameraDescription>> availableCameras() async {
    throw UnimplementedError('$defaultTargetPlatform not supported');
  }

  /// Begins the flow of data between the inputs and outputs connected the camera instance.
  Future<void> start() => configurator.start();

  /// Stops the flow of data between the inputs and outputs connected the camera instance.
  Future<void> stop() => configurator.stop();

  /// Deallocate all resources and disables further use of the controller.
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

    return null; // Unreachable code
  }

  static CameraApi _getCameraApi(CameraDescription description) {
    throw ArgumentError.value(
      description.runtimeType,
      'description.runtimeType',
      'Failed to get $CameraApi from',
    );
  }
}
