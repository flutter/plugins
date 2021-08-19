// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:html' as html;
import 'dart:ui' show hashValues;

/// The possible range of values for the zoom level configurable
/// on the camera video track.
class ZoomLevelCapability {
  /// Creates a new instance of [ZoomLevelCapability] with the given
  /// zoom level range of [minimum] to [maximum] configurable
  /// on the [videoTrack].
  ZoomLevelCapability({
    required this.minimum,
    required this.maximum,
    required this.videoTrack,
  });

  /// The zoom level constraint name.
  /// See: https://w3c.github.io/mediacapture-image/#dom-mediatracksupportedconstraints-zoom
  static const constraintName = "zoom";

  /// The minimum zoom level.
  final double minimum;

  /// The maximum zoom level.
  final double maximum;

  /// The video track capable of configuring the zoom level.
  final html.MediaStreamTrack videoTrack;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ZoomLevelCapability &&
        other.minimum == minimum &&
        other.maximum == maximum &&
        other.videoTrack == videoTrack;
  }

  @override
  int get hashCode => hashValues(minimum, maximum, videoTrack);
}
