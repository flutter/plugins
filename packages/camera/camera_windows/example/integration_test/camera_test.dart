// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'package:async/async.dart';
import 'package:camera_platform_interface/camera_platform_interface.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

// Note that these integration tests do not currently cover
// most features and code paths, as they can only be tested if
// one or more cameras are available in the test environment.
// Native unit tests with better coverage are available at
// the native part of the plugin implementation.

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('initializeCamera', () {
    testWidgets('throws exception if camera is not created',
        (WidgetTester _) async {
      final CameraPlatform camera = CameraPlatform.instance;

      expect(() async => await camera.initializeCamera(1234),
          throwsA(isA<CameraException>()));
    });
  });

  group('takePicture', () {
    testWidgets('throws exception if camera is not created',
        (WidgetTester _) async {
      final CameraPlatform camera = CameraPlatform.instance;

      expect(() async => await camera.takePicture(1234),
          throwsA(isA<PlatformException>()));
    });
  });

  group('startVideoRecording', () {
    testWidgets('throws exception if camera is not created',
        (WidgetTester _) async {
      final CameraPlatform camera = CameraPlatform.instance;

      expect(() async => await camera.startVideoRecording(1234),
          throwsA(isA<PlatformException>()));
    });
  });

  group('stopVideoRecording', () {
    testWidgets('throws exception if camera is not created',
        (WidgetTester _) async {
      final CameraPlatform camera = CameraPlatform.instance;

      expect(() async => await camera.stopVideoRecording(1234),
          throwsA(isA<PlatformException>()));
    });
  });

  group('pausePreview', () {
    testWidgets('throws exception if camera is not created',
        (WidgetTester _) async {
      final CameraPlatform camera = CameraPlatform.instance;

      expect(() async => await camera.pausePreview(1234),
          throwsA(isA<PlatformException>()));
    });
  });

  group('resumePreview', () {
    testWidgets('throws exception if camera is not created',
        (WidgetTester _) async {
      final CameraPlatform camera = CameraPlatform.instance;

      expect(() async => await camera.resumePreview(1234),
          throwsA(isA<PlatformException>()));
    });
  });

  group('onDeviceOrientationChanged', () {
    testWidgets('emits the initial DeviceOrientationChangedEvent',
        (WidgetTester _) async {
      final Stream<DeviceOrientationChangedEvent> eventStream =
          CameraPlatform.instance.onDeviceOrientationChanged();

      final StreamQueue<DeviceOrientationChangedEvent> streamQueue =
          StreamQueue<DeviceOrientationChangedEvent>(eventStream);

      expect(
        await streamQueue.next,
        equals(
          const DeviceOrientationChangedEvent(
            DeviceOrientation.landscapeRight,
          ),
        ),
      );
    });
  });
}
