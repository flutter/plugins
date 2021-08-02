// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:html' as html;
import 'dart:ui';

import 'package:camera_platform_interface/camera_platform_interface.dart';
import 'package:camera_web/src/camera_settings.dart';
import 'package:camera_web/src/types/types.dart';

import 'shims/dart_ui.dart' as ui;

String _getViewType(int cameraId) => 'plugins.flutter.io/camera_$cameraId';

/// A camera initialized from the media devices in the current window.
/// See: https://developer.mozilla.org/en-US/docs/Web/API/MediaDevices
///
/// The obtained camera stream is constrained by [options] and fetched
/// with [CameraSettings.getMediaStreamForOptions].
///
/// The camera stream is displayed in the [videoElement] wrapped in the
/// [divElement] to avoid overriding the custom styles applied to
/// the video element in [_applyDefaultVideoStyles].
/// See: https://github.com/flutter/flutter/issues/79519
///
/// The camera can be played/stopped by calling [play]/[stop]
/// or may capture a picture by calling [takePicture].
///
/// The [textureId] is used to register a camera view with the id
/// defined by [_getViewType].
class Camera {
  /// Creates a new instance of [Camera]
  /// with the given [textureId] and optional
  /// [options] and [window].
  Camera({
    required this.textureId,
    required CameraSettings cameraSettings,
    this.options = const CameraOptions(),
  }) : _cameraSettings = cameraSettings;

  /// The texture id used to register the camera view.
  final int textureId;

  /// The camera options used to initialize a camera, empty by default.
  final CameraOptions options;

  /// The video element that displays the camera stream.
  /// Initialized in [initialize].
  late html.VideoElement videoElement;

  /// The wrapping element for the [videoElement] to avoid overriding
  /// the custom styles applied in [_applyDefaultVideoStyles].
  /// Initialized in [initialize].
  late html.DivElement divElement;

  /// The camera settings used to get the media stream for the camera.
  final CameraSettings _cameraSettings;

  /// Initializes the camera stream displayed in the [videoElement].
  /// Registers the camera view with [textureId] under [_getViewType] type.
  Future<void> initialize() async {
    final stream = await _cameraSettings.getMediaStreamForOptions(
      options,
      cameraId: textureId,
    );

    videoElement = html.VideoElement();
    _applyDefaultVideoStyles(videoElement);

    divElement = html.DivElement()
      ..style.setProperty('object-fit', 'cover')
      ..append(videoElement);

    ui.platformViewRegistry.registerViewFactory(
      _getViewType(textureId),
      (_) => divElement,
    );

    videoElement
      ..autoplay = false
      ..muted = !options.audio.enabled
      ..srcObject = stream
      ..setAttribute('playsinline', '');
  }

  /// Starts the camera stream.
  ///
  /// Initializes the camera source if the camera was previously stopped.
  Future<void> play() async {
    if (videoElement.srcObject == null) {
      final stream = await _cameraSettings.getMediaStreamForOptions(
        options,
        cameraId: textureId,
      );
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

  /// Returns the registered view type of the camera.
  String getViewType() => _getViewType(textureId);

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
