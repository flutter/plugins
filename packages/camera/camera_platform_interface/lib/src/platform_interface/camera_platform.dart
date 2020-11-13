// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:camera_platform_interface/src/method_channel/method_channel_camera.dart';
import 'package:file_selector_platform_interface/file_selector_platform_interface.dart';
import 'package:flutter/widgets.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import '../../camera_platform_interface.dart';

/// The interface that implementations of camera must implement.
///
/// Platform implementations should extend this class rather than implement it as `camera`
/// does not consider newly added methods to be breaking changes. Extending this class
/// (using `extends`) ensures that the subclass will get the default implementation, while
/// platform implementations that `implements` this interface will be broken by newly added
/// [CameraPlatform] methods.
abstract class CameraPlatform extends PlatformInterface {
  /// Constructs a CameraPlatform.
  CameraPlatform() : super(token: _token);

  static final Object _token = Object();

  static CameraPlatform _instance = MethodChannelCamera();

  /// The default instance of [CameraPlatform] to use.
  ///
  /// Defaults to [MethodChannelCamera].
  static CameraPlatform get instance => _instance;

  /// Platform-specific plugins should set this with their own platform-specific
  /// class that extends [CameraPlatform] when they register themselves.
  static set instance(CameraPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  /// Completes with a list of available cameras.
  Future<List<CameraDescription>> availableCameras() {
    throw UnimplementedError('availableCameras() is not implemented.');
  }

  /// Initializes the camera on the device and returns its cameraId.
  Future<int> initializeCamera(
    CameraDescription cameraDescription, {
    ResolutionPreset resolutionPreset,
    bool enableAudio,
  }) {
    throw UnimplementedError('initializeCamera() is not implemented.');
  }

  /// The camera's resolution has changed
  Stream<ResolutionChangedEvent> onResolutionChanged(int cameraId) {
    throw UnimplementedError('onResolutionChanged() is not implemented.');
  }

  /// The camera started to close.
  Stream<CameraClosingEvent> onCameraClosing(int cameraId) {
    throw UnimplementedError('onCameraClosing() is not implemented.');
  }

  /// The camera experienced an error.
  Stream<CameraErrorEvent> onCameraError(int cameraId) {
    throw UnimplementedError('onCameraError() is not implemented.');
  }

  /// Captures an image and returns the file where it was saved.
  Future<XFile> takePicture(int cameraId) {
    throw UnimplementedError('takePicture() is not implemented.');
  }

  /// Prepare the capture session for video recording.
  Future<void> prepareForVideoRecording() {
    throw UnimplementedError('prepareForVideoRecording() is not implemented.');
  }

  /// Starts a video recording and returns the file where it will be saved.
  ///
  /// The file is written on the flight as the video is being recorded.
  /// The file can be read as soon as [stopVideoRecording] returns.
  Future<XFile> startVideoRecording(int cameraId) {
    throw UnimplementedError('startVideoRecording() is not implemented.');
  }

  /// Stops the video recording.
  ///
  /// When the [stopVideoRecording] method completes successfully the recorded
  /// video can be accessed through the file returned by the
  /// [startVideoRecording] method.
  Future<void> stopVideoRecording(int cameraId) {
    throw UnimplementedError('stopVideoRecording() is not implemented.');
  }

  /// Pause video recording.
  Future<void> pauseVideoRecording(int cameraId) {
    throw UnimplementedError('pauseVideoRecording() is not implemented.');
  }

  /// Resume video recording after pausing.
  Future<void> resumeVideoRecording(int cameraId) {
    throw UnimplementedError('resumeVideoRecording() is not implemented.');
  }

  /// Returns a widget showing a live camera preview.
  Widget buildView(int cameraId) {
    throw UnimplementedError('buildView() has not been implemented.');
  }

  /// Releases the resources of this camera.
  Future<void> dispose(int cameraId) {
    throw UnimplementedError('dispose() is not implemented.');
  }
}
