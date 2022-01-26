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

/// An implementation of [CameraPlatform] for Windows.
class CameraWindows extends CameraPlatform {
  /// Registers the Windows implementation of CameraPlatform.
  static void registerWith() {
    CameraPlatform.instance = CameraWindows();
  }

  /// The method channel used to interact with the native platform.
  final MethodChannel _pluginChannel =
      const MethodChannel('plugins.flutter.io/camera');

  /// Camera specific method channels to allow comminicating with specific cameras.
  final Map<int, MethodChannel> _cameraChannels = <int, MethodChannel>{};

  /// The controller that broadcasts events coming from handleCameraMethodCall
  ///
  /// It is a `broadcast` because multiple controllers will connect to
  /// different stream views of this Controller.
  /// This is only exposed for test purposes. It shouldn't be used by clients of
  /// the plugin as it may break or change at any time.
  @visibleForTesting
  final StreamController<CameraEvent> cameraEventStreamController =
      StreamController<CameraEvent>.broadcast();

  /// Returns a stream of camera events for the given [cameraId].
  Stream<CameraEvent> _cameraEvents(int cameraId) =>
      cameraEventStreamController.stream
          .where((CameraEvent event) => event.cameraId == cameraId);

  @override
  Future<List<CameraDescription>> availableCameras() async {
    try {
      final List<Map<dynamic, dynamic>>? cameras = await _pluginChannel
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
      final Map<String, dynamic>? reply = await _pluginChannel
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

    /// Creates channel for camera events.
    _cameraChannels.putIfAbsent(requestedCameraId, () {
      final MethodChannel channel =
          MethodChannel('flutter.io/cameraPlugin/camera$requestedCameraId');
      channel.setMethodCallHandler(
        (MethodCall call) => handleCameraMethodCall(call, requestedCameraId),
      );
      return channel;
    });

    final Map<String, double>? reply;
    try {
      reply = await _pluginChannel.invokeMapMethod<String, double>(
        'initialize',
        <String, dynamic>{
          'cameraId': requestedCameraId,
        },
      );
    } on PlatformException catch (e) {
      throw CameraException(e.code, e.message);
    }

    cameraEventStreamController.add(
      CameraInitializedEvent(
        requestedCameraId,
        reply!['previewWidth']!,
        reply['previewHeight']!,
        ExposureMode.auto,
        false,
        FocusMode.auto,
        false,
      ),
    );
  }

  @override
  Future<void> dispose(int cameraId) async {
    if (_cameraChannels.containsKey(cameraId)) {
      final MethodChannel? cameraChannel = _cameraChannels[cameraId];
      cameraChannel?.setMethodCallHandler(null);
      _cameraChannels.remove(cameraId);
    }

    try {
      await _pluginChannel.invokeMethod<void>(
        'dispose',
        <String, dynamic>{'cameraId': cameraId},
      );
    } on PlatformException catch (e) {
      throw CameraException(e.code, e.message);
    }
  }

  @override
  Stream<CameraInitializedEvent> onCameraInitialized(int cameraId) {
    return _cameraEvents(cameraId).whereType<CameraInitializedEvent>();
  }

  @override
  Stream<CameraResolutionChangedEvent> onCameraResolutionChanged(int cameraId) {
    /// Windows camera plugin does not support resolution changed events.
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
    /// Windows camera plugin does not support capture orientations.
    /// Force device orientation to landscape as by default camera plugin uses portraitUp orientation.
    return Stream<DeviceOrientationChangedEvent>.value(
      const DeviceOrientationChangedEvent(DeviceOrientation.landscapeRight),
    );
  }

  @override
  Future<void> lockCaptureOrientation(
    int cameraId,
    DeviceOrientation orientation,
  ) async {
    throw UnimplementedError('lockCaptureOrientation() is not implemented.');
  }

  @override
  Future<void> unlockCaptureOrientation(int cameraId) async {
    throw UnimplementedError('unlockCaptureOrientation() is not implemented.');
  }

  @override
  Future<XFile> takePicture(int cameraId) async {
    final String? path;
    try {
      path = await _pluginChannel.invokeMethod<String>(
        'takePicture',
        <String, dynamic>{'cameraId': cameraId},
      );
    } on PlatformException catch (e) {
      throw CameraException(e.code, e.message);
    }

    return XFile(path!);
  }

  @override
  Future<void> prepareForVideoRecording() async {
    try {
      _pluginChannel.invokeMethod<void>('prepareForVideoRecording');
    } on PlatformException catch (e) {
      throw CameraException(e.code, e.message);
    }
  }

  @override
  Future<void> startVideoRecording(
    int cameraId, {
    Duration? maxVideoDuration,
  }) async {
    try {
      await _pluginChannel.invokeMethod<void>(
        'startVideoRecording',
        <String, dynamic>{
          'cameraId': cameraId,
          'maxVideoDuration': maxVideoDuration?.inMilliseconds,
        },
      );
    } on PlatformException catch (e) {
      throw CameraException(e.code, e.message);
    }
  }

  @override
  Future<XFile> stopVideoRecording(int cameraId) async {
    final String? path;

    try {
      path = await _pluginChannel.invokeMethod<String>(
        'stopVideoRecording',
        <String, dynamic>{'cameraId': cameraId},
      );
    } on PlatformException catch (e) {
      throw CameraException(e.code, e.message);
    }

    return XFile(path!);
  }

  @override
  Future<void> pauseVideoRecording(int cameraId) async {
    throw UnimplementedError('pauseVideoRecording() is not implemented.');
  }

  @override
  Future<void> resumeVideoRecording(int cameraId) async {
    throw UnimplementedError('resumeVideoRecording() is not implemented.');
  }

  @override
  Future<void> setFlashMode(int cameraId, FlashMode mode) async {
    throw UnimplementedError('setFlashMode() is not implemented.');
  }

  @override
  Future<void> setExposureMode(int cameraId, ExposureMode mode) async {
    throw UnimplementedError('setExposureMode() is not implemented.');
  }

  @override
  Future<void> setExposurePoint(int cameraId, Point<double>? point) async {
    assert(point == null || point.x >= 0 && point.x <= 1);
    assert(point == null || point.y >= 0 && point.y <= 1);

    throw UnimplementedError('setExposurePoint() is not implemented.');
  }

  @override
  Future<double> getMinExposureOffset(int cameraId) async {
    /// Explosure offset is not supported by camera windows plugin yet.
    /// Default min offset value is returned.
    return 0.0;
  }

  @override
  Future<double> getMaxExposureOffset(int cameraId) async {
    /// Explosure offset is not supported by camera windows plugin yet.
    /// Default max offset value is returned.
    return 0.0;
  }

  @override
  Future<double> getExposureOffsetStepSize(int cameraId) async {
    /// Explosure offset is not supported by camera windows plugin yet.
    /// Default step value is returned.
    return 1.0;
  }

  @override
  Future<double> setExposureOffset(int cameraId, double offset) async {
    /// Explosure offset is not supported by camera windows plugin yet.
    /// Default exposure offset value is returned as a response.
    return 0.0;
  }

  @override
  Future<void> setFocusMode(int cameraId, FocusMode mode) async {
    throw UnimplementedError('setFocusMode() is not implemented.');
  }

  @override
  Future<void> setFocusPoint(int cameraId, Point<double>? point) async {
    assert(point == null || point.x >= 0 && point.x <= 1);
    assert(point == null || point.y >= 0 && point.y <= 1);

    throw UnimplementedError('setFocusPoint() is not implemented.');
  }

  @override
  Future<double> getMinZoomLevel(int cameraId) async {
    /// Zoom level is not supported by camera windows plugin yet.
    /// Default min zoom level value is returned as a response.
    return 1.0;
  }

  @override
  Future<double> getMaxZoomLevel(int cameraId) async {
    /// Zoom level is not supported by camera windows plugin yet.
    /// Default max zoom level value is returned as a response.
    return 1.0;
  }

  @override
  Future<void> setZoomLevel(int cameraId, double zoom) async {
    throw UnimplementedError('setZoomLevel() is not implemented.');
  }

  @override
  Future<void> pausePreview(int cameraId) async {
    try {
      await _pluginChannel.invokeMethod<double>(
        'pausePreview',
        <String, dynamic>{'cameraId': cameraId},
      );
    } on PlatformException catch (e) {
      throw CameraException(e.code, e.message);
    }
  }

  @override
  Future<void> resumePreview(int cameraId) async {
    try {
      await _pluginChannel.invokeMethod<double>(
        'resumePreview',
        <String, dynamic>{'cameraId': cameraId},
      );
    } on PlatformException catch (e) {
      throw CameraException(e.code, e.message);
    }
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

        /// This is called if maxVideoDuration was given on record start.
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
