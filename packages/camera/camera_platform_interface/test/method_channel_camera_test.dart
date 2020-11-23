// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:async/async.dart';
import 'package:camera_platform_interface/camera_platform_interface.dart';
import 'package:camera_platform_interface/src/method_channel/method_channel_camera.dart';
import 'package:file_selector_platform_interface/file_selector_platform_interface.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'utils/method_channel_mock.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('$MethodChannelCamera', () {
    group('Initialization & Disposal Tests', () {
      test('Should receive a camera id when initialized', () async {
        // Arrange
        MethodChannelMock cameraMockChannel = MethodChannelMock(
            channelName: 'plugins.flutter.io/camera',
            methods: {
              'initialize': {'cameraId': 1}
            });
        final camera = MethodChannelCamera();

        // Act
        final cameraId = await camera.initializeCamera(
          CameraDescription(name: 'Test'),
          ResolutionPreset.high,
        );

        // Assert
        expect(cameraId, 1);
        expect(cameraMockChannel.log, <Matcher>[
          isMethodCall(
            'initialize',
            arguments: {
              'cameraName': 'Test',
              'resolutionPreset': 'high',
              'enableAudio': null
            },
          ),
        ]);
      });

      test('Should send a disposal call on dispose', () async {
        // Arrange
        MethodChannelMock cameraMockChannel = MethodChannelMock(
            channelName: 'plugins.flutter.io/camera',
            methods: {
              'initialize': {'cameraId': 1},
              'dispose': {'cameraId': 1}
            });

        final camera = MethodChannelCamera();
        final cameraId = await camera.initializeCamera(
          CameraDescription(name: 'Test'),
          ResolutionPreset.high,
        );

        // Act
        await camera.dispose(cameraId);

        // Assert
        expect(cameraId, 1);
        expect(cameraMockChannel.log, <Matcher>[
          isNotNull,
          isMethodCall(
            'dispose',
            arguments: {'cameraId': 1},
          ),
        ]);
      });
    });

    group('Event Tests', () {
      MethodChannelCamera camera;
      int cameraId;
      setUp(() async {
        MethodChannelMock(
          channelName: 'plugins.flutter.io/camera',
          methods: {
            'initialize': {'cameraId': 1},
          },
        );
        camera = MethodChannelCamera();
        cameraId = await camera.initializeCamera(
          CameraDescription(name: 'Test'),
          ResolutionPreset.high,
        );
      });

      test('Should receive resolution changes', () async {
        // Act
        final Stream<ResolutionChangedEvent> resolutionStream =
            camera.onResolutionChanged(cameraId);
        final streamQueue = StreamQueue(resolutionStream);

        // Emit test events
        final fhdEvent =
            ResolutionChangedEvent(cameraId, 1920, 1080, 1280, 720);
        final uhdEvent =
            ResolutionChangedEvent(cameraId, 3840, 2160, 1280, 720);
        await camera.handleMethodCall(
            MethodCall('resolution_changed', fhdEvent.toJson()),
            cameraId);
        await camera.handleMethodCall(
            MethodCall('resolution_changed', uhdEvent.toJson()),
            cameraId);
        await camera.handleMethodCall(
            MethodCall('resolution_changed', fhdEvent.toJson()),
            cameraId);
        await camera.handleMethodCall(
            MethodCall('resolution_changed', uhdEvent.toJson()),
            cameraId);

        // Assert
        expect(await streamQueue.next, fhdEvent);
        expect(await streamQueue.next, uhdEvent);
        expect(await streamQueue.next, fhdEvent);
        expect(await streamQueue.next, uhdEvent);
        //
        // // Clean up
        await streamQueue.cancel();
      });

      test('Should receive camera closing events', () async {
        // Act
        final Stream<CameraClosingEvent> eventStream =
            camera.onCameraClosing(cameraId);
        final streamQueue = StreamQueue(eventStream);

        // Emit test events
        final event = CameraClosingEvent(cameraId);
        await camera.handleMethodCall(
            MethodCall('camera_closing', event.toJson()), cameraId);
        await camera.handleMethodCall(
            MethodCall('camera_closing', event.toJson()), cameraId);
        await camera.handleMethodCall(
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
        await camera.handleMethodCall(
            MethodCall('error', event.toJson()), cameraId);
        await camera.handleMethodCall(
            MethodCall('error', event.toJson()), cameraId);
        await camera.handleMethodCall(
            MethodCall('error', event.toJson()), cameraId);

        // Assert
        expect(await streamQueue.next, event);
        expect(await streamQueue.next, event);
        expect(await streamQueue.next, event);

        // Clean up
        await streamQueue.cancel();
      });
    });

    group('Function Tests', () {
      MethodChannelCamera camera;
      int cameraId;
      setUp(() async {
        MethodChannelMock(
          channelName: 'plugins.flutter.io/camera',
          methods: {
            'initialize': {'cameraId': 1},
          },
        );
        camera = MethodChannelCamera();
        cameraId = await camera.initializeCamera(
          CameraDescription(name: 'Test'),
          ResolutionPreset.high,
        );
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
                camera.parseCameraLensDirection(returnData[i]['lensFacing']),
            sensorOrientation: returnData[i]['sensorOrientation'],
          );
          expect(cameras[i], cameraDescription);
        }
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

      test('Should start recording a video and return an XFile instance',
          () async {
        // Arrange
        MethodChannelMock channel = MethodChannelMock(
            channelName: 'plugins.flutter.io/camera',
            methods: {'startVideoRecording': '/test/path.mkv'});

        // Act
        XFile file = await camera.startVideoRecording(cameraId);

        // Assert
        expect(channel.log, <Matcher>[
          isMethodCall('startVideoRecording', arguments: {
            'cameraId': cameraId,
          }),
        ]);
        expect(file.path, '/test/path.mkv');
      });

      test('Should stop a video recording', () async {
        // Arrange
        MethodChannelMock channel = MethodChannelMock(
          channelName: 'plugins.flutter.io/camera',
          methods: {'stopVideoRecording': null},
        );

        // Act
        await camera.stopVideoRecording(cameraId);

        // Assert
        expect(channel.log, <Matcher>[
          isMethodCall('stopVideoRecording', arguments: {
            'cameraId': cameraId,
          }),
        ]);
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

      test('Should build a texture widget as view widget', () async {
        // Act
        Widget widget = camera.buildView(cameraId);

        // Act
        expect(widget is Texture, isTrue);
        expect((widget as Texture).textureId, cameraId);
      });
    });
  });
}
