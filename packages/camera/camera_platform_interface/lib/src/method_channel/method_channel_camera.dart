// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:camera_platform_interface/camera_platform_interface.dart';
import 'package:cross_file/cross_file.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:meta/meta.dart';
import 'package:stream_transform/stream_transform.dart';

const MethodChannel _channel = MethodChannel('plugins.flutter.io/camera');

/// An implementation of [CameraPlatform] that uses method channels.
class MethodChannelCamera extends CameraPlatform {
  final Map<int, MethodChannel> _channels = {};

  @visibleForTesting
  final StreamController<CameraEvent> cameraEventStreamController =
      StreamController<CameraEvent>.broadcast();

  Stream<CameraEvent> _events(int cameraId) =>
      cameraEventStreamController.stream
          .where((event) => event.cameraId == cameraId);

  @override
  Future<List<CameraDescription>> availableCameras() async {
    try {
      final List<Map<dynamic, dynamic>> cameras = await _channel
          .invokeListMethod<Map<dynamic, dynamic>>('availableCameras');
      return cameras.map((Map<dynamic, dynamic> camera) {
        return CameraDescription(
          name: camera['name'],
          lensDirection: parseCameraLensDirection(camera['lensFacing']),
          sensorOrientation: camera['sensorOrientation'],
        );
      }).toList();
    } on PlatformException catch (e) {
      throw CameraException(e.code, e.message);
    }
  }

  @override
  Future<int> createCamera(
    CameraDescription cameraDescription,
    ResolutionPreset resolutionPreset, {
    bool enableAudio,
  }) async {
    try {
      final Map<String, dynamic> reply =
          await _channel.invokeMapMethod<String, dynamic>(
        'create',
        <String, dynamic>{
          'cameraName': cameraDescription.name,
          'resolutionPreset': resolutionPreset != null
              ? _serializeResolutionPreset(resolutionPreset)
              : null,
          'enableAudio': enableAudio,
        },
      );
      return reply['cameraId'];
    } on PlatformException catch (e) {
      throw CameraException(e.code, e.message);
    }
  }

  @override
  Future<void> initializeCamera(int cameraId) {
    if (!_channels.containsKey(cameraId)) {
      final channel = MethodChannel('flutter.io/cameraPlugin/camera$cameraId');
      channel.setMethodCallHandler(
          (MethodCall call) => handleMethodCall(call, cameraId));
      _channels[cameraId] = channel;
    }

    Completer _completer = Completer();
    
    onCameraInitialized(cameraId).first.then((value) {
      _completer.complete();
    });
    
    _channel.invokeMapMethod<String, dynamic>(
      'initialize',
      <String, dynamic>{
        'cameraId': cameraId,
      },
    );
    
    return _completer.future;
  }

  @override
  Future<void> dispose(int cameraId) async {
    await _channel.invokeMethod<void>(
      'dispose',
      <String, dynamic>{'cameraId': cameraId},
    );
    _channels.remove(cameraId);
  }

  @override
  Stream<CameraInitializedEvent> onCameraInitialized(int cameraId) {
    return _events(cameraId).whereType<CameraInitializedEvent>();
  }

  @override
  Stream<CameraResolutionChangedEvent> onCameraResolutionChanged(int cameraId) {
    return _events(cameraId).whereType<CameraResolutionChangedEvent>();
  }

  @override
  Stream<CameraClosingEvent> onCameraClosing(int cameraId) {
    return _events(cameraId).whereType<CameraClosingEvent>();
  }

  @override
  Stream<CameraErrorEvent> onCameraError(int cameraId) {
    return _events(cameraId).whereType<CameraErrorEvent>();
  }

  @override
  Future<XFile> takePicture(int cameraId) async {
    String path = await _channel.invokeMethod<String>(
      'takePicture',
      <String, dynamic>{'cameraId': cameraId},
    );
    return XFile(path);
  }

  @override
  Future<void> prepareForVideoRecording() =>
      _channel.invokeMethod<void>('prepareForVideoRecording');

  @override
  Future<XFile> startVideoRecording(int cameraId) async {
    String path = await _channel.invokeMethod<String>(
      'startVideoRecording',
      <String, dynamic>{'cameraId': cameraId},
    );
    return XFile(path);
  }

  @override
  Future<void> stopVideoRecording(int cameraId) async {
    await _channel.invokeMethod<void>(
      'stopVideoRecording',
      <String, dynamic>{'cameraId': cameraId},
    );
  }

  @override
  Future<void> pauseVideoRecording(int cameraId) => _channel.invokeMethod<void>(
        'pauseVideoRecording',
        <String, dynamic>{'cameraId': cameraId},
      );

  @override
  Future<void> resumeVideoRecording(int cameraId) =>
      _channel.invokeMethod<void>(
        'resumeVideoRecording',
        <String, dynamic>{'cameraId': cameraId},
      );

  @override
  Widget buildView(int cameraId) {
    return Texture(textureId: cameraId);
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

  /// Parses a string into a corresponding CameraLensDirection.
  @visibleForTesting
  CameraLensDirection parseCameraLensDirection(String string) {
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
      case 'initialized':
        cameraEventStreamController.add(CameraInitializedEvent(
          cameraId,
          call.arguments['previewWidth'],
          call.arguments['previewHeight'],
        ));
        break;
      case 'resolution_changed':
        cameraEventStreamController.add(CameraResolutionChangedEvent(
          cameraId,
          call.arguments['captureWidth'],
          call.arguments['captureHeight'],
        ));
        break;
      case 'camera_closing':
        cameraEventStreamController.add(CameraClosingEvent(
          cameraId,
        ));
        break;
      case 'error':
        cameraEventStreamController.add(CameraErrorEvent(
          cameraId,
          call.arguments['description'],
        ));
        break;
      default:
        throw MissingPluginException();
    }
  }
}
