// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'java_object.dart';

/// Handle onto the raw buffer managed by screen compositor.
///
/// See https://developer.android.com/reference/android/view/Surface.html.
class Surface extends JavaObject {
  /// Creates a detached [UseCase].
  Surface.detached({super.binaryMessenger, super.instanceManager})
      : super.detached();

  /// Rotation constant to signify the natural orientation.
  ///
  /// See https://developer.android.com/reference/android/view/Surface.html#ROTATION_0.
  static const int ROTATION_0 = 0;

  /// Rotation constant to signify a 90 degrees rotation.
  ///
  /// See https://developer.android.com/reference/android/view/Surface.html#ROTATION_90.
  static const int ROTATION_90 = 1;

  /// Rotation constant to signify a 180 degrees rotation.
  ///
  /// See https://developer.android.com/reference/android/view/Surface.html#ROTATION_180.
  static const int ROTATION_180 = 2;

  /// Rotation constant to signify a 270 degrees rotation.
  ///
  /// See https://developer.android.com/reference/android/view/Surface.html#ROTATION_270.
  static const int ROTATION_270 = 3;
}
