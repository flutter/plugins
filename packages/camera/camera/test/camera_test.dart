// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:ui';

import 'package:camera/camera.dart';
import 'package:camera_platform_interface/camera_platform_interface.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

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

get mockOnCameraInitializedEvent => CameraInitializedEvent(13, 75, 75);

get mockOnCameraClosingEvent => null;

get mockOnCameraErrorEvent => CameraErrorEvent(13, 'closing');

XFile mockTakePicture = XFile('foo/bar.png');

get mockVideoRecordingXFile => null;

bool mockPlatformException = false;

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

    test('initialize() throws CameraException when disposed', () async {
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

      expect(
          cameraController.initialize,
          throwsA(isA<CameraException>().having(
            (error) => error.description,
            'Error description',
            'initialize was called on a disposed CameraController',
          )));
    });

    test('initialize() throws $CameraException on $PlatformException ',
        () async {
      CameraController cameraController = CameraController(
          CameraDescription(
              name: 'cam',
              lensDirection: CameraLensDirection.back,
              sensorOrientation: 90),
          ResolutionPreset.max);

      mockPlatformException = true;

      expect(
          cameraController.initialize,
          throwsA(isA<CameraException>().having(
            (error) => error.description,
            'foo',
            'bar',
          )));
      mockPlatformException = false;
    });

    test('prepareForVideoRecording() calls $CameraPlatform ', () async {
      CameraController cameraController = CameraController(
          CameraDescription(
              name: 'cam',
              lensDirection: CameraLensDirection.back,
              sensorOrientation: 90),
          ResolutionPreset.max);
      await cameraController.initialize();

      await cameraController.prepareForVideoRecording();

      verify(CameraPlatform.instance.prepareForVideoRecording()).called(1);
    });

    test('takePicture() throws $CameraException when uninitialized ', () async {
      CameraController cameraController = CameraController(
          CameraDescription(
              name: 'cam',
              lensDirection: CameraLensDirection.back,
              sensorOrientation: 90),
          ResolutionPreset.max);
      expect(
          cameraController.takePicture(),
          throwsA(isA<CameraException>().having(
            (error) => error.description,
            'Uninitialized CameraController.',
            'takePicture was called on uninitialized CameraController',
          )));
    });

    test('takePicture() throws $CameraException when takePicture is true',
        () async {
      CameraController cameraController = CameraController(
          CameraDescription(
              name: 'cam',
              lensDirection: CameraLensDirection.back,
              sensorOrientation: 90),
          ResolutionPreset.max);
      await cameraController.initialize();

      cameraController.value =
          cameraController.value.copyWith(isTakingPicture: true);
      expect(
          cameraController.takePicture(),
          throwsA(isA<CameraException>().having(
            (error) => error.description,
            'Previous capture has not returned yet.',
            'takePicture was called before the previous capture returned.',
          )));
    });

    test('takePicture() returns $XFile', () async {
      CameraController cameraController = CameraController(
          CameraDescription(
              name: 'cam',
              lensDirection: CameraLensDirection.back,
              sensorOrientation: 90),
          ResolutionPreset.max);
      await cameraController.initialize();
      XFile xFile = await cameraController.takePicture();

      expect(xFile.path, mockTakePicture.path);
    });

    test('takePicture() throws $CameraException on $PlatformException',
        () async {
      CameraController cameraController = CameraController(
          CameraDescription(
              name: 'cam',
              lensDirection: CameraLensDirection.back,
              sensorOrientation: 90),
          ResolutionPreset.max);
      await cameraController.initialize();

      mockPlatformException = true;
      expect(
          cameraController.takePicture(),
          throwsA(isA<CameraException>().having(
            (error) => error.description,
            'foo',
            'bar',
          )));
      mockPlatformException = false;
    });

    test('startVideoRecording() throws $CameraException when uninitialized',
        () async {
      CameraController cameraController = CameraController(
          CameraDescription(
              name: 'cam',
              lensDirection: CameraLensDirection.back,
              sensorOrientation: 90),
          ResolutionPreset.max);

      expect(
          cameraController.startVideoRecording(),
          throwsA(isA<CameraException>().having(
            (error) => error.description,
            'Uninitialized CameraController',
            'startVideoRecording was called on uninitialized CameraController',
          )));
    });
    test('startVideoRecording() throws $CameraException when recording videos',
        () async {
      CameraController cameraController = CameraController(
          CameraDescription(
              name: 'cam',
              lensDirection: CameraLensDirection.back,
              sensorOrientation: 90),
          ResolutionPreset.max);

      await cameraController.initialize();

      cameraController.value =
          cameraController.value.copyWith(isRecordingVideo: true);

      expect(
          cameraController.startVideoRecording(),
          throwsA(isA<CameraException>().having(
            (error) => error.description,
            'A video recording is already started.',
            'startVideoRecording was called when a recording is already started.',
          )));
    });

    test(
        'startVideoRecording() throws $CameraException when already streaming images',
        () async {
      CameraController cameraController = CameraController(
          CameraDescription(
              name: 'cam',
              lensDirection: CameraLensDirection.back,
              sensorOrientation: 90),
          ResolutionPreset.max);

      await cameraController.initialize();

      cameraController.value =
          cameraController.value.copyWith(isStreamingImages: true);

      expect(
          cameraController.startVideoRecording(),
          throwsA(isA<CameraException>().having(
            (error) => error.description,
            'A camera has started streaming images.',
            'startVideoRecording was called while a camera was streaming images.',
          )));
    });

    test('getMaxZoomLevel() throws $CameraException when uninitialized',
        () async {
      CameraController cameraController = CameraController(
          CameraDescription(
              name: 'cam',
              lensDirection: CameraLensDirection.back,
              sensorOrientation: 90),
          ResolutionPreset.max);

      expect(
          cameraController.getMaxZoomLevel,
          throwsA(isA<CameraException>().having(
            (error) => error.description,
            'Uninitialized CameraController',
            'getMaxZoomLevel was called on uninitialized CameraController',
          )));
    });

    test('getMaxZoomLevel() throws $CameraException when disposed', () async {
      CameraController cameraController = CameraController(
          CameraDescription(
              name: 'cam',
              lensDirection: CameraLensDirection.back,
              sensorOrientation: 90),
          ResolutionPreset.max);

      await cameraController.initialize();
      await cameraController.dispose();

      expect(
          cameraController.getMaxZoomLevel,
          throwsA(isA<CameraException>().having(
            (error) => error.description,
            'Uninitialized CameraController',
            'getMaxZoomLevel was called on uninitialized CameraController',
          )));
    });

    test(
        'getMaxZoomLevel() throws $CameraException when a platform exception occured.',
        () async {
      CameraController cameraController = CameraController(
          CameraDescription(
              name: 'cam',
              lensDirection: CameraLensDirection.back,
              sensorOrientation: 90),
          ResolutionPreset.max);

      await cameraController.initialize();
      when(CameraPlatform.instance.getMaxZoomLevel(mockInitializeCamera))
          .thenThrow(PlatformException(
              code: 'TEST_ERROR',
              message: 'This is a test error messge',
              details: null));

      expect(
          cameraController.getMaxZoomLevel,
          throwsA(isA<CameraException>()
              .having((error) => error.code, 'code', 'TEST_ERROR')
              .having(
                (error) => error.description,
                'description',
                'This is a test error messge',
              )));
    });

    test('getMaxZoomLevel() returns max zoom level.', () async {
      CameraController cameraController = CameraController(
          CameraDescription(
              name: 'cam',
              lensDirection: CameraLensDirection.back,
              sensorOrientation: 90),
          ResolutionPreset.max);

      await cameraController.initialize();
      when(CameraPlatform.instance.getMaxZoomLevel(mockInitializeCamera))
          .thenAnswer((_) => Future.value(42.0));

      final maxZoomLevel = await cameraController.getMaxZoomLevel();
      expect(maxZoomLevel, 42.0);
    });

    test('getMinZoomLevel() throws $CameraException when uninitialized',
        () async {
      CameraController cameraController = CameraController(
          CameraDescription(
              name: 'cam',
              lensDirection: CameraLensDirection.back,
              sensorOrientation: 90),
          ResolutionPreset.max);

      expect(
          cameraController.getMinZoomLevel,
          throwsA(isA<CameraException>().having(
            (error) => error.description,
            'Uninitialized CameraController',
            'getMinZoomLevel was called on uninitialized CameraController',
          )));
    });

    test('getMinZoomLevel() throws $CameraException when disposed', () async {
      CameraController cameraController = CameraController(
          CameraDescription(
              name: 'cam',
              lensDirection: CameraLensDirection.back,
              sensorOrientation: 90),
          ResolutionPreset.max);

      await cameraController.initialize();
      await cameraController.dispose();

      expect(
          cameraController.getMinZoomLevel,
          throwsA(isA<CameraException>().having(
            (error) => error.description,
            'Uninitialized CameraController',
            'getMinZoomLevel was called on uninitialized CameraController',
          )));
    });

    test(
        'getMinZoomLevel() throws $CameraException when a platform exception occured.',
        () async {
      CameraController cameraController = CameraController(
          CameraDescription(
              name: 'cam',
              lensDirection: CameraLensDirection.back,
              sensorOrientation: 90),
          ResolutionPreset.max);

      await cameraController.initialize();
      when(CameraPlatform.instance.getMinZoomLevel(mockInitializeCamera))
          .thenThrow(PlatformException(
              code: 'TEST_ERROR',
              message: 'This is a test error messge',
              details: null));

      expect(
          cameraController.getMinZoomLevel,
          throwsA(isA<CameraException>()
              .having((error) => error.code, 'code', 'TEST_ERROR')
              .having(
                (error) => error.description,
                'description',
                'This is a test error messge',
              )));
    });

    test('getMinZoomLevel() returns max zoom level.', () async {
      CameraController cameraController = CameraController(
          CameraDescription(
              name: 'cam',
              lensDirection: CameraLensDirection.back,
              sensorOrientation: 90),
          ResolutionPreset.max);

      await cameraController.initialize();
      when(CameraPlatform.instance.getMinZoomLevel(mockInitializeCamera))
          .thenAnswer((_) => Future.value(42.0));

      final maxZoomLevel = await cameraController.getMinZoomLevel();
      expect(maxZoomLevel, 42.0);
    });

    test('setZoomLevel() throws $CameraException when uninitialized', () async {
      CameraController cameraController = CameraController(
          CameraDescription(
              name: 'cam',
              lensDirection: CameraLensDirection.back,
              sensorOrientation: 90),
          ResolutionPreset.max);

      expect(
          () => cameraController.setZoomLevel(42.0),
          throwsA(isA<CameraException>().having(
            (error) => error.description,
            'Uninitialized CameraController',
            'setZoomLevel was called on uninitialized CameraController',
          )));
    });

    test('setZoomLevel() throws $CameraException when disposed', () async {
      CameraController cameraController = CameraController(
          CameraDescription(
              name: 'cam',
              lensDirection: CameraLensDirection.back,
              sensorOrientation: 90),
          ResolutionPreset.max);

      await cameraController.initialize();
      await cameraController.dispose();

      expect(
          () => cameraController.setZoomLevel(42.0),
          throwsA(isA<CameraException>().having(
            (error) => error.description,
            'Uninitialized CameraController',
            'setZoomLevel was called on uninitialized CameraController',
          )));
    });

    test(
        'setZoomLevel() throws $CameraException when a platform exception occured.',
        () async {
      CameraController cameraController = CameraController(
          CameraDescription(
              name: 'cam',
              lensDirection: CameraLensDirection.back,
              sensorOrientation: 90),
          ResolutionPreset.max);

      await cameraController.initialize();
      when(CameraPlatform.instance.setZoomLevel(mockInitializeCamera, 42.0))
          .thenThrow(PlatformException(
              code: 'TEST_ERROR',
              message: 'This is a test error messge',
              details: null));

      expect(
          () => cameraController.setZoomLevel(42),
          throwsA(isA<CameraException>()
              .having((error) => error.code, 'code', 'TEST_ERROR')
              .having(
                (error) => error.description,
                'description',
                'This is a test error messge',
              )));

      reset(CameraPlatform.instance);
    });

    test(
        'setZoomLevel() completes and calls method channel with correct value.',
        () async {
      CameraController cameraController = CameraController(
          CameraDescription(
              name: 'cam',
              lensDirection: CameraLensDirection.back,
              sensorOrientation: 90),
          ResolutionPreset.max);

      await cameraController.initialize();
      await cameraController.setZoomLevel(42.0);

      verify(CameraPlatform.instance.setZoomLevel(mockInitializeCamera, 42.0))
          .called(1);
    });

    test('setFlashMode() calls $CameraPlatform', () async {
      CameraController cameraController = CameraController(
          CameraDescription(
              name: 'cam',
              lensDirection: CameraLensDirection.back,
              sensorOrientation: 90),
          ResolutionPreset.max);
      await cameraController.initialize();

      await cameraController.setFlashMode(FlashMode.always);

      verify(CameraPlatform.instance
              .setFlashMode(cameraController.cameraId, FlashMode.always))
          .called(1);
    });

    test('setFlashMode() throws $CameraException on $PlatformException',
        () async {
      CameraController cameraController = CameraController(
          CameraDescription(
              name: 'cam',
              lensDirection: CameraLensDirection.back,
              sensorOrientation: 90),
          ResolutionPreset.max);
      await cameraController.initialize();

      when(CameraPlatform.instance
              .setFlashMode(cameraController.cameraId, FlashMode.always))
          .thenThrow(
        PlatformException(
          code: 'TEST_ERROR',
          message: 'This is a test error message',
          details: null,
        ),
      );

      expect(
          cameraController.setFlashMode(FlashMode.always),
          throwsA(isA<CameraException>().having(
            (error) => error.description,
            'TEST_ERROR',
            'This is a test error message',
          )));
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
  Future<int> createCamera(
    CameraDescription description,
    ResolutionPreset resolutionPreset, {
    bool enableAudio,
  }) =>
      mockPlatformException
          ? throw PlatformException(code: 'foo', message: 'bar')
          : Future.value(mockInitializeCamera);

  @override
  Stream<CameraInitializedEvent> onCameraInitialized(int cameraId) =>
      Stream.value(mockOnCameraInitializedEvent);

  @override
  Stream<CameraClosingEvent> onCameraClosing(int cameraId) =>
      Stream.value(mockOnCameraClosingEvent);

  @override
  Stream<CameraErrorEvent> onCameraError(int cameraId) =>
      Stream.value(mockOnCameraErrorEvent);

  @override
  Future<XFile> takePicture(int cameraId) => mockPlatformException
      ? throw PlatformException(code: 'foo', message: 'bar')
      : Future.value(mockTakePicture);

  @override
  Future<XFile> startVideoRecording(int cameraId) =>
      Future.value(mockVideoRecordingXFile);
}

class MockCameraDescription extends CameraDescription {
  @override
  CameraLensDirection get lensDirection => CameraLensDirection.back;

  @override
  String get name => 'back';
}
