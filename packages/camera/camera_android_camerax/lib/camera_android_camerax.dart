// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

library camera_android_camerax;

import 'src/camerax.pigeon.dart';
import 'src/process_camera_provider.dart';

export 'src/java_object.dart' show JavaObject;
export 'src/process_camera_provider.dart' show ProcessCameraProvider;

/// Android Camera implented with the CameraX library.
class CameraAndroidCamerax {
  static void registerWith() {
    ProcessCameraProviderFlutterApi.setup(ProcessCameraProviderFlutterApi());
  }
}
