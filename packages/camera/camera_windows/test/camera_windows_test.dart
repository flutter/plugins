// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:async/async.dart';
import 'package:camera_platform_interface/camera_platform_interface.dart';
import 'package:camera_windows/camera_windows.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import './utils/method_channel_mock.dart';

void main() {
  const String pluginChannelName = 'plugins.flutter.io/camera_windows';
  TestWidgetsFlutterBinding.ensureInitialized();

  group('$CameraWindows()', () {
    test('registered instance', () {
      CameraWindows.registerWith();
      expect(CameraPlatform.instance, isA<CameraWindows>());
    });

    group('Creation, Initialization & Disposal Tests', () {
      test('Should send creation data and receive back a camera id', () async {
        // Arrange
        final MethodChannelMock cameraMockChannel = MethodChannelMock(
            channelName: pluginChannelName,
            methods: <String, dynamic>{
              'create': <String, dynamic>{
                'cameraId': 1,
                'imageFormatGroup': 'unknown',
              }
            });
        final CameraWindows plugin = CameraWindows();

        // Act
        final int cameraId = await plugin.createCamera(
          const CameraDescription(
              name: 'Test',
              lensDirection: CameraLensDirection.front,
              sensorOrientation: 0),
          ResolutionPreset.high,
        );

        // Assert
        expect(cameraMockChannel.log, <Matcher>[
          isMethodCall(
            'create',
            arguments: <String, Object?>{
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
        MethodChannelMock(
            channelName: pluginChannelName,
            methods: <String, dynamic>{
              'create': PlatformException(
                code: 'TESTING_ERROR_CODE',
                message: 'Mock error message used during testing.',
              )
            });
        final CameraWindows plugin = CameraWindows();

        // Act
        expect(
          () => plugin.createCamera(
            const CameraDescription(
              name: 'Test',
              lensDirection: CameraLensDirection.back,
              sensorOrientation: 0,
            ),
            ResolutionPreset.high,
          ),
          throwsA(
            isA<CameraException>()
                .having(
                    (CameraException e) => e.code, 'code', 'TESTING_ERROR_CODE')
                .having((CameraException e) => e.description, 'description',
                    'Mock error message used during testing.'),
          ),
        );
      });

      test(
        'Should throw CameraException when initialize throws a PlatformException',
        () {
          // Arrange
          MethodChannelMock(
            channelName: pluginChannelName,
            methods: <String, dynamic>{
              'initialize': PlatformException(
                code: 'TESTING_ERROR_CODE',
                message: 'Mock error message used during testing.',
              )
            },
          );
          final CameraWindows plugin = CameraWindows();

          // Act
          expect(
            () => plugin.initializeCamera(0),
            throwsA(
              isA<CameraException>()
                  .having((CameraException e) => e.code, 'code',
                      'TESTING_ERROR_CODE')
                  .having(
                    (CameraException e) => e.description,
                    'description',
                    'Mock error message used during testing.',
                  ),
            ),
          );
        },
      );

      test('Should send initialization data', () async {
        // Arrange
        final MethodChannelMock cameraMockChannel = MethodChannelMock(
            channelName: pluginChannelName,
            methods: <String, dynamic>{
              'create': <String, dynamic>{
                'cameraId': 1,
                'imageFormatGroup': 'unknown',
              },
              'initialize': <String, dynamic>{
                'previewWidth': 1920.toDouble(),
                'previewHeight': 1080.toDouble()
              },
            });
        final CameraWindows plugin = CameraWindows();
        final int cameraId = await plugin.createCamera(
          const CameraDescription(
            name: 'Test',
            lensDirection: CameraLensDirection.back,
            sensorOrientation: 0,
          ),
          ResolutionPreset.high,
        );

        // Act
        await plugin.initializeCamera(cameraId);

        // Assert
        expect(cameraId, 1);
        expect(cameraMockChannel.log, <Matcher>[
          anything,
          isMethodCall(
            'initialize',
            arguments: <String, Object?>{'cameraId': 1},
          ),
        ]);
      });

      test('Should send a disposal call on dispose', () async {
        // Arrange
        final MethodChannelMock cameraMockChannel = MethodChannelMock(
            channelName: pluginChannelName,
            methods: <String, dynamic>{
              'create': <String, dynamic>{'cameraId': 1},
              'initialize': <String, dynamic>{
                'previewWidth': 1920.toDouble(),
                'previewHeight': 1080.toDouble()
              },
              'dispose': <String, dynamic>{'cameraId': 1}
            });

        final CameraWindows plugin = CameraWindows();
        final int cameraId = await plugin.createCamera(
          const CameraDescription(
            name: 'Test',
            lensDirection: CameraLensDirection.back,
            sensorOrientation: 0,
          ),
          ResolutionPreset.high,
        );
        await plugin.initializeCamera(cameraId);

        // Act
        await plugin.dispose(cameraId);

        // Assert
        expect(cameraId, 1);
        expect(cameraMockChannel.log, <Matcher>[
          anything,
          anything,
          isMethodCall(
            'dispose',
            arguments: <String, Object?>{'cameraId': 1},
          ),
        ]);
      });
    });

    group('Event Tests', () {
      late CameraWindows plugin;
      late int cameraId;
      setUp(() async {
        MethodChannelMock(
          channelName: pluginChannelName,
          methods: <String, dynamic>{
            'create': <String, dynamic>{'cameraId': 1},
            'initialize': <String, dynamic>{
              'previewWidth': 1920.toDouble(),
              'previewHeight': 1080.toDouble()
            },
          },
        );

        plugin = CameraWindows();
        cameraId = await plugin.createCamera(
          const CameraDescription(
            name: 'Test',
            lensDirection: CameraLensDirection.back,
            sensorOrientation: 0,
          ),
          ResolutionPreset.high,
        );
        await plugin.initializeCamera(cameraId);
      });

      test('Should receive camera closing events', () async {
        // Act
        final Stream<CameraClosingEvent> eventStream =
            plugin.onCameraClosing(cameraId);
        final StreamQueue<CameraClosingEvent> streamQueue =
            StreamQueue<CameraClosingEvent>(eventStream);

        // Emit test events
        final CameraClosingEvent event = CameraClosingEvent(cameraId);
        await plugin.handleCameraMethodCall(
            MethodCall('camera_closing', event.toJson()), cameraId);
        await plugin.handleCameraMethodCall(
            MethodCall('camera_closing', event.toJson()), cameraId);
        await plugin.handleCameraMethodCall(
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
        final Stream<CameraErrorEvent> errorStream =
            plugin.onCameraError(cameraId);
        final StreamQueue<CameraErrorEvent> streamQueue =
            StreamQueue<CameraErrorEvent>(errorStream);

        // Emit test events
        final CameraErrorEvent event =
            CameraErrorEvent(cameraId, 'Error Description');
        await plugin.handleCameraMethodCall(
            MethodCall('error', event.toJson()), cameraId);
        await plugin.handleCameraMethodCall(
            MethodCall('error', event.toJson()), cameraId);
        await plugin.handleCameraMethodCall(
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
      late CameraWindows plugin;
      late int cameraId;

      setUp(() async {
        MethodChannelMock(
          channelName: pluginChannelName,
          methods: <String, dynamic>{
            'create': <String, dynamic>{'cameraId': 1},
            'initialize': <String, dynamic>{
              'previewWidth': 1920.toDouble(),
              'previewHeight': 1080.toDouble()
            },
          },
        );
        plugin = CameraWindows();
        cameraId = await plugin.createCamera(
          const CameraDescription(
            name: 'Test',
            lensDirection: CameraLensDirection.back,
            sensorOrientation: 0,
          ),
          ResolutionPreset.high,
        );
        await plugin.initializeCamera(cameraId);
      });

      test('Should fetch CameraDescription instances for available cameras',
          () async {
        // Arrange
        final List<dynamic> returnData = <dynamic>[
          <String, dynamic>{
            'name': 'Test 1',
            'lensFacing': 'front',
            'sensorOrientation': 1
          },
          <String, dynamic>{
            'name': 'Test 2',
            'lensFacing': 'back',
            'sensorOrientation': 2
          }
        ];
        final MethodChannelMock channel = MethodChannelMock(
          channelName: pluginChannelName,
          methods: <String, dynamic>{'availableCameras': returnData},
        );

        // Act
        final List<CameraDescription> cameras = await plugin.availableCameras();

        // Assert
        expect(channel.log, <Matcher>[
          isMethodCall('availableCameras', arguments: null),
        ]);
        expect(cameras.length, returnData.length);
        for (int i = 0; i < returnData.length; i++) {
          final CameraDescription cameraDescription = CameraDescription(
            name: returnData[i]['name']! as String,
            lensDirection: plugin.parseCameraLensDirection(
                returnData[i]['lensFacing']! as String),
            sensorOrientation: returnData[i]['sensorOrientation']! as int,
          );
          expect(cameras[i], cameraDescription);
        }
      });

      test(
          'Should throw CameraException when availableCameras throws a PlatformException',
          () {
        // Arrange
        MethodChannelMock(
            channelName: pluginChannelName,
            methods: <String, dynamic>{
              'availableCameras': PlatformException(
                code: 'TESTING_ERROR_CODE',
                message: 'Mock error message used during testing.',
              )
            });

        // Act
        expect(
          plugin.availableCameras,
          throwsA(
            isA<CameraException>()
                .having(
                    (CameraException e) => e.code, 'code', 'TESTING_ERROR_CODE')
                .having((CameraException e) => e.description, 'description',
                    'Mock error message used during testing.'),
          ),
        );
      });

      test('Should take a picture and return an XFile instance', () async {
        // Arrange
        final MethodChannelMock channel = MethodChannelMock(
            channelName: pluginChannelName,
            methods: <String, dynamic>{'takePicture': '/test/path.jpg'});

        // Act
        final XFile file = await plugin.takePicture(cameraId);

        // Assert
        expect(channel.log, <Matcher>[
          isMethodCall('takePicture', arguments: <String, Object?>{
            'cameraId': cameraId,
          }),
        ]);
        expect(file.path, '/test/path.jpg');
      });

      test('Should prepare for video recording', () async {
        // Arrange
        final MethodChannelMock channel = MethodChannelMock(
          channelName: pluginChannelName,
          methods: <String, dynamic>{'prepareForVideoRecording': null},
        );

        // Act
        await plugin.prepareForVideoRecording();

        // Assert
        expect(channel.log, <Matcher>[
          isMethodCall('prepareForVideoRecording', arguments: null),
        ]);
      });

      test('Should start recording a video', () async {
        // Arrange
        final MethodChannelMock channel = MethodChannelMock(
          channelName: pluginChannelName,
          methods: <String, dynamic>{'startVideoRecording': null},
        );

        // Act
        await plugin.startVideoRecording(cameraId);

        // Assert
        expect(channel.log, <Matcher>[
          isMethodCall('startVideoRecording', arguments: <String, Object?>{
            'cameraId': cameraId,
            'maxVideoDuration': null,
          }),
        ]);
      });

      test('Should pass maxVideoDuration when starting recording a video',
          () async {
        // Arrange
        final MethodChannelMock channel = MethodChannelMock(
          channelName: pluginChannelName,
          methods: <String, dynamic>{'startVideoRecording': null},
        );

        // Act
        await plugin.startVideoRecording(
          cameraId,
          maxVideoDuration: const Duration(seconds: 10),
        );

        // Assert
        expect(channel.log, <Matcher>[
          isMethodCall('startVideoRecording', arguments: <String, Object?>{
            'cameraId': cameraId,
            'maxVideoDuration': 10000
          }),
        ]);
      });

      test('Should stop a video recording and return the file', () async {
        // Arrange
        final MethodChannelMock channel = MethodChannelMock(
          channelName: pluginChannelName,
          methods: <String, dynamic>{'stopVideoRecording': '/test/path.mp4'},
        );

        // Act
        final XFile file = await plugin.stopVideoRecording(cameraId);

        // Assert
        expect(channel.log, <Matcher>[
          isMethodCall('stopVideoRecording', arguments: <String, Object?>{
            'cameraId': cameraId,
          }),
        ]);
        expect(file.path, '/test/path.mp4');
      });

      test('Should throw UnsupportedError when pause video recording is called',
          () async {
        // Act
        expect(
          () => plugin.pauseVideoRecording(cameraId),
          throwsA(isA<UnsupportedError>()),
        );
      });

      test(
          'Should throw UnsupportedError when resume video recording is called',
          () async {
        // Act
        expect(
          () => plugin.resumeVideoRecording(cameraId),
          throwsA(isA<UnsupportedError>()),
        );
      });

      test('Should throw UnimplementedError when flash mode is set', () async {
        // Act
        expect(
          () => plugin.setFlashMode(cameraId, FlashMode.torch),
          throwsA(isA<UnimplementedError>()),
        );
      });

      test('Should throw UnimplementedError when exposure mode is set',
          () async {
        // Act
        expect(
          () => plugin.setExposureMode(cameraId, ExposureMode.auto),
          throwsA(isA<UnimplementedError>()),
        );
      });

      test('Should throw UnsupportedError when exposure point is set',
          () async {
        // Act
        expect(
          () => plugin.setExposurePoint(cameraId, null),
          throwsA(isA<UnsupportedError>()),
        );
      });

      test('Should get the min exposure offset', () async {
        // Act
        final double minExposureOffset =
            await plugin.getMinExposureOffset(cameraId);

        // Assert
        expect(minExposureOffset, 0.0);
      });

      test('Should get the max exposure offset', () async {
        // Act
        final double maxExposureOffset =
            await plugin.getMaxExposureOffset(cameraId);

        // Assert
        expect(maxExposureOffset, 0.0);
      });

      test('Should get the exposure offset step size', () async {
        // Act
        final double stepSize =
            await plugin.getExposureOffsetStepSize(cameraId);

        // Assert
        expect(stepSize, 1.0);
      });

      test('Should throw UnimplementedError when exposure offset is set',
          () async {
        // Act
        expect(
          () => plugin.setExposureOffset(cameraId, 0.5),
          throwsA(isA<UnimplementedError>()),
        );
      });

      test('Should throw UnimplementedError when focus mode is set', () async {
        // Act
        expect(
          () => plugin.setFocusMode(cameraId, FocusMode.auto),
          throwsA(isA<UnimplementedError>()),
        );
      });

      test('Should throw UnsupportedError when exposure point is set',
          () async {
        // Act
        expect(
          () => plugin.setFocusMode(cameraId, FocusMode.auto),
          throwsA(isA<UnsupportedError>()),
        );
      });

      test('Should build a texture widget as preview widget', () async {
        // Act
        final Widget widget = plugin.buildPreview(cameraId);

        // Act
        expect(widget is Texture, isTrue);
        expect((widget as Texture).textureId, cameraId);
      });

      test('Should throw UnimplementedError when handling unknown method', () {
        final CameraWindows plugin = CameraWindows();

        expect(
            () => plugin.handleCameraMethodCall(
                const MethodCall('unknown_method'), 1),
            throwsA(isA<UnimplementedError>()));
      });

      test('Should get the max zoom level', () async {
        // Act
        final double maxZoomLevel = await plugin.getMaxZoomLevel(cameraId);

        // Assert
        expect(maxZoomLevel, 1.0);
      });

      test('Should get the min zoom level', () async {
        // Act
        final double maxZoomLevel = await plugin.getMinZoomLevel(cameraId);

        // Assert
        expect(maxZoomLevel, 1.0);
      });

      test('Should throw UnimplementedError when zoom level is set', () async {
        // Act
        expect(
          () => plugin.setZoomLevel(cameraId, 2.0),
          throwsA(isA<UnimplementedError>()),
        );
      });

      test(
          'Should throw UnimplementedError when lock capture orientation is called',
          () async {
        // Act
        expect(
          () => plugin.setZoomLevel(cameraId, 2.0),
          throwsA(isA<UnimplementedError>()),
        );
      });

      test(
          'Should throw UnimplementedError when unlock capture orientation is called',
          () async {
        // Act
        expect(
          () => plugin.unlockCaptureOrientation(cameraId),
          throwsA(isA<UnimplementedError>()),
        );
      });

      test('Should pause the camera preview', () async {
        // Arrange
        final MethodChannelMock channel = MethodChannelMock(
          channelName: pluginChannelName,
          methods: <String, dynamic>{'pausePreview': null},
        );

        // Act
        await plugin.pausePreview(cameraId);

        // Assert
        expect(channel.log, <Matcher>[
          isMethodCall('pausePreview',
              arguments: <String, Object?>{'cameraId': cameraId}),
        ]);
      });

      test('Should resume the camera preview', () async {
        // Arrange
        final MethodChannelMock channel = MethodChannelMock(
          channelName: pluginChannelName,
          methods: <String, dynamic>{'resumePreview': null},
        );

        // Act
        await plugin.resumePreview(cameraId);

        // Assert
        expect(channel.log, <Matcher>[
          isMethodCall('resumePreview',
              arguments: <String, Object?>{'cameraId': cameraId}),
        ]);
      });
    });
  });
}
