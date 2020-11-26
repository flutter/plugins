// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
import 'dart:async';
import 'dart:ui';

import 'package:camera/camera.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:pedantic/pedantic.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:rxdart/rxdart.dart';

get mockAvailableCameras => [
      CameraDescription(
          name: 'camBack',
          lensDirection: CameraLensDirection.back,
          sensorOrientation: 90),
      CameraDescription(
          name: 'camFront',
          lensDirection: CameraLensDirection.front,
          sensorOrientation: 180),
    ];

get mockInitializeCamera => 13;

get mockOnResolutionChangedEvent =>
    ResolutionChangedEvent(13, 100, 100, 75, 75);

get mockOnCameraClosingEvent => null;

get mockOnCameraErrorEvent => CameraErrorEvent(13, 'closing');

get mockTakePicture => null;

get mockVideoRecordingXFile => null;

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  group('camera', () {
    test('debugCheckIsDisposed should not throw assertion error when disposed',
        () {
      final MockCameraDescription description = MockCameraDescription();
      final CameraController controller = CameraController(
        description,
        ResolutionPreset.low,
      );

      controller.dispose();

      expect(controller.debugCheckIsDisposed, returnsNormally);
    });

    test('debugCheckIsDisposed should throw assertion error when not disposed',
        () {
      final MockCameraDescription description = MockCameraDescription();
      final CameraController controller = CameraController(
        description,
        ResolutionPreset.low,
      );

      expect(
        () => controller.debugCheckIsDisposed(),
        throwsAssertionError,
      );
    });

    test('availableCameras() has camera', () async {
      CameraPlatform.instance = MockCameraPlatform();

      var camList = await availableCameras();

      expect(camList, equals(mockAvailableCameras));
    });
  });

  group('$CameraController', () {
    setUpAll(() {
      CameraPlatform.instance = MockCameraPlatform();
    });

    test('Can be initialized', () async {
      CameraController cameraController = CameraController(
          CameraDescription(
              name: 'cam',
              lensDirection: CameraLensDirection.back,
              sensorOrientation: 90),
          ResolutionPreset.max);
      await cameraController.initialize();

      expect(cameraController.value.aspectRatio, 1);
      expect(cameraController.value.previewSize, Size(75, 75));
      expect(cameraController.value.isInitialized, isTrue);
    });

    test('can be disposed', () async {
      CameraController cameraController = CameraController(
          CameraDescription(
              name: 'cam',
              lensDirection: CameraLensDirection.back,
              sensorOrientation: 90),
          ResolutionPreset.max);
      await cameraController.initialize();

      expect(cameraController.value.aspectRatio, 1);
      expect(cameraController.value.previewSize, Size(75, 75));
      expect(cameraController.value.isInitialized, isTrue);

      await cameraController.dispose();

      verify(CameraPlatform.instance.dispose(13)).called(1);
    });

    test('initialize() returns when disposed', () async {
      CameraController cameraController = CameraController(
          CameraDescription(
              name: 'cam',
              lensDirection: CameraLensDirection.back,
              sensorOrientation: 90),
          ResolutionPreset.max);
      await cameraController.initialize();

      expect(cameraController.value.aspectRatio, 1);
      expect(cameraController.value.previewSize, Size(75, 75));
      expect(cameraController.value.isInitialized, isTrue);

      await cameraController.dispose();

      verify(CameraPlatform.instance.dispose(13)).called(1);
      expect(cameraController.value.isInitialized, isFalse);

      await cameraController.initialize();
      expect(cameraController.value.isInitialized, isTrue);


    });
  });
}

class MockCameraPlatform extends Mock
    with MockPlatformInterfaceMixin
    implements CameraPlatform {

  @override
  Future<List<CameraDescription>> availableCameras() =>
      Future.value(mockAvailableCameras);

  @override
  Future<int> initializeCamera(
    CameraDescription cameraDescription,
    ResolutionPreset resolutionPreset, {
    bool enableAudio,
  }) =>
      Future.value(mockInitializeCamera);

  @override
  Stream<ResolutionChangedEvent> onResolutionChanged(int cameraId) {
    return Stream.value(mockOnResolutionChangedEvent);
  }

  @override
  Stream<CameraClosingEvent> onCameraClosing(int cameraId) {
    return Stream.value(mockOnCameraClosingEvent);
  }

  @override
  Stream<CameraErrorEvent> onCameraError(int cameraId) {
    return Stream.value(mockOnCameraErrorEvent);
  }

  @override
  Future<XFile> takePicture(int cameraId) => Future.value(mockTakePicture);

  // @override
  // Future<void> prepareForVideoRecording() {
  //
  // }

  @override
  Future<XFile> startVideoRecording(int cameraId) =>
      Future.value(mockVideoRecordingXFile);

// @override
// Future<void> stopVideoRecording(int cameraId) {
//
// }

// @override
// Future<void> pauseVideoRecording(int cameraId) {
//   throw UnimplementedError('pauseVideoRecording() is not implemented.');
// }

// @override
// Future<void> resumeVideoRecording(int cameraId) {
//   throw UnimplementedError('resumeVideoRecording() is not implemented.');
// }

// @override
// Widget buildView(int cameraId) {
//   throw UnimplementedError('buildView() has not been implemented.');
// }

}

class MockCameraDescription extends CameraDescription {
  @override
  CameraLensDirection get lensDirection => CameraLensDirection.back;

  @override
  String get name => 'back';
}
