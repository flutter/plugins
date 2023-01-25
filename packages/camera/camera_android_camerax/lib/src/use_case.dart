// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'java_object.dart';

/// An object representing the different functionalitites of the camera.
///
/// See https://developer.android.com/reference/androidx/camera/core/UseCase.
class UseCase extends JavaObject {
  /// Creates a detached [UseCase].
  UseCase.detached({super.binaryMessenger, super.instanceManager})
      : super.detached();
}
