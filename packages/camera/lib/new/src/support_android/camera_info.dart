// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/foundation.dart';

import '../common/camera_interface.dart';

/// The direction that the camera faces.
enum Facing { back, front }

/// Information about a camera.
///
/// Retrieved from [Camera.getCameraInfo].
class CameraInfo implements CameraDescription {
  const CameraInfo({
    @required this.id,
    @required this.facing,
    @required this.orientation,
  })  : assert(id != null),
        assert(facing != null),
        assert(orientation != null);

  factory CameraInfo.fromMap(Map<String, dynamic> map) {
    return CameraInfo(
      id: map['id'],
      orientation: map['orientation'],
      facing: Facing.values.firstWhere(
        (Facing facing) => facing.toString() == map['facing'],
      ),
    );
  }

  /// Identifier for a particular camera.
  final int id;

  /// The direction that the camera faces.
  final Facing facing;

  /// The orientation of the camera image.
  ///
  /// The value is the angle that the camera image needs to be rotated clockwise
  /// so it shows correctly on the display in its natural orientation.
  /// It should be 0, 90, 180, or 270.
  ///
  /// For example, suppose a device has a naturally tall screen. The back-facing
  /// camera sensor is mounted in landscape. You are looking at the screen. If
  /// the top side of the camera sensor is aligned with the right edge of the
  /// screen in natural orientation, the value should be 90. If the top side of
  /// a front-facing camera sensor is aligned with the right of the screen, the
  /// value should be 270.
  final int orientation;

  @override
  String get name => id.toString();

  @override
  LensDirection get direction {
    switch (facing) {
      case Facing.front:
        return LensDirection.front;
      case Facing.back:
        return LensDirection.back;
    }

    return null;
  }
}
