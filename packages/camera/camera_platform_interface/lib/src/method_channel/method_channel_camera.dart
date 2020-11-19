// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:camera_platform_interface/camera_platform_interface.dart';
import 'package:camera_platform_interface/src/utils/utils.dart';
import 'package:cross_file/cross_file.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart';

const MethodChannel _channel = MethodChannel('plugins.flutter.io/camera');

/// An implementation of [CameraPlatform] that uses method channels.
class MethodChannelCamera extends CameraPlatform {
  final Map<int, MethodChannel> _channels = {};

  /// The controller we need to broadcast the different events coming
  /// from handleMethodCall.
  ///
  /// It is a `broadcast` because multiple controllers will connect to
  /// different stream views of this Controller.
  /// This is only exposed for test purposes. It shouldn't be used by clients of
  /// the plugin as it may break or change at any time.
  @visibleForTesting
  final StreamController<CameraEvent> cameraEventStreamController =
      StreamController<CameraEvent>.broadcast();

  final Map<int, Stream> _cameraResolutionChangedEventStreams = {};

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
    int _cameraId;
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
      _cameraId = reply['cameraId'];
    } on PlatformException catch (e) {
      throw CameraException(e.code, e.message);
    }
    if (!_channels.containsKey(_cameraId)) {
      final channel =
          MethodChannel('flutter.io/cameraPlugin/camera$_cameraId');
      channel.setMethodCallHandler(
          (MethodCall call) => handleMethodCall(call, _cameraId));
      _channels[_cameraId] = channel;
      _cameraResolutionChangedEventStreams[_cameraId] = _events(_cameraId)
          .whereType<ResolutionChangedEvent>()
          .shareReplay(maxSize: 1);
    }
    return _cameraId;
  }

  @override
  Future<void> dispose(int cameraId) async {
    await _channel.invokeMethod<void>(
      'dispose',
      <String, dynamic>{'cameraId': cameraId},
    );

    if (_channels.containsKey(cameraId)) {
      _channels[cameraId].setMethodCallHandler(null);
      _channels.remove(cameraId);
    }
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
  Future<void> startVideoRecording(int cameraId) async {
    await _channel.invokeMethod<void>(
      'startVideoRecording',
      <String, dynamic>{'cameraId': cameraId},
    );
  }

  @override
  Future<XFile> stopVideoRecording(int cameraId) async {
    String path = await _channel.invokeMethod<String>(
      'stopVideoRecording',
      <String, dynamic>{'cameraId': cameraId},
    );
    return XFile(path);
  }

  @override
  Future<void> pauseVideoRecording(int cameraId) =>
    _channel.invokeMethod<void>(
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
  Future<void> setFlashMode(int cameraId, FlashMode mode) =>
      _channel.invokeMethod<void>(
        'setFlashMode',
        <String, dynamic>{
          'cameraId': cameraId,
          'mode': _serializeFlashMode(mode),
        },
      );

  @override
  Future<double> getMaxZoomLevel(int cameraId) => _channel.invokeMethod<double>(
        'getMaxZoomLevel',
        <String, dynamic>{'cameraId': cameraId},
      );

  @override
  Future<double> getMinZoomLevel(int cameraId) => _channel.invokeMethod<double>(
        'getMinZoomLevel',
        <String, dynamic>{'cameraId': cameraId},
      );

  @override
  Future<void> setZoomLevel(int cameraId, double zoom) async {
    try {
      await _channel.invokeMethod<double>(
        'setZoomLevel',
        <String, dynamic>{
          'cameraId': cameraId,
          'zoom': zoom,
        },
      );
    } on PlatformException catch (e) {
      throw CameraException(e.code, e.message);
    }
  }

  @override
  Widget buildPreview(int cameraId) {
    return Texture(textureId: cameraId);
  }

  /// Returns the flash mode as a String.
  String _serializeFlashMode(FlashMode flashMode) {
    switch (flashMode) {
      case FlashMode.off:
        return 'off';
      case FlashMode.auto:
        return 'auto';
      case FlashMode.always:
        return 'always';
      default:
        throw ArgumentError('Unknown FlashMode value');
    }
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
      default:
        throw ArgumentError('Unknown ResolutionPreset value');
    }
  }

  /// Converts messages received from the native platform into events.
  ///
  /// This is only exposed for test purposes. It shouldn't be used by clients of
  /// the plugin as it may break or change at any time.
  @visibleForTesting
  Future<dynamic> handleMethodCall(MethodCall call, int cameraId) async {
    switch (call.method) {
      case 'resolution_changed':
        _cameraEventStreamController.add(ResolutionChangedEvent(
          cameraId,
          call.arguments['previewWidth'],
          call.arguments['previewHeight'],
        ));
        break;
      case 'camera_closing':
        _cameraEventStreamController.add(CameraClosingEvent(
          cameraId,
        ));
        break;
      case 'error':
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
