// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:html';
import 'dart:ui';

import 'package:camera_platform_interface/camera_platform_interface.dart';
import 'package:camera_web/src/camera.dart';
import 'package:camera_web/src/types/camera_error_codes.dart';
import 'package:camera_web/src/types/camera_options.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mocktail/mocktail.dart';

import 'helpers/helpers.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Camera', () {
    late Window window;
    late Navigator navigator;
    late MediaStream mediaStream;
    late MediaDevices mediaDevices;

    setUp(() {
      window = MockWindow();
      navigator = MockNavigator();
      mediaDevices = MockMediaDevices();

      final videoElement = getVideoElementWithBlankStream(Size(10, 10));
      mediaStream = videoElement.captureStream();

      when(() => window.navigator).thenReturn(navigator);
      when(() => navigator.mediaDevices).thenReturn(mediaDevices);
      when(
        () => mediaDevices.getUserMedia(any()),
      ).thenAnswer((_) async => mediaStream);
    });

    group('initialize', () {
      testWidgets(
          'creates a video element '
          'with correct properties', (tester) async {
        const audioConstraints = AudioConstraints(enabled: true);

        final camera = Camera(
          textureId: 1,
          options: CameraOptions(
            audio: audioConstraints,
          ),
          window: window,
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
          window: window,
        );

        await camera.initialize();

        expect(camera.divElement, isNotNull);
        expect(camera.divElement.style.objectFit, equals('cover'));
        expect(camera.divElement.children, contains(camera.videoElement));
      });

      testWidgets('calls getUserMedia with provided options', (tester) async {
        final options = CameraOptions(
          video: VideoConstraints(
            facingMode: FacingModeConstraint.exact(CameraType.user),
            width: VideoSizeConstraint(ideal: 200),
          ),
        );

        final optionsJson = await options.toJson();

        final camera = Camera(
          textureId: 1,
          options: options,
          window: window,
        );

        await camera.initialize();

        verify(() => mediaDevices.getUserMedia(optionsJson)).called(1);
      });

      group('throws CameraException', () {
        testWidgets(
            'with notSupported error '
            'when there are no media devices', (tester) async {
          when(() => navigator.mediaDevices).thenReturn(null);

          final camera = Camera(
            textureId: 1,
            window: window,
          );

          expect(
            camera.initialize,
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
            'with notFound error '
            'when getUserMedia throws DomException '
            'with NotFoundError', (tester) async {
          when(() => mediaDevices.getUserMedia(any()))
              .thenThrow(FakeDomException('NotFoundError'));

          final camera = Camera(
            textureId: 1,
            window: window,
          );

          expect(
            camera.initialize,
            throwsA(
              isA<CameraException>().having(
                (e) => e.code,
                'code',
                CameraErrorCodes.notFound,
              ),
            ),
          );
        });

        testWidgets(
            'with notFound error '
            'when getUserMedia throws DomException '
            'with DevicesNotFoundError', (tester) async {
          when(() => mediaDevices.getUserMedia(any()))
              .thenThrow(FakeDomException('DevicesNotFoundError'));

          final camera = Camera(
            textureId: 1,
            window: window,
          );

          expect(
            camera.initialize,
            throwsA(
              isA<CameraException>().having(
                (e) => e.code,
                'code',
                CameraErrorCodes.notFound,
              ),
            ),
          );
        });

        testWidgets(
            'with notReadable error '
            'when getUserMedia throws DomException '
            'with NotReadableError', (tester) async {
          when(() => mediaDevices.getUserMedia(any()))
              .thenThrow(FakeDomException('NotReadableError'));

          final camera = Camera(
            textureId: 1,
            window: window,
          );

          expect(
            camera.initialize,
            throwsA(
              isA<CameraException>().having(
                (e) => e.code,
                'code',
                CameraErrorCodes.notReadable,
              ),
            ),
          );
        });

        testWidgets(
            'with notReadable error '
            'when getUserMedia throws DomException '
            'with TrackStartError', (tester) async {
          when(() => mediaDevices.getUserMedia(any()))
              .thenThrow(FakeDomException('TrackStartError'));

          final camera = Camera(
            textureId: 1,
            window: window,
          );

          expect(
            camera.initialize,
            throwsA(
              isA<CameraException>().having(
                (e) => e.code,
                'code',
                CameraErrorCodes.notReadable,
              ),
            ),
          );
        });

        testWidgets(
            'with overconstrained error '
            'when getUserMedia throws DomException '
            'with OverconstrainedError', (tester) async {
          when(() => mediaDevices.getUserMedia(any()))
              .thenThrow(FakeDomException('OverconstrainedError'));

          final camera = Camera(
            textureId: 1,
            window: window,
          );

          expect(
            camera.initialize,
            throwsA(
              isA<CameraException>().having(
                (e) => e.code,
                'code',
                CameraErrorCodes.overconstrained,
              ),
            ),
          );
        });

        testWidgets(
            'with overconstrained error '
            'when getUserMedia throws DomException '
            'with ConstraintNotSatisfiedError', (tester) async {
          when(() => mediaDevices.getUserMedia(any()))
              .thenThrow(FakeDomException('ConstraintNotSatisfiedError'));

          final camera = Camera(
            textureId: 1,
            window: window,
          );

          expect(
            camera.initialize,
            throwsA(
              isA<CameraException>().having(
                (e) => e.code,
                'code',
                CameraErrorCodes.overconstrained,
              ),
            ),
          );
        });

        testWidgets(
            'with permissionDenied error '
            'when getUserMedia throws DomException '
            'with NotAllowedError', (tester) async {
          when(() => mediaDevices.getUserMedia(any()))
              .thenThrow(FakeDomException('NotAllowedError'));

          final camera = Camera(
            textureId: 1,
            window: window,
          );

          expect(
            camera.initialize,
            throwsA(
              isA<CameraException>().having(
                (e) => e.code,
                'code',
                CameraErrorCodes.permissionDenied,
              ),
            ),
          );
        });

        testWidgets(
            'with permissionDenied error '
            'when getUserMedia throws DomException '
            'with PermissionDeniedError', (tester) async {
          when(() => mediaDevices.getUserMedia(any()))
              .thenThrow(FakeDomException('PermissionDeniedError'));

          final camera = Camera(
            textureId: 1,
            window: window,
          );

          expect(
            camera.initialize,
            throwsA(
              isA<CameraException>().having(
                (e) => e.code,
                'code',
                CameraErrorCodes.permissionDenied,
              ),
            ),
          );
        });

        testWidgets(
            'with type error '
            'when getUserMedia throws DomException '
            'with TypeError', (tester) async {
          when(() => mediaDevices.getUserMedia(any()))
              .thenThrow(FakeDomException('TypeError'));

          final camera = Camera(
            textureId: 1,
            window: window,
          );

          expect(
            camera.initialize,
            throwsA(
              isA<CameraException>().having(
                (e) => e.code,
                'code',
                CameraErrorCodes.type,
              ),
            ),
          );
        });

        testWidgets(
            'with unknown error '
            'when getUserMedia throws DomException '
            'with an unknown error', (tester) async {
          when(() => mediaDevices.getUserMedia(any()))
              .thenThrow(FakeDomException('Unknown'));

          final camera = Camera(
            textureId: 1,
            window: window,
          );

          expect(
            camera.initialize,
            throwsA(
              isA<CameraException>().having(
                (e) => e.code,
                'code',
                CameraErrorCodes.unknown,
              ),
            ),
          );
        });

        testWidgets(
            'with unknown error '
            'when getUserMedia throws an unknown exception', (tester) async {
          when(() => mediaDevices.getUserMedia(any())).thenThrow(Exception());

          final camera = Camera(
            textureId: 1,
            window: window,
          );

          expect(
            camera.initialize,
            throwsA(
              isA<CameraException>().having(
                (e) => e.code,
                'code',
                CameraErrorCodes.unknown,
              ),
            ),
          );
        });
      });
    });

    group('play', () {
      testWidgets('starts playing the video element', (tester) async {
        var startedPlaying = false;

        final camera = Camera(
          textureId: 1,
          window: window,
        );

        await camera.initialize();

        camera.videoElement.onPlay.listen((event) => startedPlaying = true);

        await camera.play();

        expect(startedPlaying, isTrue);
      });

      testWidgets(
          'assigns media stream to the video element\'s source '
          'if it does not exist', (tester) async {
        final camera = Camera(
          textureId: 1,
          window: window,
        );

        await camera.initialize();

        /// Remove the video element's source
        /// by stopping the camera.
        // ignore: cascade_invocations
        camera.stop();

        await camera.play();

        expect(camera.videoElement.srcObject, mediaStream);
      });
    });

    group('stop', () {
      testWidgets('resets the video element\'s source', (tester) async {
        final camera = Camera(
          textureId: 1,
          window: window,
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
          window: window,
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
          window: window,
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
          window: window,
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
          window: window,
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
          window: window,
        );

        await camera.initialize();

        camera.dispose();

        expect(camera.videoElement.srcObject, isNull);
      });
    });
  });
}
