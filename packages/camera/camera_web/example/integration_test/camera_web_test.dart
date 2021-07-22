// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:html';

import 'package:camera_platform_interface/camera_platform_interface.dart';
import 'package:camera_web/camera_web.dart';
import 'package:camera_web/src/camera_settings.dart';
import 'package:camera_web/src/types/types.dart';
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
      videoElement = VideoElement()
        ..src =
            'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4'
        ..preload = 'true'
        ..width = 10
        ..height = 10
        ..crossOrigin = 'anonymous';

      cameraSettings = MockCameraSettings();

      when(() => window.navigator).thenReturn(navigator);
      when(() => navigator.mediaDevices).thenReturn(mediaDevices);
      when(
        () => mediaDevices.getUserMedia(any()),
      ).thenAnswer((_) async => videoElement.captureStream());

      CameraPlatform.instance = CameraPlugin(
        cameraSettings: cameraSettings,
      )..window = window;
    });

    setUpAll(() {
      registerFallbackValue<MediaStreamTrack>(MockMediaStreamTrack());
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
      });

      testWidgets(
          'throws CameraException '
          'with notSupported error '
          'when there are no media devices', (tester) async {
        when(() => navigator.mediaDevices).thenReturn(null);

        expect(
          () => CameraPlatform.instance.availableCameras(),
          throwsA(
            isA<CameraException>().having(
              (e) => e.code,
              'code',
              CameraErrorCodes.notSupported,
            ),
          ),
        );
      });

      testWidgets(
          'calls MediaDevices.getUserMedia '
          'on the video input device', (tester) async {
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
          () => mediaDevices.getUserMedia(
            CameraOptions(
              video: VideoConstraints(
                deviceId: videoDevice.deviceId,
              ),
            ).toJson(),
          ),
        ).called(1);
      });

      testWidgets(
          'calls CameraSettings.getLensDirectionForVideoTrack '
          'on the first video track of the video input device', (tester) async {
        final videoDevice = FakeMediaDeviceInfo(
          '1',
          'Camera 1',
          MediaDeviceKind.videoInput,
        );

        final videoStream =
            FakeMediaStream([MockMediaStreamTrack(), MockMediaStreamTrack()]);

        when(
          () => mediaDevices.getUserMedia(
            CameraOptions(
              video: VideoConstraints(deviceId: videoDevice.deviceId),
            ).toJson(),
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
          'for multiple media devices', (tester) async {
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
              'Camera 2',
              MediaDeviceKind.audioInput,
            ),
            FakeMediaDeviceInfo(
              '3',
              'Camera 3',
              MediaDeviceKind.audioOutput,
            ),
            secondVideoDevice,
          ]),
        );

        // Mock media devices to return the first video stream
        // for the first video device.
        when(
          () => mediaDevices.getUserMedia(
            CameraOptions(
              video: VideoConstraints(deviceId: firstVideoDevice.deviceId),
            ).toJson(),
          ),
        ).thenAnswer((_) => Future.value(firstVideoStream));

        // Mock media devices to return the second video stream
        // for the second video device.
        when(
          () => mediaDevices.getUserMedia(
            CameraOptions(
              video: VideoConstraints(deviceId: secondVideoDevice.deviceId),
            ).toJson(),
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
          () => mediaDevices.getUserMedia(
            CameraOptions(
              video: VideoConstraints(deviceId: videoDevice.deviceId),
            ).toJson(),
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
    });

    testWidgets('createCamera throws UnimplementedError', (tester) async {
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

    testWidgets('initializeCamera throws UnimplementedError', (tester) async {
      expect(
        () => CameraPlatform.instance.initializeCamera(cameraId),
        throwsUnimplementedError,
      );
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

    testWidgets('takePicture throws UnimplementedError', (tester) async {
      expect(
        () => CameraPlatform.instance.takePicture(cameraId),
        throwsUnimplementedError,
      );
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

    testWidgets('buildPreview throws UnimplementedError', (tester) async {
      expect(
        () => CameraPlatform.instance.buildPreview(cameraId),
        throwsUnimplementedError,
      );
    });

    testWidgets('dispose throws UnimplementedError', (tester) async {
      expect(
        () => CameraPlatform.instance.dispose(cameraId),
        throwsUnimplementedError,
      );
    });

    group('events', () {
      testWidgets('onCameraInitialized throws UnimplementedError',
          (tester) async {
        expect(
          () => CameraPlatform.instance.onCameraInitialized(cameraId),
          throwsUnimplementedError,
        );
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

      testWidgets('onCameraError throws UnimplementedError', (tester) async {
        expect(
          () => CameraPlatform.instance.onCameraError(cameraId),
          throwsUnimplementedError,
        );
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
