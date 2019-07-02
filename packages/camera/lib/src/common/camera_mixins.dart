// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'camera_channel.dart';

mixin NativeMethodCallHandler {
  final int handle = CameraChannel.nextHandle++;
}

mixin CameraMappable {
  Map<String, dynamic> asMap();
}

mixin CameraClosable {
  bool isClosed = false;
}
