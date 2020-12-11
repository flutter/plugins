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

import 'utils/method_channel_mock.dart';

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

    test('startImageStream() throws $CameraException when uninitialized', () {
      CameraController cameraController = CameraController(
          CameraDescription(
              name: 'cam',
              lensDirection: CameraLensDirection.back,
              sensorOrientation: 90),
          ResolutionPreset.max);
      expect(
          cameraController.startImageStream((image) => null),
          throwsA(isA<CameraException>().having(
            (error) => error.description,
            'Uninitialized CameraController.',
            'startImageStream was called on uninitialized CameraController.',
          )));
    });

    test('startImageStream() throws $CameraException when recording videos',
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
          cameraController.startImageStream((image) => null),
          throwsA(isA<CameraException>().having(
            (error) => error.description,
            'A video recording is already started.',
            'startImageStream was called while a video is being recorded.',
          )));
    });
    test(
        'startImageStream() throws $CameraException when already streaming images',
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
          cameraController.startImageStream((image) => null),
          throwsA(isA<CameraException>().having(
            (error) => error.description,
            'A camera has started streaming images.',
            'startImageStream was called while a camera was streaming images.',
          )));
    });

    test('startImageStream() calls CameraPlatform', () async {
      MethodChannelMock methodChannelMock = MethodChannelMock(
          channelName: 'plugins.flutter.io/camera',
          methods: {'startImageStream': {}});
      CameraController cameraController = CameraController(
          CameraDescription(
              name: 'cam',
              lensDirection: CameraLensDirection.back,
              sensorOrientation: 90),
          ResolutionPreset.max);
      await cameraController.initialize();

      await cameraController.startImageStream((image) => null);

      expect(methodChannelMock.log,
          <Matcher>[isMethodCall('startImageStream', arguments: null)]);
    });

    test('stopImageStream() throws $CameraException when uninitialized', () {
      CameraController cameraController = CameraController(
          CameraDescription(
              name: 'cam',
              lensDirection: CameraLensDirection.back,
              sensorOrientation: 90),
          ResolutionPreset.max);

      expect(
          cameraController.stopImageStream(),
          throwsA(isA<CameraException>().having(
            (error) => error.description,
            'Uninitialized CameraController.',
            'stopImageStream was called on uninitialized CameraController.',
          )));
    });

    test('stopImageStream() throws $CameraException when recording videos',
        () async {
      CameraController cameraController = CameraController(
          CameraDescription(
              name: 'cam',
              lensDirection: CameraLensDirection.back,
              sensorOrientation: 90),
          ResolutionPreset.max);
      await cameraController.initialize();

      await cameraController.startImageStream((image) => null);
      cameraController.value =
          cameraController.value.copyWith(isRecordingVideo: true);
      expect(
          cameraController.stopImageStream(),
          throwsA(isA<CameraException>().having(
            (error) => error.description,
            'A video recording is already started.',
            'stopImageStream was called while a video is being recorded.',
          )));
    });

    test('stopImageStream() throws $CameraException when not streaming images',
        () async {
      CameraController cameraController = CameraController(
          CameraDescription(
              name: 'cam',
              lensDirection: CameraLensDirection.back,
              sensorOrientation: 90),
          ResolutionPreset.max);
      await cameraController.initialize();

      expect(
          cameraController.stopImageStream(),
          throwsA(isA<CameraException>().having(
            (error) => error.description,
            'No camera is streaming images',
            'stopImageStream was called when no camera is streaming images.',
          )));
    });

    test('stopImageStream() intended behaviour', () async {
      MethodChannelMock methodChannelMock = MethodChannelMock(
          channelName: 'plugins.flutter.io/camera',
          methods: {'startImageStream': {}, 'stopImageStream': {}});
      CameraController cameraController = CameraController(
          CameraDescription(
              name: 'cam',
              lensDirection: CameraLensDirection.back,
              sensorOrientation: 90),
          ResolutionPreset.max);
      await cameraController.initialize();
      await cameraController.startImageStream((image) => null);
      await cameraController.stopImageStream();
      expect(methodChannelMock.log, <Matcher>[
        isMethodCall('startImageStream', arguments: null),
        isMethodCall('stopImageStream', arguments: null)
      ]);
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
