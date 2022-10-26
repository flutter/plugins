// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'java_object.dart';

class Camera extends JavaObject {
    /// Creates a [Camera].
    Camera(
      {BinaryMessneger? binaryMessenger,
      InstanceManager? instanceManager})
    : super.detached(
        binaryMessenger: binaryMessenger,
        instanceManager: instanceManager);
}