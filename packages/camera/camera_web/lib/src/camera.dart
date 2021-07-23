// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:html' as html;
import 'dart:ui';
import 'shims/dart_ui.dart' as ui;

import 'package:camera_platform_interface/camera_platform_interface.dart';
import 'package:camera_web/src/types/camera_error_codes.dart';
import 'package:camera_web/src/types/camera_options.dart';

String _getViewType(int cameraId) => 'plugins.flutter.io/camera_$cameraId';

/// A camera initialized from the media devices in the current [window].
/// The obtained camera is constrained by the [options] used when
/// querying the media input in [_getMediaStream].
///
/// The camera stream is displayed in the [videoElement] wrapped in the
/// [divElement] to avoid overriding the custom styles applied to
/// the video element in [_applyDefaultVideoStyles].
/// See: https://github.com/flutter/flutter/issues/79519
///
/// The camera can be played/stopped by calling [play]/[stop]
/// or may capture a picture by [takePicture].
///
/// The [textureId] is used to register a camera view with the id
/// returned by [_getViewType].
class Camera {
  /// Creates a new instance of [Camera]
  /// with the given [textureId] and optional
  /// [options] and [window].
  Camera({
    required this.textureId,
    this.options = const CameraOptions(),
    html.Window? window,
  }) : window = window ?? html.window;

  /// The texture id used to register the camera view.
  final int textureId;

  /// The camera options used to initialize a camera, empty by default.
  final CameraOptions options;

  /// The current browser window used to access device cameras.
  final html.Window window;

  /// The video element that displays the camera stream.
  /// Initialized in [initialize].
  late html.VideoElement videoElement;

  /// The wrapping element for the [videoElement] to avoid overriding
  /// the custom styles applied in [_applyDefaultVideoStyles].
  /// Initialized in [initialize].
  late html.DivElement divElement;

  /// Initializes the camera stream displayed in the [videoElement].
  /// Registers the camera view with [textureId] under [_getViewType] type.
  Future<void> initialize() async {
    final isSupported = window.navigator.mediaDevices?.getUserMedia != null;
    if (!isSupported) {
      throw CameraException(
        CameraErrorCodes.notSupported,
        'The camera is not supported on this device.',
      );
    }

    videoElement = html.VideoElement();
    _applyDefaultVideoStyles(videoElement);

    divElement = html.DivElement()
      ..style.setProperty('object-fit', 'cover')
      ..append(videoElement);

    ui.platformViewRegistry.registerViewFactory(
      _getViewType(textureId),
      (_) => divElement,
    );

    final stream = await _getMediaStream();
    videoElement
      ..autoplay = false
      ..muted = !options.audio.enabled
      ..srcObject = stream
      ..setAttribute('playsinline', '');
  }

  Future<html.MediaStream> _getMediaStream() async {
    try {
      final constraints = await options.toJson();
      return await window.navigator.mediaDevices!.getUserMedia(constraints);
    } on html.DomException catch (e) {
      switch (e.name) {
        case 'NotFoundError':
        case 'DevicesNotFoundError':
          throw CameraException(
            CameraErrorCodes.notFound,
            'No camera found for the given camera options.',
          );
        case 'NotReadableError':
        case 'TrackStartError':
          throw CameraException(
            CameraErrorCodes.notReadable,
            'The camera is not readable due to a hardware error '
            'that prevented access to the device.',
          );
        case 'OverconstrainedError':
        case 'ConstraintNotSatisfiedError':
          throw CameraException(
            CameraErrorCodes.overconstrained,
            'The camera options are impossible to satisfy.',
          );
        case 'NotAllowedError':
        case 'PermissionDeniedError':
          throw CameraException(
            CameraErrorCodes.permissionDenied,
            'The camera cannot be used or the permission '
            'to access the camera is not granted.',
          );
        case 'TypeError':
          throw CameraException(
            CameraErrorCodes.type,
            'The camera options are incorrect or attempted'
            'to access the media input from an insecure context.',
          );
        default:
          throw CameraException(
            CameraErrorCodes.unknown,
            'An unknown error occured when initializing the camera.',
          );
      }
    } catch (_) {
      throw CameraException(
        CameraErrorCodes.unknown,
        'An unknown error occured when initializing the camera.',
      );
    }
  }

  /// Starts the camera stream.
  ///
  /// Initializes the camera source if the camera was previously stopped.
  Future<void> play() async {
    if (videoElement.srcObject == null) {
      final stream = await _getMediaStream();
      videoElement.srcObject = stream;
    }
    await videoElement.play();
  }

  /// Stops the camera stream and resets the camera source.
  void stop() {
    final tracks = videoElement.srcObject?.getTracks();
    if (tracks != null) {
      for (final track in tracks) {
        track.stop();
      }
    }
    videoElement.srcObject = null;
  }

  /// Captures a picture and returns the saved file in a JPEG format.
  Future<XFile> takePicture() async {
    final videoWidth = videoElement.videoWidth;
    final videoHeight = videoElement.videoHeight;
    final canvas = html.CanvasElement(width: videoWidth, height: videoHeight);
    canvas.context2D
      ..translate(videoWidth, 0)
      ..scale(-1, 1)
      ..drawImageScaled(videoElement, 0, 0, videoWidth, videoHeight);
    final blob = await canvas.toBlob('image/jpeg');
    return XFile(html.Url.createObjectUrl(blob));
  }

  /// Returns a size of the camera video based on its first video track size.
  ///
  /// Returns [Size.zero] if the camera is missing a video track or
  /// the video track does not include the width or height setting.
  Future<Size> getVideoSize() async {
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

  /// Disposes the camera by stopping the camera stream
  /// and reloading the camera source.
  void dispose() {
    /// Stop the camera stream.
    stop();

    /// Reset the [videoElement] to its initial state.
    videoElement
      ..srcObject = null
      ..load();
  }

  /// Applies default styles to the video [element].
  void _applyDefaultVideoStyles(html.VideoElement element) {
    element.style
      ..transformOrigin = 'center'
      ..pointerEvents = 'none'
      ..width = '100%'
      ..height = '100%'
      ..objectFit = 'cover'
      ..transform = 'scaleX(-1)';
  }
}
