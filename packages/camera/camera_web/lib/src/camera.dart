// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:html' as html;
import 'dart:ui';

import 'package:camera_platform_interface/camera_platform_interface.dart';
import 'package:camera_web/src/camera_service.dart';
import 'package:camera_web/src/types/types.dart';
import 'package:flutter/foundation.dart';

import 'shims/dart_ui.dart' as ui;

String _getViewType(int cameraId) => 'plugins.flutter.io/camera_$cameraId';

/// A camera initialized from the media devices in the current window.
/// See: https://developer.mozilla.org/en-US/docs/Web/API/MediaDevices
///
/// The obtained camera stream is constrained by [options] and fetched
/// with [CameraService.getMediaStreamForOptions].
///
/// The camera stream is displayed in the [videoElement] wrapped in the
/// [divElement] to avoid overriding the custom styles applied to
/// the video element in [_applyDefaultVideoStyles].
/// See: https://github.com/flutter/flutter/issues/79519
///
/// The camera can be played/stopped by calling [play]/[stop]
/// or may capture a picture by calling [takePicture].
///
/// The camera zoom may be adjusted with [setZoomLevel]. The provided
/// zoom level must be a value in the range of [getMinZoomLevel] to
/// [getMaxZoomLevel].
///
/// The [textureId] is used to register a camera view with the id
/// defined by [_getViewType].
class Camera {
  /// Creates a new instance of [Camera]
  /// with the given [textureId] and optional
  /// [options] and [window].
  Camera({
    required this.textureId,
    required CameraService cameraService,
    this.options = const CameraOptions(),
  }) : _cameraService = cameraService;

  // A torch mode constraint name.
  // See: https://w3c.github.io/mediacapture-image/#dom-mediatracksupportedconstraints-torch
  static const _torchModeKey = "torch";

  /// The texture id used to register the camera view.
  final int textureId;

  /// The camera options used to initialize a camera, empty by default.
  final CameraOptions options;

  /// The video element that displays the camera stream.
  /// Initialized in [initialize].
  late final html.VideoElement videoElement;

  /// The wrapping element for the [videoElement] to avoid overriding
  /// the custom styles applied in [_applyDefaultVideoStyles].
  /// Initialized in [initialize].
  late final html.DivElement divElement;

  /// The camera stream displayed in the [videoElement].
  /// Initialized in [initialize] and [play], reset in [stop].
  html.MediaStream? stream;

  /// The stream of the camera video tracks that have ended playing.
  ///
  /// This occurs when there is no more camera stream data, e.g.
  /// the user has stopped the stream by changing the camera device,
  /// revoked the camera permissions or ejected the camera device.
  ///
  /// MediaStreamTrack.onended:
  /// https://developer.mozilla.org/en-US/docs/Web/API/MediaStreamTrack/onended
  Stream<html.MediaStreamTrack> get onEnded => onEndedStreamController.stream;

  /// The stream controller for the [onEnded] stream.
  @visibleForTesting
  final onEndedStreamController =
      StreamController<html.MediaStreamTrack>.broadcast();

  StreamSubscription<html.Event>? _onEndedSubscription;

  /// The camera flash mode.
  @visibleForTesting
  FlashMode? flashMode;

  /// The camera service used to get the media stream for the camera.
  final CameraService _cameraService;

  /// The current browser window used to access media devices.
  @visibleForTesting
  html.Window? window = html.window;

  /// Initializes the camera stream displayed in the [videoElement].
  /// Registers the camera view with [textureId] under [_getViewType] type.
  /// Emits the camera default video track on the [onEnded] stream when it ends.
  Future<void> initialize() async {
    stream = await _cameraService.getMediaStreamForOptions(
      options,
      cameraId: textureId,
    );

    videoElement = html.VideoElement();

    divElement = html.DivElement()
      ..style.setProperty('object-fit', 'cover')
      ..append(videoElement);

    ui.platformViewRegistry.registerViewFactory(
      _getViewType(textureId),
      (_) => divElement,
    );

    videoElement
      ..autoplay = false
      ..muted = true
      ..srcObject = stream
      ..setAttribute('playsinline', '');

    _applyDefaultVideoStyles(videoElement);

    final videoTracks = stream!.getVideoTracks();

    if (videoTracks.isNotEmpty) {
      final defaultVideoTrack = videoTracks.first;

      _onEndedSubscription = defaultVideoTrack.onEnded.listen((html.Event _) {
        onEndedStreamController.add(defaultVideoTrack);
      });
    }
  }

  /// Starts the camera stream.
  ///
  /// Initializes the camera source if the camera was previously stopped.
  Future<void> play() async {
    if (videoElement.srcObject == null) {
      stream = await _cameraService.getMediaStreamForOptions(
        options,
        cameraId: textureId,
      );
      videoElement.srcObject = stream;
    }
    await videoElement.play();
  }

  /// Pauses the camera stream on the current frame.
  void pause() {
    videoElement.pause();
  }

  /// Stops the camera stream and resets the camera source.
  void stop() {
    final videoTracks = stream!.getVideoTracks();
    if (videoTracks.isNotEmpty) {
      onEndedStreamController.add(videoTracks.first);
    }

    final tracks = stream?.getTracks();
    if (tracks != null) {
      for (final track in tracks) {
        track.stop();
      }
    }
    videoElement.srcObject = null;
    stream = null;
  }

  /// Captures a picture and returns the saved file in a JPEG format.
  ///
  /// Enables the camera flash (torch mode) for a period of taking a picture
  /// if the flash mode is either [FlashMode.auto] or [FlashMode.always].
  Future<XFile> takePicture() async {
    final shouldEnableTorchMode =
        flashMode == FlashMode.auto || flashMode == FlashMode.always;

    if (shouldEnableTorchMode) {
      _setTorchMode(enabled: true);
    }

    final videoWidth = videoElement.videoWidth;
    final videoHeight = videoElement.videoHeight;
    final canvas = html.CanvasElement(width: videoWidth, height: videoHeight);
    final isBackCamera = getLensDirection() == CameraLensDirection.back;

    // Flip the picture horizontally if it is not taken from a back camera.
    if (!isBackCamera) {
      canvas.context2D
        ..translate(videoWidth, 0)
        ..scale(-1, 1);
    }

    canvas.context2D
        .drawImageScaled(videoElement, 0, 0, videoWidth, videoHeight);

    final blob = await canvas.toBlob('image/jpeg');

    if (shouldEnableTorchMode) {
      _setTorchMode(enabled: false);
    }

    return XFile(html.Url.createObjectUrl(blob));
  }

  /// Returns a size of the camera video based on its first video track size.
  ///
  /// Returns [Size.zero] if the camera is missing a video track or
  /// the video track does not include the width or height setting.
  Size getVideoSize() {
    final videoTracks = videoElement.srcObject?.getVideoTracks() ?? [];

    if (videoTracks.isEmpty) {
      return Size.zero;
    }

    final defaultVideoTrack = videoTracks.first;
    final defaultVideoTrackSettings = defaultVideoTrack.getSettings();

    final width = defaultVideoTrackSettings['width'];
    final height = defaultVideoTrackSettings['height'];

    if (width != null && height != null) {
      return Size(width, height);
    } else {
      return Size.zero;
    }
  }

  /// Sets the camera flash mode to [mode] by modifying the camera
  /// torch mode constraint.
  ///
  /// The torch mode is enabled for [FlashMode.torch] and
  /// disabled for [FlashMode.off].
  ///
  /// For [FlashMode.auto] and [FlashMode.always] the torch mode is enabled
  /// only for a period of taking a picture in [takePicture].
  ///
  /// Throws a [CameraWebException] if the torch mode is not supported
  /// or the camera has not been initialized or started.
  void setFlashMode(FlashMode mode) {
    final mediaDevices = window?.navigator.mediaDevices;
    final supportedConstraints = mediaDevices?.getSupportedConstraints();
    final torchModeSupported = supportedConstraints?[_torchModeKey] ?? false;

    if (!torchModeSupported) {
      throw CameraWebException(
        textureId,
        CameraErrorCode.torchModeNotSupported,
        'The torch mode is not supported in the current browser.',
      );
    }

    // Save the updated flash mode to be used later when taking a picture.
    flashMode = mode;

    // Enable the torch mode only if the flash mode is torch.
    _setTorchMode(enabled: mode == FlashMode.torch);
  }

  /// Sets the camera torch mode constraint to [enabled].
  ///
  /// Throws a [CameraWebException] if the torch mode is not supported
  /// or the camera has not been initialized or started.
  void _setTorchMode({required bool enabled}) {
    final videoTracks = stream?.getVideoTracks() ?? [];

    if (videoTracks.isNotEmpty) {
      final defaultVideoTrack = videoTracks.first;

      final bool canEnableTorchMode =
          defaultVideoTrack.getCapabilities()[_torchModeKey] ?? false;

      if (canEnableTorchMode) {
        defaultVideoTrack.applyConstraints({
          "advanced": [
            {
              _torchModeKey: enabled,
            }
          ]
        });
      } else {
        throw CameraWebException(
          textureId,
          CameraErrorCode.torchModeNotSupported,
          'The torch mode is not supported by the current camera.',
        );
      }
    } else {
      throw CameraWebException(
        textureId,
        CameraErrorCode.notStarted,
        'The camera has not been initialized or started.',
      );
    }
  }

  /// Returns the camera maximum zoom level.
  ///
  /// Throws a [CameraWebException] if the zoom level is not supported
  /// or the camera has not been initialized or started.
  double getMaxZoomLevel() =>
      _cameraService.getZoomLevelCapabilityForCamera(this).maximum;

  /// Returns the camera minimum zoom level.
  ///
  /// Throws a [CameraWebException] if the zoom level is not supported
  /// or the camera has not been initialized or started.
  double getMinZoomLevel() =>
      _cameraService.getZoomLevelCapabilityForCamera(this).minimum;

  /// Sets the camera zoom level to [zoom].
  ///
  /// Throws a [CameraWebException] if the zoom level is invalid,
  /// not supported or the camera has not been initialized or started.
  void setZoomLevel(double zoom) {
    final zoomLevelCapability =
        _cameraService.getZoomLevelCapabilityForCamera(this);

    if (zoom < zoomLevelCapability.minimum ||
        zoom > zoomLevelCapability.maximum) {
      throw CameraWebException(
        textureId,
        CameraErrorCode.zoomLevelInvalid,
        'The provided zoom level must be in the range of ${zoomLevelCapability.minimum} to ${zoomLevelCapability.maximum}.',
      );
    }

    zoomLevelCapability.videoTrack.applyConstraints({
      "advanced": [
        {
          ZoomLevelCapability.constraintName: zoom,
        }
      ]
    });
  }

  /// Returns a lens direction of this camera.
  ///
  /// Returns null if the camera is missing a video track or
  /// the video track does not include the facing mode setting.
  CameraLensDirection? getLensDirection() {
    final videoTracks = videoElement.srcObject?.getVideoTracks() ?? [];

    if (videoTracks.isEmpty) {
      return null;
    }

    final defaultVideoTrack = videoTracks.first;
    final defaultVideoTrackSettings = defaultVideoTrack.getSettings();

    final facingMode = defaultVideoTrackSettings['facingMode'];

    if (facingMode != null) {
      return _cameraService.mapFacingModeToLensDirection(facingMode);
    } else {
      return null;
    }
  }

  /// Returns the registered view type of the camera.
  String getViewType() => _getViewType(textureId);

  /// Disposes the camera by stopping the camera stream
  /// and reloading the camera source.
  Future<void> dispose() async {
    /// Stop the camera stream.
    stop();

    /// Reset the [videoElement] to its initial state.
    videoElement
      ..srcObject = null
      ..load();

    await _onEndedSubscription?.cancel();
    _onEndedSubscription = null;

    await onEndedStreamController.close();
  }

  /// Applies default styles to the video [element].
  void _applyDefaultVideoStyles(html.VideoElement element) {
    final isBackCamera = getLensDirection() == CameraLensDirection.back;

    // Flip the video horizontally if it is not taken from a back camera.
    if (!isBackCamera) {
      element.style.transform = 'scaleX(-1)';
    }

    element.style
      ..transformOrigin = 'center'
      ..pointerEvents = 'none'
      ..width = '100%'
      ..height = '100%'
      ..objectFit = 'cover';
  }
}
