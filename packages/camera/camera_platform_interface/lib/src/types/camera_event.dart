// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:ui';

import 'package:meta/meta.dart';

/// Event emitted from the platform implementation.
class CameraEvent {
  /// Creates an instance of [CameraEvent].
  ///
  /// The [eventType] argument is required.
  ///
  /// Depending on the [eventType], the [captureSize], [previewSize] and
  /// [errorDescription] arguments can be null.
  CameraEvent({
    @required this.eventType,
    this.captureSize,
    this.previewSize,
    this.errorDescription,
  });

  /// The type of the event.
  final CameraEventType eventType;

  /// The capture size in pixels.
  ///
  /// Only used if the [eventType] is [CameraEventType.initialized]
  final Size captureSize;

  /// The size of the preview in pixels.
  ///
  /// Only used if the [eventType] is [CameraEventType.initialized]
  final Size previewSize;

  /// Description of the error.
  ///
  /// Only used if [eventType] is [CameraEventType.error].
  final String errorDescription;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is CameraEvent &&
            runtimeType == other.runtimeType &&
            eventType == other.eventType &&
            captureSize == other.captureSize &&
            previewSize == other.previewSize &&
            errorDescription == other.errorDescription;
  }

  @override
  int get hashCode =>
      eventType.hashCode ^
      captureSize.hashCode ^
      previewSize.hashCode ^
      errorDescription.hashCode;
}

/// Type of the event.
///
/// Emitted by the platform implementation when the camera is closing or
/// if an error occured.
enum CameraEventType {
  /// The camera has been initialized.

  /// The camera is closing.
  cameraClosing,

  /// An error occured while accessing the camera.
  error,

  /// An unknown event has been received.
  unknown,
}
