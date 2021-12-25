// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:html';
import 'dart:ui';

import 'package:async/async.dart';
import 'package:camera_platform_interface/camera_platform_interface.dart';
import 'package:camera_web/src/camera.dart';
import 'package:camera_web/src/camera_service.dart';
import 'package:camera_web/src/types/types.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mocktail/mocktail.dart';

import 'helpers/helpers.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Camera', () {
    const textureId = 1;

    late Window window;
    late Navigator navigator;
    late MediaDevices mediaDevices;

    late MediaStream mediaStream;
    late CameraService cameraService;

    setUp(() {
      window = MockWindow();
      navigator = MockNavigator();
      mediaDevices = MockMediaDevices();

      when(() => window.navigator).thenReturn(navigator);
      when(() => navigator.mediaDevices).thenReturn(mediaDevices);

      cameraService = MockCameraService();

      final videoElement = getVideoElementWithBlankStream(Size(10, 10));
      mediaStream = videoElement.captureStream();

      when(
        () => cameraService.getMediaStreamForOptions(
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
          'calls CameraService.getMediaStreamForOptions '
          'with provided options', (tester) async {
        final options = CameraOptions(
          video: VideoConstraints(
            facingMode: FacingModeConstraint.exact(CameraType.user),
            width: VideoSizeConstraint(ideal: 200),
          ),
        );

        final camera = Camera(
          textureId: textureId,
          options: options,
          cameraService: cameraService,
        );

        await camera.initialize();

        verify(
          () => cameraService.getMediaStreamForOptions(
            options,
            cameraId: textureId,
          ),
        ).called(1);
      });

      testWidgets(
          'creates a video element '
          'with correct properties', (tester) async {
        const audioConstraints = AudioConstraints(enabled: true);
        final videoConstraints = VideoConstraints(
          facingMode: FacingModeConstraint(
            CameraType.user,
          ),
        );

        final camera = Camera(
          textureId: textureId,
          options: CameraOptions(
            audio: audioConstraints,
            video: videoConstraints,
          ),
          cameraService: cameraService,
        );

        await camera.initialize();

        expect(camera.videoElement, isNotNull);
        expect(camera.videoElement.autoplay, isFalse);
        expect(camera.videoElement.muted, isTrue);
        expect(camera.videoElement.srcObject, mediaStream);
        expect(camera.videoElement.attributes.keys, contains('playsinline'));

        expect(
            camera.videoElement.style.transformOrigin, equals('center center'));
        expect(camera.videoElement.style.pointerEvents, equals('none'));
        expect(camera.videoElement.style.width, equals('100%'));
        expect(camera.videoElement.style.height, equals('100%'));
        expect(camera.videoElement.style.objectFit, equals('cover'));
      });

      testWidgets(
          'flips the video element horizontally '
          'for a back camera', (tester) async {
        final videoConstraints = VideoConstraints(
          facingMode: FacingModeConstraint(
            CameraType.environment,
          ),
        );

        final camera = Camera(
          textureId: textureId,
          options: CameraOptions(
            video: videoConstraints,
          ),
          cameraService: cameraService,
        );

        await camera.initialize();

        expect(camera.videoElement.style.transform, equals('scaleX(-1)'));
      });

      testWidgets(
          'creates a wrapping div element '
          'with correct properties', (tester) async {
        final camera = Camera(
          textureId: textureId,
          cameraService: cameraService,
        );

        await camera.initialize();

        expect(camera.divElement, isNotNull);
        expect(camera.divElement.style.objectFit, equals('cover'));
        expect(camera.divElement.children, contains(camera.videoElement));
      });

      testWidgets('initializes the camera stream', (tester) async {
        final camera = Camera(
          textureId: textureId,
          cameraService: cameraService,
        );

        await camera.initialize();

        expect(camera.stream, mediaStream);
      });

      testWidgets(
          'throws an exception '
          'when CameraService.getMediaStreamForOptions throws', (tester) async {
        final exception = Exception('A media stream exception occured.');

        when(() => cameraService.getMediaStreamForOptions(any(),
            cameraId: any(named: 'cameraId'))).thenThrow(exception);

        final camera = Camera(
          textureId: textureId,
          cameraService: cameraService,
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
          textureId: textureId,
          cameraService: cameraService,
        );

        await camera.initialize();

        final cameraPlaySubscription =
            camera.videoElement.onPlay.listen((event) => startedPlaying = true);

        await camera.play();

        expect(startedPlaying, isTrue);

        await cameraPlaySubscription.cancel();
      });

      testWidgets(
          'initializes the camera stream '
          'from CameraService.getMediaStreamForOptions '
          'if it does not exist', (tester) async {
        final options = CameraOptions(
          video: VideoConstraints(
            width: VideoSizeConstraint(ideal: 100),
          ),
        );

        final camera = Camera(
          textureId: textureId,
          options: options,
          cameraService: cameraService,
        );

        await camera.initialize();

        /// Remove the video element's source
        /// by stopping the camera.
        camera.stop();

        await camera.play();

        // Should be called twice: for initialize and play.
        verify(
          () => cameraService.getMediaStreamForOptions(
            options,
            cameraId: textureId,
          ),
        ).called(2);

        expect(camera.videoElement.srcObject, mediaStream);
        expect(camera.stream, mediaStream);
      });
    });

    group('pause', () {
      testWidgets('pauses the camera stream', (tester) async {
        final camera = Camera(
          textureId: textureId,
          cameraService: cameraService,
        );

        await camera.initialize();
        await camera.play();

        expect(camera.videoElement.paused, isFalse);

        camera.pause();

        expect(camera.videoElement.paused, isTrue);
      });
    });

    group('stop', () {
      testWidgets('resets the camera stream', (tester) async {
        final camera = Camera(
          textureId: textureId,
          cameraService: cameraService,
        );

        await camera.initialize();
        await camera.play();

        camera.stop();

        expect(camera.videoElement.srcObject, isNull);
        expect(camera.stream, isNull);
      });
    });

    group('takePicture', () {
      testWidgets('returns a captured picture', (tester) async {
        final camera = Camera(
          textureId: textureId,
          cameraService: cameraService,
        );

        await camera.initialize();
        await camera.play();

        final pictureFile = await camera.takePicture();

        expect(pictureFile, isNotNull);
      });

      group(
          'enables the torch mode '
          'when taking a picture', () {
        late List<MediaStreamTrack> videoTracks;
        late MediaStream videoStream;
        late VideoElement videoElement;

        setUp(() {
          videoTracks = [MockMediaStreamTrack(), MockMediaStreamTrack()];
          videoStream = FakeMediaStream(videoTracks);

          videoElement = getVideoElementWithBlankStream(Size(100, 100))
            ..muted = true;

          when(() => videoTracks.first.applyConstraints(any()))
              .thenAnswer((_) async => {});

          when(videoTracks.first.getCapabilities).thenReturn({
            'torch': true,
          });
        });

        testWidgets('if the flash mode is auto', (tester) async {
          final camera = Camera(
            textureId: textureId,
            cameraService: cameraService,
          )
            ..window = window
            ..stream = videoStream
            ..videoElement = videoElement
            ..flashMode = FlashMode.auto;

          await camera.play();

          final _ = await camera.takePicture();

          verify(
            () => videoTracks.first.applyConstraints({
              "advanced": [
                {
                  "torch": true,
                }
              ]
            }),
          ).called(1);

          verify(
            () => videoTracks.first.applyConstraints({
              "advanced": [
                {
                  "torch": false,
                }
              ]
            }),
          ).called(1);
        });

        testWidgets('if the flash mode is always', (tester) async {
          final camera = Camera(
            textureId: textureId,
            cameraService: cameraService,
          )
            ..window = window
            ..stream = videoStream
            ..videoElement = videoElement
            ..flashMode = FlashMode.always;

          await camera.play();

          final _ = await camera.takePicture();

          verify(
            () => videoTracks.first.applyConstraints({
              "advanced": [
                {
                  "torch": true,
                }
              ]
            }),
          ).called(1);

          verify(
            () => videoTracks.first.applyConstraints({
              "advanced": [
                {
                  "torch": false,
                }
              ]
            }),
          ).called(1);
        });
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
          textureId: textureId,
          cameraService: cameraService,
        );

        await camera.initialize();

        expect(
          camera.getVideoSize(),
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
          textureId: textureId,
          cameraService: cameraService,
        );

        await camera.initialize();

        expect(
          camera.getVideoSize(),
          equals(Size.zero),
        );
      });
    });

    group('setFlashMode', () {
      late List<MediaStreamTrack> videoTracks;
      late MediaStream videoStream;

      setUp(() {
        videoTracks = [MockMediaStreamTrack(), MockMediaStreamTrack()];
        videoStream = FakeMediaStream(videoTracks);

        when(() => videoTracks.first.applyConstraints(any()))
            .thenAnswer((_) async => {});

        when(videoTracks.first.getCapabilities).thenReturn({});
      });

      testWidgets('sets the camera flash mode', (tester) async {
        when(mediaDevices.getSupportedConstraints).thenReturn({
          'torch': true,
        });

        when(videoTracks.first.getCapabilities).thenReturn({
          'torch': true,
        });

        final camera = Camera(
          textureId: textureId,
          cameraService: cameraService,
        )
          ..window = window
          ..stream = videoStream;

        const flashMode = FlashMode.always;

        camera.setFlashMode(flashMode);

        expect(
          camera.flashMode,
          equals(flashMode),
        );
      });

      testWidgets(
          'enables the torch mode '
          'if the flash mode is torch', (tester) async {
        when(mediaDevices.getSupportedConstraints).thenReturn({
          'torch': true,
        });

        when(videoTracks.first.getCapabilities).thenReturn({
          'torch': true,
        });

        final camera = Camera(
          textureId: textureId,
          cameraService: cameraService,
        )
          ..window = window
          ..stream = videoStream;

        camera.setFlashMode(FlashMode.torch);

        verify(
          () => videoTracks.first.applyConstraints({
            "advanced": [
              {
                "torch": true,
              }
            ]
          }),
        ).called(1);
      });

      testWidgets(
          'disables the torch mode '
          'if the flash mode is not torch', (tester) async {
        when(mediaDevices.getSupportedConstraints).thenReturn({
          'torch': true,
        });

        when(videoTracks.first.getCapabilities).thenReturn({
          'torch': true,
        });

        final camera = Camera(
          textureId: textureId,
          cameraService: cameraService,
        )
          ..window = window
          ..stream = videoStream;

        camera.setFlashMode(FlashMode.auto);

        verify(
          () => videoTracks.first.applyConstraints({
            "advanced": [
              {
                "torch": false,
              }
            ]
          }),
        ).called(1);
      });

      group('throws a CameraWebException', () {
        testWidgets(
            'with torchModeNotSupported error '
            'when there are no media devices', (tester) async {
          when(() => navigator.mediaDevices).thenReturn(null);

          final camera = Camera(
            textureId: textureId,
            cameraService: cameraService,
          )
            ..window = window
            ..stream = videoStream;

          expect(
            () => camera.setFlashMode(FlashMode.always),
            throwsA(
              isA<CameraWebException>()
                  .having(
                    (e) => e.cameraId,
                    'cameraId',
                    textureId,
                  )
                  .having(
                    (e) => e.code,
                    'code',
                    CameraErrorCode.torchModeNotSupported,
                  ),
            ),
          );
        });

        testWidgets(
            'with torchModeNotSupported error '
            'when the torch mode is not supported '
            'in the browser', (tester) async {
          when(mediaDevices.getSupportedConstraints).thenReturn({
            'torch': false,
          });

          when(videoTracks.first.getCapabilities).thenReturn({
            'torch': true,
          });

          final camera = Camera(
            textureId: textureId,
            cameraService: cameraService,
          )
            ..window = window
            ..stream = videoStream;

          expect(
            () => camera.setFlashMode(FlashMode.always),
            throwsA(
              isA<CameraWebException>()
                  .having(
                    (e) => e.cameraId,
                    'cameraId',
                    textureId,
                  )
                  .having(
                    (e) => e.code,
                    'code',
                    CameraErrorCode.torchModeNotSupported,
                  ),
            ),
          );
        });

        testWidgets(
            'with torchModeNotSupported error '
            'when the torch mode is not supported '
            'by the camera', (tester) async {
          when(mediaDevices.getSupportedConstraints).thenReturn({
            'torch': true,
          });

          when(videoTracks.first.getCapabilities).thenReturn({
            'torch': false,
          });

          final camera = Camera(
            textureId: textureId,
            cameraService: cameraService,
          )
            ..window = window
            ..stream = videoStream;

          expect(
            () => camera.setFlashMode(FlashMode.always),
            throwsA(
              isA<CameraWebException>()
                  .having(
                    (e) => e.cameraId,
                    'cameraId',
                    textureId,
                  )
                  .having(
                    (e) => e.code,
                    'code',
                    CameraErrorCode.torchModeNotSupported,
                  ),
            ),
          );
        });

        testWidgets(
            'with notStarted error '
            'when the camera stream has not been initialized', (tester) async {
          when(mediaDevices.getSupportedConstraints).thenReturn({
            'torch': true,
          });

          when(videoTracks.first.getCapabilities).thenReturn({
            'torch': true,
          });

          final camera = Camera(
            textureId: textureId,
            cameraService: cameraService,
          )..window = window;

          expect(
            () => camera.setFlashMode(FlashMode.always),
            throwsA(
              isA<CameraWebException>()
                  .having(
                    (e) => e.cameraId,
                    'cameraId',
                    textureId,
                  )
                  .having(
                    (e) => e.code,
                    'code',
                    CameraErrorCode.notStarted,
                  ),
            ),
          );
        });
      });
    });

    group('zoomLevel', () {
      group('getMaxZoomLevel', () {
        testWidgets(
            'returns maximum '
            'from CameraService.getZoomLevelCapabilityForCamera',
            (tester) async {
          final camera = Camera(
            textureId: textureId,
            cameraService: cameraService,
          );

          final zoomLevelCapability = ZoomLevelCapability(
            minimum: 50.0,
            maximum: 100.0,
            videoTrack: MockMediaStreamTrack(),
          );

          when(() => cameraService.getZoomLevelCapabilityForCamera(camera))
              .thenReturn(zoomLevelCapability);

          final maximumZoomLevel = camera.getMaxZoomLevel();

          verify(() => cameraService.getZoomLevelCapabilityForCamera(camera))
              .called(1);

          expect(
            maximumZoomLevel,
            equals(zoomLevelCapability.maximum),
          );
        });
      });

      group('getMinZoomLevel', () {
        testWidgets(
            'returns minimum '
            'from CameraService.getZoomLevelCapabilityForCamera',
            (tester) async {
          final camera = Camera(
            textureId: textureId,
            cameraService: cameraService,
          );

          final zoomLevelCapability = ZoomLevelCapability(
            minimum: 50.0,
            maximum: 100.0,
            videoTrack: MockMediaStreamTrack(),
          );

          when(() => cameraService.getZoomLevelCapabilityForCamera(camera))
              .thenReturn(zoomLevelCapability);

          final minimumZoomLevel = camera.getMinZoomLevel();

          verify(() => cameraService.getZoomLevelCapabilityForCamera(camera))
              .called(1);

          expect(
            minimumZoomLevel,
            equals(zoomLevelCapability.minimum),
          );
        });
      });

      group('setZoomLevel', () {
        testWidgets(
            'applies zoom on the video track '
            'from CameraService.getZoomLevelCapabilityForCamera',
            (tester) async {
          final camera = Camera(
            textureId: textureId,
            cameraService: cameraService,
          );

          final videoTrack = MockMediaStreamTrack();

          final zoomLevelCapability = ZoomLevelCapability(
            minimum: 50.0,
            maximum: 100.0,
            videoTrack: videoTrack,
          );

          when(() => videoTrack.applyConstraints(any()))
              .thenAnswer((_) async {});

          when(() => cameraService.getZoomLevelCapabilityForCamera(camera))
              .thenReturn(zoomLevelCapability);

          const zoom = 75.0;

          camera.setZoomLevel(zoom);

          verify(
            () => videoTrack.applyConstraints({
              "advanced": [
                {
                  ZoomLevelCapability.constraintName: zoom,
                }
              ]
            }),
          ).called(1);
        });

        group('throws a CameraWebException', () {
          testWidgets(
              'with zoomLevelInvalid error '
              'when the provided zoom level is below minimum', (tester) async {
            final camera = Camera(
              textureId: textureId,
              cameraService: cameraService,
            );

            final zoomLevelCapability = ZoomLevelCapability(
              minimum: 50.0,
              maximum: 100.0,
              videoTrack: MockMediaStreamTrack(),
            );

            when(() => cameraService.getZoomLevelCapabilityForCamera(camera))
                .thenReturn(zoomLevelCapability);

            expect(
                () => camera.setZoomLevel(45.0),
                throwsA(
                  isA<CameraWebException>()
                      .having(
                        (e) => e.cameraId,
                        'cameraId',
                        textureId,
                      )
                      .having(
                        (e) => e.code,
                        'code',
                        CameraErrorCode.zoomLevelInvalid,
                      ),
                ));
          });

          testWidgets(
              'with zoomLevelInvalid error '
              'when the provided zoom level is below minimum', (tester) async {
            final camera = Camera(
              textureId: textureId,
              cameraService: cameraService,
            );

            final zoomLevelCapability = ZoomLevelCapability(
              minimum: 50.0,
              maximum: 100.0,
              videoTrack: MockMediaStreamTrack(),
            );

            when(() => cameraService.getZoomLevelCapabilityForCamera(camera))
                .thenReturn(zoomLevelCapability);

            expect(
              () => camera.setZoomLevel(105.0),
              throwsA(
                isA<CameraWebException>()
                    .having(
                      (e) => e.cameraId,
                      'cameraId',
                      textureId,
                    )
                    .having(
                      (e) => e.code,
                      'code',
                      CameraErrorCode.zoomLevelInvalid,
                    ),
              ),
            );
          });
        });
      });
    });

    group('getLensDirection', () {
      testWidgets(
          'returns a lens direction '
          'based on the first video track settings', (tester) async {
        final videoElement = MockVideoElement();

        final camera = Camera(
          textureId: textureId,
          cameraService: cameraService,
        )..videoElement = videoElement;

        final firstVideoTrack = MockMediaStreamTrack();

        when(() => videoElement.srcObject).thenReturn(
          FakeMediaStream([
            firstVideoTrack,
            MockMediaStreamTrack(),
          ]),
        );

        when(firstVideoTrack.getSettings)
            .thenReturn({'facingMode': 'environment'});

        when(() => cameraService.mapFacingModeToLensDirection('environment'))
            .thenReturn(CameraLensDirection.external);

        expect(
          camera.getLensDirection(),
          equals(CameraLensDirection.external),
        );
      });

      testWidgets(
          'returns null '
          'if the first video track is missing the facing mode',
          (tester) async {
        final videoElement = MockVideoElement();

        final camera = Camera(
          textureId: textureId,
          cameraService: cameraService,
        )..videoElement = videoElement;

        final firstVideoTrack = MockMediaStreamTrack();

        when(() => videoElement.srcObject).thenReturn(
          FakeMediaStream([
            firstVideoTrack,
            MockMediaStreamTrack(),
          ]),
        );

        when(firstVideoTrack.getSettings).thenReturn({});

        expect(
          camera.getLensDirection(),
          isNull,
        );
      });

      testWidgets(
          'returns null '
          'if the camera is missing video tracks', (tester) async {
        // Create a video stream with no video tracks.
        final videoElement = VideoElement();
        mediaStream = videoElement.captureStream();

        final camera = Camera(
          textureId: textureId,
          cameraService: cameraService,
        );

        await camera.initialize();

        expect(
          camera.getLensDirection(),
          isNull,
        );
      });
    });

    group('getViewType', () {
      testWidgets('returns a correct view type', (tester) async {
        final camera = Camera(
          textureId: textureId,
          cameraService: cameraService,
        );

        await camera.initialize();

        expect(
          camera.getViewType(),
          equals('plugins.flutter.io/camera_$textureId'),
        );
      });
    });

    group('video recording', () {
      const supportedVideoType = 'video/webm';

      late MediaRecorder mediaRecorder;

      bool isVideoTypeSupported(String type) => type == supportedVideoType;

      setUp(() {
        mediaRecorder = MockMediaRecorder();

        when(() => mediaRecorder.onError)
            .thenAnswer((_) => const Stream.empty());
      });

      group('startVideoRecording', () {
        testWidgets(
            'creates a media recorder '
            'with appropriate options', (tester) async {
          final camera = Camera(
            textureId: 1,
            cameraService: cameraService,
          )..isVideoTypeSupported = isVideoTypeSupported;

          await camera.initialize();
          await camera.play();

          await camera.startVideoRecording();

          expect(
            camera.mediaRecorder!.stream,
            equals(camera.stream),
          );

          expect(
            camera.mediaRecorder!.mimeType,
            equals(supportedVideoType),
          );

          expect(
            camera.mediaRecorder!.state,
            equals('recording'),
          );
        });

        testWidgets('listens to the media recorder data events',
            (tester) async {
          final camera = Camera(
            textureId: 1,
            cameraService: cameraService,
          )
            ..mediaRecorder = mediaRecorder
            ..isVideoTypeSupported = isVideoTypeSupported;

          await camera.initialize();
          await camera.play();

          await camera.startVideoRecording();

          verify(
            () => mediaRecorder.addEventListener('dataavailable', any()),
          ).called(1);
        });

        testWidgets('listens to the media recorder stop events',
            (tester) async {
          final camera = Camera(
            textureId: 1,
            cameraService: cameraService,
          )
            ..mediaRecorder = mediaRecorder
            ..isVideoTypeSupported = isVideoTypeSupported;

          await camera.initialize();
          await camera.play();

          await camera.startVideoRecording();

          verify(
            () => mediaRecorder.addEventListener('stop', any()),
          ).called(1);
        });

        testWidgets('starts a video recording', (tester) async {
          final camera = Camera(
            textureId: 1,
            cameraService: cameraService,
          )
            ..mediaRecorder = mediaRecorder
            ..isVideoTypeSupported = isVideoTypeSupported;

          await camera.initialize();
          await camera.play();

          await camera.startVideoRecording();

          verify(mediaRecorder.start).called(1);
        });

        testWidgets(
            'starts a video recording '
            'with maxVideoDuration', (tester) async {
          const maxVideoDuration = Duration(hours: 1);

          final camera = Camera(
            textureId: 1,
            cameraService: cameraService,
          )
            ..mediaRecorder = mediaRecorder
            ..isVideoTypeSupported = isVideoTypeSupported;

          await camera.initialize();
          await camera.play();

          await camera.startVideoRecording(maxVideoDuration: maxVideoDuration);

          verify(() => mediaRecorder.start(maxVideoDuration.inMilliseconds))
              .called(1);
        });

        group('throws a CameraWebException', () {
          testWidgets(
              'with notSupported error '
              'when maxVideoDuration is 0 milliseconds or less',
              (tester) async {
            final camera = Camera(
              textureId: 1,
              cameraService: cameraService,
            )
              ..mediaRecorder = mediaRecorder
              ..isVideoTypeSupported = isVideoTypeSupported;

            await camera.initialize();
            await camera.play();

            expect(
              () => camera.startVideoRecording(maxVideoDuration: Duration.zero),
              throwsA(
                isA<CameraWebException>()
                    .having(
                      (e) => e.cameraId,
                      'cameraId',
                      textureId,
                    )
                    .having(
                      (e) => e.code,
                      'code',
                      CameraErrorCode.notSupported,
                    ),
              ),
            );
          });

          testWidgets(
              'with notSupported error '
              'when no video types are supported', (tester) async {
            final camera = Camera(
              textureId: 1,
              cameraService: cameraService,
            )..isVideoTypeSupported = (type) => false;

            await camera.initialize();
            await camera.play();

            expect(
              camera.startVideoRecording,
              throwsA(
                isA<CameraWebException>()
                    .having(
                      (e) => e.cameraId,
                      'cameraId',
                      textureId,
                    )
                    .having(
                      (e) => e.code,
                      'code',
                      CameraErrorCode.notSupported,
                    ),
              ),
            );
          });
        });
      });

      group('pauseVideoRecording', () {
        testWidgets('pauses a video recording', (tester) async {
          final camera = Camera(
            textureId: 1,
            cameraService: cameraService,
          )..mediaRecorder = mediaRecorder;

          await camera.pauseVideoRecording();

          verify(mediaRecorder.pause).called(1);
        });

        testWidgets(
            'throws a CameraWebException '
            'with videoRecordingNotStarted error '
            'if the video recording was not started', (tester) async {
          final camera = Camera(
            textureId: 1,
            cameraService: cameraService,
          );

          expect(
            camera.pauseVideoRecording,
            throwsA(
              isA<CameraWebException>()
                  .having(
                    (e) => e.cameraId,
                    'cameraId',
                    textureId,
                  )
                  .having(
                    (e) => e.code,
                    'code',
                    CameraErrorCode.videoRecordingNotStarted,
                  ),
            ),
          );
        });
      });

      group('resumeVideoRecording', () {
        testWidgets('resumes a video recording', (tester) async {
          final camera = Camera(
            textureId: 1,
            cameraService: cameraService,
          )..mediaRecorder = mediaRecorder;

          await camera.resumeVideoRecording();

          verify(mediaRecorder.resume).called(1);
        });

        testWidgets(
            'throws a CameraWebException '
            'with videoRecordingNotStarted error '
            'if the video recording was not started', (tester) async {
          final camera = Camera(
            textureId: 1,
            cameraService: cameraService,
          );

          expect(
            camera.resumeVideoRecording,
            throwsA(
              isA<CameraWebException>()
                  .having(
                    (e) => e.cameraId,
                    'cameraId',
                    textureId,
                  )
                  .having(
                    (e) => e.code,
                    'code',
                    CameraErrorCode.videoRecordingNotStarted,
                  ),
            ),
          );
        });
      });

      group('stopVideoRecording', () {
        testWidgets(
            'stops a video recording and '
            'returns the captured file '
            'based on all video data parts', (tester) async {
          final camera = Camera(
            textureId: 1,
            cameraService: cameraService,
          )
            ..mediaRecorder = mediaRecorder
            ..isVideoTypeSupported = isVideoTypeSupported;

          await camera.initialize();
          await camera.play();

          late void Function(Event) videoDataAvailableListener;
          late void Function(Event) videoRecordingStoppedListener;

          when(
            () => mediaRecorder.addEventListener('dataavailable', any()),
          ).thenAnswer((invocation) {
            videoDataAvailableListener = invocation.positionalArguments[1];
          });

          when(
            () => mediaRecorder.addEventListener('stop', any()),
          ).thenAnswer((invocation) {
            videoRecordingStoppedListener = invocation.positionalArguments[1];
          });

          Blob? finalVideo;
          List<Blob>? videoParts;
          camera.blobBuilder = (blobs, videoType) {
            videoParts = [...blobs];
            finalVideo = Blob(blobs, videoType);
            return finalVideo!;
          };

          await camera.startVideoRecording();
          final videoFileFuture = camera.stopVideoRecording();

          final capturedVideoPartOne = Blob([]);
          final capturedVideoPartTwo = Blob([]);

          final capturedVideoParts = [
            capturedVideoPartOne,
            capturedVideoPartTwo,
          ];

          videoDataAvailableListener
            ..call(FakeBlobEvent(capturedVideoPartOne))
            ..call(FakeBlobEvent(capturedVideoPartTwo));

          videoRecordingStoppedListener.call(Event('stop'));

          final videoFile = await videoFileFuture;

          verify(mediaRecorder.stop).called(1);

          expect(
            videoFile,
            isNotNull,
          );

          expect(
            videoFile.mimeType,
            equals(supportedVideoType),
          );

          expect(
            videoFile.name,
            equals(finalVideo.hashCode.toString()),
          );

          expect(
            videoParts,
            equals(capturedVideoParts),
          );
        });

        testWidgets(
            'throws a CameraWebException '
            'with videoRecordingNotStarted error '
            'if the video recording was not started', (tester) async {
          final camera = Camera(
            textureId: 1,
            cameraService: cameraService,
          );

          expect(
            camera.stopVideoRecording,
            throwsA(
              isA<CameraWebException>()
                  .having(
                    (e) => e.cameraId,
                    'cameraId',
                    textureId,
                  )
                  .having(
                    (e) => e.code,
                    'code',
                    CameraErrorCode.videoRecordingNotStarted,
                  ),
            ),
          );
        });
      });

      group('on video data available', () {
        late void Function(Event) videoDataAvailableListener;

        setUp(() {
          when(
            () => mediaRecorder.addEventListener('dataavailable', any()),
          ).thenAnswer((invocation) {
            videoDataAvailableListener = invocation.positionalArguments[1];
          });
        });

        testWidgets(
            'stops a video recording '
            'if maxVideoDuration is given and '
            'the recording was not stopped manually', (tester) async {
          const maxVideoDuration = Duration(hours: 1);

          final camera = Camera(
            textureId: 1,
            cameraService: cameraService,
          )
            ..mediaRecorder = mediaRecorder
            ..isVideoTypeSupported = isVideoTypeSupported;

          await camera.initialize();
          await camera.play();
          await camera.startVideoRecording(maxVideoDuration: maxVideoDuration);

          when(() => mediaRecorder.state).thenReturn('recording');

          videoDataAvailableListener.call(FakeBlobEvent(Blob([])));

          await Future.microtask(() {});

          verify(mediaRecorder.stop).called(1);
        });
      });

      group('on video recording stopped', () {
        late void Function(Event) videoRecordingStoppedListener;

        setUp(() {
          when(
            () => mediaRecorder.addEventListener('stop', any()),
          ).thenAnswer((invocation) {
            videoRecordingStoppedListener = invocation.positionalArguments[1];
          });
        });

        testWidgets('stops listening to the media recorder data events',
            (tester) async {
          final camera = Camera(
            textureId: 1,
            cameraService: cameraService,
          )
            ..mediaRecorder = mediaRecorder
            ..isVideoTypeSupported = isVideoTypeSupported;

          await camera.initialize();
          await camera.play();

          await camera.startVideoRecording();

          videoRecordingStoppedListener.call(Event('stop'));

          await Future.microtask(() {});

          verify(
            () => mediaRecorder.removeEventListener('dataavailable', any()),
          ).called(1);
        });

        testWidgets('stops listening to the media recorder stop events',
            (tester) async {
          final camera = Camera(
            textureId: 1,
            cameraService: cameraService,
          )
            ..mediaRecorder = mediaRecorder
            ..isVideoTypeSupported = isVideoTypeSupported;

          await camera.initialize();
          await camera.play();

          await camera.startVideoRecording();

          videoRecordingStoppedListener.call(Event('stop'));

          await Future.microtask(() {});

          verify(
            () => mediaRecorder.removeEventListener('stop', any()),
          ).called(1);
        });

        testWidgets('stops listening to the media recorder errors',
            (tester) async {
          final onErrorStreamController = StreamController<ErrorEvent>();

          final camera = Camera(
            textureId: 1,
            cameraService: cameraService,
          )
            ..mediaRecorder = mediaRecorder
            ..isVideoTypeSupported = isVideoTypeSupported;

          when(() => mediaRecorder.onError)
              .thenAnswer((_) => onErrorStreamController.stream);

          await camera.initialize();
          await camera.play();

          await camera.startVideoRecording();

          videoRecordingStoppedListener.call(Event('stop'));

          await Future.microtask(() {});

          expect(
            onErrorStreamController.hasListener,
            isFalse,
          );
        });
      });
    });

    group('dispose', () {
      testWidgets('resets the video element\'s source', (tester) async {
        final camera = Camera(
          textureId: textureId,
          cameraService: cameraService,
        );

        await camera.initialize();
        await camera.dispose();

        expect(camera.videoElement.srcObject, isNull);
      });

      testWidgets('closes the onEnded stream', (tester) async {
        final camera = Camera(
          textureId: textureId,
          cameraService: cameraService,
        );

        await camera.initialize();
        await camera.dispose();

        expect(
          camera.onEndedController.isClosed,
          isTrue,
        );
      });

      testWidgets('closes the onVideoRecordedEvent stream', (tester) async {
        final camera = Camera(
          textureId: textureId,
          cameraService: cameraService,
        );

        await camera.initialize();
        await camera.dispose();

        expect(
          camera.videoRecorderController.isClosed,
          isTrue,
        );
      });

      testWidgets('closes the onVideoRecordingError stream', (tester) async {
        final camera = Camera(
          textureId: textureId,
          cameraService: cameraService,
        );

        await camera.initialize();
        await camera.dispose();

        expect(
          camera.videoRecordingErrorController.isClosed,
          isTrue,
        );
      });
    });

    group('events', () {
      group('onVideoRecordedEvent', () {
        testWidgets(
            'emits a VideoRecordedEvent '
            'when a video recording is created', (tester) async {
          const maxVideoDuration = Duration(hours: 1);
          const supportedVideoType = 'video/webm';

          final mediaRecorder = MockMediaRecorder();
          when(() => mediaRecorder.onError)
              .thenAnswer((_) => const Stream.empty());

          final camera = Camera(
            textureId: 1,
            cameraService: cameraService,
          )
            ..mediaRecorder = mediaRecorder
            ..isVideoTypeSupported = (type) => type == 'video/webm';

          await camera.initialize();
          await camera.play();

          late void Function(Event) videoDataAvailableListener;
          late void Function(Event) videoRecordingStoppedListener;

          when(
            () => mediaRecorder.addEventListener('dataavailable', any()),
          ).thenAnswer((invocation) {
            videoDataAvailableListener = invocation.positionalArguments[1];
          });

          when(
            () => mediaRecorder.addEventListener('stop', any()),
          ).thenAnswer((invocation) {
            videoRecordingStoppedListener = invocation.positionalArguments[1];
          });

          final streamQueue = StreamQueue(camera.onVideoRecordedEvent);

          await camera.startVideoRecording(maxVideoDuration: maxVideoDuration);

          Blob? finalVideo;
          camera.blobBuilder = (blobs, videoType) {
            finalVideo = Blob(blobs, videoType);
            return finalVideo!;
          };

          videoDataAvailableListener.call(FakeBlobEvent(Blob([])));
          videoRecordingStoppedListener.call(Event('stop'));

          expect(
            await streamQueue.next,
            equals(
              isA<VideoRecordedEvent>()
                  .having(
                    (e) => e.cameraId,
                    'cameraId',
                    textureId,
                  )
                  .having(
                    (e) => e.file,
                    'file',
                    isA<XFile>()
                        .having(
                          (f) => f.mimeType,
                          'mimeType',
                          supportedVideoType,
                        )
                        .having(
                          (f) => f.name,
                          'name',
                          finalVideo.hashCode.toString(),
                        ),
                  )
                  .having(
                    (e) => e.maxVideoDuration,
                    'maxVideoDuration',
                    maxVideoDuration,
                  ),
            ),
          );

          await streamQueue.cancel();
        });
      });

      group('onEnded', () {
        testWidgets(
            'emits the default video track '
            'when it emits an ended event', (tester) async {
          final camera = Camera(
            textureId: textureId,
            cameraService: cameraService,
          );

          final streamQueue = StreamQueue(camera.onEnded);

          await camera.initialize();

          final videoTracks = camera.stream!.getVideoTracks();
          final defaultVideoTrack = videoTracks.first;

          defaultVideoTrack.dispatchEvent(Event('ended'));

          expect(
            await streamQueue.next,
            equals(defaultVideoTrack),
          );

          await streamQueue.cancel();
        });

        testWidgets(
            'emits the default video track '
            'when the camera is stopped', (tester) async {
          final camera = Camera(
            textureId: textureId,
            cameraService: cameraService,
          );

          final streamQueue = StreamQueue(camera.onEnded);

          await camera.initialize();

          final videoTracks = camera.stream!.getVideoTracks();
          final defaultVideoTrack = videoTracks.first;

          camera.stop();

          expect(
            await streamQueue.next,
            equals(defaultVideoTrack),
          );

          await streamQueue.cancel();
        });
      });

      group('onVideoRecordingError', () {
        testWidgets(
            'emits an ErrorEvent '
            'when the media recorder fails '
            'when recording a video', (tester) async {
          final mediaRecorder = MockMediaRecorder();
          final errorController = StreamController<ErrorEvent>();

          final camera = Camera(
            textureId: textureId,
            cameraService: cameraService,
          )..mediaRecorder = mediaRecorder;

          when(() => mediaRecorder.onError)
              .thenAnswer((_) => errorController.stream);

          final streamQueue = StreamQueue(camera.onVideoRecordingError);

          await camera.initialize();
          await camera.play();

          await camera.startVideoRecording();

          final errorEvent = ErrorEvent('type');
          errorController.add(errorEvent);

          expect(
            await streamQueue.next,
            equals(errorEvent),
          );

          await streamQueue.cancel();
        });
      });
    });
  });
}
