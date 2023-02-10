// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:camera_android_camerax/camera_android_camerax.dart';
import 'package:camera_platform_interface/camera_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    CameraPlatform.instance = AndroidCameraCameraX();
  });

  testWidgets('availableCameras only supports valid back or front cameras',
      (WidgetTester tester) async {
    final List<CameraDescription> availableCameras =
        await CameraPlatform.instance.availableCameras();

    for (final CameraDescription cameraDescription in availableCameras) {
      expect(
          cameraDescription.lensDirection, isNot(CameraLensDirection.external));
      expect(cameraDescription.sensorOrientation, anyOf(0, 90, 180, 270));
    }
  });
}
