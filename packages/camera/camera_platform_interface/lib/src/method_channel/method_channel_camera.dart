// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:math';

import 'package:camera_platform_interface/camera_platform_interface.dart';
import 'package:camera_platform_interface/src/events/device_event.dart';
import 'package:camera_platform_interface/src/types/focus_mode.dart';
import 'package:camera_platform_interface/src/types/image_format_group.dart';
import 'package:camera_platform_interface/src/utils/utils.dart';
import 'package:cross_file/cross_file.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:meta/meta.dart';
import 'package:stream_transform/stream_transform.dart';

const MethodChannel _channel = MethodChannel('plugins.flutter.io/camera');

/// An implementation of [CameraPlatform] that uses method channels.
class MethodChannelCamera extends CameraPlatform {
  final Map<int, MethodChannel> _channels = {};

  /// The controller we need to broadcast the different events coming
  /// from handleMethodCall, specific to camera events.
  ///
  /// It is a `broadcast` because multiple controllers will connect to
  /// different stream views of this Controller.
  /// This is only exposed for test purposes. It shouldn't be used by clients of
  /// the plugin as it may break or change at any time.
  @visibleForTesting
  final StreamController<CameraEvent> cameraEventStreamController =
      StreamController<CameraEvent>.broadcast();

  /// The controller we need to broadcast the different events coming
  /// from handleMethodCall, specific to general device events.
  ///
  /// It is a `broadcast` because multiple controllers will connect to
  /// different stream views of this Controller.
  /// This is only exposed for test purposes. It shouldn't be used by clients of
  /// the plugin as it may break or change at any time.
  @visibleForTesting
  final StreamController<DeviceEvent> deviceEventStreamController =
      StreamController<DeviceEvent>.broadcast();

  Stream<CameraEvent> _cameraEvents(int cameraId) =>
      cameraEventStreamController.stream
          .where((event) => event.cameraId == cameraId);

  /// Construct a new method channel camera instance.
  MethodChannelCamera() {
    final channel = MethodChannel('flutter.io/cameraPlugin/device');
    channel.setMethodCallHandler(
        (MethodCall call) => handleDeviceMethodCall(call));
  }

  @override
  Future<List<CameraDescription>> availableCameras() async {
    try {
      final List<Map<dynamic, dynamic>>? cameras = await _channel
          .invokeListMethod<Map<dynamic, dynamic>>('availableCameras');

      if (cameras == null) {
        return <CameraDescription>[];
      }

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
    ResolutionPreset? resolutionPreset, {
    bool enableAudio = false,
  }) async {
    try {
      final reply = await _channel
          .invokeMapMethod<String, dynamic>('create', <String, dynamic>{
        'cameraName': cameraDescription.name,
        'resolutionPreset': resolutionPreset != null
            ? _serializeResolutionPreset(resolutionPreset)
            : null,
        'enableAudio': enableAudio,
      });

      return reply!['cameraId'];
    } on PlatformException catch (e) {
      throw CameraException(e.code, e.message);
    }
  }

  @override
  Future<void> initializeCamera(
    int cameraId, {
    ImageFormatGroup imageFormatGroup = ImageFormatGroup.unknown,
  }) {
    _channels.putIfAbsent(cameraId, () {
      final channel = MethodChannel('flutter.io/cameraPlugin/camera$cameraId');
      channel.setMethodCallHandler(
          (MethodCall call) => handleCameraMethodCall(call, cameraId));
      return channel;
    });

    Completer _completer = Completer();

    onCameraInitialized(cameraId).first.then((value) {
      _completer.complete();
    });

    _channel.invokeMapMethod<String, dynamic>(
      'initialize',
      <String, dynamic>{
        'cameraId': cameraId,
        'imageFormatGroup': imageFormatGroup.name(),
      },
    );

    return _completer.future;
  }

  @override
  Future<void> dispose(int cameraId) async {
    if (_channels.containsKey(cameraId)) {
      final cameraChannel = _channels[cameraId];
      cameraChannel?.setMethodCallHandler(null);
      _channels.remove(cameraId);
    }

    await _channel.invokeMethod<void>(
      'dispose',
      <String, dynamic>{'cameraId': cameraId},
    );
  }

  @override
  Stream<CameraInitializedEvent> onCameraInitialized(int cameraId) {
    return _cameraEvents(cameraId).whereType<CameraInitializedEvent>();
  }

  @override
  Stream<CameraResolutionChangedEvent> onCameraResolutionChanged(int cameraId) {
    return _cameraEvents(cameraId).whereType<CameraResolutionChangedEvent>();
  }

  @override
  Stream<CameraClosingEvent> onCameraClosing(int cameraId) {
    return _cameraEvents(cameraId).whereType<CameraClosingEvent>();
  }

  @override
  Stream<CameraErrorEvent> onCameraError(int cameraId) {
    return _cameraEvents(cameraId).whereType<CameraErrorEvent>();
  }

  @override
  Stream<VideoRecordedEvent> onVideoRecordedEvent(int cameraId) {
    return _cameraEvents(cameraId).whereType<VideoRecordedEvent>();
  }

  @override
  Stream<DeviceOrientationChangedEvent> onDeviceOrientationChanged() {
    return deviceEventStreamController.stream
        .whereType<DeviceOrientationChangedEvent>();
  }

  @override
  Future<void> lockCaptureOrientation(
    int cameraId,
    DeviceOrientation orientation,
  ) async {
    await _channel.invokeMethod<String>(
      'lockCaptureOrientation',
      <String, dynamic>{
        'cameraId': cameraId,
        'orientation': serializeDeviceOrientation(orientation)
      },
    );
  }

  @override
  Future<void> unlockCaptureOrientation(int cameraId) async {
    await _channel.invokeMethod<String>(
      'unlockCaptureOrientation',
      <String, dynamic>{'cameraId': cameraId},
    );
  }

  @override
  Future<XFile> takePicture(int cameraId) async {
    final path = await _channel.invokeMethod<String>(
      'takePicture',
      <String, dynamic>{'cameraId': cameraId},
    );

    if (path == null) {
      throw CameraException(
        'INVALID_PATH',
        'The platform "$defaultTargetPlatform" did not return a path while reporting success. The platform should always return a valid path or report an error.',
      );
    }

    return XFile(path);
  }

  @override
  Future<void> prepareForVideoRecording() =>
      _channel.invokeMethod<void>('prepareForVideoRecording');

  @override
  Future<void> startVideoRecording(int cameraId,
      {Duration? maxVideoDuration}) async {
    await _channel.invokeMethod<void>(
      'startVideoRecording',
      <String, dynamic>{
        'cameraId': cameraId,
        'maxVideoDuration': maxVideoDuration?.inMilliseconds,
      },
    );
  }

  @override
  Future<XFile> stopVideoRecording(int cameraId) async {
    final path = await _channel.invokeMethod<String>(
      'stopVideoRecording',
      <String, dynamic>{'cameraId': cameraId},
    );

    if (path == null) {
      throw CameraException(
        'INVALID_PATH',
        'The platform "$defaultTargetPlatform" did not return a path while reporting success. The platform should always return a valid path or report an error.',
      );
    }

    return XFile(path);
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
  Future<void> setFlashMode(int cameraId, FlashMode mode) =>
      _channel.invokeMethod<void>(
        'setFlashMode',
        <String, dynamic>{
          'cameraId': cameraId,
          'mode': _serializeFlashMode(mode),
        },
      );

  @override
  Future<void> setExposureMode(int cameraId, ExposureMode mode) =>
      _channel.invokeMethod<void>(
        'setExposureMode',
        <String, dynamic>{
          'cameraId': cameraId,
          'mode': serializeExposureMode(mode),
        },
      );

  @override
  Future<void> setExposurePoint(int cameraId, Point<double>? point) {
    assert(point == null || point.x >= 0 && point.x <= 1);
    assert(point == null || point.y >= 0 && point.y <= 1);

    return _channel.invokeMethod<void>(
      'setExposurePoint',
      <String, dynamic>{
        'cameraId': cameraId,
        'reset': point == null,
        'x': point?.x,
        'y': point?.y,
      },
    );
  }

  @override
  Future<double> getMinExposureOffset(int cameraId) async {
    final minExposureOffset = await _channel.invokeMethod<double>(
      'getMinExposureOffset',
      <String, dynamic>{'cameraId': cameraId},
    );

    return minExposureOffset!;
  }

  @override
  Future<double> getMaxExposureOffset(int cameraId) async {
    final maxExposureOffset = await _channel.invokeMethod<double>(
      'getMaxExposureOffset',
      <String, dynamic>{'cameraId': cameraId},
    );

    return maxExposureOffset!;
  }

  @override
  Future<double> getExposureOffsetStepSize(int cameraId) async {
    final stepSize = await _channel.invokeMethod<double>(
      'getExposureOffsetStepSize',
      <String, dynamic>{'cameraId': cameraId},
    );

    return stepSize!;
  }

  @override
  Future<double> setExposureOffset(int cameraId, double offset) async {
    final appliedOffset = await _channel.invokeMethod<double>(
      'setExposureOffset',
      <String, dynamic>{
        'cameraId': cameraId,
        'offset': offset,
      },
    );

    return appliedOffset!;
  }

  @override
  Future<void> setFocusMode(int cameraId, FocusMode mode) =>
      _channel.invokeMethod<void>(
        'setFocusMode',
        <String, dynamic>{
          'cameraId': cameraId,
          'mode': serializeFocusMode(mode),
        },
      );

  @override
  Future<void> setFocusPoint(int cameraId, Point<double>? point) {
    assert(point == null || point.x >= 0 && point.x <= 1);
    assert(point == null || point.y >= 0 && point.y <= 1);

    return _channel.invokeMethod<void>(
      'setFocusPoint',
      <String, dynamic>{
        'cameraId': cameraId,
        'reset': point == null,
        'x': point?.x,
        'y': point?.y,
      },
    );
  }

  @override
  Future<double> getMaxZoomLevel(int cameraId) async {
    final maxZoomLevel = await _channel.invokeMethod<double>(
      'getMaxZoomLevel',
      <String, dynamic>{'cameraId': cameraId},
    );

    return maxZoomLevel!;
  }

  @override
  Future<double> getMinZoomLevel(int cameraId) async {
    final minZoomLevel = await _channel.invokeMethod<double>(
      'getMinZoomLevel',
      <String, dynamic>{'cameraId': cameraId},
    );

    return minZoomLevel!;
  }

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
  Future<void> pausePreview(int cameraId) async {
    await _channel.invokeMethod<double>(
      'pausePreview',
      <String, dynamic>{'cameraId': cameraId},
    );
  }

  @override
  Future<void> resumePreview(int cameraId) async {
    await _channel.invokeMethod<double>(
      'resumePreview',
      <String, dynamic>{'cameraId': cameraId},
    );
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
      case FlashMode.torch:
        return 'torch';
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

  /// Converts messages received from the native platform into device events.
  ///
  /// This is only exposed for test purposes. It shouldn't be used by clients of
  /// the plugin as it may break or change at any time.
  Future<dynamic> handleDeviceMethodCall(MethodCall call) async {
    switch (call.method) {
      case 'orientation_changed':
        deviceEventStreamController.add(DeviceOrientationChangedEvent(
            deserializeDeviceOrientation(call.arguments['orientation'])));
        break;
      default:
        throw MissingPluginException();
    }
  }

  /// Converts messages received from the native platform into camera events.
  ///
  /// This is only exposed for test purposes. It shouldn't be used by clients of
  /// the plugin as it may break or change at any time.
  @visibleForTesting
  Future<dynamic> handleCameraMethodCall(MethodCall call, int cameraId) async {
    switch (call.method) {
      case 'initialized':
        cameraEventStreamController.add(CameraInitializedEvent(
          cameraId,
          call.arguments['previewWidth'],
          call.arguments['previewHeight'],
          deserializeExposureMode(call.arguments['exposureMode']),
          call.arguments['exposurePointSupported'],
          deserializeFocusMode(call.arguments['focusMode']),
          call.arguments['focusPointSupported'],
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
      case 'video_recorded':
        cameraEventStreamController.add(VideoRecordedEvent(
          cameraId,
          XFile(call.arguments['path']),
          call.arguments['maxVideoDuration'] != null
              ? Duration(milliseconds: call.arguments['maxVideoDuration'])
              : null,
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
