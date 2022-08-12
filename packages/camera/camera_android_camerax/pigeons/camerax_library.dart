// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:pigeon/pigeon.dart';

@ConfigurePigeon(
  PigeonOptions(
    dartOut: 'lib/src/camerax.pigeon.dart',
    dartTestOut: 'test/test_camerax.pigeon.dart',
    dartOptions: DartOptions(copyrightHeader: <String>[
      'Copyright 2013 The Flutter Authors. All rights reserved.',
      'Use of this source code is governed by a BSD-style license that can be',
      'found in the LICENSE file.',
    ]),
    javaOut:
        'android/src/main/java/io/flutter/plugins/camerax/GeneratedCameraXLibrary.java',
    javaOptions: JavaOptions(
      package: 'io.flutter.plugins.camera',
      className: 'GeneratedCameraXLibrary',
      copyrightHeader: <String>[
        'Copyright 2013 The Flutter Authors. All rights reserved.',
        'Use of this source code is governed by a BSD-style license that can be',
        'found in the LICENSE file.',
      ],
    ),
  ),
)

@HostApi()
abstract class JavaObjectHostApi {
  void dispose(int instanceId);
}

@FlutterApi()
abstract class JavaObjectFlutterApi {
  void dispose(int instanceId);
}

@HostApi()
abstract class ProcessCameraProviderHostApi {
  @async
  int getInstance();

  List<int> getAvailableCameraInfos();
}

@FlutterApi()
abstract class ProcessCameraProviderFlutterApi {
  void create(int instanceId);
}

@HostApi()
abstract class CameraInfo {
  int getSensorOrientationDegrees(int instanceId);
}

@FlutterApi()
abstract class CameraInfo {
  void create(int instanceId);
}

@HostApi()
abstract class CameraSelector {
  List<int> filter(List<int> cameraInfos);
}


