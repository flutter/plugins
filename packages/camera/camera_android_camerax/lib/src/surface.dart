// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/services.dart' show BinaryMessenger;

import 'instance_manager.dart';
import 'java_object.dart';

/// Handle onto raw buffer managed by screen copmositor.
///
/// See https://developer.android.com/reference/android/view/Surface.html#ROTATION_0--.
class Surface extends JavaObject {
  /// Creates a detached [UseCase].
  Surface.detached(
      {BinaryMessenger? binaryMessenger, InstanceManager? instanceManager})
      : super.detached(
            binaryMessenger: binaryMessenger, instanceManager: instanceManager);

  static const ROTATION_0 = 0;

  static const ROTATION_180 = 2;

  static const ROTATION_270 = 3;

  static const ROTATION_90 = 1;
}
