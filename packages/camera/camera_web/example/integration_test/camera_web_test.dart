// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:html';
import 'dart:ui';

import 'package:async/async.dart';
import 'package:camera_platform_interface/camera_platform_interface.dart';
import 'package:camera_web/camera_web.dart';
import 'package:camera_web/src/camera.dart';
import 'package:camera_web/src/camera_settings.dart';
import 'package:camera_web/src/types/types.dart';
import 'package:flutter/widgets.dart' as widgets;
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
    late CameraSettings cameraSettings;

    setUp(() async {
      window = MockWindow();
      navigator = MockNavigator();
      mediaDevices = MockMediaDevices();

      videoElement = getVideoElementWithBlankStream(Size(10, 10));

      cameraSettings = MockCameraSettings();

      when(() => window.navigator).thenReturn(navigator);
      when(() => navigator.mediaDevices).thenReturn(mediaDevices);

      when(
        () => cameraSettings.getMediaStreamForOptions(
          any(),
          cameraId: any(named: 'cameraId'),
        ),
      ).thenAnswer(
        (_) async => videoElement.captureStream(),
      );

      CameraPlatform.instance = CameraPlugin(
        cameraSettings: cameraSettings,
      )..window = window;
    });

    setUpAll(() {
      registerFallbackValue<MediaStreamTrack>(MockMediaStreamTrack());
      registerFallbackValue<CameraOptions>(MockCameraOptions());
    });

    testWidgets('CameraPlugin is the live instance', (tester) async {
      expect(CameraPlatform.instance, isA<CameraPlugin>());
    });

    group('availableCameras', () {
      setUp(() {
        when(
          () => cameraSettings.getFacingModeForVideoTrack(
            any(),
          ),
        ).thenReturn(null);

        when(mediaDevices.enumerateDevices).thenAnswer(
          (_) async => [],
        );
      });

      testWidgets('requests video and audio permissions', (tester) async {
        final _ = await CameraPlatform.instance.availableCameras();

        verify(
          () => cameraSettings.getMediaStreamForOptions(
            CameraOptions(
              audio: AudioConstraints(enabled: true),
            ),
          ),
        ).called(1);
      });

      testWidgets(
          'gets a video stream '
          'for a video input device', (tester) async {
        final videoDevice = FakeMediaDeviceInfo(
          '1',
          'Camera 1',
          MediaDeviceKind.videoInput,
        );

        when(mediaDevices.enumerateDevices).thenAnswer(
          (_) => Future.value([videoDevice]),
        );

        final _ = await CameraPlatform.instance.availableCameras();

        verify(
          () => cameraSettings.getMediaStreamForOptions(
            CameraOptions(
              video: VideoConstraints(
                deviceId: videoDevice.deviceId,
              ),
            ),
          ),
        ).called(1);
      });

      testWidgets(
          'does not get a video stream '
          'for the video input device '
          'with an empty device id', (tester) async {
        final videoDevice = FakeMediaDeviceInfo(
          '',
          'Camera 1',
          MediaDeviceKind.videoInput,
        );

        when(mediaDevices.enumerateDevices).thenAnswer(
          (_) => Future.value([videoDevice]),
        );

        final _ = await CameraPlatform.instance.availableCameras();

        verifyNever(
          () => cameraSettings.getMediaStreamForOptions(
            CameraOptions(
              video: VideoConstraints(
                deviceId: videoDevice.deviceId,
              ),
            ),
          ),
        );
      });

      testWidgets(
          'gets the facing mode '
          'from the first available video track '
          'of the video input device', (tester) async {
        final videoDevice = FakeMediaDeviceInfo(
          '1',
          'Camera 1',
          MediaDeviceKind.videoInput,
        );

        final videoStream =
            FakeMediaStream([MockMediaStreamTrack(), MockMediaStreamTrack()]);

        when(
          () => cameraSettings.getMediaStreamForOptions(
            CameraOptions(
              video: VideoConstraints(deviceId: videoDevice.deviceId),
            ),
          ),
        ).thenAnswer((_) => Future.value(videoStream));

        when(mediaDevices.enumerateDevices).thenAnswer(
          (_) => Future.value([videoDevice]),
        );

        final _ = await CameraPlatform.instance.availableCameras();

        verify(
          () => cameraSettings.getFacingModeForVideoTrack(
            videoStream.getVideoTracks().first,
          ),
        ).called(1);
      });

      testWidgets(
          'returns appropriate camera descriptions '
          'for multiple video devices '
          'based on video streams', (tester) async {
        final firstVideoDevice = FakeMediaDeviceInfo(
          '1',
          'Camera 1',
          MediaDeviceKind.videoInput,
        );

        final secondVideoDevice = FakeMediaDeviceInfo(
          '4',
          'Camera 4',
          MediaDeviceKind.videoInput,
        );

        // Create a video stream for the first video device.
        final firstVideoStream =
            FakeMediaStream([MockMediaStreamTrack(), MockMediaStreamTrack()]);

        // Create a video stream for the second video device.
        final secondVideoStream = FakeMediaStream([MockMediaStreamTrack()]);

        // Mock media devices to return two video input devices
        // and two audio devices.
        when(mediaDevices.enumerateDevices).thenAnswer(
          (_) => Future.value([
            firstVideoDevice,
            FakeMediaDeviceInfo(
              '2',
              'Audio Input 2',
              MediaDeviceKind.audioInput,
            ),
            FakeMediaDeviceInfo(
              '3',
              'Audio Output 3',
              MediaDeviceKind.audioOutput,
            ),
            secondVideoDevice,
          ]),
        );

        // Mock camera settings to return the first video stream
        // for the first video device.
        when(
          () => cameraSettings.getMediaStreamForOptions(
            CameraOptions(
              video: VideoConstraints(deviceId: firstVideoDevice.deviceId),
            ),
          ),
        ).thenAnswer((_) => Future.value(firstVideoStream));

        // Mock camera settings to return the second video stream
        // for the second video device.
        when(
          () => cameraSettings.getMediaStreamForOptions(
            CameraOptions(
              video: VideoConstraints(deviceId: secondVideoDevice.deviceId),
            ),
          ),
        ).thenAnswer((_) => Future.value(secondVideoStream));

        // Mock camera settings to return a user facing mode
        // for the first video stream.
        when(
          () => cameraSettings.getFacingModeForVideoTrack(
            firstVideoStream.getVideoTracks().first,
          ),
        ).thenReturn('user');

        when(() => cameraSettings.mapFacingModeToLensDirection('user'))
            .thenReturn(CameraLensDirection.front);

        // Mock camera settings to return an environment facing mode
        // for the second video stream.
        when(
          () => cameraSettings.getFacingModeForVideoTrack(
            secondVideoStream.getVideoTracks().first,
          ),
        ).thenReturn('environment');

        when(() => cameraSettings.mapFacingModeToLensDirection('environment'))
            .thenReturn(CameraLensDirection.back);

        final cameras = await CameraPlatform.instance.availableCameras();

        // Expect two cameras and ignore two audio devices.
        expect(
          cameras,
          equals([
            CameraDescription(
              name: firstVideoDevice.label!,
              lensDirection: CameraLensDirection.front,
              sensorOrientation: 0,
            ),
            CameraDescription(
              name: secondVideoDevice.label!,
              lensDirection: CameraLensDirection.back,
              sensorOrientation: 0,
            )
          ]),
        );
      });

      testWidgets(
          'sets camera metadata '
          'for the camera description', (tester) async {
        final videoDevice = FakeMediaDeviceInfo(
          '1',
          'Camera 1',
          MediaDeviceKind.videoInput,
        );

        final videoStream =
            FakeMediaStream([MockMediaStreamTrack(), MockMediaStreamTrack()]);

        when(mediaDevices.enumerateDevices).thenAnswer(
          (_) => Future.value([videoDevice]),
        );

        when(
          () => cameraSettings.getMediaStreamForOptions(
            CameraOptions(
              video: VideoConstraints(deviceId: videoDevice.deviceId),
            ),
          ),
        ).thenAnswer((_) => Future.value(videoStream));

        when(
          () => cameraSettings.getFacingModeForVideoTrack(
            videoStream.getVideoTracks().first,
          ),
        ).thenReturn('left');

        when(() => cameraSettings.mapFacingModeToLensDirection('left'))
            .thenReturn(CameraLensDirection.external);

        final camera = (await CameraPlatform.instance.availableCameras()).first;

        expect(
          (CameraPlatform.instance as CameraPlugin).camerasMetadata,
          equals({
            camera: CameraMetadata(
              deviceId: videoDevice.deviceId!,
              facingMode: 'left',
            )
          }),
        );
      });

      group('throws CameraException', () {
        testWidgets(
            'with notSupported error '
            'when there are no media devices', (tester) async {
          when(() => navigator.mediaDevices).thenReturn(null);

          expect(
            () => CameraPlatform.instance.availableCameras(),
            throwsA(
              isA<CameraException>().having(
                (e) => e.code,
                'code',
                CameraErrorCode.notSupported.toString(),
              ),
            ),
          );
        });

        testWidgets('when MediaDevices.enumerateDevices throws DomException',
            (tester) async {
          final exception = FakeDomException(DomException.UNKNOWN);

          when(mediaDevices.enumerateDevices).thenThrow(exception);

          expect(
            () => CameraPlatform.instance.availableCameras(),
            throwsA(
              isA<CameraException>().having(
                (e) => e.code,
                'code',
                exception.name,
              ),
            ),
          );
        });

        testWidgets(
            'when CameraSettings.getMediaStreamForOptions '
            'throws CameraWebException', (tester) async {
          final exception = CameraWebException(
            cameraId,
            CameraErrorCode.security,
            'description',
          );

          when(() => cameraSettings.getMediaStreamForOptions(any()))
              .thenThrow(exception);

          expect(
            () => CameraPlatform.instance.availableCameras(),
            throwsA(
              isA<CameraException>().having(
                (e) => e.code,
                'code',
                exception.code.toString(),
              ),
            ),
          );
        });

        testWidgets(
            'when CameraSettings.getMediaStreamForOptions '
            'throws PlatformException', (tester) async {
          final exception = PlatformException(
            code: CameraErrorCode.notSupported.toString(),
            message: 'message',
          );

          when(() => cameraSettings.getMediaStreamForOptions(any()))
              .thenThrow(exception);

          expect(
            () => CameraPlatform.instance.availableCameras(),
            throwsA(
              isA<CameraException>().having(
                (e) => e.code,
                'code',
                exception.code.toString(),
              ),
            ),
          );
        });
      });
    });

    group('createCamera', () {
      group('creates a camera', () {
        const ultraHighResolutionSize = Size(3840, 2160);
        const maxResolutionSize = Size(3840, 2160);

        final cameraDescription = CameraDescription(
          name: 'name',
          lensDirection: CameraLensDirection.front,
          sensorOrientation: 0,
        );

        final cameraMetadata = CameraMetadata(
          deviceId: 'deviceId',
          facingMode: 'user',
        );

        setUp(() {
          // Add metadata for the camera description.
          (CameraPlatform.instance as CameraPlugin)
              .camerasMetadata[cameraDescription] = cameraMetadata;

          when(
            () => cameraSettings.mapFacingModeToCameraType('user'),
          ).thenReturn(CameraType.user);
        });

        testWidgets('with appropriate options', (tester) async {
          when(
            () => cameraSettings
                .mapResolutionPresetToSize(ResolutionPreset.ultraHigh),
          ).thenReturn(ultraHighResolutionSize);

          final cameraId = await CameraPlatform.instance.createCamera(
            cameraDescription,
            ResolutionPreset.ultraHigh,
            enableAudio: true,
          );

          expect(
            (CameraPlatform.instance as CameraPlugin).cameras[cameraId],
            isA<Camera>()
                .having(
                  (camera) => camera.textureId,
                  'textureId',
                  cameraId,
                )
                .having(
                  (camera) => camera.options,
                  'options',
                  CameraOptions(
                    audio: AudioConstraints(enabled: true),
                    video: VideoConstraints(
                      facingMode: FacingModeConstraint(CameraType.user),
                      width: VideoSizeConstraint(
                        ideal: ultraHighResolutionSize.width.toInt(),
                      ),
                      height: VideoSizeConstraint(
                        ideal: ultraHighResolutionSize.height.toInt(),
                      ),
                      deviceId: cameraMetadata.deviceId,
                    ),
                  ),
                ),
          );
        });

        testWidgets(
            'with a max resolution preset '
            'and enabled audio set to false '
            'when no options are specified', (tester) async {
          when(
            () =>
                cameraSettings.mapResolutionPresetToSize(ResolutionPreset.max),
          ).thenReturn(maxResolutionSize);

          final cameraId = await CameraPlatform.instance.createCamera(
            cameraDescription,
            null,
          );

          expect(
            (CameraPlatform.instance as CameraPlugin).cameras[cameraId],
            isA<Camera>().having(
              (camera) => camera.options,
              'options',
              CameraOptions(
                audio: AudioConstraints(enabled: false),
                video: VideoConstraints(
                  facingMode: FacingModeConstraint(CameraType.user),
                  width: VideoSizeConstraint(
                    ideal: maxResolutionSize.width.toInt(),
                  ),
                  height: VideoSizeConstraint(
                    ideal: maxResolutionSize.height.toInt(),
                  ),
                  deviceId: cameraMetadata.deviceId,
                ),
              ),
            ),
          );
        });
      });

      testWidgets(
          'throws CameraException '
          'with missingMetadata error '
          'if there is no metadata '
          'for the given camera description', (tester) async {
        expect(
          () => CameraPlatform.instance.createCamera(
            CameraDescription(
              name: 'name',
              lensDirection: CameraLensDirection.back,
              sensorOrientation: 0,
            ),
            ResolutionPreset.ultraHigh,
          ),
          throwsA(
            isA<CameraException>().having(
              (e) => e.code,
              'code',
              CameraErrorCode.missingMetadata.toString(),
            ),
          ),
        );
      });
    });

    group('initializeCamera', () {
      late Camera camera;
      late VideoElement videoElement;

      setUp(() {
        camera = MockCamera();
        videoElement = MockVideoElement();

        when(() => camera.videoElement).thenReturn(videoElement);
        when(() => videoElement.onError)
            .thenAnswer((_) => FakeElementStream(Stream.empty()));
        when(() => videoElement.onAbort)
            .thenAnswer((_) => FakeElementStream(Stream.empty()));
      });

      testWidgets('initializes and plays the camera', (tester) async {
        when(camera.getVideoSize).thenAnswer(
          (_) => Future.value(Size(10, 10)),
        );
        when(camera.initialize).thenAnswer((_) => Future.value());
        when(camera.play).thenAnswer((_) => Future.value());

        // Save the camera in the camera plugin.
        (CameraPlatform.instance as CameraPlugin).cameras[cameraId] = camera;

        await CameraPlatform.instance.initializeCamera(cameraId);

        verify(camera.initialize).called(1);
        verify(camera.play).called(1);
      });

      group('throws PlatformException', () {
        testWidgets(
            'with notFound error '
            'if the camera does not exist', (tester) async {
          expect(
            () => CameraPlatform.instance.initializeCamera(cameraId),
            throwsA(
              isA<PlatformException>().having(
                (e) => e.code,
                'code',
                CameraErrorCode.notFound.toString(),
              ),
            ),
          );
        });

        testWidgets('when camera throws CameraWebException', (tester) async {
          final exception = CameraWebException(
            cameraId,
            CameraErrorCode.permissionDenied,
            'description',
          );

          when(camera.initialize).thenThrow(exception);

          // Save the camera in the camera plugin.
          (CameraPlatform.instance as CameraPlugin).cameras[cameraId] = camera;

          expect(
            () => CameraPlatform.instance.initializeCamera(cameraId),
            throwsA(
              isA<PlatformException>().having(
                (e) => e.code,
                'code',
                exception.code.toString(),
              ),
            ),
          );
        });

        testWidgets('when camera throws DomException', (tester) async {
          final exception = FakeDomException(DomException.NOT_ALLOWED);

          when(camera.initialize).thenAnswer((_) => Future.value());
          when(camera.play).thenThrow(exception);

          // Save the camera in the camera plugin.
          (CameraPlatform.instance as CameraPlugin).cameras[cameraId] = camera;

          expect(
            () => CameraPlatform.instance.initializeCamera(cameraId),
            throwsA(
              isA<PlatformException>().having(
                (e) => e.code,
                'code',
                exception.name.toString(),
              ),
            ),
          );
        });
      });
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

    group('takePicture', () {
      testWidgets('captures a picture', (tester) async {
        final camera = MockCamera();
        final capturedPicture = MockXFile();

        when(camera.takePicture)
            .thenAnswer((_) => Future.value(capturedPicture));

        // Save the camera in the camera plugin.
        (CameraPlatform.instance as CameraPlugin).cameras[cameraId] = camera;

        final picture = await CameraPlatform.instance.takePicture(cameraId);

        verify(camera.takePicture).called(1);

        expect(picture, equals(capturedPicture));
      });

      group('throws PlatformException', () {
        testWidgets(
            'with notFound error '
            'if the camera does not exist', (tester) async {
          expect(
            () => CameraPlatform.instance.takePicture(cameraId),
            throwsA(
              isA<PlatformException>().having(
                (e) => e.code,
                'code',
                CameraErrorCode.notFound.toString(),
              ),
            ),
          );
        });

        testWidgets('when takePicture throws DomException', (tester) async {
          final camera = MockCamera();
          final exception = FakeDomException(DomException.NOT_SUPPORTED);

          when(camera.takePicture).thenThrow(exception);

          // Save the camera in the camera plugin.
          (CameraPlatform.instance as CameraPlugin).cameras[cameraId] = camera;

          expect(
            () => CameraPlatform.instance.takePicture(cameraId),
            throwsA(
              isA<PlatformException>().having(
                (e) => e.code,
                'code',
                exception.name,
              ),
            ),
          );
        });
      });
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

    testWidgets(
        'buildPreview returns an HtmlElementView '
        'with an appropriate view type', (tester) async {
      final camera = Camera(
        textureId: cameraId,
        cameraSettings: cameraSettings,
      );

      // Save the camera in the camera plugin.
      (CameraPlatform.instance as CameraPlugin).cameras[cameraId] = camera;

      expect(
        CameraPlatform.instance.buildPreview(cameraId),
        isA<widgets.HtmlElementView>().having(
          (view) => view.viewType,
          'viewType',
          camera.getViewType(),
        ),
      );
    });

    group('dispose', () {
      testWidgets('disposes the correct camera', (tester) async {
        const firstCameraId = 0;
        const secondCameraId = 1;

        final firstCamera = MockCamera();
        final secondCamera = MockCamera();

        when(firstCamera.dispose).thenAnswer((_) => Future.value());
        when(secondCamera.dispose).thenAnswer((_) => Future.value());

        // Save cameras in the camera plugin.
        (CameraPlatform.instance as CameraPlugin).cameras.addAll({
          firstCameraId: firstCamera,
          secondCameraId: secondCamera,
        });

        // Dispose the first camera.
        await CameraPlatform.instance.dispose(firstCameraId);

        // The first camera should be disposed.
        verify(firstCamera.dispose).called(1);
        verifyNever(secondCamera.dispose);

        // The first camera should be removed from the camera plugin.
        expect(
          (CameraPlatform.instance as CameraPlugin).cameras,
          equals({
            secondCameraId: secondCamera,
          }),
        );
      });

      testWidgets('cancels camera video and abort error subscriptions',
          (tester) async {
        final camera = MockCamera();
        final videoElement = MockVideoElement();

        final errorStreamController = StreamController<Event>();
        final abortStreamController = StreamController<Event>();

        when(camera.getVideoSize).thenAnswer(
          (_) => Future.value(Size(10, 10)),
        );
        when(camera.initialize).thenAnswer((_) => Future.value());
        when(camera.play).thenAnswer((_) => Future.value());

        when(() => camera.videoElement).thenReturn(videoElement);
        when(() => videoElement.onError)
            .thenAnswer((_) => FakeElementStream(errorStreamController.stream));
        when(() => videoElement.onAbort)
            .thenAnswer((_) => FakeElementStream(abortStreamController.stream));

        // Save the camera in the camera plugin.
        (CameraPlatform.instance as CameraPlugin).cameras[cameraId] = camera;

        await CameraPlatform.instance.initializeCamera(cameraId);

        expect(errorStreamController.hasListener, isTrue);
        expect(abortStreamController.hasListener, isTrue);

        await CameraPlatform.instance.dispose(cameraId);

        expect(errorStreamController.hasListener, isFalse);
        expect(abortStreamController.hasListener, isFalse);
      });

      group('throws PlatformException', () {
        testWidgets(
            'with notFound error '
            'if the camera does not exist', (tester) async {
          expect(
            () => CameraPlatform.instance.dispose(cameraId),
            throwsA(
              isA<PlatformException>().having(
                (e) => e.code,
                'code',
                CameraErrorCode.notFound.toString(),
              ),
            ),
          );
        });

        testWidgets('when dispose throws DomException', (tester) async {
          final camera = MockCamera();
          final exception = FakeDomException(DomException.INVALID_ACCESS);

          when(camera.dispose).thenThrow(exception);

          // Save the camera in the camera plugin.
          (CameraPlatform.instance as CameraPlugin).cameras[cameraId] = camera;

          expect(
            () => CameraPlatform.instance.dispose(cameraId),
            throwsA(
              isA<PlatformException>().having(
                (e) => e.code,
                'code',
                exception.name,
              ),
            ),
          );
        });
      });
    });

    group('getCamera', () {
      testWidgets('returns the correct camera', (tester) async {
        final camera = Camera(
          textureId: cameraId,
          cameraSettings: cameraSettings,
        );

        // Save the camera in the camera plugin.
        (CameraPlatform.instance as CameraPlugin).cameras[cameraId] = camera;

        expect(
          (CameraPlatform.instance as CameraPlugin).getCamera(cameraId),
          equals(camera),
        );
      });

      testWidgets(
          'throws PlatformException '
          'with notFound error '
          'if the camera does not exist', (tester) async {
        expect(
          () => (CameraPlatform.instance as CameraPlugin).getCamera(cameraId),
          throwsA(
            isA<PlatformException>().having(
              (e) => e.code,
              'code',
              CameraErrorCode.notFound.toString(),
            ),
          ),
        );
      });
    });

    group('events', () {
      testWidgets(
          'onCameraInitialized emits a CameraInitializedEvent '
          'on initializeCamera', (tester) async {
        // Mock the camera to use a blank video stream of size 1280x720.
        const videoSize = Size(1280, 720);

        videoElement = getVideoElementWithBlankStream(videoSize);

        when(
          () => cameraSettings.getMediaStreamForOptions(
            any(),
            cameraId: cameraId,
          ),
        ).thenAnswer((_) async => videoElement.captureStream());

        final camera = Camera(
          textureId: cameraId,
          cameraSettings: cameraSettings,
        );

        // Save the camera in the camera plugin.
        (CameraPlatform.instance as CameraPlugin).cameras[cameraId] = camera;

        final Stream<CameraInitializedEvent> eventStream =
            CameraPlatform.instance.onCameraInitialized(cameraId);

        final streamQueue = StreamQueue(eventStream);

        await CameraPlatform.instance.initializeCamera(cameraId);

        expect(
          await streamQueue.next,
          equals(
            CameraInitializedEvent(
              cameraId,
              videoSize.width,
              videoSize.height,
              ExposureMode.auto,
              false,
              FocusMode.auto,
              false,
            ),
          ),
        );

        await streamQueue.cancel();
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

      group('onCameraError', () {
        late Camera camera;
        late VideoElement videoElement;

        late StreamController<Event> errorStreamController,
            abortStreamController;

        setUp(() {
          camera = MockCamera();
          videoElement = MockVideoElement();

          errorStreamController = StreamController<Event>();
          abortStreamController = StreamController<Event>();

          when(camera.getVideoSize).thenAnswer(
            (_) => Future.value(Size(10, 10)),
          );
          when(camera.initialize).thenAnswer((_) => Future.value());
          when(camera.play).thenAnswer((_) => Future.value());

          when(() => camera.videoElement).thenReturn(videoElement);
          when(() => videoElement.onError).thenAnswer(
              (_) => FakeElementStream(errorStreamController.stream));
          when(() => videoElement.onAbort).thenAnswer(
              (_) => FakeElementStream(abortStreamController.stream));

          // Save the camera in the camera plugin.
          (CameraPlatform.instance as CameraPlugin).cameras[cameraId] = camera;
        });

        testWidgets(
            'emits a CameraErrorEvent '
            'on video error '
            'with a message', (tester) async {
          final Stream<CameraErrorEvent> eventStream =
              CameraPlatform.instance.onCameraError(cameraId);

          final streamQueue = StreamQueue(eventStream);

          await CameraPlatform.instance.initializeCamera(cameraId);

          final error = FakeMediaError(
            MediaError.MEDIA_ERR_NETWORK,
            'A network error occured.',
          );

          final errorCode = CameraErrorCode.fromMediaError(error);

          when(() => videoElement.error).thenReturn(error);

          errorStreamController.add(Event('error'));

          expect(
            await streamQueue.next,
            equals(
              CameraErrorEvent(
                cameraId,
                'Error code: ${errorCode}, error message: ${error.message}',
              ),
            ),
          );

          await streamQueue.cancel();
        });

        testWidgets(
            'emits a CameraErrorEvent '
            'on video error '
            'with no message', (tester) async {
          final Stream<CameraErrorEvent> eventStream =
              CameraPlatform.instance.onCameraError(cameraId);

          final streamQueue = StreamQueue(eventStream);

          await CameraPlatform.instance.initializeCamera(cameraId);

          final error = FakeMediaError(MediaError.MEDIA_ERR_NETWORK);
          final errorCode = CameraErrorCode.fromMediaError(error);

          when(() => videoElement.error).thenReturn(error);

          errorStreamController.add(Event('error'));

          expect(
            await streamQueue.next,
            equals(
              CameraErrorEvent(
                cameraId,
                'Error code: ${errorCode}, error message: No further diagnostic information can be determined or provided.',
              ),
            ),
          );

          await streamQueue.cancel();
        });

        testWidgets(
            'emits a CameraErrorEvent '
            'on abort error', (tester) async {
          final Stream<CameraErrorEvent> eventStream =
              CameraPlatform.instance.onCameraError(cameraId);

          final streamQueue = StreamQueue(eventStream);

          await CameraPlatform.instance.initializeCamera(cameraId);

          abortStreamController.add(Event('abort'));

          expect(
            await streamQueue.next,
            equals(
              CameraErrorEvent(
                cameraId,
                'Error code: ${CameraErrorCode.abort}, error message: The video element\'s source has not fully loaded.',
              ),
            ),
          );

          await streamQueue.cancel();
        });
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
