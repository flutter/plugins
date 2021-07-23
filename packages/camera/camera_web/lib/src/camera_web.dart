// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:html' as html;
import 'dart:math';

import 'package:camera_platform_interface/camera_platform_interface.dart';
import 'package:camera_web/src/camera.dart';
import 'package:camera_web/src/camera_settings.dart';
import 'package:camera_web/src/types/types.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';

/// The web implementation of [CameraPlatform].
///
/// This class implements the `package:camera` functionality for the web.
class CameraPlugin extends CameraPlatform {
  /// Creates a new instance of [CameraPlugin]
  /// with the given [cameraSettings] utility.
  CameraPlugin({required CameraSettings cameraSettings})
      : _cameraSettings = cameraSettings;

  /// Registers this class as the default instance of [CameraPlatform].
  static void registerWith(Registrar registrar) {
    CameraPlatform.instance = CameraPlugin(
      cameraSettings: CameraSettings(),
    );
  }

  final CameraSettings _cameraSettings;

  /// The cameras managed by the [CameraPlugin].
  @visibleForTesting
  final cameras = <int, Camera>{};
  var _textureCounter = 1;

  /// Metadata associated with each camera description.
  /// Populated in [availableCameras].
  @visibleForTesting
  final camerasMetadata = <CameraDescription, CameraMetadata>{};

  /// The current browser window used to access media devices.
  @visibleForTesting
  html.Window? window = html.window;

  @override
  Future<List<CameraDescription>> availableCameras() async {
    final mediaDevices = window?.navigator.mediaDevices;
    final cameras = <CameraDescription>[];

    // Throw a not supported exception if the current browser window
    // does not support any media devices.
    if (mediaDevices == null) {
      throw CameraException(
        CameraErrorCodes.notSupported,
        'The camera is not supported on this device.',
      );
    }

    // Request available media devices.
    final devices = await mediaDevices.enumerateDevices();

    // Filter video input devices.
    final videoInputDevices = devices
        .whereType<html.MediaDeviceInfo>()
        .where((device) => device.kind == MediaDeviceKind.videoInput)

        /// The device id property is currently not supported on Internet Explorer:
        /// https://developer.mozilla.org/en-US/docs/Web/API/MediaDeviceInfo/deviceId#browser_compatibility
        .where((device) => device.deviceId != null);

    // Map video input devices to camera descriptions.
    for (final videoInputDevice in videoInputDevices) {
      // Get the video stream for the current video input device
      // to later use for the available video tracks.
      final videoStream = await _getVideoStreamForDevice(
        mediaDevices,
        videoInputDevice.deviceId!,
      );

      // Get all video tracks in the video stream
      // to later extract the lens direction from the first track.
      final videoTracks = videoStream.getVideoTracks();

      if (videoTracks.isNotEmpty) {
        // Get the facing mode from the first available video track.
        final facingMode = _cameraSettings.getFacingModeForVideoTrack(
          videoTracks.first,
        );

        // Get the lens direction based on the facing mode.
        // Fallback to the external lens direction
        // if the facing mode is not available.
        final lensDirection = facingMode != null
            ? _cameraSettings.mapFacingModeToLensDirection(facingMode)
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
  }

  @override
  Future<int> createCamera(
    CameraDescription cameraDescription,
    ResolutionPreset? resolutionPreset, {
    bool enableAudio = false,
  }) async {
    if (!camerasMetadata.containsKey(cameraDescription)) {
      throw CameraException(
        CameraErrorCodes.missingMetadata,
        'Missing camera metadata. Make sure to call `availableCameras` before creating a camera.',
      );
    }

    final textureId = _textureCounter++;

    final cameraMetadata = camerasMetadata[cameraDescription]!;

    final cameraType = cameraMetadata.facingMode != null
        ? _cameraSettings.mapFacingModeToCameraType(cameraMetadata.facingMode!)
        : null;

    // Use the highest resolution possible
    // if the resolution preset is not specified.
    final videoSize = _cameraSettings
        .mapResolutionPresetToSize(resolutionPreset ?? ResolutionPreset.max);

    // Create a camera with the given audio and video constraints.
    // Sensor orientation is currently not supported.
    final camera = Camera(
      textureId: textureId,
      window: window,
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
  }

  @override
  Future<void> initializeCamera(
    int cameraId, {
    ImageFormatGroup imageFormatGroup = ImageFormatGroup.unknown,
  }) {
    throw UnimplementedError('initializeCamera() is not implemented.');
  }

  @override
  Stream<CameraInitializedEvent> onCameraInitialized(int cameraId) {
    throw UnimplementedError('onCameraInitialized() is not implemented.');
  }

  @override
  Stream<CameraResolutionChangedEvent> onCameraResolutionChanged(int cameraId) {
    throw UnimplementedError('onCameraResolutionChanged() is not implemented.');
  }

  @override
  Stream<CameraClosingEvent> onCameraClosing(int cameraId) {
    throw UnimplementedError('onCameraClosing() is not implemented.');
  }

  @override
  Stream<CameraErrorEvent> onCameraError(int cameraId) {
    throw UnimplementedError('onCameraError() is not implemented.');
  }

  @override
  Stream<VideoRecordedEvent> onVideoRecordedEvent(int cameraId) {
    throw UnimplementedError('onVideoRecordedEvent() is not implemented.');
  }

  @override
  Stream<DeviceOrientationChangedEvent> onDeviceOrientationChanged() {
    throw UnimplementedError(
      'onDeviceOrientationChanged() is not implemented.',
    );
  }

  @override
  Future<void> lockCaptureOrientation(
    int cameraId,
    DeviceOrientation orientation,
  ) {
    throw UnimplementedError('lockCaptureOrientation() is not implemented.');
  }

  @override
  Future<void> unlockCaptureOrientation(int cameraId) {
    throw UnimplementedError('unlockCaptureOrientation() is not implemented.');
  }

  @override
  Future<XFile> takePicture(int cameraId) {
    throw UnimplementedError('takePicture() is not implemented.');
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
  Future<void> setFlashMode(int cameraId, FlashMode mode) {
    throw UnimplementedError('setFlashMode() is not implemented.');
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
  Future<double> getMaxZoomLevel(int cameraId) {
    throw UnimplementedError('getMaxZoomLevel() is not implemented.');
  }

  @override
  Future<double> getMinZoomLevel(int cameraId) {
    throw UnimplementedError('getMinZoomLevel() is not implemented.');
  }

  @override
  Future<void> setZoomLevel(int cameraId, double zoom) {
    throw UnimplementedError('setZoomLevel() is not implemented.');
  }

  @override
  Widget buildPreview(int cameraId) {
    throw UnimplementedError('buildPreview() is not implemented.');
  }

  @override
  Future<void> dispose(int cameraId) {
    throw UnimplementedError('dispose() is not implemented.');
  }

  /// Returns a media video stream for the device with the given [deviceId].
  Future<html.MediaStream> _getVideoStreamForDevice(
    html.MediaDevices mediaDevices,
    String deviceId,
  ) {
    // Create camera options with the desired device id.
    final cameraOptions = CameraOptions(
      video: VideoConstraints(deviceId: deviceId),
    );

    return mediaDevices.getUserMedia(cameraOptions.toJson());
  }
}
