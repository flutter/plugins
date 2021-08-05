// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:html';
import 'dart:ui';

import 'package:camera_web/src/camera.dart';
import 'package:camera_web/src/camera_settings.dart';
import 'package:camera_web/src/types/types.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mocktail/mocktail.dart';

import 'helpers/helpers.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Camera', () {
    late MediaStream mediaStream;
    late CameraSettings cameraSettings;

    setUp(() {
      cameraSettings = MockCameraSettings();

      final videoElement = getVideoElementWithBlankStream(Size(10, 10));
      mediaStream = videoElement.captureStream();

      when(
        () => cameraSettings.getMediaStreamForOptions(
          any(),
          cameraId: any(named: 'cameraId'),
        ),
      ).thenAnswer((_) => Future.value(mediaStream));
    });

    setUpAll(() {
      registerFallbackValue<CameraOptions>(MockCameraOptions());
    });

    group('initialize', () {
      testWidgets(
          'calls CameraSettings.getMediaStreamForOptions '
          'with provided options', (tester) async {
        final options = CameraOptions(
          video: VideoConstraints(
            facingMode: FacingModeConstraint.exact(CameraType.user),
            width: VideoSizeConstraint(ideal: 200),
          ),
        );

        final camera = Camera(
          textureId: 1,
          options: options,
          cameraSettings: cameraSettings,
        );

        await camera.initialize();

        verify(
          () => cameraSettings.getMediaStreamForOptions(
            options,
            cameraId: 1,
          ),
        ).called(1);
      });

      testWidgets(
          'creates a video element '
          'with correct properties', (tester) async {
        const audioConstraints = AudioConstraints(enabled: true);

        final camera = Camera(
          textureId: 1,
          options: CameraOptions(
            audio: audioConstraints,
          ),
          cameraSettings: cameraSettings,
        );

        await camera.initialize();

        expect(camera.videoElement, isNotNull);
        expect(camera.videoElement.autoplay, isFalse);
        expect(camera.videoElement.muted, !audioConstraints.enabled);
        expect(camera.videoElement.srcObject, mediaStream);
        expect(camera.videoElement.attributes.keys, contains('playsinline'));

        expect(
            camera.videoElement.style.transformOrigin, equals('center center'));
        expect(camera.videoElement.style.pointerEvents, equals('none'));
        expect(camera.videoElement.style.width, equals('100%'));
        expect(camera.videoElement.style.height, equals('100%'));
        expect(camera.videoElement.style.objectFit, equals('cover'));
        expect(camera.videoElement.style.transform, equals('scaleX(-1)'));
      });

      testWidgets(
          'creates a wrapping div element '
          'with correct properties', (tester) async {
        final camera = Camera(
          textureId: 1,
          cameraSettings: cameraSettings,
        );

        await camera.initialize();

        expect(camera.divElement, isNotNull);
        expect(camera.divElement.style.objectFit, equals('cover'));
        expect(camera.divElement.children, contains(camera.videoElement));
      });

      testWidgets(
          'throws an exception '
          'when CameraSettings.getMediaStreamForOptions throws',
          (tester) async {
        final exception = Exception('A media stream exception occured.');

        when(() => cameraSettings.getMediaStreamForOptions(any(),
            cameraId: any(named: 'cameraId'))).thenThrow(exception);

        final camera = Camera(
          textureId: 1,
          cameraSettings: cameraSettings,
        );

        expect(
          camera.initialize,
          throwsA(exception),
        );
      });
    });

    group('play', () {
      testWidgets('starts playing the video element', (tester) async {
        var startedPlaying = false;

        final camera = Camera(
          textureId: 1,
          cameraSettings: cameraSettings,
        );

        await camera.initialize();

        final cameraPlaySubscription =
            camera.videoElement.onPlay.listen((event) => startedPlaying = true);

        await camera.play();

        expect(startedPlaying, isTrue);

        await cameraPlaySubscription.cancel();
      });

      testWidgets(
          'assigns a media stream '
          'from CameraSettings.getMediaStreamForOptions '
          'to the video element\'s source '
          'if it does not exist', (tester) async {
        final options = CameraOptions(
          video: VideoConstraints(
            width: VideoSizeConstraint(ideal: 100),
          ),
        );

        final camera = Camera(
          textureId: 1,
          options: options,
          cameraSettings: cameraSettings,
        );

        await camera.initialize();

        /// Remove the video element's source
        /// by stopping the camera.
        camera.stop();

        await camera.play();

        // Should be called twice: for initialize and play.
        verify(
          () => cameraSettings.getMediaStreamForOptions(
            options,
            cameraId: 1,
          ),
        ).called(2);

        expect(camera.videoElement.srcObject, mediaStream);
      });
    });

    group('stop', () {
      testWidgets('resets the video element\'s source', (tester) async {
        final camera = Camera(
          textureId: 1,
          cameraSettings: cameraSettings,
        );

        await camera.initialize();
        await camera.play();

        camera.stop();

        expect(camera.videoElement.srcObject, isNull);
      });
    });

    group('takePicture', () {
      testWidgets('returns a captured picture', (tester) async {
        final camera = Camera(
          textureId: 1,
          cameraSettings: cameraSettings,
        );

        await camera.initialize();
        await camera.play();

        final pictureFile = await camera.takePicture();

        expect(pictureFile, isNotNull);
      });
    });

    group('getVideoSize', () {
      testWidgets(
          'returns a size '
          'based on the first video track settings', (tester) async {
        const videoSize = Size(1280, 720);

        final videoElement = getVideoElementWithBlankStream(videoSize);
        mediaStream = videoElement.captureStream();

        final camera = Camera(
          textureId: 1,
          cameraSettings: cameraSettings,
        );

        await camera.initialize();

        expect(
          await camera.getVideoSize(),
          equals(videoSize),
        );
      });

      testWidgets(
          'returns Size.zero '
          'if the camera is missing video tracks', (tester) async {
        // Create a video stream with no video tracks.
        final videoElement = VideoElement();
        mediaStream = videoElement.captureStream();

        final camera = Camera(
          textureId: 1,
          cameraSettings: cameraSettings,
        );

        await camera.initialize();

        expect(
          await camera.getVideoSize(),
          equals(Size.zero),
        );
      });
    });

    group('getViewType', () {
      testWidgets('returns a correct view type', (tester) async {
        const textureId = 1;

        final camera = Camera(
          textureId: textureId,
          cameraSettings: cameraSettings,
        );

        await camera.initialize();

        expect(
          camera.getViewType(),
          equals('plugins.flutter.io/camera_$textureId'),
        );
      });
    });

    group('dispose', () {
      testWidgets('resets the video element\'s source', (tester) async {
        final camera = Camera(
          textureId: 1,
          cameraSettings: cameraSettings,
        );

        await camera.initialize();

        camera.dispose();

        expect(camera.videoElement.srcObject, isNull);
      });
    });
  });
}
