// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import 'types.dart';

/// A container object for configuration options when building a widget.
///
/// This is intended for use as a parameter in platform interface methods, to
/// allow adding new configuration options to existing methods.
@immutable
class MapWidgetConfiguration {
  /// Creates a new configuration with all the given settings.
  const MapWidgetConfiguration({
    required this.initialCameraPosition,
    required this.textDirection,
    this.gestureRecognizers = const <Factory<OneSequenceGestureRecognizer>>{},
  });

  /// The initial camera position to display.
  final CameraPosition initialCameraPosition;

  /// The text direction for the widget.
  final TextDirection textDirection;

  /// Gesture recognizers to add to the widget.
  final Set<Factory<OneSequenceGestureRecognizer>> gestureRecognizers;
}
