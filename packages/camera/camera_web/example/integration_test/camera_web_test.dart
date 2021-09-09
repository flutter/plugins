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
import 'package:camera_web/src/camera_service.dart';
import 'package:camera_web/src/types/types.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart' as widgets;
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
    late Screen screen;
    late ScreenOrientation screenOrientation;
    late Document document;
    late Element documentElement;

    late CameraService cameraService;

    setUp(() async {
      window = MockWindow();
      navigator = MockNavigator();
      mediaDevices = MockMediaDevices();

      videoElement = getVideoElementWithBlankStream(Size(10, 10));

      when(() => window.navigator).thenReturn(navigator);
      when(() => navigator.mediaDevices).thenReturn(mediaDevices);

      screen = MockScreen();
      screenOrientation = MockScreenOrientation();

      when(() => screen.orientation).thenReturn(screenOrientation);
      when(() => window.screen).thenReturn(screen);

      document = MockDocument();
      documentElement = MockElement();

      when(() => document.documentElement).thenReturn(documentElement);
      when(() => window.document).thenReturn(document);

      cameraService = MockCameraService();

      when(
        () => cameraService.getMediaStreamForOptions(
          any(),
          cameraId: any(named: 'cameraId'),
        ),
      ).thenAnswer(
        (_) async => videoElement.captureStream(),
      );

      CameraPlatform.instance = CameraPlugin(
        cameraService: cameraService,
      )..window = window;
    });

    setUpAll(() {
      registerFallbackValue<MediaStreamTrack>(MockMediaStreamTrack());
      registerFallbackValue<CameraOptions>(MockCameraOptions());
      registerFallbackValue<FlashMode>(FlashMode.off);
    });

    testWidgets('CameraPlugin is the live instance', (tester) async {
      expect(CameraPlatform.instance, isA<CameraPlugin>());
    });

    group('availableCameras', () {
      setUp(() {
        when(
          () => cameraService.getFacingModeForVideoTrack(
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
          () => cameraService.getMediaStreamForOptions(
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
          () => cameraService.getMediaStreamForOptions(
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
          () => cameraService.getMediaStreamForOptions(
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
          () => cameraService.getMediaStreamForOptions(
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
          () => cameraService.getFacingModeForVideoTrack(
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

        // Mock camera service to return the first video stream
        // for the first video device.
        when(
          () => cameraService.getMediaStreamForOptions(
            CameraOptions(
              video: VideoConstraints(deviceId: firstVideoDevice.deviceId),
            ),
          ),
        ).thenAnswer((_) => Future.value(firstVideoStream));

        // Mock camera service to return the second video stream
        // for the second video device.
        when(
          () => cameraService.getMediaStreamForOptions(
            CameraOptions(
              video: VideoConstraints(deviceId: secondVideoDevice.deviceId),
            ),
          ),
        ).thenAnswer((_) => Future.value(secondVideoStream));

        // Mock camera service to return a user facing mode
        // for the first video stream.
        when(
          () => cameraService.getFacingModeForVideoTrack(
            firstVideoStream.getVideoTracks().first,
          ),
        ).thenReturn('user');

        when(() => cameraService.mapFacingModeToLensDirection('user'))
            .thenReturn(CameraLensDirection.front);

        // Mock camera service to return an environment facing mode
        // for the second video stream.
        when(
          () => cameraService.getFacingModeForVideoTrack(
            secondVideoStream.getVideoTracks().first,
          ),
        ).thenReturn('environment');

        when(() => cameraService.mapFacingModeToLensDirection('environment'))
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
          () => cameraService.getMediaStreamForOptions(
            CameraOptions(
              video: VideoConstraints(deviceId: videoDevice.deviceId),
            ),
          ),
        ).thenAnswer((_) => Future.value(videoStream));

        when(
          () => cameraService.getFacingModeForVideoTrack(
            videoStream.getVideoTracks().first,
          ),
        ).thenReturn('left');

        when(() => cameraService.mapFacingModeToLensDirection('left'))
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
            'when CameraService.getMediaStreamForOptions '
            'throws CameraWebException', (tester) async {
          final exception = CameraWebException(
            cameraId,
            CameraErrorCode.security,
            'description',
          );

          when(() => cameraService.getMediaStreamForOptions(any()))
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
            'when CameraService.getMediaStreamForOptions '
            'throws PlatformException', (tester) async {
          final exception = PlatformException(
            code: CameraErrorCode.notSupported.toString(),
            message: 'message',
          );

          when(() => cameraService.getMediaStreamForOptions(any()))
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
            () => cameraService.mapFacingModeToCameraType('user'),
          ).thenReturn(CameraType.user);
        });

        testWidgets('with appropriate options', (tester) async {
          when(
            () => cameraService
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
            () => cameraService.mapResolutionPresetToSize(ResolutionPreset.max),
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

      late StreamController<Event> errorStreamController, abortStreamController;
      late StreamController<MediaStreamTrack> endedStreamController;

      setUp(() {
        camera = MockCamera();
        videoElement = MockVideoElement();

        errorStreamController = StreamController<Event>();
        abortStreamController = StreamController<Event>();
        endedStreamController = StreamController<MediaStreamTrack>();

        when(camera.getVideoSize).thenReturn(Size(10, 10));
        when(camera.initialize).thenAnswer((_) => Future.value());
        when(camera.play).thenAnswer((_) => Future.value());

        when(() => camera.videoElement).thenReturn(videoElement);
        when(() => videoElement.onError)
            .thenAnswer((_) => FakeElementStream(errorStreamController.stream));
        when(() => videoElement.onAbort)
            .thenAnswer((_) => FakeElementStream(abortStreamController.stream));

        when(() => camera.onEnded)
            .thenAnswer((_) => endedStreamController.stream);
      });

      testWidgets('initializes and plays the camera', (tester) async {
        // Save the camera in the camera plugin.
        (CameraPlatform.instance as CameraPlugin).cameras[cameraId] = camera;

        await CameraPlatform.instance.initializeCamera(cameraId);

        verify(camera.initialize).called(1);
        verify(camera.play).called(1);
      });

      testWidgets('starts listening to the camera video error and abort events',
          (tester) async {
        // Save the camera in the camera plugin.
        (CameraPlatform.instance as CameraPlugin).cameras[cameraId] = camera;

        expect(errorStreamController.hasListener, isFalse);
        expect(abortStreamController.hasListener, isFalse);

        await CameraPlatform.instance.initializeCamera(cameraId);

        expect(errorStreamController.hasListener, isTrue);
        expect(abortStreamController.hasListener, isTrue);
      });

      testWidgets('starts listening to the camera ended events',
          (tester) async {
        // Save the camera in the camera plugin.
        (CameraPlatform.instance as CameraPlugin).cameras[cameraId] = camera;

        expect(endedStreamController.hasListener, isFalse);

        await CameraPlatform.instance.initializeCamera(cameraId);

        expect(endedStreamController.hasListener, isTrue);
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

    group('lockCaptureOrientation', () {
      setUp(() {
        when(
          () => cameraService.mapDeviceOrientationToOrientationType(any()),
        ).thenReturn(OrientationType.portraitPrimary);
      });

      testWidgets(
          'requests full-screen mode '
          'on documentElement', (tester) async {
        await CameraPlatform.instance.lockCaptureOrientation(
          cameraId,
          DeviceOrientation.portraitUp,
        );

        verify(documentElement.requestFullscreen).called(1);
      });

      testWidgets(
          'locks the capture orientation '
          'based on the given device orientation', (tester) async {
        when(
          () => cameraService.mapDeviceOrientationToOrientationType(
            DeviceOrientation.landscapeRight,
          ),
        ).thenReturn(OrientationType.landscapeSecondary);

        await CameraPlatform.instance.lockCaptureOrientation(
          cameraId,
          DeviceOrientation.landscapeRight,
        );

        verify(
          () => cameraService.mapDeviceOrientationToOrientationType(
            DeviceOrientation.landscapeRight,
          ),
        ).called(1);

        verify(
          () => screenOrientation.lock(
            OrientationType.landscapeSecondary,
          ),
        ).called(1);
      });

      group('throws PlatformException', () {
        testWidgets(
            'with orientationNotSupported error '
            'when screen is not supported', (tester) async {
          when(() => window.screen).thenReturn(null);

          expect(
            () => CameraPlatform.instance.lockCaptureOrientation(
              cameraId,
              DeviceOrientation.portraitUp,
            ),
            throwsA(
              isA<PlatformException>().having(
                (e) => e.code,
                'code',
                CameraErrorCode.orientationNotSupported.toString(),
              ),
            ),
          );
        });

        testWidgets(
            'with orientationNotSupported error '
            'when screen orientation is not supported', (tester) async {
          when(() => screen.orientation).thenReturn(null);

          expect(
            () => CameraPlatform.instance.lockCaptureOrientation(
              cameraId,
              DeviceOrientation.portraitUp,
            ),
            throwsA(
              isA<PlatformException>().having(
                (e) => e.code,
                'code',
                CameraErrorCode.orientationNotSupported.toString(),
              ),
            ),
          );
        });

        testWidgets(
            'with orientationNotSupported error '
            'when documentElement is not available', (tester) async {
          when(() => document.documentElement).thenReturn(null);

          expect(
            () => CameraPlatform.instance.lockCaptureOrientation(
              cameraId,
              DeviceOrientation.portraitUp,
            ),
            throwsA(
              isA<PlatformException>().having(
                (e) => e.code,
                'code',
                CameraErrorCode.orientationNotSupported.toString(),
              ),
            ),
          );
        });

        testWidgets('when lock throws DomException', (tester) async {
          final exception = FakeDomException(DomException.NOT_ALLOWED);

          when(() => screenOrientation.lock(any())).thenThrow(exception);

          expect(
            () => CameraPlatform.instance.lockCaptureOrientation(
              cameraId,
              DeviceOrientation.portraitDown,
            ),
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

    group('unlockCaptureOrientation', () {
      setUp(() {
        when(
          () => cameraService.mapDeviceOrientationToOrientationType(any()),
        ).thenReturn(OrientationType.portraitPrimary);
      });

      testWidgets('unlocks the capture orientation', (tester) async {
        await CameraPlatform.instance.unlockCaptureOrientation(
          cameraId,
        );

        verify(screenOrientation.unlock).called(1);
      });

      group('throws PlatformException', () {
        testWidgets(
            'with orientationNotSupported error '
            'when screen is not supported', (tester) async {
          when(() => window.screen).thenReturn(null);

          expect(
            () => CameraPlatform.instance.unlockCaptureOrientation(
              cameraId,
            ),
            throwsA(
              isA<PlatformException>().having(
                (e) => e.code,
                'code',
                CameraErrorCode.orientationNotSupported.toString(),
              ),
            ),
          );
        });

        testWidgets(
            'with orientationNotSupported error '
            'when screen orientation is not supported', (tester) async {
          when(() => screen.orientation).thenReturn(null);

          expect(
            () => CameraPlatform.instance.unlockCaptureOrientation(
              cameraId,
            ),
            throwsA(
              isA<PlatformException>().having(
                (e) => e.code,
                'code',
                CameraErrorCode.orientationNotSupported.toString(),
              ),
            ),
          );
        });

        testWidgets(
            'with orientationNotSupported error '
            'when documentElement is not available', (tester) async {
          when(() => document.documentElement).thenReturn(null);

          expect(
            () => CameraPlatform.instance.unlockCaptureOrientation(
              cameraId,
            ),
            throwsA(
              isA<PlatformException>().having(
                (e) => e.code,
                'code',
                CameraErrorCode.orientationNotSupported.toString(),
              ),
            ),
          );
        });

        testWidgets('when unlock throws DomException', (tester) async {
          final exception = FakeDomException(DomException.NOT_ALLOWED);

          when(screenOrientation.unlock).thenThrow(exception);

          expect(
            () => CameraPlatform.instance.unlockCaptureOrientation(
              cameraId,
            ),
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

        testWidgets('when takePicture throws CameraWebException',
            (tester) async {
          final camera = MockCamera();
          final exception = CameraWebException(
            cameraId,
            CameraErrorCode.notStarted,
            'description',
          );

          when(camera.takePicture).thenThrow(exception);

          // Save the camera in the camera plugin.
          (CameraPlatform.instance as CameraPlugin).cameras[cameraId] = camera;

          expect(
            () => CameraPlatform.instance.takePicture(cameraId),
            throwsA(
              isA<PlatformException>().having(
                (e) => e.code,
                'code',
                exception.code.toString(),
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

    group('setFlashMode', () {
      testWidgets('calls setFlashMode on the camera', (tester) async {
        final camera = MockCamera();
        const flashMode = FlashMode.always;

        // Save the camera in the camera plugin.
        (CameraPlatform.instance as CameraPlugin).cameras[cameraId] = camera;

        await CameraPlatform.instance.setFlashMode(
          cameraId,
          flashMode,
        );

        verify(() => camera.setFlashMode(flashMode)).called(1);
      });

      group('throws PlatformException', () {
        testWidgets(
            'with notFound error '
            'if the camera does not exist', (tester) async {
          expect(
            () => CameraPlatform.instance.setFlashMode(
              cameraId,
              FlashMode.always,
            ),
            throwsA(
              isA<PlatformException>().having(
                (e) => e.code,
                'code',
                CameraErrorCode.notFound.toString(),
              ),
            ),
          );
        });

        testWidgets('when setFlashMode throws DomException', (tester) async {
          final camera = MockCamera();
          final exception = FakeDomException(DomException.NOT_SUPPORTED);

          when(() => camera.setFlashMode(any())).thenThrow(exception);

          // Save the camera in the camera plugin.
          (CameraPlatform.instance as CameraPlugin).cameras[cameraId] = camera;

          expect(
            () => CameraPlatform.instance.setFlashMode(
              cameraId,
              FlashMode.always,
            ),
            throwsA(
              isA<PlatformException>().having(
                (e) => e.code,
                'code',
                exception.name,
              ),
            ),
          );
        });

        testWidgets('when setFlashMode throws CameraWebException',
            (tester) async {
          final camera = MockCamera();
          final exception = CameraWebException(
            cameraId,
            CameraErrorCode.notStarted,
            'description',
          );

          when(() => camera.setFlashMode(any())).thenThrow(exception);

          // Save the camera in the camera plugin.
          (CameraPlatform.instance as CameraPlugin).cameras[cameraId] = camera;

          expect(
            () => CameraPlatform.instance.setFlashMode(
              cameraId,
              FlashMode.torch,
            ),
            throwsA(
              isA<PlatformException>().having(
                (e) => e.code,
                'code',
                exception.code.toString(),
              ),
            ),
          );
        });
      });
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

    group('getMaxZoomLevel', () {
      testWidgets('calls getMaxZoomLevel on the camera', (tester) async {
        final camera = MockCamera();
        const maximumZoomLevel = 100.0;

        when(camera.getMaxZoomLevel).thenReturn(maximumZoomLevel);

        // Save the camera in the camera plugin.
        (CameraPlatform.instance as CameraPlugin).cameras[cameraId] = camera;

        expect(
          await CameraPlatform.instance.getMaxZoomLevel(
            cameraId,
          ),
          equals(maximumZoomLevel),
        );

        verify(camera.getMaxZoomLevel).called(1);
      });

      group('throws PlatformException', () {
        testWidgets(
            'with notFound error '
            'if the camera does not exist', (tester) async {
          expect(
            () async => await CameraPlatform.instance.getMaxZoomLevel(
              cameraId,
            ),
            throwsA(
              isA<PlatformException>().having(
                (e) => e.code,
                'code',
                CameraErrorCode.notFound.toString(),
              ),
            ),
          );
        });

        testWidgets('when getMaxZoomLevel throws DomException', (tester) async {
          final camera = MockCamera();
          final exception = FakeDomException(DomException.NOT_SUPPORTED);

          when(camera.getMaxZoomLevel).thenThrow(exception);

          // Save the camera in the camera plugin.
          (CameraPlatform.instance as CameraPlugin).cameras[cameraId] = camera;

          expect(
            () async => await CameraPlatform.instance.getMaxZoomLevel(
              cameraId,
            ),
            throwsA(
              isA<PlatformException>().having(
                (e) => e.code,
                'code',
                exception.name,
              ),
            ),
          );
        });

        testWidgets('when getMaxZoomLevel throws CameraWebException',
            (tester) async {
          final camera = MockCamera();
          final exception = CameraWebException(
            cameraId,
            CameraErrorCode.notStarted,
            'description',
          );

          when(camera.getMaxZoomLevel).thenThrow(exception);

          // Save the camera in the camera plugin.
          (CameraPlatform.instance as CameraPlugin).cameras[cameraId] = camera;

          expect(
            () async => await CameraPlatform.instance.getMaxZoomLevel(
              cameraId,
            ),
            throwsA(
              isA<PlatformException>().having(
                (e) => e.code,
                'code',
                exception.code.toString(),
              ),
            ),
          );
        });
      });
    });

    group('getMinZoomLevel', () {
      testWidgets('calls getMinZoomLevel on the camera', (tester) async {
        final camera = MockCamera();
        const minimumZoomLevel = 100.0;

        when(camera.getMinZoomLevel).thenReturn(minimumZoomLevel);

        // Save the camera in the camera plugin.
        (CameraPlatform.instance as CameraPlugin).cameras[cameraId] = camera;

        expect(
          await CameraPlatform.instance.getMinZoomLevel(
            cameraId,
          ),
          equals(minimumZoomLevel),
        );

        verify(camera.getMinZoomLevel).called(1);
      });

      group('throws PlatformException', () {
        testWidgets(
            'with notFound error '
            'if the camera does not exist', (tester) async {
          expect(
            () async => await CameraPlatform.instance.getMinZoomLevel(
              cameraId,
            ),
            throwsA(
              isA<PlatformException>().having(
                (e) => e.code,
                'code',
                CameraErrorCode.notFound.toString(),
              ),
            ),
          );
        });

        testWidgets('when getMinZoomLevel throws DomException', (tester) async {
          final camera = MockCamera();
          final exception = FakeDomException(DomException.NOT_SUPPORTED);

          when(camera.getMinZoomLevel).thenThrow(exception);

          // Save the camera in the camera plugin.
          (CameraPlatform.instance as CameraPlugin).cameras[cameraId] = camera;

          expect(
            () async => await CameraPlatform.instance.getMinZoomLevel(
              cameraId,
            ),
            throwsA(
              isA<PlatformException>().having(
                (e) => e.code,
                'code',
                exception.name,
              ),
            ),
          );
        });

        testWidgets('when getMinZoomLevel throws CameraWebException',
            (tester) async {
          final camera = MockCamera();
          final exception = CameraWebException(
            cameraId,
            CameraErrorCode.notStarted,
            'description',
          );

          when(camera.getMinZoomLevel).thenThrow(exception);

          // Save the camera in the camera plugin.
          (CameraPlatform.instance as CameraPlugin).cameras[cameraId] = camera;

          expect(
            () async => await CameraPlatform.instance.getMinZoomLevel(
              cameraId,
            ),
            throwsA(
              isA<PlatformException>().having(
                (e) => e.code,
                'code',
                exception.code.toString(),
              ),
            ),
          );
        });
      });
    });

    group('setZoomLevel', () {
      testWidgets('calls setZoomLevel on the camera', (tester) async {
        final camera = MockCamera();

        // Save the camera in the camera plugin.
        (CameraPlatform.instance as CameraPlugin).cameras[cameraId] = camera;

        const zoom = 100.0;

        await CameraPlatform.instance.setZoomLevel(cameraId, zoom);

        verify(() => camera.setZoomLevel(zoom)).called(1);
      });

      group('throws CameraException', () {
        testWidgets(
            'with notFound error '
            'if the camera does not exist', (tester) async {
          expect(
            () async => await CameraPlatform.instance.setZoomLevel(
              cameraId,
              100.0,
            ),
            throwsA(
              isA<CameraException>().having(
                (e) => e.code,
                'code',
                CameraErrorCode.notFound.toString(),
              ),
            ),
          );
        });

        testWidgets('when setZoomLevel throws DomException', (tester) async {
          final camera = MockCamera();
          final exception = FakeDomException(DomException.NOT_SUPPORTED);

          when(() => camera.setZoomLevel(any())).thenThrow(exception);

          // Save the camera in the camera plugin.
          (CameraPlatform.instance as CameraPlugin).cameras[cameraId] = camera;

          expect(
            () async => await CameraPlatform.instance.setZoomLevel(
              cameraId,
              100.0,
            ),
            throwsA(
              isA<CameraException>().having(
                (e) => e.code,
                'code',
                exception.name,
              ),
            ),
          );
        });

        testWidgets('when setZoomLevel throws PlatformException',
            (tester) async {
          final camera = MockCamera();
          final exception = PlatformException(
            code: CameraErrorCode.notSupported.toString(),
            message: 'message',
          );

          when(() => camera.setZoomLevel(any())).thenThrow(exception);

          // Save the camera in the camera plugin.
          (CameraPlatform.instance as CameraPlugin).cameras[cameraId] = camera;

          expect(
            () async => await CameraPlatform.instance.setZoomLevel(
              cameraId,
              100.0,
            ),
            throwsA(
              isA<CameraException>().having(
                (e) => e.code,
                'code',
                exception.code,
              ),
            ),
          );
        });

        testWidgets('when setZoomLevel throws CameraWebException',
            (tester) async {
          final camera = MockCamera();
          final exception = CameraWebException(
            cameraId,
            CameraErrorCode.notStarted,
            'description',
          );

          when(() => camera.setZoomLevel(any())).thenThrow(exception);

          // Save the camera in the camera plugin.
          (CameraPlatform.instance as CameraPlugin).cameras[cameraId] = camera;

          expect(
            () async => await CameraPlatform.instance.setZoomLevel(
              cameraId,
              100.0,
            ),
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

    group('pausePreview', () {
      testWidgets('calls pause on the camera', (tester) async {
        final camera = MockCamera();

        // Save the camera in the camera plugin.
        (CameraPlatform.instance as CameraPlugin).cameras[cameraId] = camera;

        await CameraPlatform.instance.pausePreview(cameraId);

        verify(camera.pause).called(1);
      });

      group('throws PlatformException', () {
        testWidgets(
            'with notFound error '
            'if the camera does not exist', (tester) async {
          expect(
            () async => await CameraPlatform.instance.pausePreview(cameraId),
            throwsA(
              isA<PlatformException>().having(
                (e) => e.code,
                'code',
                CameraErrorCode.notFound.toString(),
              ),
            ),
          );
        });

        testWidgets('when pause throws DomException', (tester) async {
          final camera = MockCamera();
          final exception = FakeDomException(DomException.NOT_SUPPORTED);

          when(camera.pause).thenThrow(exception);

          // Save the camera in the camera plugin.
          (CameraPlatform.instance as CameraPlugin).cameras[cameraId] = camera;

          expect(
            () async => await CameraPlatform.instance.pausePreview(cameraId),
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

    group('resumePreview', () {
      testWidgets('calls play on the camera', (tester) async {
        final camera = MockCamera();

        when(camera.play).thenAnswer((_) async => {});

        // Save the camera in the camera plugin.
        (CameraPlatform.instance as CameraPlugin).cameras[cameraId] = camera;

        await CameraPlatform.instance.resumePreview(cameraId);

        verify(camera.play).called(1);
      });

      group('throws PlatformException', () {
        testWidgets(
            'with notFound error '
            'if the camera does not exist', (tester) async {
          expect(
            () async => await CameraPlatform.instance.resumePreview(cameraId),
            throwsA(
              isA<PlatformException>().having(
                (e) => e.code,
                'code',
                CameraErrorCode.notFound.toString(),
              ),
            ),
          );
        });

        testWidgets('when play throws DomException', (tester) async {
          final camera = MockCamera();
          final exception = FakeDomException(DomException.NOT_SUPPORTED);

          when(camera.play).thenThrow(exception);

          // Save the camera in the camera plugin.
          (CameraPlatform.instance as CameraPlugin).cameras[cameraId] = camera;

          expect(
            () async => await CameraPlatform.instance.resumePreview(cameraId),
            throwsA(
              isA<PlatformException>().having(
                (e) => e.code,
                'code',
                exception.name,
              ),
            ),
          );
        });

        testWidgets('when play throws CameraWebException', (tester) async {
          final camera = MockCamera();
          final exception = CameraWebException(
            cameraId,
            CameraErrorCode.unknown,
            'description',
          );

          when(camera.play).thenThrow(exception);

          // Save the camera in the camera plugin.
          (CameraPlatform.instance as CameraPlugin).cameras[cameraId] = camera;

          expect(
            () async => await CameraPlatform.instance.resumePreview(cameraId),
            throwsA(
              isA<PlatformException>().having(
                (e) => e.code,
                'code',
                exception.code.toString(),
              ),
            ),
          );
        });
      });
    });

    testWidgets(
        'buildPreview returns an HtmlElementView '
        'with an appropriate view type', (tester) async {
      final camera = Camera(
        textureId: cameraId,
        cameraService: cameraService,
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
      late Camera camera;
      late VideoElement videoElement;

      late StreamController<Event> errorStreamController, abortStreamController;
      late StreamController<MediaStreamTrack> endedStreamController;

      setUp(() {
        camera = MockCamera();
        videoElement = MockVideoElement();

        errorStreamController = StreamController<Event>();
        abortStreamController = StreamController<Event>();
        endedStreamController = StreamController<MediaStreamTrack>();

        when(camera.getVideoSize).thenReturn(Size(10, 10));
        when(camera.initialize).thenAnswer((_) => Future.value());
        when(camera.play).thenAnswer((_) => Future.value());
        when(camera.dispose).thenAnswer((_) => Future.value());

        when(() => camera.videoElement).thenReturn(videoElement);
        when(() => videoElement.onError)
            .thenAnswer((_) => FakeElementStream(errorStreamController.stream));
        when(() => videoElement.onAbort)
            .thenAnswer((_) => FakeElementStream(abortStreamController.stream));

        when(() => camera.onEnded)
            .thenAnswer((_) => endedStreamController.stream);
      });

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

      testWidgets('cancels the camera video error and abort subscriptions',
          (tester) async {
        // Save the camera in the camera plugin.
        (CameraPlatform.instance as CameraPlugin).cameras[cameraId] = camera;

        await CameraPlatform.instance.initializeCamera(cameraId);
        await CameraPlatform.instance.dispose(cameraId);

        expect(errorStreamController.hasListener, isFalse);
        expect(abortStreamController.hasListener, isFalse);
      });

      testWidgets('cancels the camera ended subscriptions', (tester) async {
        // Save the camera in the camera plugin.
        (CameraPlatform.instance as CameraPlugin).cameras[cameraId] = camera;

        await CameraPlatform.instance.initializeCamera(cameraId);
        await CameraPlatform.instance.dispose(cameraId);

        expect(endedStreamController.hasListener, isFalse);
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
          cameraService: cameraService,
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
      late Camera camera;
      late VideoElement videoElement;

      late StreamController<Event> errorStreamController, abortStreamController;
      late StreamController<MediaStreamTrack> endedStreamController;

      setUp(() {
        camera = MockCamera();
        videoElement = MockVideoElement();

        errorStreamController = StreamController<Event>();
        abortStreamController = StreamController<Event>();
        endedStreamController = StreamController<MediaStreamTrack>();

        when(camera.getVideoSize).thenReturn(Size(10, 10));
        when(camera.initialize).thenAnswer((_) => Future.value());
        when(camera.play).thenAnswer((_) => Future.value());

        when(() => camera.videoElement).thenReturn(videoElement);
        when(() => videoElement.onError)
            .thenAnswer((_) => FakeElementStream(errorStreamController.stream));
        when(() => videoElement.onAbort)
            .thenAnswer((_) => FakeElementStream(abortStreamController.stream));

        when(() => camera.onEnded)
            .thenAnswer((_) => endedStreamController.stream);
      });

      testWidgets(
          'onCameraInitialized emits a CameraInitializedEvent '
          'on initializeCamera', (tester) async {
        // Mock the camera to use a blank video stream of size 1280x720.
        const videoSize = Size(1280, 720);

        videoElement = getVideoElementWithBlankStream(videoSize);

        when(
          () => cameraService.getMediaStreamForOptions(
            any(),
            cameraId: cameraId,
          ),
        ).thenAnswer((_) async => videoElement.captureStream());

        final camera = Camera(
          textureId: cameraId,
          cameraService: cameraService,
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

      testWidgets('onCameraResolutionChanged emits an empty stream',
          (tester) async {
        expect(
          CameraPlatform.instance.onCameraResolutionChanged(cameraId),
          emits(isEmpty),
        );
      });

      testWidgets(
          'onCameraClosing emits a CameraClosingEvent '
          'on the camera ended event', (tester) async {
        // Save the camera in the camera plugin.
        (CameraPlatform.instance as CameraPlugin).cameras[cameraId] = camera;

        final Stream<CameraClosingEvent> eventStream =
            CameraPlatform.instance.onCameraClosing(cameraId);

        final streamQueue = StreamQueue(eventStream);

        await CameraPlatform.instance.initializeCamera(cameraId);

        endedStreamController.add(MockMediaStreamTrack());

        expect(
          await streamQueue.next,
          equals(
            CameraClosingEvent(cameraId),
          ),
        );

        await streamQueue.cancel();
      });

      group('onCameraError', () {
        setUp(() {
          // Save the camera in the camera plugin.
          (CameraPlatform.instance as CameraPlugin).cameras[cameraId] = camera;
        });

        testWidgets(
            'emits a CameraErrorEvent '
            'on the camera video error event '
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
            'on the camera video error event '
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
            'on the camera video abort event', (tester) async {
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

        testWidgets(
            'emits a CameraErrorEvent '
            'on takePicture error', (tester) async {
          final exception = CameraWebException(
            cameraId,
            CameraErrorCode.notStarted,
            'description',
          );

          when(camera.takePicture).thenThrow(exception);

          final Stream<CameraErrorEvent> eventStream =
              CameraPlatform.instance.onCameraError(cameraId);

          final streamQueue = StreamQueue(eventStream);

          expect(
            () async => await CameraPlatform.instance.takePicture(cameraId),
            throwsA(
              isA<PlatformException>(),
            ),
          );

          expect(
            await streamQueue.next,
            equals(
              CameraErrorEvent(
                cameraId,
                'Error code: ${exception.code}, error message: ${exception.description}',
              ),
            ),
          );

          await streamQueue.cancel();
        });

        testWidgets(
            'emits a CameraErrorEvent '
            'on setFlashMode error', (tester) async {
          final exception = CameraWebException(
            cameraId,
            CameraErrorCode.notStarted,
            'description',
          );

          when(() => camera.setFlashMode(any())).thenThrow(exception);

          final Stream<CameraErrorEvent> eventStream =
              CameraPlatform.instance.onCameraError(cameraId);

          final streamQueue = StreamQueue(eventStream);

          expect(
            () async => await CameraPlatform.instance.setFlashMode(
              cameraId,
              FlashMode.always,
            ),
            throwsA(
              isA<PlatformException>(),
            ),
          );

          expect(
            await streamQueue.next,
            equals(
              CameraErrorEvent(
                cameraId,
                'Error code: ${exception.code}, error message: ${exception.description}',
              ),
            ),
          );

          await streamQueue.cancel();
        });

        testWidgets(
            'emits a CameraErrorEvent '
            'on getMaxZoomLevel error', (tester) async {
          final exception = CameraWebException(
            cameraId,
            CameraErrorCode.zoomLevelNotSupported,
            'description',
          );

          when(camera.getMaxZoomLevel).thenThrow(exception);

          final Stream<CameraErrorEvent> eventStream =
              CameraPlatform.instance.onCameraError(cameraId);

          final streamQueue = StreamQueue(eventStream);

          expect(
            () async => await CameraPlatform.instance.getMaxZoomLevel(
              cameraId,
            ),
            throwsA(
              isA<PlatformException>(),
            ),
          );

          expect(
            await streamQueue.next,
            equals(
              CameraErrorEvent(
                cameraId,
                'Error code: ${exception.code}, error message: ${exception.description}',
              ),
            ),
          );

          await streamQueue.cancel();
        });

        testWidgets(
            'emits a CameraErrorEvent '
            'on getMinZoomLevel error', (tester) async {
          final exception = CameraWebException(
            cameraId,
            CameraErrorCode.zoomLevelNotSupported,
            'description',
          );

          when(camera.getMinZoomLevel).thenThrow(exception);

          final Stream<CameraErrorEvent> eventStream =
              CameraPlatform.instance.onCameraError(cameraId);

          final streamQueue = StreamQueue(eventStream);

          expect(
            () async => await CameraPlatform.instance.getMinZoomLevel(
              cameraId,
            ),
            throwsA(
              isA<PlatformException>(),
            ),
          );

          expect(
            await streamQueue.next,
            equals(
              CameraErrorEvent(
                cameraId,
                'Error code: ${exception.code}, error message: ${exception.description}',
              ),
            ),
          );

          await streamQueue.cancel();
        });

        testWidgets(
            'emits a CameraErrorEvent '
            'on setZoomLevel error', (tester) async {
          final exception = CameraWebException(
            cameraId,
            CameraErrorCode.zoomLevelNotSupported,
            'description',
          );

          when(() => camera.setZoomLevel(any())).thenThrow(exception);

          final Stream<CameraErrorEvent> eventStream =
              CameraPlatform.instance.onCameraError(cameraId);

          final streamQueue = StreamQueue(eventStream);

          expect(
            () async => await CameraPlatform.instance.setZoomLevel(
              cameraId,
              100.0,
            ),
            throwsA(
              isA<CameraException>(),
            ),
          );

          expect(
            await streamQueue.next,
            equals(
              CameraErrorEvent(
                cameraId,
                'Error code: ${exception.code}, error message: ${exception.description}',
              ),
            ),
          );

          await streamQueue.cancel();
        });

        testWidgets(
            'emits a CameraErrorEvent '
            'on resumePreview error', (tester) async {
          final exception = CameraWebException(
            cameraId,
            CameraErrorCode.unknown,
            'description',
          );

          when(camera.play).thenThrow(exception);

          final Stream<CameraErrorEvent> eventStream =
              CameraPlatform.instance.onCameraError(cameraId);

          final streamQueue = StreamQueue(eventStream);

          expect(
            () async => await CameraPlatform.instance.resumePreview(cameraId),
            throwsA(
              isA<PlatformException>(),
            ),
          );

          expect(
            await streamQueue.next,
            equals(
              CameraErrorEvent(
                cameraId,
                'Error code: ${exception.code}, error message: ${exception.description}',
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

      group('onDeviceOrientationChanged', () {
        group('emits an empty stream', () {
          testWidgets('when screen is not supported', (tester) async {
            when(() => window.screen).thenReturn(null);

            expect(
              CameraPlatform.instance.onDeviceOrientationChanged(),
              emits(isEmpty),
            );
          });

          testWidgets('when screen orientation is not supported',
              (tester) async {
            when(() => screen.orientation).thenReturn(null);

            expect(
              CameraPlatform.instance.onDeviceOrientationChanged(),
              emits(isEmpty),
            );
          });
        });

        testWidgets('emits the initial DeviceOrientationChangedEvent',
            (tester) async {
          when(
            () => cameraService.mapOrientationTypeToDeviceOrientation(
              OrientationType.portraitPrimary,
            ),
          ).thenReturn(DeviceOrientation.portraitUp);

          // Set the initial screen orientation to portraitPrimary.
          when(() => screenOrientation.type)
              .thenReturn(OrientationType.portraitPrimary);

          final eventStreamController = StreamController<Event>();

          when(() => screenOrientation.onChange)
              .thenAnswer((_) => eventStreamController.stream);

          final Stream<DeviceOrientationChangedEvent> eventStream =
              CameraPlatform.instance.onDeviceOrientationChanged();

          final streamQueue = StreamQueue(eventStream);

          expect(
            await streamQueue.next,
            equals(
              DeviceOrientationChangedEvent(
                DeviceOrientation.portraitUp,
              ),
            ),
          );

          await streamQueue.cancel();
        });

        testWidgets(
            'emits a DeviceOrientationChangedEvent '
            'when the screen orientation is changed', (tester) async {
          when(
            () => cameraService.mapOrientationTypeToDeviceOrientation(
              OrientationType.landscapePrimary,
            ),
          ).thenReturn(DeviceOrientation.landscapeLeft);

          when(
            () => cameraService.mapOrientationTypeToDeviceOrientation(
              OrientationType.portraitSecondary,
            ),
          ).thenReturn(DeviceOrientation.portraitDown);

          final eventStreamController = StreamController<Event>();

          when(() => screenOrientation.onChange)
              .thenAnswer((_) => eventStreamController.stream);

          final Stream<DeviceOrientationChangedEvent> eventStream =
              CameraPlatform.instance.onDeviceOrientationChanged();

          final streamQueue = StreamQueue(eventStream);

          // Change the screen orientation to landscapePrimary and
          // emit an event on the screenOrientation.onChange stream.
          when(() => screenOrientation.type)
              .thenReturn(OrientationType.landscapePrimary);

          eventStreamController.add(Event('change'));

          expect(
            await streamQueue.next,
            equals(
              DeviceOrientationChangedEvent(
                DeviceOrientation.landscapeLeft,
              ),
            ),
          );

          // Change the screen orientation to portraitSecondary and
          // emit an event on the screenOrientation.onChange stream.
          when(() => screenOrientation.type)
              .thenReturn(OrientationType.portraitSecondary);

          eventStreamController.add(Event('change'));

          expect(
            await streamQueue.next,
            equals(
              DeviceOrientationChangedEvent(
                DeviceOrientation.portraitDown,
              ),
            ),
          );

          await streamQueue.cancel();
        });
      });
    });
  });
}
