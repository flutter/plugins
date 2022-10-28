// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/foundation.dart';

import 'camera_image_data.dart';

/// Options wrapper for [CameraPlatform.startVideoCapturing] parameters.
@immutable
class VideoCaptureOptions {
  /// Constructs a new instance.
  const VideoCaptureOptions(
    this.cameraId, {
    this.maxDuration,
    this.streamCallback,
    this.streamOptions,
  }) : assert(
          streamOptions == null || streamCallback != null,
          'Must specify streamCallback if providing streamOptions.',
        );

  /// The ID of the camera to use for capturing.
  final int cameraId;

  /// The maximum time to perform capturing for.
  ///
  /// By default there is no maximum on the capture time.
  final Duration? maxDuration;

  /// An optional callback to enable streaming.
  ///
  /// If set, then each image captured by the camera will be
  /// passed to this callback.
  final Function(CameraImageData image)? streamCallback;

  /// Configuration options for streaming.
  ///
  /// Should only be set if a streamCallback is also present.
  final CameraImageStreamOptions? streamOptions;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VideoCaptureOptions &&
          runtimeType == other.runtimeType &&
          cameraId == other.cameraId &&
          maxDuration == other.maxDuration &&
          streamCallback == other.streamCallback &&
          streamOptions == other.streamOptions;

  @override
  int get hashCode =>
      Object.hash(cameraId, maxDuration, streamCallback, streamOptions);
}
