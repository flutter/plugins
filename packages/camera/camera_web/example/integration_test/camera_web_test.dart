// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:html';

import 'package:camera_platform_interface/camera_platform_interface.dart';
import 'package:camera_web/camera_web.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mocktail/mocktail.dart';

import 'helpers/helpers.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('CameraPlugin', () {
    const cameraId = 0;

    late Window window;
    late Navigator navigator;
    late MediaDevices mediaDevices;
    late VideoElement videoElement;

    setUp(() async {
      window = MockWindow();
      navigator = MockNavigator();
      mediaDevices = MockMediaDevices();
      videoElement = VideoElement()
        ..src =
            'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4'
        ..preload = 'true'
        ..width = 10
        ..height = 10;

      when(() => window.navigator).thenReturn(navigator);
      when(() => navigator.mediaDevices).thenReturn(mediaDevices);
      when(
        () => mediaDevices.getUserMedia(any()),
      ).thenAnswer((_) async => videoElement.captureStream());

      CameraPlatform.instance = CameraPlugin()..window = window;
    });

    testWidgets('CameraPlugin is the live instance', (tester) async {
      expect(CameraPlatform.instance, isA<CameraPlugin>());
    });

    testWidgets('availableCameras throws UnimplementedError', (tester) async {
      expect(
        () => CameraPlatform.instance.availableCameras(),
        throwsUnimplementedError,
      );
    });

    testWidgets('createCamera throws UnimplementedError', (tester) async {
      expect(
        () => CameraPlatform.instance.createCamera(
          CameraDescription(
            name: 'name',
            lensDirection: CameraLensDirection.external,
            sensorOrientation: 0,
          ),
          ResolutionPreset.medium,
        ),
        throwsUnimplementedError,
      );
    });

    testWidgets('initializeCamera throws UnimplementedError', (tester) async {
      expect(
        () => CameraPlatform.instance.initializeCamera(cameraId),
        throwsUnimplementedError,
      );
    });

    testWidgets('lockCaptureOrientation throws UnimplementedError',
        (tester) async {
      expect(
        () => CameraPlatform.instance.lockCaptureOrientation(
          cameraId,
          DeviceOrientation.landscapeLeft,
        ),
        throwsUnimplementedError,
      );
    });

    testWidgets('unlockCaptureOrientation throws UnimplementedError',
        (tester) async {
      expect(
        () => CameraPlatform.instance.unlockCaptureOrientation(cameraId),
        throwsUnimplementedError,
      );
    });

    testWidgets('takePicture throws UnimplementedError', (tester) async {
      expect(
        () => CameraPlatform.instance.takePicture(cameraId),
        throwsUnimplementedError,
      );
    });

    testWidgets('prepareForVideoRecording throws UnimplementedError',
        (tester) async {
      expect(
        () => CameraPlatform.instance.prepareForVideoRecording(),
        throwsUnimplementedError,
      );
    });

    testWidgets('startVideoRecording throws UnimplementedError',
        (tester) async {
      expect(
        () => CameraPlatform.instance.startVideoRecording(cameraId),
        throwsUnimplementedError,
      );
    });

    testWidgets('stopVideoRecording throws UnimplementedError', (tester) async {
      expect(
        () => CameraPlatform.instance.stopVideoRecording(cameraId),
        throwsUnimplementedError,
      );
    });

    testWidgets('pauseVideoRecording throws UnimplementedError',
        (tester) async {
      expect(
        () => CameraPlatform.instance.pauseVideoRecording(cameraId),
        throwsUnimplementedError,
      );
    });

    testWidgets('resumeVideoRecording throws UnimplementedError',
        (tester) async {
      expect(
        () => CameraPlatform.instance.resumeVideoRecording(cameraId),
        throwsUnimplementedError,
      );
    });

    testWidgets('setFlashMode throws UnimplementedError', (tester) async {
      expect(
        () => CameraPlatform.instance.setFlashMode(
          cameraId,
          FlashMode.auto,
        ),
        throwsUnimplementedError,
      );
    });

    testWidgets('setExposureMode throws UnimplementedError', (tester) async {
      expect(
        () => CameraPlatform.instance.setExposureMode(
          cameraId,
          ExposureMode.auto,
        ),
        throwsUnimplementedError,
      );
    });

    testWidgets('setExposurePoint throws UnimplementedError', (tester) async {
      expect(
        () => CameraPlatform.instance.setExposurePoint(
          cameraId,
          const Point(0, 0),
        ),
        throwsUnimplementedError,
      );
    });

    testWidgets('getMinExposureOffset throws UnimplementedError',
        (tester) async {
      expect(
        () => CameraPlatform.instance.getMinExposureOffset(cameraId),
        throwsUnimplementedError,
      );
    });

    testWidgets('getMaxExposureOffset throws UnimplementedError',
        (tester) async {
      expect(
        () => CameraPlatform.instance.getMaxExposureOffset(cameraId),
        throwsUnimplementedError,
      );
    });

    testWidgets('getExposureOffsetStepSize throws UnimplementedError',
        (tester) async {
      expect(
        () => CameraPlatform.instance.getExposureOffsetStepSize(cameraId),
        throwsUnimplementedError,
      );
    });

    testWidgets('setExposureOffset throws UnimplementedError', (tester) async {
      expect(
        () => CameraPlatform.instance.setExposureOffset(
          cameraId,
          0,
        ),
        throwsUnimplementedError,
      );
    });

    testWidgets('setFocusMode throws UnimplementedError', (tester) async {
      expect(
        () => CameraPlatform.instance.setFocusMode(
          cameraId,
          FocusMode.auto,
        ),
        throwsUnimplementedError,
      );
    });

    testWidgets('setFocusPoint throws UnimplementedError', (tester) async {
      expect(
        () => CameraPlatform.instance.setFocusPoint(
          cameraId,
          const Point(0, 0),
        ),
        throwsUnimplementedError,
      );
    });

    testWidgets('getMaxZoomLevel throws UnimplementedError', (tester) async {
      expect(
        () => CameraPlatform.instance.getMaxZoomLevel(cameraId),
        throwsUnimplementedError,
      );
    });

    testWidgets('getMinZoomLevel throws UnimplementedError', (tester) async {
      expect(
        () => CameraPlatform.instance.getMinZoomLevel(cameraId),
        throwsUnimplementedError,
      );
    });

    testWidgets('setZoomLevel throws UnimplementedError', (tester) async {
      expect(
        () => CameraPlatform.instance.setZoomLevel(
          cameraId,
          1.0,
        ),
        throwsUnimplementedError,
      );
    });

    testWidgets('buildPreview throws UnimplementedError', (tester) async {
      expect(
        () => CameraPlatform.instance.buildPreview(cameraId),
        throwsUnimplementedError,
      );
    });

    testWidgets('dispose throws UnimplementedError', (tester) async {
      expect(
        () => CameraPlatform.instance.dispose(cameraId),
        throwsUnimplementedError,
      );
    });

    group('events', () {
      testWidgets('onCameraInitialized throws UnimplementedError',
          (tester) async {
        expect(
          () => CameraPlatform.instance.onCameraInitialized(cameraId),
          throwsUnimplementedError,
        );
      });

      testWidgets('onCameraResolutionChanged throws UnimplementedError',
          (tester) async {
        expect(
          () => CameraPlatform.instance.onCameraResolutionChanged(cameraId),
          throwsUnimplementedError,
        );
      });

      testWidgets('onCameraClosing throws UnimplementedError', (tester) async {
        expect(
          () => CameraPlatform.instance.onCameraClosing(cameraId),
          throwsUnimplementedError,
        );
      });

      testWidgets('onCameraError throws UnimplementedError', (tester) async {
        expect(
          () => CameraPlatform.instance.onCameraError(cameraId),
          throwsUnimplementedError,
        );
      });

      testWidgets('onVideoRecordedEvent throws UnimplementedError',
          (tester) async {
        expect(
          () => CameraPlatform.instance.onVideoRecordedEvent(cameraId),
          throwsUnimplementedError,
        );
      });

      testWidgets('onDeviceOrientationChanged throws UnimplementedError',
          (tester) async {
        expect(
          () => CameraPlatform.instance.onDeviceOrientationChanged(),
          throwsUnimplementedError,
        );
      });
    });
  });
}
