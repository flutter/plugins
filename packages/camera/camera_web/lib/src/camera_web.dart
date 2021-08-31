// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:html' as html;
import 'dart:math';

import 'package:camera_platform_interface/camera_platform_interface.dart';
import 'package:camera_web/src/camera.dart';
import 'package:camera_web/src/camera_service.dart';
import 'package:camera_web/src/types/types.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:stream_transform/stream_transform.dart';

// The default error message, when the error is an empty string.
// See: https://developer.mozilla.org/en-US/docs/Web/API/MediaError/message
const String _kDefaultErrorMessage =
    'No further diagnostic information can be determined or provided.';

/// The web implementation of [CameraPlatform].
///
/// This class implements the `package:camera` functionality for the web.
class CameraPlugin extends CameraPlatform {
  /// Creates a new instance of [CameraPlugin]
  /// with the given [cameraService].
  CameraPlugin({required CameraService cameraService})
      : _cameraService = cameraService;

  /// Registers this class as the default instance of [CameraPlatform].
  static void registerWith(Registrar registrar) {
    CameraPlatform.instance = CameraPlugin(
      cameraService: CameraService(),
    );
  }

  final CameraService _cameraService;

  /// The cameras managed by the [CameraPlugin].
  @visibleForTesting
  final cameras = <int, Camera>{};
  var _textureCounter = 1;

  /// Metadata associated with each camera description.
  /// Populated in [availableCameras].
  @visibleForTesting
  final camerasMetadata = <CameraDescription, CameraMetadata>{};

  /// The controller used to broadcast different camera events.
  ///
  /// It is `broadcast` as multiple controllers may subscribe
  /// to different stream views of this controller.
  @visibleForTesting
  final cameraEventStreamController = StreamController<CameraEvent>.broadcast();

  final _cameraVideoErrorSubscriptions =
      <int, StreamSubscription<html.Event>>{};

  final _cameraVideoAbortSubscriptions =
      <int, StreamSubscription<html.Event>>{};

  final _cameraEndedSubscriptions =
      <int, StreamSubscription<html.MediaStreamTrack>>{};

  /// Returns a stream of camera events for the given [cameraId].
  Stream<CameraEvent> _cameraEvents(int cameraId) =>
      cameraEventStreamController.stream
          .where((event) => event.cameraId == cameraId);

  /// The current browser window used to access media devices.
  @visibleForTesting
  html.Window? window = html.window;

  @override
  Future<List<CameraDescription>> availableCameras() async {
    try {
      final mediaDevices = window?.navigator.mediaDevices;
      final cameras = <CameraDescription>[];

      // Throw a not supported exception if the current browser window
      // does not support any media devices.
      if (mediaDevices == null) {
        throw PlatformException(
          code: CameraErrorCode.notSupported.toString(),
          message: 'The camera is not supported on this device.',
        );
      }

      // Request video and audio permissions.
      await _cameraService.getMediaStreamForOptions(
        CameraOptions(
          audio: AudioConstraints(enabled: true),
        ),
      );

      // Request available media devices.
      final devices = await mediaDevices.enumerateDevices();

      // Filter video input devices.
      final videoInputDevices = devices
          .whereType<html.MediaDeviceInfo>()
          .where((device) => device.kind == MediaDeviceKind.videoInput)

          /// The device id property is currently not supported on Internet Explorer:
          /// https://developer.mozilla.org/en-US/docs/Web/API/MediaDeviceInfo/deviceId#browser_compatibility
          .where(
            (device) => device.deviceId != null && device.deviceId!.isNotEmpty,
          );

      // Map video input devices to camera descriptions.
      for (final videoInputDevice in videoInputDevices) {
        // Get the video stream for the current video input device
        // to later use for the available video tracks.
        final videoStream = await _getVideoStreamForDevice(
          videoInputDevice.deviceId!,
        );

        // Get all video tracks in the video stream
        // to later extract the lens direction from the first track.
        final videoTracks = videoStream.getVideoTracks();

        if (videoTracks.isNotEmpty) {
          // Get the facing mode from the first available video track.
          final facingMode =
              _cameraService.getFacingModeForVideoTrack(videoTracks.first);

          // Get the lens direction based on the facing mode.
          // Fallback to the external lens direction
          // if the facing mode is not available.
          final lensDirection = facingMode != null
              ? _cameraService.mapFacingModeToLensDirection(facingMode)
              : CameraLensDirection.external;

          // Create a camera description.
          //
          // The name is a camera label which might be empty
          // if no permissions to media devices have been granted.
          //
          // MediaDeviceInfo.label:
          // https://developer.mozilla.org/en-US/docs/Web/API/MediaDeviceInfo/label
          //
          // Sensor orientation is currently not supported.
          final cameraLabel = videoInputDevice.label ?? '';
          final camera = CameraDescription(
            name: cameraLabel,
            lensDirection: lensDirection,
            sensorOrientation: 0,
          );

          final cameraMetadata = CameraMetadata(
            deviceId: videoInputDevice.deviceId!,
            facingMode: facingMode,
          );

          cameras.add(camera);

          camerasMetadata[camera] = cameraMetadata;
        } else {
          // Ignore as no video tracks exist in the current video input device.
          continue;
        }
      }

      return cameras;
    } on html.DomException catch (e) {
      throw CameraException(e.name, e.message);
    } on PlatformException catch (e) {
      throw CameraException(e.code, e.message);
    } on CameraWebException catch (e) {
      _addCameraErrorEvent(e);
      throw CameraException(e.code.toString(), e.description);
    }
  }

  @override
  Future<int> createCamera(
    CameraDescription cameraDescription,
    ResolutionPreset? resolutionPreset, {
    bool enableAudio = false,
  }) async {
    try {
      if (!camerasMetadata.containsKey(cameraDescription)) {
        throw PlatformException(
          code: CameraErrorCode.missingMetadata.toString(),
          message:
              'Missing camera metadata. Make sure to call `availableCameras` before creating a camera.',
        );
      }

      final textureId = _textureCounter++;

      final cameraMetadata = camerasMetadata[cameraDescription]!;

      final cameraType = cameraMetadata.facingMode != null
          ? _cameraService.mapFacingModeToCameraType(cameraMetadata.facingMode!)
          : null;

      // Use the highest resolution possible
      // if the resolution preset is not specified.
      final videoSize = _cameraService
          .mapResolutionPresetToSize(resolutionPreset ?? ResolutionPreset.max);

      // Create a camera with the given audio and video constraints.
      // Sensor orientation is currently not supported.
      final camera = Camera(
        textureId: textureId,
        cameraService: _cameraService,
        options: CameraOptions(
          audio: AudioConstraints(enabled: enableAudio),
          video: VideoConstraints(
            facingMode:
                cameraType != null ? FacingModeConstraint(cameraType) : null,
            width: VideoSizeConstraint(
              ideal: videoSize.width.toInt(),
            ),
            height: VideoSizeConstraint(
              ideal: videoSize.height.toInt(),
            ),
            deviceId: cameraMetadata.deviceId,
          ),
        ),
      );

      cameras[textureId] = camera;

      return textureId;
    } on PlatformException catch (e) {
      throw CameraException(e.code, e.message);
    }
  }

  @override
  Future<void> initializeCamera(
    int cameraId, {
    // The image format group is currently not supported.
    ImageFormatGroup imageFormatGroup = ImageFormatGroup.unknown,
  }) async {
    try {
      final camera = getCamera(cameraId);

      await camera.initialize();

      // Add camera's video error events to the camera events stream.
      // The error event fires when the video element's source has failed to load, or can't be used.
      _cameraVideoErrorSubscriptions[cameraId] =
          camera.videoElement.onError.listen((html.Event _) {
        // The Event itself (_) doesn't contain information about the actual error.
        // We need to look at the HTMLMediaElement.error.
        // See: https://developer.mozilla.org/en-US/docs/Web/API/HTMLMediaElement/error
        final error = camera.videoElement.error!;
        final errorCode = CameraErrorCode.fromMediaError(error);
        final errorMessage =
            error.message != '' ? error.message : _kDefaultErrorMessage;

        cameraEventStreamController.add(
          CameraErrorEvent(
            cameraId,
            'Error code: ${errorCode}, error message: ${errorMessage}',
          ),
        );
      });

      // Add camera's video abort events to the camera events stream.
      // The abort event fires when the video element's source has not fully loaded.
      _cameraVideoAbortSubscriptions[cameraId] =
          camera.videoElement.onAbort.listen((html.Event _) {
        cameraEventStreamController.add(
          CameraErrorEvent(
            cameraId,
            'Error code: ${CameraErrorCode.abort}, error message: The video element\'s source has not fully loaded.',
          ),
        );
      });

      await camera.play();

      // Add camera's closing events to the camera events stream.
      // The onEnded stream fires when there is no more camera stream data.
      _cameraEndedSubscriptions[cameraId] =
          camera.onEnded.listen((html.MediaStreamTrack _) {
        cameraEventStreamController.add(
          CameraClosingEvent(cameraId),
        );
      });

      final cameraSize = camera.getVideoSize();

      cameraEventStreamController.add(
        CameraInitializedEvent(
          cameraId,
          cameraSize.width,
          cameraSize.height,
          // TODO(camera_web): Add support for exposure mode and point (https://github.com/flutter/flutter/issues/86857).
          ExposureMode.auto,
          false,
          // TODO(camera_web): Add support for focus mode and point (https://github.com/flutter/flutter/issues/86858).
          FocusMode.auto,
          false,
        ),
      );
    } on html.DomException catch (e) {
      throw PlatformException(code: e.name, message: e.message);
    } on CameraWebException catch (e) {
      _addCameraErrorEvent(e);
      throw PlatformException(code: e.code.toString(), message: e.description);
    }
  }

  @override
  Stream<CameraInitializedEvent> onCameraInitialized(int cameraId) {
    return _cameraEvents(cameraId).whereType<CameraInitializedEvent>();
  }

  /// Emits an empty stream as there is no event corresponding to a change
  /// in the camera resolution on the web.
  ///
  /// In order to change the camera resolution a new camera with appropriate
  /// [CameraOptions.video] constraints has to be created and initialized.
  @override
  Stream<CameraResolutionChangedEvent> onCameraResolutionChanged(int cameraId) {
    return const Stream.empty();
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
    throw UnimplementedError('onVideoRecordedEvent() is not implemented.');
  }

  @override
  Stream<DeviceOrientationChangedEvent> onDeviceOrientationChanged() {
    final orientation = window?.screen?.orientation;

    if (orientation != null) {
      // Create an initial orientation event that emits the device orientation
      // as soon as subscribed to this stream.
      final initialOrientationEvent = html.Event("change");

      return orientation.onChange.startWith(initialOrientationEvent).map(
        (html.Event _) {
          final deviceOrientation = _cameraService
              .mapOrientationTypeToDeviceOrientation(orientation.type!);
          return DeviceOrientationChangedEvent(deviceOrientation);
        },
      );
    } else {
      return const Stream.empty();
    }
  }

  @override
  Future<void> lockCaptureOrientation(
    int cameraId,
    DeviceOrientation deviceOrientation,
  ) async {
    try {
      final orientation = window?.screen?.orientation;
      final documentElement = window?.document.documentElement;

      if (orientation != null && documentElement != null) {
        final orientationType = _cameraService
            .mapDeviceOrientationToOrientationType(deviceOrientation);

        // Full-screen mode may be required to modify the device orientation.
        // See: https://w3c.github.io/screen-orientation/#interaction-with-fullscreen-api
        documentElement.requestFullscreen();
        await orientation.lock(orientationType.toString());
      } else {
        throw PlatformException(
          code: CameraErrorCode.orientationNotSupported.toString(),
          message: 'Orientation is not supported in the current browser.',
        );
      }
    } on html.DomException catch (e) {
      throw PlatformException(code: e.name, message: e.message);
    }
  }

  @override
  Future<void> unlockCaptureOrientation(int cameraId) async {
    try {
      final orientation = window?.screen?.orientation;
      final documentElement = window?.document.documentElement;

      if (orientation != null && documentElement != null) {
        orientation.unlock();
      } else {
        throw PlatformException(
          code: CameraErrorCode.orientationNotSupported.toString(),
          message: 'Orientation is not supported in the current browser.',
        );
      }
    } on html.DomException catch (e) {
      throw PlatformException(code: e.name, message: e.message);
    }
  }

  @override
  Future<XFile> takePicture(int cameraId) {
    try {
      return getCamera(cameraId).takePicture();
    } on html.DomException catch (e) {
      throw PlatformException(code: e.name, message: e.message);
    } on CameraWebException catch (e) {
      _addCameraErrorEvent(e);
      throw PlatformException(code: e.code.toString(), message: e.description);
    }
  }

  @override
  Future<void> prepareForVideoRecording() {
    throw UnimplementedError('prepareForVideoRecording() is not implemented.');
  }

  @override
  Future<void> startVideoRecording(int cameraId, {Duration? maxVideoDuration}) {
    throw UnimplementedError('startVideoRecording() is not implemented.');
  }

  @override
  Future<XFile> stopVideoRecording(int cameraId) {
    throw UnimplementedError('stopVideoRecording() is not implemented.');
  }

  @override
  Future<void> pauseVideoRecording(int cameraId) {
    throw UnimplementedError('pauseVideoRecording() is not implemented.');
  }

  @override
  Future<void> resumeVideoRecording(int cameraId) {
    throw UnimplementedError('resumeVideoRecording() is not implemented.');
  }

  @override
  Future<void> setFlashMode(int cameraId, FlashMode mode) async {
    try {
      getCamera(cameraId).setFlashMode(mode);
    } on html.DomException catch (e) {
      throw PlatformException(code: e.name, message: e.message);
    } on CameraWebException catch (e) {
      _addCameraErrorEvent(e);
      throw PlatformException(code: e.code.toString(), message: e.description);
    }
  }

  @override
  Future<void> setExposureMode(int cameraId, ExposureMode mode) {
    throw UnimplementedError('setExposureMode() is not implemented.');
  }

  @override
  Future<void> setExposurePoint(int cameraId, Point<double>? point) {
    throw UnimplementedError('setExposurePoint() is not implemented.');
  }

  @override
  Future<double> getMinExposureOffset(int cameraId) {
    throw UnimplementedError('getMinExposureOffset() is not implemented.');
  }

  @override
  Future<double> getMaxExposureOffset(int cameraId) {
    throw UnimplementedError('getMaxExposureOffset() is not implemented.');
  }

  @override
  Future<double> getExposureOffsetStepSize(int cameraId) {
    throw UnimplementedError('getExposureOffsetStepSize() is not implemented.');
  }

  @override
  Future<double> setExposureOffset(int cameraId, double offset) {
    throw UnimplementedError('setExposureOffset() is not implemented.');
  }

  @override
  Future<void> setFocusMode(int cameraId, FocusMode mode) {
    throw UnimplementedError('setFocusMode() is not implemented.');
  }

  @override
  Future<void> setFocusPoint(int cameraId, Point<double>? point) {
    throw UnimplementedError('setFocusPoint() is not implemented.');
  }

  @override
  Future<double> getMaxZoomLevel(int cameraId) async {
    try {
      return getCamera(cameraId).getMaxZoomLevel();
    } on html.DomException catch (e) {
      throw PlatformException(code: e.name, message: e.message);
    } on CameraWebException catch (e) {
      _addCameraErrorEvent(e);
      throw PlatformException(code: e.code.toString(), message: e.description);
    }
  }

  @override
  Future<double> getMinZoomLevel(int cameraId) async {
    try {
      return getCamera(cameraId).getMinZoomLevel();
    } on html.DomException catch (e) {
      throw PlatformException(code: e.name, message: e.message);
    } on CameraWebException catch (e) {
      _addCameraErrorEvent(e);
      throw PlatformException(code: e.code.toString(), message: e.description);
    }
  }

  @override
  Future<void> setZoomLevel(int cameraId, double zoom) async {
    try {
      getCamera(cameraId).setZoomLevel(zoom);
    } on html.DomException catch (e) {
      throw CameraException(e.name, e.message);
    } on PlatformException catch (e) {
      throw CameraException(e.code, e.message);
    } on CameraWebException catch (e) {
      _addCameraErrorEvent(e);
      throw CameraException(e.code.toString(), e.description);
    }
  }

  @override
  Future<void> pausePreview(int cameraId) async {
    try {
      getCamera(cameraId).pause();
    } on html.DomException catch (e) {
      throw PlatformException(code: e.name, message: e.message);
    }
  }

  @override
  Future<void> resumePreview(int cameraId) async {
    try {
      await getCamera(cameraId).play();
    } on html.DomException catch (e) {
      throw PlatformException(code: e.name, message: e.message);
    } on CameraWebException catch (e) {
      _addCameraErrorEvent(e);
      throw PlatformException(code: e.code.toString(), message: e.description);
    }
  }

  @override
  Widget buildPreview(int cameraId) {
    return HtmlElementView(
      viewType: getCamera(cameraId).getViewType(),
    );
  }

  @override
  Future<void> dispose(int cameraId) async {
    try {
      await getCamera(cameraId).dispose();
      await _cameraVideoErrorSubscriptions[cameraId]?.cancel();
      await _cameraVideoAbortSubscriptions[cameraId]?.cancel();
      await _cameraEndedSubscriptions[cameraId]?.cancel();

      cameras.remove(cameraId);
      _cameraVideoErrorSubscriptions.remove(cameraId);
      _cameraVideoAbortSubscriptions.remove(cameraId);
      _cameraEndedSubscriptions.remove(cameraId);
    } on html.DomException catch (e) {
      throw PlatformException(code: e.name, message: e.message);
    }
  }

  /// Returns a media video stream for the device with the given [deviceId].
  Future<html.MediaStream> _getVideoStreamForDevice(
    String deviceId,
  ) {
    // Create camera options with the desired device id.
    final cameraOptions = CameraOptions(
      video: VideoConstraints(deviceId: deviceId),
    );

    return _cameraService.getMediaStreamForOptions(cameraOptions);
  }

  /// Returns a camera for the given [cameraId].
  ///
  /// Throws a [CameraException] if the camera does not exist.
  @visibleForTesting
  Camera getCamera(int cameraId) {
    final camera = cameras[cameraId];

    if (camera == null) {
      throw PlatformException(
        code: CameraErrorCode.notFound.toString(),
        message: 'No camera found for the given camera id $cameraId.',
      );
    }

    return camera;
  }

  /// Adds a [CameraErrorEvent], associated with the [exception],
  /// to the stream of camera events.
  void _addCameraErrorEvent(CameraWebException exception) {
    cameraEventStreamController.add(
      CameraErrorEvent(
        exception.cameraId,
        'Error code: ${exception.code}, error message: ${exception.description}',
      ),
    );
  }
}
