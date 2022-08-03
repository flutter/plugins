// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'camera_android_camerax_platform_interface.dart';

class CameraAndroidCamerax {
  Future<String?> getPlatformVersion() {
    return CameraAndroidCameraxPlatform.instance.getPlatformVersion();
  }
}
