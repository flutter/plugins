// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:math';

import 'package:camera_platform_interface/camera_platform_interface.dart';
import 'package:camera_windows/src/utils/utils.dart';
import 'package:cross_file/cross_file.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:meta/meta.dart';
import 'package:stream_transform/stream_transform.dart';

/// An implementation of [CameraPlatform] that uses method channels.
class CameraWindows extends CameraPlatform {
  /// The method channel used to interact with the native platform.
  final MethodChannel _channel =
      const MethodChannel('plugins.flutter.io/camera');

  /// Registers the Windows implementation of CameraPlatform.
  static void registerWith() {
    CameraPlatform.instance = CameraWindows();
  }

  final Map<int, MethodChannel> _channels = <int, MethodChannel>{};

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

  Stream<CameraEvent> _cameraEvents(int cameraId) =>
      cameraEventStreamController.stream
          .where((CameraEvent event) => event.cameraId == cameraId);

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
          name: camera['name'] as String,
          lensDirection:
              parseCameraLensDirection(camera['lensFacing'] as String),
          sensorOrientation: camera['sensorOrientation'] as int,
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
      final Map<String, dynamic>? reply = await _channel
          .invokeMapMethod<String, dynamic>('create', <String, dynamic>{
        'cameraName': cameraDescription.name,
        'resolutionPreset': resolutionPreset != null
            ? _serializeResolutionPreset(resolutionPreset)
            : null,
        'enableAudio': enableAudio,
      });

      if (reply == null) {
        throw CameraException('System', 'Cannot create camera');
      }

      return reply['cameraId']! as int;
    } on PlatformException catch (e) {
      throw CameraException(e.code, e.message);
    }
  }

  @override
  Future<void> initializeCamera(
    int cameraId, {
    ImageFormatGroup imageFormatGroup = ImageFormatGroup.unknown,
  }) async {
    final int requestedCameraId = cameraId;

    //Create channel for camera events
    _channels.putIfAbsent(requestedCameraId, () {
      final MethodChannel channel =
          MethodChannel('flutter.io/cameraPlugin/camera$requestedCameraId');
      channel.setMethodCallHandler(
        (MethodCall call) => handleCameraMethodCall(call, requestedCameraId),
      );
      return channel;
    });

    final Map<String, double>? reply =
        await _channel.invokeMapMethod<String, double>(
      'initialize',
      <String, dynamic>{
        'cameraId': requestedCameraId,
      },
    );

    if (reply != null &&
        reply.containsKey('previewWidth') &&
        reply.containsKey('previewHeight')) {
      cameraEventStreamController.add(
        CameraInitializedEvent(
          requestedCameraId,
          reply['previewWidth']!,
          reply['previewHeight']!,
          ExposureMode.auto,
          false,
          FocusMode.auto,
          false,
        ),
      );
    } else {
      throw CameraException(
        'INITIALIZATION_FAILED',
        'The platform "$defaultTargetPlatform" did not return valid data when reporting success. The platform should always return a valid data or report an error.',
      );
    }
  }

  @override
  Future<void> dispose(int cameraId) async {
    if (_channels.containsKey(cameraId)) {
      final MethodChannel? cameraChannel = _channels[cameraId];
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
    //Windows camera plugin does not support resolution changed events
    return const Stream<CameraResolutionChangedEvent>.empty();
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
    //Windows camera plugin does not support capture orientations
    //Force device orientation to landscape (by default camera plugin uses portraitUp orientation)
    return Stream<DeviceOrientationChangedEvent>.value(
      DeviceOrientationChangedEvent(DeviceOrientation.landscapeRight),
    );
  }

  @override
  Future<void> lockCaptureOrientation(
    int cameraId,
    DeviceOrientation orientation,
  ) async {
    //Windows camera plugin does not support capture orientation locking
  }

  @override
  Future<void> unlockCaptureOrientation(int cameraId) async {
    //Windows camera plugin does not support capture orientation locking
  }

  @override
  Future<XFile> takePicture(int cameraId) async {
    final String? path = await _channel.invokeMethod<String>(
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
  Future<void> startVideoRecording(
    int cameraId, {
    Duration? maxVideoDuration,
  }) async {
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
    final String? path = await _channel.invokeMethod<String>(
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
  Future<void> pauseVideoRecording(int cameraId) async {
    //Video recording cannot be paused on windows
  }

  @override
  Future<void> resumeVideoRecording(int cameraId) async {
    //Video recording cannot be paused on windows
  }

  @override
  Future<void> setFlashMode(int cameraId, FlashMode mode) async {
    //Windows camera plugin does not support setFlashMode yet
  }

  @override
  Future<void> setExposureMode(int cameraId, ExposureMode mode) async {
    //Windows camera plugin does not support setExposureMode yet
  }

  @override
  Future<void> setExposurePoint(int cameraId, Point<double>? point) async {
    assert(point == null || point.x >= 0 && point.x <= 1);
    assert(point == null || point.y >= 0 && point.y <= 1);

    //Windows camera plugin does not support setExposurePoint yet
  }

  @override
  Future<double> getMinExposureOffset(int cameraId) async {
    //Windows camera plugin does not support getMinExposureOffset yet
    return 0.0;
  }

  @override
  Future<double> getMaxExposureOffset(int cameraId) async {
    //Windows camera plugin does not support getMaxExposureOffset yet
    return 0.0;
  }

  @override
  Future<double> getExposureOffsetStepSize(int cameraId) async {
    //Windows camera plugin does not support getExposureOffsetStepSize yet
    return 1.0;
  }

  @override
  Future<double> setExposureOffset(int cameraId, double offset) async {
    //Windows camera plugin does not support setExposureOffset yet
    return 0.0;
  }

  @override
  Future<void> setFocusMode(int cameraId, FocusMode mode) async {
    //Windows camera plugin does not support focus modes yet
  }

  @override
  Future<void> setFocusPoint(int cameraId, Point<double>? point) async {
    assert(point == null || point.x >= 0 && point.x <= 1);
    assert(point == null || point.y >= 0 && point.y <= 1);

    //Windows camera plugin does not support focus points yet
  }

  @override
  Future<double> getMaxZoomLevel(int cameraId) async {
    //Windows camera plugin does not support zoom levels yet
    return 1.0;
  }

  @override
  Future<double> getMinZoomLevel(int cameraId) async {
    //Windows camera plugin does not support zoom levels yet
    return 1.0;
  }

  @override
  Future<void> setZoomLevel(int cameraId, double zoom) async {
    //Windows camera plugin does not support zoom levels yet
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

  /// Converts messages received from the native platform into camera events.
  ///
  /// This is only exposed for test purposes. It shouldn't be used by clients of
  /// the plugin as it may break or change at any time.
  @visibleForTesting
  Future<dynamic> handleCameraMethodCall(MethodCall call, int cameraId) async {
    switch (call.method) {
      case 'camera_closing':
        cameraEventStreamController.add(
          CameraClosingEvent(
            cameraId,
          ),
        );
        break;
      case 'video_recorded':
        //This is called if maxVideoDuration was given on record start
        cameraEventStreamController.add(
          VideoRecordedEvent(
            cameraId,
            XFile(call.arguments['path'] as String),
            call.arguments['maxVideoDuration'] != null
                ? Duration(
                    milliseconds: call.arguments['maxVideoDuration'] as int,
                  )
                : null,
          ),
        );
        break;
      case 'error':
        cameraEventStreamController.add(
          CameraErrorEvent(
            cameraId,
            call.arguments['description'] as String,
          ),
        );
        break;
      default:
        throw MissingPluginException();
    }
  }
}
