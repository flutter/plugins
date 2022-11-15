// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/services.dart' show BinaryMessenger;

import 'instance_manager.dart';
import 'java_object.dart';

/// [?] Does this need to be connected to native side?
/// An object representing the different functionalitites of the camera.
///
/// See https://developer.android.com/reference/androidx/camera/core/UseCase.
class UseCase extends JavaObject {
  /// Creates a detached [UseCase].
    UseCase.detached(
      {BinaryMessenger? binaryMessenger,
      InstanceManager? instanceManager})
    : super.detached(
        binaryMessenger: binaryMessenger,
        instanceManager: instanceManager);
}
