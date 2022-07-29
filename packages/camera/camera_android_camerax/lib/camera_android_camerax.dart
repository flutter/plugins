// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'camera_android_camerax_platform_interface.dart';

/// Android camera implented with CameraX.
class CameraAndroidCamerax {
  /// Rertireves platform version of camera.
  Future<String?> getPlatformVersion() {
    return CameraAndroidCameraxPlatform.instance.getPlatformVersion();
  }
}
