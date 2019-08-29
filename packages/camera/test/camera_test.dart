// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:camera/new/camera.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:camera/new/src/camera_testing.dart';
import 'package:camera/new/src/common/native_texture.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Camera', () {
    final List<MethodCall> log = <MethodCall>[];

    setUpAll(() {
      CameraTesting.channel
          .setMockMethodCallHandler((MethodCall methodCall) async {
        log.add(methodCall);
        switch (methodCall.method) {
          case 'NativeTexture#allocate':
            return 15;
        }

        throw ArgumentError.value(
          methodCall.method,
          'methodCall.method',
          'No method found for',
        );
      });
    });

    setUp(() {
      log.clear();
      CameraTesting.nextHandle = 0;
    });

    group('$CameraController', () {
      test('Initializing a second controller closes the first', () {
        final MockCameraDescription description = MockCameraDescription();
        final MockCameraConfigurator configurator = MockCameraConfigurator();

        final CameraController controller1 =
            CameraController.customConfigurator(
          description: description,
          configurator: configurator,
        );

        controller1.initialize();

        final CameraController controller2 =
            CameraController.customConfigurator(
          description: description,
          configurator: configurator,
        );

        controller2.initialize();

        expect(
          () => controller1.start(),
          throwsA(isInstanceOf<AssertionError>()),
        );

        expect(
          () => controller1.stop(),
          throwsA(isInstanceOf<AssertionError>()),
        );

        expect(controller1.isDisposed, isTrue);
      });
    });

    group('$NativeTexture', () {
      test('allocate', () async {
        final NativeTexture texture = await NativeTexture.allocate();

        expect(texture.textureId, 15);
        expect(log, <Matcher>[
          isMethodCall(
            '$NativeTexture#allocate',
            arguments: <String, dynamic>{'textureHandle': 0},
          )
        ]);
      });
    });
  });
}

class MockCameraDescription extends CameraDescription {
  @override
  LensDirection get direction => LensDirection.unknown;

  @override
  String get name => 'none';
}

class MockCameraConfigurator extends CameraConfigurator {
  @override
  Future<int> addPreviewTexture() => Future<int>.value(7);

  @override
  Future<void> dispose() => Future<void>.value();

  @override
  Future<void> initialize() => Future<void>.value();

  @override
  int get previewTextureId => 7;

  @override
  Future<void> start() => Future<void>.value();

  @override
  Future<void> stop() => Future<void>.value();
}
