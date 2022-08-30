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
      package: 'io.flutter.plugins.camerax',
      className: 'GeneratedCameraXLibrary',
      copyrightHeader: <String>[
        'Copyright 2013 The Flutter Authors. All rights reserved.',
        'Use of this source code is governed by a BSD-style license that can be',
        'found in the LICENSE file.',
      ],
    ),
  ),
)
@HostApi(dartHostTestHandler: 'TestJavaObjectHostApi')
abstract class JavaObjectHostApi {
  void dispose(int instanceId);
}

@FlutterApi()
abstract class JavaObjectFlutterApi {
  void dispose(int instanceId);
}

@HostApi(dartHostTestHandler: 'TestJavaObjectHostApi')
abstract class ProcessCameraProviderHostApi {
  @async
  int getInstance();

  List<int> getAvailableCameraInfos(int instanceId);
}

@FlutterApi()
abstract class ProcessCameraProviderFlutterApi {
  void create(int instanceId);
}

@HostApi(dartHostTestHandler: 'TestJavaObjectHostApi')
abstract class CameraInfoHostApi {
  int getSensorRotationDegrees(int instanceId);
}

@FlutterApi()
abstract class CameraInfoFlutterApi {
  void create(int instanceId);
}

@HostApi(dartHostTestHandler: 'TestJavaObjectHostApi')
abstract class CameraSelectorHostApi {
  int requireLensFacing(int lensDirection);

  List<int> filter(int instanceId, List<int> cameraInfoIds);
}

@FlutterApi()
abstract class CameraSelectorFlutterApi {
  void create(int instanceId, int? lensFacing);
}
