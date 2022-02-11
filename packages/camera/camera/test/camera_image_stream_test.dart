// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:camera/camera.dart';
import 'package:camera_platform_interface/camera_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';

import 'camera_test.dart';
import 'utils/method_channel_mock.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    CameraPlatform.instance = MockCameraPlatform();
  });

  test('startImageStream() throws $CameraException when uninitialized', () {
    final CameraController cameraController = CameraController(
        const CameraDescription(
            name: 'cam',
            lensDirection: CameraLensDirection.back,
            sensorOrientation: 90),
        ResolutionPreset.max);

    expect(
      () => cameraController.startImageStream((CameraImage image) => null),
      throwsA(
        isA<CameraException>()
            .having(
              (CameraException error) => error.code,
              'code',
              'Uninitialized CameraController',
            )
            .having(
              (CameraException error) => error.description,
              'description',
              'startImageStream() was called on an uninitialized CameraController.',
            ),
      ),
    );
  });

  test('startImageStream() throws $CameraException when recording videos',
      () async {
    final CameraController cameraController = CameraController(
        const CameraDescription(
            name: 'cam',
            lensDirection: CameraLensDirection.back,
            sensorOrientation: 90),
        ResolutionPreset.max);

    await cameraController.initialize();

    cameraController.value =
        cameraController.value.copyWith(isRecordingVideo: true);

    expect(
        () => cameraController.startImageStream((CameraImage image) => null),
        throwsA(isA<CameraException>().having(
          (CameraException error) => error.description,
          'A video recording is already started.',
          'startImageStream was called while a video is being recorded.',
        )));
  });
  test(
      'startImageStream() throws $CameraException when already streaming images',
      () async {
    final CameraController cameraController = CameraController(
        const CameraDescription(
            name: 'cam',
            lensDirection: CameraLensDirection.back,
            sensorOrientation: 90),
        ResolutionPreset.max);
    await cameraController.initialize();

    cameraController.value =
        cameraController.value.copyWith(isStreamingImages: true);
    expect(
        () => cameraController.startImageStream((CameraImage image) => null),
        throwsA(isA<CameraException>().having(
          (CameraException error) => error.description,
          'A camera has started streaming images.',
          'startImageStream was called while a camera was streaming images.',
        )));
  });

  test('startImageStream() calls CameraPlatform', () async {
    final MethodChannelMock cameraChannelMock = MethodChannelMock(
        channelName: 'plugins.flutter.io/camera',
        methods: <String, dynamic>{'startImageStream': <String, dynamic>{}});
    final MethodChannelMock streamChannelMock = MethodChannelMock(
        channelName: 'plugins.flutter.io/camera/imageStream',
        methods: <String, dynamic>{'listen': <String, dynamic>{}});

    final CameraController cameraController = CameraController(
        const CameraDescription(
            name: 'cam',
            lensDirection: CameraLensDirection.back,
            sensorOrientation: 90),
        ResolutionPreset.max);
    await cameraController.initialize();

    await cameraController.startImageStream((CameraImage image) => null);

    expect(cameraChannelMock.log,
        <Matcher>[isMethodCall('startImageStream', arguments: null)]);
    expect(streamChannelMock.log,
        <Matcher>[isMethodCall('listen', arguments: null)]);
  });

  test('stopImageStream() throws $CameraException when uninitialized', () {
    final CameraController cameraController = CameraController(
        const CameraDescription(
            name: 'cam',
            lensDirection: CameraLensDirection.back,
            sensorOrientation: 90),
        ResolutionPreset.max);

    expect(
      cameraController.stopImageStream,
      throwsA(
        isA<CameraException>()
            .having(
              (CameraException error) => error.code,
              'code',
              'Uninitialized CameraController',
            )
            .having(
              (CameraException error) => error.description,
              'description',
              'stopImageStream() was called on an uninitialized CameraController.',
            ),
      ),
    );
  });

  test('stopImageStream() throws $CameraException when recording videos',
      () async {
    final CameraController cameraController = CameraController(
        const CameraDescription(
            name: 'cam',
            lensDirection: CameraLensDirection.back,
            sensorOrientation: 90),
        ResolutionPreset.max);
    await cameraController.initialize();

    await cameraController.startImageStream((CameraImage image) => null);
    cameraController.value =
        cameraController.value.copyWith(isRecordingVideo: true);
    expect(
        cameraController.stopImageStream,
        throwsA(isA<CameraException>().having(
          (CameraException error) => error.description,
          'A video recording is already started.',
          'stopImageStream was called while a video is being recorded.',
        )));
  });

  test('stopImageStream() throws $CameraException when not streaming images',
      () async {
    final CameraController cameraController = CameraController(
        const CameraDescription(
            name: 'cam',
            lensDirection: CameraLensDirection.back,
            sensorOrientation: 90),
        ResolutionPreset.max);
    await cameraController.initialize();

    expect(
        cameraController.stopImageStream,
        throwsA(isA<CameraException>().having(
          (CameraException error) => error.description,
          'No camera is streaming images',
          'stopImageStream was called when no camera is streaming images.',
        )));
  });

  test('stopImageStream() intended behaviour', () async {
    final MethodChannelMock cameraChannelMock = MethodChannelMock(
        channelName: 'plugins.flutter.io/camera',
        methods: <String, dynamic>{
          'startImageStream': <String, dynamic>{},
          'stopImageStream': <String, dynamic>{}
        });
    final MethodChannelMock streamChannelMock = MethodChannelMock(
        channelName: 'plugins.flutter.io/camera/imageStream',
        methods: <String, dynamic>{
          'listen': <String, dynamic>{},
          'cancel': <String, dynamic>{}
        });

    final CameraController cameraController = CameraController(
        const CameraDescription(
            name: 'cam',
            lensDirection: CameraLensDirection.back,
            sensorOrientation: 90),
        ResolutionPreset.max);
    await cameraController.initialize();
    await cameraController.startImageStream((CameraImage image) => null);
    await cameraController.stopImageStream();

    expect(cameraChannelMock.log, <Matcher>[
      isMethodCall('startImageStream', arguments: null),
      isMethodCall('stopImageStream', arguments: null)
    ]);

    expect(streamChannelMock.log, <Matcher>[
      isMethodCall('listen', arguments: null),
      isMethodCall('cancel', arguments: null)
    ]);
  });
}
