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
/// This class is used as a simple interface to control a camera on Android or
/// iOS.
///
/// Only one instance of [CameraController] can be active at a time. If you call
/// [initialize] on a [CameraController] while another is active, the old
/// controller will be disposed before initializing the new controller.
///
/// Example using [CameraController]:
///
/// ```dart
/// final List<CameraDescription> cameras = async CameraController.availableCameras();
/// final CameraController controller = CameraController(description: cameras[0]);
/// controller.initialize();
/// controller.start();
/// ```
class CameraController {
  /// Default constructor.
  ///
  /// Use [CameraController.availableCameras] to get a list of available
  /// cameras.
  ///
  /// This will choose the best [CameraConfigurator] for the current device.
  factory CameraController({@required CameraDescription description}) {
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

  static const String _isNotInitializedMessage = 'Initialize was not called.';
  static const String _isDisposedMessage = 'This controller has been disposed.';

  // Keep only one active instance of CameraController.
  static CameraController _instance;

  bool _isDisposed = false;

  /// Details for the camera this controller accesses.
  final CameraDescription description;

  /// Configurator used to control the camera.
  final CameraConfigurator configurator;

  /// Api used by the [configurator].
  final CameraApi api;

  bool get isDisposed => _isDisposed;

  /// Retrieves a list of available cameras for the current device.
  ///
  /// This will choose the best [CameraAPI] for the current device.
  static Future<List<CameraDescription>> availableCameras() async {
    throw UnimplementedError('$defaultTargetPlatform not supported');
  }

  /// Initializes the camera on the device.
  ///
  /// You must call [dispose] when you are done using the camera, otherwise it
  /// will remain locked and be unavailable to other applications.
  ///
  /// Only one instance of [CameraController] can be active at a time. If you
  /// call [initialize] on a [CameraController] while another is active, the old
  /// controller will be disposed before initializing the new controller.
  Future<void> initialize() {
    if (_instance == this) {
      return Future<void>.value();
    }

    final Completer<void> completer = Completer<void>();

    if (_instance != null) {
      _instance
          .dispose()
          .then((_) => configurator.initialize())
          .then((_) => completer.complete());
    }
    _instance = this;

    return completer.future;
  }

  /// Begins the flow of data between the inputs and outputs connected to the camera instance.
  Future<void> start() {
    assert(!_isDisposed, _isDisposedMessage);
    assert(_instance != this, _isNotInitializedMessage);

    return configurator.start();
  }

  /// Stops the flow of data between the inputs and outputs connected to the camera instance.
  Future<void> stop() {
    assert(!_isDisposed, _isDisposedMessage);
    assert(_instance != this, _isNotInitializedMessage);

    return configurator.stop();
  }

  /// Deallocate all resources and disables further use of the controller.
  Future<void> dispose() {
    _instance = null;
    _isDisposed = true;
    return configurator.dispose();
  }

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
    return CameraApi.iOS;

    // TODO(bparrishMines): Uncomment this when platform specific code is added.
    /*
    throw ArgumentError.value(
      description.runtimeType,
      'description.runtimeType',
      'Failed to get $CameraApi from',
    );
    */
  }
}
