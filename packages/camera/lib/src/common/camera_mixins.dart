// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'camera_channel.dart';

mixin NativeMethodCallHandler {
  /// Identifier for an object on the native side of the plugin.
  ///
  /// Only used internally and for debugging.
  final int handle = CameraChannel.nextHandle++;
}

mixin CameraMappable {
  /// Creates a description of the object compatible with [PlatformChannel]s.
  ///
  /// Only used as an internal method and for debugging.
  Map<String, dynamic> asMap();
}
