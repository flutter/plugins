// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:camera_platform_interface/camera_platform_interface.dart';
import 'package:camera_windows/camera_windows.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('$CameraWindows()', () {
    final CameraWindows plugin = CameraWindows();

    final List<MethodCall> log = <MethodCall>[];

    setUp(() {
      plugin.pluginChannel
          .setMockMethodCallHandler((MethodCall methodCall) async {
        log.add(methodCall);
        return null;
      });

      log.clear();
    });

    test('registered instance', () {
      CameraWindows.registerWith();
      expect(CameraPlatform.instance, isA<CameraWindows>());
    });
  });
}
