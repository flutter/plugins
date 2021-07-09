// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:html';

import 'package:camera_platform_interface/camera_platform_interface.dart';
import 'package:camera_web/camera_web.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'helpers/helpers.dart';

void main() {
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
        ..src = 'https://www.w3schools.com/tags/mov_bbb.mp4'
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

    test('availableCameras throws UnimplementedError', () {
      expect(
        () => CameraPlatform.instance.availableCameras(),
        throwsUnimplementedError,
      );
    });

    test('createCamera throws UnimplementedError', () {
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

    test('initializeCamera throws UnimplementedError', () {
      expect(
        () => CameraPlatform.instance.initializeCamera(cameraId),
        throwsUnimplementedError,
      );
    });

    test('lockCaptureOrientation throws UnimplementedError', () {
      expect(
        () => CameraPlatform.instance.lockCaptureOrientation(
          cameraId,
          DeviceOrientation.landscapeLeft,
        ),
        throwsUnimplementedError,
      );
    });

    test('unlockCaptureOrientation throws UnimplementedError', () {
      expect(
        () => CameraPlatform.instance.unlockCaptureOrientation(cameraId),
        throwsUnimplementedError,
      );
    });

    test('takePicture throws UnimplementedError', () {
      expect(
        () => CameraPlatform.instance.takePicture(cameraId),
        throwsUnimplementedError,
      );
    });

    test('prepareForVideoRecording throws UnimplementedError', () {
      expect(
        () => CameraPlatform.instance.prepareForVideoRecording(),
        throwsUnimplementedError,
      );
    });

    test('startVideoRecording throws UnimplementedError', () {
      expect(
        () => CameraPlatform.instance.startVideoRecording(cameraId),
        throwsUnimplementedError,
      );
    });

    test('stopVideoRecording throws UnimplementedError', () {
      expect(
        () => CameraPlatform.instance.stopVideoRecording(cameraId),
        throwsUnimplementedError,
      );
    });

    test('pauseVideoRecording throws UnimplementedError', () {
      expect(
        () => CameraPlatform.instance.pauseVideoRecording(cameraId),
        throwsUnimplementedError,
      );
    });

    test('resumeVideoRecording throws UnimplementedError', () {
      expect(
        () => CameraPlatform.instance.resumeVideoRecording(cameraId),
        throwsUnimplementedError,
      );
    });

    test('setFlashMode throws UnimplementedError', () {
      expect(
        () => CameraPlatform.instance.setFlashMode(
          cameraId,
          FlashMode.auto,
        ),
        throwsUnimplementedError,
      );
    });

    test('setExposureMode throws UnimplementedError', () {
      expect(
        () => CameraPlatform.instance.setExposureMode(
          cameraId,
          ExposureMode.auto,
        ),
        throwsUnimplementedError,
      );
    });

    test('setExposurePoint throws UnimplementedError', () {
      expect(
        () => CameraPlatform.instance.setExposurePoint(
          cameraId,
          const Point(0, 0),
        ),
        throwsUnimplementedError,
      );
    });

    test('getMinExposureOffset throws UnimplementedError', () {
      expect(
        () => CameraPlatform.instance.getMinExposureOffset(cameraId),
        throwsUnimplementedError,
      );
    });

    test('getMaxExposureOffset throws UnimplementedError', () {
      expect(
        () => CameraPlatform.instance.getMaxExposureOffset(cameraId),
        throwsUnimplementedError,
      );
    });

    test('getExposureOffsetStepSize throws UnimplementedError', () {
      expect(
        () => CameraPlatform.instance.getExposureOffsetStepSize(cameraId),
        throwsUnimplementedError,
      );
    });

    test('setExposureOffset throws UnimplementedError', () {
      expect(
        () => CameraPlatform.instance.setExposureOffset(
          cameraId,
          0,
        ),
        throwsUnimplementedError,
      );
    });

    test('setFocusMode throws UnimplementedError', () {
      expect(
        () => CameraPlatform.instance.setFocusMode(
          cameraId,
          FocusMode.auto,
        ),
        throwsUnimplementedError,
      );
    });

    test('setFocusPoint throws UnimplementedError', () {
      expect(
        () => CameraPlatform.instance.setFocusPoint(
          cameraId,
          const Point(0, 0),
        ),
        throwsUnimplementedError,
      );
    });

    test('getMaxZoomLevel throws UnimplementedError', () {
      expect(
        () => CameraPlatform.instance.getMaxZoomLevel(cameraId),
        throwsUnimplementedError,
      );
    });

    test('getMinZoomLevel throws UnimplementedError', () {
      expect(
        () => CameraPlatform.instance.getMinZoomLevel(cameraId),
        throwsUnimplementedError,
      );
    });

    test('setZoomLevel throws UnimplementedError', () {
      expect(
        () => CameraPlatform.instance.setZoomLevel(
          cameraId,
          1.0,
        ),
        throwsUnimplementedError,
      );
    });

    test('buildPreview throws UnimplementedError', () {
      expect(
        () => CameraPlatform.instance.buildPreview(cameraId),
        throwsUnimplementedError,
      );
    });

    test('dispose throws UnimplementedError', () {
      expect(
        () => CameraPlatform.instance.dispose(cameraId),
        throwsUnimplementedError,
      );
    });

    group('events', () {
      test('onCameraInitialized throws UnimplementedError', () {
        expect(
          () => CameraPlatform.instance.onCameraInitialized(cameraId),
          throwsUnimplementedError,
        );
      });

      test('onCameraResolutionChanged throws UnimplementedError', () {
        expect(
          () => CameraPlatform.instance.onCameraResolutionChanged(cameraId),
          throwsUnimplementedError,
        );
      });

      test('onCameraClosing throws UnimplementedError', () {
        expect(
          () => CameraPlatform.instance.onCameraClosing(cameraId),
          throwsUnimplementedError,
        );
      });

      test('onCameraError throws UnimplementedError', () {
        expect(
          () => CameraPlatform.instance.onCameraError(cameraId),
          throwsUnimplementedError,
        );
      });

      test('onVideoRecordedEvent throws UnimplementedError', () {
        expect(
          () => CameraPlatform.instance.onVideoRecordedEvent(cameraId),
          throwsUnimplementedError,
        );
      });

      test('onDeviceOrientationChanged throws UnimplementedError', () {
        expect(
          () => CameraPlatform.instance.onDeviceOrientationChanged(),
          throwsUnimplementedError,
        );
      });
    });
  });
}
