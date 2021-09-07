// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:math';

import 'package:async/async.dart';
import 'package:camera_platform_interface/camera_platform_interface.dart';
import 'package:camera_platform_interface/src/events/device_event.dart';
import 'package:camera_platform_interface/src/method_channel/method_channel_camera.dart';
import 'package:camera_platform_interface/src/types/focus_mode.dart';
import 'package:camera_platform_interface/src/utils/utils.dart';
import 'package:flutter/services.dart' hide DeviceOrientation;
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../utils/method_channel_mock.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('$MethodChannelCamera', () {
    group('Creation, Initialization & Disposal Tests', () {
      test('Should send creation data and receive back a camera id', () async {
        // Arrange
        MethodChannelMock cameraMockChannel = MethodChannelMock(
            channelName: 'plugins.flutter.io/camera',
            methods: {
              'create': {
                'cameraId': 1,
                'imageFormatGroup': 'unknown',
              }
            });
        final camera = MethodChannelCamera();

        // Act
        final cameraId = await camera.createCamera(
          CameraDescription(
              name: 'Test',
              lensDirection: CameraLensDirection.back,
              sensorOrientation: 0),
          ResolutionPreset.high,
        );

        // Assert
        expect(cameraMockChannel.log, <Matcher>[
          isMethodCall(
            'create',
            arguments: {
              'cameraName': 'Test',
              'resolutionPreset': 'high',
              'enableAudio': false
            },
          ),
        ]);
        expect(cameraId, 1);
      });

      test(
          'Should throw CameraException when create throws a PlatformException',
          () {
        // Arrange
        MethodChannelMock(channelName: 'plugins.flutter.io/camera', methods: {
          'create': PlatformException(
            code: 'TESTING_ERROR_CODE',
            message: 'Mock error message used during testing.',
          )
        });
        final camera = MethodChannelCamera();

        // Act
        expect(
          () => camera.createCamera(
            CameraDescription(
              name: 'Test',
              lensDirection: CameraLensDirection.back,
              sensorOrientation: 0,
            ),
            ResolutionPreset.high,
          ),
          throwsA(
            isA<CameraException>()
                .having((e) => e.code, 'code', 'TESTING_ERROR_CODE')
                .having((e) => e.description, 'description',
                    'Mock error message used during testing.'),
          ),
        );
      });

      test(
          'Should throw CameraException when create throws a PlatformException',
          () {
        // Arrange
        MethodChannelMock(channelName: 'plugins.flutter.io/camera', methods: {
          'create': PlatformException(
            code: 'TESTING_ERROR_CODE',
            message: 'Mock error message used during testing.',
          )
        });
        final camera = MethodChannelCamera();

        // Act
        expect(
          () => camera.createCamera(
            CameraDescription(
              name: 'Test',
              lensDirection: CameraLensDirection.back,
              sensorOrientation: 0,
            ),
            ResolutionPreset.high,
          ),
          throwsA(
            isA<CameraException>()
                .having((e) => e.code, 'code', 'TESTING_ERROR_CODE')
                .having((e) => e.description, 'description',
                    'Mock error message used during testing.'),
          ),
        );
      });

      test('Should send initialization data', () async {
        // Arrange
        MethodChannelMock cameraMockChannel = MethodChannelMock(
            channelName: 'plugins.flutter.io/camera',
            methods: {
              'create': {
                'cameraId': 1,
                'imageFormatGroup': 'unknown',
              },
              'initialize': null
            });
        final camera = MethodChannelCamera();
        final cameraId = await camera.createCamera(
          CameraDescription(
            name: 'Test',
            lensDirection: CameraLensDirection.back,
            sensorOrientation: 0,
          ),
          ResolutionPreset.high,
        );

        // Act
        Future<void> initializeFuture = camera.initializeCamera(cameraId);
        camera.cameraEventStreamController.add(CameraInitializedEvent(
          cameraId,
          1920,
          1080,
          ExposureMode.auto,
          true,
          FocusMode.auto,
          true,
        ));
        await initializeFuture;

        // Assert
        expect(cameraId, 1);
        expect(cameraMockChannel.log, <Matcher>[
          anything,
          isMethodCall(
            'initialize',
            arguments: {
              'cameraId': 1,
              'imageFormatGroup': 'unknown',
            },
          ),
        ]);
      });

      test('Should send a disposal call on dispose', () async {
        // Arrange
        MethodChannelMock cameraMockChannel = MethodChannelMock(
            channelName: 'plugins.flutter.io/camera',
            methods: {
              'create': {'cameraId': 1},
              'initialize': null,
              'dispose': {'cameraId': 1}
            });

        final camera = MethodChannelCamera();
        final cameraId = await camera.createCamera(
          CameraDescription(
            name: 'Test',
            lensDirection: CameraLensDirection.back,
            sensorOrientation: 0,
          ),
          ResolutionPreset.high,
        );
        Future<void> initializeFuture = camera.initializeCamera(cameraId);
        camera.cameraEventStreamController.add(CameraInitializedEvent(
          cameraId,
          1920,
          1080,
          ExposureMode.auto,
          true,
          FocusMode.auto,
          true,
        ));
        await initializeFuture;

        // Act
        await camera.dispose(cameraId);

        // Assert
        expect(cameraId, 1);
        expect(cameraMockChannel.log, <Matcher>[
          anything,
          anything,
          isMethodCall(
            'dispose',
            arguments: {'cameraId': 1},
          ),
        ]);
      });
    });

    group('Event Tests', () {
      late MethodChannelCamera camera;
      late int cameraId;
      setUp(() async {
        MethodChannelMock(
          channelName: 'plugins.flutter.io/camera',
          methods: {
            'create': {'cameraId': 1},
            'initialize': null
          },
        );
        camera = MethodChannelCamera();
        cameraId = await camera.createCamera(
          CameraDescription(
            name: 'Test',
            lensDirection: CameraLensDirection.back,
            sensorOrientation: 0,
          ),
          ResolutionPreset.high,
        );
        Future<void> initializeFuture = camera.initializeCamera(cameraId);
        camera.cameraEventStreamController.add(CameraInitializedEvent(
          cameraId,
          1920,
          1080,
          ExposureMode.auto,
          true,
          FocusMode.auto,
          true,
        ));
        await initializeFuture;
      });

      test('Should receive initialized event', () async {
        // Act
        final Stream<CameraInitializedEvent> eventStream =
            camera.onCameraInitialized(cameraId);
        final streamQueue = StreamQueue(eventStream);

        // Emit test events
        final event = CameraInitializedEvent(
          cameraId,
          3840,
          2160,
          ExposureMode.auto,
          true,
          FocusMode.auto,
          true,
        );
        await camera.handleCameraMethodCall(
            MethodCall('initialized', event.toJson()), cameraId);

        // Assert
        expect(await streamQueue.next, event);

        // Clean up
        await streamQueue.cancel();
      });

      test('Should receive resolution changes', () async {
        // Act
        final Stream<CameraResolutionChangedEvent> resolutionStream =
            camera.onCameraResolutionChanged(cameraId);
        final streamQueue = StreamQueue(resolutionStream);

        // Emit test events
        final fhdEvent = CameraResolutionChangedEvent(cameraId, 1920, 1080);
        final uhdEvent = CameraResolutionChangedEvent(cameraId, 3840, 2160);
        await camera.handleCameraMethodCall(
            MethodCall('resolution_changed', fhdEvent.toJson()), cameraId);
        await camera.handleCameraMethodCall(
            MethodCall('resolution_changed', uhdEvent.toJson()), cameraId);
        await camera.handleCameraMethodCall(
            MethodCall('resolution_changed', fhdEvent.toJson()), cameraId);
        await camera.handleCameraMethodCall(
            MethodCall('resolution_changed', uhdEvent.toJson()), cameraId);

        // Assert
        expect(await streamQueue.next, fhdEvent);
        expect(await streamQueue.next, uhdEvent);
        expect(await streamQueue.next, fhdEvent);
        expect(await streamQueue.next, uhdEvent);

        // Clean up
        await streamQueue.cancel();
      });

      test('Should receive camera closing events', () async {
        // Act
        final Stream<CameraClosingEvent> eventStream =
            camera.onCameraClosing(cameraId);
        final streamQueue = StreamQueue(eventStream);

        // Emit test events
        final event = CameraClosingEvent(cameraId);
        await camera.handleCameraMethodCall(
            MethodCall('camera_closing', event.toJson()), cameraId);
        await camera.handleCameraMethodCall(
            MethodCall('camera_closing', event.toJson()), cameraId);
        await camera.handleCameraMethodCall(
            MethodCall('camera_closing', event.toJson()), cameraId);

        // Assert
        expect(await streamQueue.next, event);
        expect(await streamQueue.next, event);
        expect(await streamQueue.next, event);

        // Clean up
        await streamQueue.cancel();
      });

      test('Should receive camera error events', () async {
        // Act
        final errorStream = camera.onCameraError(cameraId);
        final streamQueue = StreamQueue(errorStream);

        // Emit test events
        final event = CameraErrorEvent(cameraId, 'Error Description');
        await camera.handleCameraMethodCall(
            MethodCall('error', event.toJson()), cameraId);
        await camera.handleCameraMethodCall(
            MethodCall('error', event.toJson()), cameraId);
        await camera.handleCameraMethodCall(
            MethodCall('error', event.toJson()), cameraId);

        // Assert
        expect(await streamQueue.next, event);
        expect(await streamQueue.next, event);
        expect(await streamQueue.next, event);

        // Clean up
        await streamQueue.cancel();
      });

      test('Should receive device orientation change events', () async {
        // Act
        final eventStream = camera.onDeviceOrientationChanged();
        final streamQueue = StreamQueue(eventStream);

        // Emit test events
        final event =
            DeviceOrientationChangedEvent(DeviceOrientation.portraitUp);
        await camera.handleDeviceMethodCall(
            MethodCall('orientation_changed', event.toJson()));
        await camera.handleDeviceMethodCall(
            MethodCall('orientation_changed', event.toJson()));
        await camera.handleDeviceMethodCall(
            MethodCall('orientation_changed', event.toJson()));

        // Assert
        expect(await streamQueue.next, event);
        expect(await streamQueue.next, event);
        expect(await streamQueue.next, event);

        // Clean up
        await streamQueue.cancel();
      });
    });

    group('Function Tests', () {
      late MethodChannelCamera camera;
      late int cameraId;

      setUp(() async {
        MethodChannelMock(
          channelName: 'plugins.flutter.io/camera',
          methods: {
            'create': {'cameraId': 1},
            'initialize': null
          },
        );
        camera = MethodChannelCamera();
        cameraId = await camera.createCamera(
          CameraDescription(
            name: 'Test',
            lensDirection: CameraLensDirection.back,
            sensorOrientation: 0,
          ),
          ResolutionPreset.high,
        );
        Future<void> initializeFuture = camera.initializeCamera(cameraId);
        camera.cameraEventStreamController.add(
          CameraInitializedEvent(
            cameraId,
            1920,
            1080,
            ExposureMode.auto,
            true,
            FocusMode.auto,
            true,
          ),
        );
        await initializeFuture;
      });

      test('Should fetch CameraDescription instances for available cameras',
          () async {
        // Arrange
        List<Map<String, dynamic>> returnData = [
          {'name': 'Test 1', 'lensFacing': 'front', 'sensorOrientation': 1},
          {'name': 'Test 2', 'lensFacing': 'back', 'sensorOrientation': 2}
        ];
        MethodChannelMock channel = MethodChannelMock(
          channelName: 'plugins.flutter.io/camera',
          methods: {'availableCameras': returnData},
        );

        // Act
        List<CameraDescription> cameras = await camera.availableCameras();

        // Assert
        expect(channel.log, <Matcher>[
          isMethodCall('availableCameras', arguments: null),
        ]);
        expect(cameras.length, returnData.length);
        for (int i = 0; i < returnData.length; i++) {
          CameraDescription cameraDescription = CameraDescription(
            name: returnData[i]['name'],
            lensDirection:
                parseCameraLensDirection(returnData[i]['lensFacing']),
            sensorOrientation: returnData[i]['sensorOrientation'],
          );
          expect(cameras[i], cameraDescription);
        }
      });

      test(
          'Should throw CameraException when availableCameras throws a PlatformException',
          () {
        // Arrange
        MethodChannelMock(channelName: 'plugins.flutter.io/camera', methods: {
          'availableCameras': PlatformException(
            code: 'TESTING_ERROR_CODE',
            message: 'Mock error message used during testing.',
          )
        });

        // Act
        expect(
          camera.availableCameras,
          throwsA(
            isA<CameraException>()
                .having((e) => e.code, 'code', 'TESTING_ERROR_CODE')
                .having((e) => e.description, 'description',
                    'Mock error message used during testing.'),
          ),
        );
      });

      test('Should take a picture and return an XFile instance', () async {
        // Arrange
        MethodChannelMock channel = MethodChannelMock(
            channelName: 'plugins.flutter.io/camera',
            methods: {'takePicture': '/test/path.jpg'});

        // Act
        XFile file = await camera.takePicture(cameraId);

        // Assert
        expect(channel.log, <Matcher>[
          isMethodCall('takePicture', arguments: {
            'cameraId': cameraId,
          }),
        ]);
        expect(file.path, '/test/path.jpg');
      });

      test('Should prepare for video recording', () async {
        // Arrange
        MethodChannelMock channel = MethodChannelMock(
          channelName: 'plugins.flutter.io/camera',
          methods: {'prepareForVideoRecording': null},
        );

        // Act
        await camera.prepareForVideoRecording();

        // Assert
        expect(channel.log, <Matcher>[
          isMethodCall('prepareForVideoRecording', arguments: null),
        ]);
      });

      test('Should start recording a video', () async {
        // Arrange
        MethodChannelMock channel = MethodChannelMock(
          channelName: 'plugins.flutter.io/camera',
          methods: {'startVideoRecording': null},
        );

        // Act
        await camera.startVideoRecording(cameraId);

        // Assert
        expect(channel.log, <Matcher>[
          isMethodCall('startVideoRecording', arguments: {
            'cameraId': cameraId,
            'maxVideoDuration': null,
          }),
        ]);
      });

      test('Should pass maxVideoDuration when starting recording a video',
          () async {
        // Arrange
        MethodChannelMock channel = MethodChannelMock(
          channelName: 'plugins.flutter.io/camera',
          methods: {'startVideoRecording': null},
        );

        // Act
        await camera.startVideoRecording(
          cameraId,
          maxVideoDuration: Duration(seconds: 10),
        );

        // Assert
        expect(channel.log, <Matcher>[
          isMethodCall('startVideoRecording',
              arguments: {'cameraId': cameraId, 'maxVideoDuration': 10000}),
        ]);
      });

      test('Should stop a video recording and return the file', () async {
        // Arrange
        MethodChannelMock channel = MethodChannelMock(
          channelName: 'plugins.flutter.io/camera',
          methods: {'stopVideoRecording': '/test/path.mp4'},
        );

        // Act
        XFile file = await camera.stopVideoRecording(cameraId);

        // Assert
        expect(channel.log, <Matcher>[
          isMethodCall('stopVideoRecording', arguments: {
            'cameraId': cameraId,
          }),
        ]);
        expect(file.path, '/test/path.mp4');
      });

      test('Should pause a video recording', () async {
        // Arrange
        MethodChannelMock channel = MethodChannelMock(
          channelName: 'plugins.flutter.io/camera',
          methods: {'pauseVideoRecording': null},
        );

        // Act
        await camera.pauseVideoRecording(cameraId);

        // Assert
        expect(channel.log, <Matcher>[
          isMethodCall('pauseVideoRecording', arguments: {
            'cameraId': cameraId,
          }),
        ]);
      });

      test('Should resume a video recording', () async {
        // Arrange
        MethodChannelMock channel = MethodChannelMock(
          channelName: 'plugins.flutter.io/camera',
          methods: {'resumeVideoRecording': null},
        );

        // Act
        await camera.resumeVideoRecording(cameraId);

        // Assert
        expect(channel.log, <Matcher>[
          isMethodCall('resumeVideoRecording', arguments: {
            'cameraId': cameraId,
          }),
        ]);
      });

      test('Should set the flash mode', () async {
        // Arrange
        MethodChannelMock channel = MethodChannelMock(
          channelName: 'plugins.flutter.io/camera',
          methods: {'setFlashMode': null},
        );

        // Act
        await camera.setFlashMode(cameraId, FlashMode.torch);
        await camera.setFlashMode(cameraId, FlashMode.always);
        await camera.setFlashMode(cameraId, FlashMode.auto);
        await camera.setFlashMode(cameraId, FlashMode.off);

        // Assert
        expect(channel.log, <Matcher>[
          isMethodCall('setFlashMode',
              arguments: {'cameraId': cameraId, 'mode': 'torch'}),
          isMethodCall('setFlashMode',
              arguments: {'cameraId': cameraId, 'mode': 'always'}),
          isMethodCall('setFlashMode',
              arguments: {'cameraId': cameraId, 'mode': 'auto'}),
          isMethodCall('setFlashMode',
              arguments: {'cameraId': cameraId, 'mode': 'off'}),
        ]);
      });

      test('Should set the exposure mode', () async {
        // Arrange
        MethodChannelMock channel = MethodChannelMock(
          channelName: 'plugins.flutter.io/camera',
          methods: {'setExposureMode': null},
        );

        // Act
        await camera.setExposureMode(cameraId, ExposureMode.auto);
        await camera.setExposureMode(cameraId, ExposureMode.locked);

        // Assert
        expect(channel.log, <Matcher>[
          isMethodCall('setExposureMode',
              arguments: {'cameraId': cameraId, 'mode': 'auto'}),
          isMethodCall('setExposureMode',
              arguments: {'cameraId': cameraId, 'mode': 'locked'}),
        ]);
      });

      test('Should set the exposure point', () async {
        // Arrange
        MethodChannelMock channel = MethodChannelMock(
          channelName: 'plugins.flutter.io/camera',
          methods: {'setExposurePoint': null},
        );

        // Act
        await camera.setExposurePoint(cameraId, Point<double>(0.5, 0.5));
        await camera.setExposurePoint(cameraId, null);

        // Assert
        expect(channel.log, <Matcher>[
          isMethodCall('setExposurePoint', arguments: {
            'cameraId': cameraId,
            'x': 0.5,
            'y': 0.5,
            'reset': false
          }),
          isMethodCall('setExposurePoint', arguments: {
            'cameraId': cameraId,
            'x': null,
            'y': null,
            'reset': true
          }),
        ]);
      });

      test('Should get the min exposure offset', () async {
        // Arrange
        MethodChannelMock channel = MethodChannelMock(
          channelName: 'plugins.flutter.io/camera',
          methods: {'getMinExposureOffset': 2.0},
        );

        // Act
        final minExposureOffset = await camera.getMinExposureOffset(cameraId);

        // Assert
        expect(minExposureOffset, 2.0);
        expect(channel.log, <Matcher>[
          isMethodCall('getMinExposureOffset', arguments: {
            'cameraId': cameraId,
          }),
        ]);
      });

      test('Should get the max exposure offset', () async {
        // Arrange
        MethodChannelMock channel = MethodChannelMock(
          channelName: 'plugins.flutter.io/camera',
          methods: {'getMaxExposureOffset': 2.0},
        );

        // Act
        final maxExposureOffset = await camera.getMaxExposureOffset(cameraId);

        // Assert
        expect(maxExposureOffset, 2.0);
        expect(channel.log, <Matcher>[
          isMethodCall('getMaxExposureOffset', arguments: {
            'cameraId': cameraId,
          }),
        ]);
      });

      test('Should get the exposure offset step size', () async {
        // Arrange
        MethodChannelMock channel = MethodChannelMock(
          channelName: 'plugins.flutter.io/camera',
          methods: {'getExposureOffsetStepSize': 0.25},
        );

        // Act
        final stepSize = await camera.getExposureOffsetStepSize(cameraId);

        // Assert
        expect(stepSize, 0.25);
        expect(channel.log, <Matcher>[
          isMethodCall('getExposureOffsetStepSize', arguments: {
            'cameraId': cameraId,
          }),
        ]);
      });

      test('Should set the exposure offset', () async {
        // Arrange
        MethodChannelMock channel = MethodChannelMock(
          channelName: 'plugins.flutter.io/camera',
          methods: {'setExposureOffset': 0.6},
        );

        // Act
        final actualOffset = await camera.setExposureOffset(cameraId, 0.5);

        // Assert
        expect(actualOffset, 0.6);
        expect(channel.log, <Matcher>[
          isMethodCall('setExposureOffset', arguments: {
            'cameraId': cameraId,
            'offset': 0.5,
          }),
        ]);
      });

      test('Should set the focus mode', () async {
        // Arrange
        MethodChannelMock channel = MethodChannelMock(
          channelName: 'plugins.flutter.io/camera',
          methods: {'setFocusMode': null},
        );

        // Act
        await camera.setFocusMode(cameraId, FocusMode.auto);
        await camera.setFocusMode(cameraId, FocusMode.locked);

        // Assert
        expect(channel.log, <Matcher>[
          isMethodCall('setFocusMode',
              arguments: {'cameraId': cameraId, 'mode': 'auto'}),
          isMethodCall('setFocusMode',
              arguments: {'cameraId': cameraId, 'mode': 'locked'}),
        ]);
      });

      test('Should set the exposure point', () async {
        // Arrange
        MethodChannelMock channel = MethodChannelMock(
          channelName: 'plugins.flutter.io/camera',
          methods: {'setFocusPoint': null},
        );

        // Act
        await camera.setFocusPoint(cameraId, Point<double>(0.5, 0.5));
        await camera.setFocusPoint(cameraId, null);

        // Assert
        expect(channel.log, <Matcher>[
          isMethodCall('setFocusPoint', arguments: {
            'cameraId': cameraId,
            'x': 0.5,
            'y': 0.5,
            'reset': false
          }),
          isMethodCall('setFocusPoint', arguments: {
            'cameraId': cameraId,
            'x': null,
            'y': null,
            'reset': true
          }),
        ]);
      });

      test('Should build a texture widget as preview widget', () async {
        // Act
        Widget widget = camera.buildPreview(cameraId);

        // Act
        expect(widget is Texture, isTrue);
        expect((widget as Texture).textureId, cameraId);
      });

      test('Should throw MissingPluginException when handling unknown method',
          () {
        final camera = MethodChannelCamera();

        expect(
            () =>
                camera.handleCameraMethodCall(MethodCall('unknown_method'), 1),
            throwsA(isA<MissingPluginException>()));
      });

      test('Should get the max zoom level', () async {
        // Arrange
        MethodChannelMock channel = MethodChannelMock(
          channelName: 'plugins.flutter.io/camera',
          methods: {'getMaxZoomLevel': 10.0},
        );

        // Act
        final maxZoomLevel = await camera.getMaxZoomLevel(cameraId);

        // Assert
        expect(maxZoomLevel, 10.0);
        expect(channel.log, <Matcher>[
          isMethodCall('getMaxZoomLevel', arguments: {
            'cameraId': cameraId,
          }),
        ]);
      });

      test('Should get the min zoom level', () async {
        // Arrange
        MethodChannelMock channel = MethodChannelMock(
          channelName: 'plugins.flutter.io/camera',
          methods: {'getMinZoomLevel': 1.0},
        );

        // Act
        final maxZoomLevel = await camera.getMinZoomLevel(cameraId);

        // Assert
        expect(maxZoomLevel, 1.0);
        expect(channel.log, <Matcher>[
          isMethodCall('getMinZoomLevel', arguments: {
            'cameraId': cameraId,
          }),
        ]);
      });

      test('Should set the zoom level', () async {
        // Arrange
        MethodChannelMock channel = MethodChannelMock(
          channelName: 'plugins.flutter.io/camera',
          methods: {'setZoomLevel': null},
        );

        // Act
        await camera.setZoomLevel(cameraId, 2.0);

        // Assert
        expect(channel.log, <Matcher>[
          isMethodCall('setZoomLevel',
              arguments: {'cameraId': cameraId, 'zoom': 2.0}),
        ]);
      });

      test('Should throw CameraException when illegal zoom level is supplied',
          () async {
        // Arrange
        MethodChannelMock(
          channelName: 'plugins.flutter.io/camera',
          methods: {
            'setZoomLevel': PlatformException(
              code: 'ZOOM_ERROR',
              message: 'Illegal zoom error',
              details: null,
            )
          },
        );

        // Act & assert
        expect(
            () => camera.setZoomLevel(cameraId, -1.0),
            throwsA(isA<CameraException>()
                .having((e) => e.code, 'code', 'ZOOM_ERROR')
                .having((e) => e.description, 'description',
                    'Illegal zoom error')));
      });

      test('Should lock the capture orientation', () async {
        // Arrange
        MethodChannelMock channel = MethodChannelMock(
          channelName: 'plugins.flutter.io/camera',
          methods: {'lockCaptureOrientation': null},
        );

        // Act
        await camera.lockCaptureOrientation(
            cameraId, DeviceOrientation.portraitUp);

        // Assert
        expect(channel.log, <Matcher>[
          isMethodCall('lockCaptureOrientation',
              arguments: {'cameraId': cameraId, 'orientation': 'portraitUp'}),
        ]);
      });

      test('Should unlock the capture orientation', () async {
        // Arrange
        MethodChannelMock channel = MethodChannelMock(
          channelName: 'plugins.flutter.io/camera',
          methods: {'unlockCaptureOrientation': null},
        );

        // Act
        await camera.unlockCaptureOrientation(cameraId);

        // Assert
        expect(channel.log, <Matcher>[
          isMethodCall('unlockCaptureOrientation',
              arguments: {'cameraId': cameraId}),
        ]);
      });

      test('Should pause the camera preview', () async {
        // Arrange
        MethodChannelMock channel = MethodChannelMock(
          channelName: 'plugins.flutter.io/camera',
          methods: {'pausePreview': null},
        );

        // Act
        await camera.pausePreview(cameraId);

        // Assert
        expect(channel.log, <Matcher>[
          isMethodCall('pausePreview', arguments: {'cameraId': cameraId}),
        ]);
      });

      test('Should resume the camera preview', () async {
        // Arrange
        MethodChannelMock channel = MethodChannelMock(
          channelName: 'plugins.flutter.io/camera',
          methods: {'resumePreview': null},
        );

        // Act
        await camera.resumePreview(cameraId);

        // Assert
        expect(channel.log, <Matcher>[
          isMethodCall('resumePreview', arguments: {'cameraId': cameraId}),
        ]);
      });
    });
  });
}
