// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:camera_platform_interface/camera_platform_interface.dart';
import 'package:flutter/services.dart';
import 'package:meta/meta.dart';
import 'package:stream_transform/stream_transform.dart';

const MethodChannel _channel = MethodChannel('plugins.flutter.io/camera');

/// An implementation of [CameraPlatform] that uses method channels.
class MethodChannelCamera extends CameraPlatform {
  // TODO(mvanbeusekom): Add default method channel implementation of the
  // [CameraPlatform] interface.
  final Map<int, MethodChannel> _channels = {};
  final StreamController<CameraEvent> _cameraEventStreamController =
      StreamController<CameraEvent>.broadcast();

  Stream<CameraEvent> _events(int cameraId) =>
      _cameraEventStreamController.stream
          .where((event) => event.cameraId == cameraId);

  @override
  Future<List<CameraDescription>> availableCameras() async {
    try {
      final List<Map<dynamic, dynamic>> cameras = await _channel
          .invokeListMethod<Map<dynamic, dynamic>>('availableCameras');
      return cameras.map((Map<dynamic, dynamic> camera) {
        return CameraDescription(
          name: camera['name'],
          lensDirection: _parseCameraLensDirection(camera['lensFacing']),
          sensorOrientation: camera['sensorOrientation'],
        );
      }).toList();
    } on PlatformException catch (e) {
      throw CameraException(e.code, e.message);
    }
  }

  @override
  Future<int> initializeCamera(
    CameraDescription cameraDescription,
    ResolutionPreset resolutionPreset, {
    bool enableAudio,
  }) async {
    int _textureId;
    try {
      final Map<String, dynamic> reply =
          await _channel.invokeMapMethod<String, dynamic>(
        'initialize',
        <String, dynamic>{
          'cameraName': cameraDescription.name,
          'resolutionPreset': resolutionPreset != null
              ? _serializeResolutionPreset(resolutionPreset)
              : null,
          'enableAudio': enableAudio,
        },
      );
      _textureId = reply['textureId'];
    } on PlatformException catch (e) {
      throw CameraException(e.code, e.message);
    }
    if (!_channels.containsKey(_textureId)) {
      final channel =
          MethodChannel('flutter.io/cameraPlugin/camera$_textureId');
      channel.setMethodCallHandler(
          (MethodCall call) => handleMethodCall(call, _textureId));
      _channels[_textureId] = channel;
    }
    return _textureId;
  }

  @override
  Future<void> dispose(int cameraId) async {
    await _channel.invokeMethod<void>(
      'dispose',
      <String, dynamic>{'textureId': cameraId},
    );
    _channels.remove(cameraId);
  }

  @override
  Stream<ResolutionChangedEvent> onResolutionChanged(int cameraId) {
    assert(_channels.containsKey(cameraId));
    return _events(cameraId).whereType<ResolutionChangedEvent>();
  }

  @override
  Stream<CameraClosingEvent> onCameraClosing(int cameraId) {
    assert(_channels.containsKey(cameraId));
    return _events(cameraId).whereType<CameraClosingEvent>();
  }

  @override
  Stream<CameraErrorEvent> onCameraError(int cameraId) {
    assert(_channels.containsKey(cameraId));
    return _events(cameraId).whereType<CameraErrorEvent>();
  }

  /// Returns the resolution preset as a String.
  String _serializeResolutionPreset(ResolutionPreset resolutionPreset) {
    switch (resolutionPreset) {
      case ResolutionPreset.max:
        return 'max';
      case ResolutionPreset.ultraHigh:
        return 'ultraHigh';
      case ResolutionPreset.veryHigh:
        return 'veryHigh';
      case ResolutionPreset.high:
        return 'high';
      case ResolutionPreset.medium:
        return 'medium';
      case ResolutionPreset.low:
        return 'low';
    }
    throw ArgumentError('Unknown ResolutionPreset value');
  }

  // Parses a string into a corresponding CameraLensDirection.
  CameraLensDirection _parseCameraLensDirection(String string) {
    switch (string) {
      case 'front':
        return CameraLensDirection.front;
      case 'back':
        return CameraLensDirection.back;
      case 'external':
        return CameraLensDirection.external;
    }
    throw ArgumentError('Unknown CameraLensDirection value');
  }

  @visibleForTesting
  Future<dynamic> handleMethodCall(MethodCall call, int cameraId) async {
    switch (call.method) {
      case 'camera#resolutionChanged':
        _cameraEventStreamController.add(ResolutionChangedEvent(
          cameraId,
          call.arguments['captureWidth'],
          call.arguments['captureHeight'],
          call.arguments['previewWidth'],
          call.arguments['previewHeight'],
        ));
        break;
      case 'camera#closing':
        _cameraEventStreamController.add(CameraClosingEvent(
          cameraId,
        ));
        break;
      case 'camera#error':
        _cameraEventStreamController.add(CameraErrorEvent(
          cameraId,
          call.arguments['description'],
        ));
        break;
      default:
        throw MissingPluginException();
    }
  }
}
