// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:html';
import 'dart:ui';
import 'dart:js_util' as js_util;

import 'package:camera_platform_interface/camera_platform_interface.dart';
import 'package:camera_web/src/camera.dart';
import 'package:camera_web/src/camera_service.dart';
import 'package:camera_web/src/shims/dart_js_util.dart';
import 'package:camera_web/src/types/types.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mocktail/mocktail.dart';

import 'helpers/helpers.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('CameraService', () {
    const cameraId = 0;

    late Window window;
    late Navigator navigator;
    late MediaDevices mediaDevices;
    late CameraService cameraService;
    late JsUtil jsUtil;

    setUp(() async {
      window = MockWindow();
      navigator = MockNavigator();
      mediaDevices = MockMediaDevices();
      jsUtil = MockJsUtil();

      when(() => window.navigator).thenReturn(navigator);
      when(() => navigator.mediaDevices).thenReturn(mediaDevices);

      // Mock JsUtil to return the real getProperty from dart:js_util.
      when(() => jsUtil.getProperty(any(), any())).thenAnswer(
        (invocation) => js_util.getProperty(
          invocation.positionalArguments[0],
          invocation.positionalArguments[1],
        ),
      );

      cameraService = CameraService()..window = window;
    });

    group('getMediaStreamForOptions', () {
      testWidgets(
          'calls MediaDevices.getUserMedia '
          'with provided options', (tester) async {
        when(() => mediaDevices.getUserMedia(any()))
            .thenAnswer((_) async => FakeMediaStream([]));

        final options = CameraOptions(
          video: VideoConstraints(
            facingMode: FacingModeConstraint.exact(CameraType.user),
            width: VideoSizeConstraint(ideal: 200),
          ),
        );

        await cameraService.getMediaStreamForOptions(options);

        verify(
          () => mediaDevices.getUserMedia(options.toJson()),
        ).called(1);
      });

      testWidgets(
          'throws PlatformException '
          'with notSupported error '
          'when there are no media devices', (tester) async {
        when(() => navigator.mediaDevices).thenReturn(null);

        expect(
          () => cameraService.getMediaStreamForOptions(CameraOptions()),
          throwsA(
            isA<PlatformException>().having(
              (e) => e.code,
              'code',
              CameraErrorCode.notSupported.toString(),
            ),
          ),
        );
      });

      group('throws CameraWebException', () {
        testWidgets(
            'with notFound error '
            'when MediaDevices.getUserMedia throws DomException '
            'with NotFoundError', (tester) async {
          when(() => mediaDevices.getUserMedia(any()))
              .thenThrow(FakeDomException('NotFoundError'));

          expect(
            () => cameraService.getMediaStreamForOptions(
              CameraOptions(),
              cameraId: cameraId,
            ),
            throwsA(
              isA<CameraWebException>()
                  .having((e) => e.cameraId, 'cameraId', cameraId)
                  .having((e) => e.code, 'code', CameraErrorCode.notFound),
            ),
          );
        });

        testWidgets(
            'with notFound error '
            'when MediaDevices.getUserMedia throws DomException '
            'with DevicesNotFoundError', (tester) async {
          when(() => mediaDevices.getUserMedia(any()))
              .thenThrow(FakeDomException('DevicesNotFoundError'));

          expect(
            () => cameraService.getMediaStreamForOptions(
              CameraOptions(),
              cameraId: cameraId,
            ),
            throwsA(
              isA<CameraWebException>()
                  .having((e) => e.cameraId, 'cameraId', cameraId)
                  .having((e) => e.code, 'code', CameraErrorCode.notFound),
            ),
          );
        });

        testWidgets(
            'with notReadable error '
            'when MediaDevices.getUserMedia throws DomException '
            'with NotReadableError', (tester) async {
          when(() => mediaDevices.getUserMedia(any()))
              .thenThrow(FakeDomException('NotReadableError'));

          expect(
            () => cameraService.getMediaStreamForOptions(
              CameraOptions(),
              cameraId: cameraId,
            ),
            throwsA(
              isA<CameraWebException>()
                  .having((e) => e.cameraId, 'cameraId', cameraId)
                  .having((e) => e.code, 'code', CameraErrorCode.notReadable),
            ),
          );
        });

        testWidgets(
            'with notReadable error '
            'when MediaDevices.getUserMedia throws DomException '
            'with TrackStartError', (tester) async {
          when(() => mediaDevices.getUserMedia(any()))
              .thenThrow(FakeDomException('TrackStartError'));

          expect(
            () => cameraService.getMediaStreamForOptions(
              CameraOptions(),
              cameraId: cameraId,
            ),
            throwsA(
              isA<CameraWebException>()
                  .having((e) => e.cameraId, 'cameraId', cameraId)
                  .having((e) => e.code, 'code', CameraErrorCode.notReadable),
            ),
          );
        });

        testWidgets(
            'with overconstrained error '
            'when MediaDevices.getUserMedia throws DomException '
            'with OverconstrainedError', (tester) async {
          when(() => mediaDevices.getUserMedia(any()))
              .thenThrow(FakeDomException('OverconstrainedError'));

          expect(
            () => cameraService.getMediaStreamForOptions(
              CameraOptions(),
              cameraId: cameraId,
            ),
            throwsA(
              isA<CameraWebException>()
                  .having((e) => e.cameraId, 'cameraId', cameraId)
                  .having(
                      (e) => e.code, 'code', CameraErrorCode.overconstrained),
            ),
          );
        });

        testWidgets(
            'with overconstrained error '
            'when MediaDevices.getUserMedia throws DomException '
            'with ConstraintNotSatisfiedError', (tester) async {
          when(() => mediaDevices.getUserMedia(any()))
              .thenThrow(FakeDomException('ConstraintNotSatisfiedError'));

          expect(
            () => cameraService.getMediaStreamForOptions(
              CameraOptions(),
              cameraId: cameraId,
            ),
            throwsA(
              isA<CameraWebException>()
                  .having((e) => e.cameraId, 'cameraId', cameraId)
                  .having(
                      (e) => e.code, 'code', CameraErrorCode.overconstrained),
            ),
          );
        });

        testWidgets(
            'with permissionDenied error '
            'when MediaDevices.getUserMedia throws DomException '
            'with NotAllowedError', (tester) async {
          when(() => mediaDevices.getUserMedia(any()))
              .thenThrow(FakeDomException('NotAllowedError'));

          expect(
            () => cameraService.getMediaStreamForOptions(
              CameraOptions(),
              cameraId: cameraId,
            ),
            throwsA(
              isA<CameraWebException>()
                  .having((e) => e.cameraId, 'cameraId', cameraId)
                  .having(
                      (e) => e.code, 'code', CameraErrorCode.permissionDenied),
            ),
          );
        });

        testWidgets(
            'with permissionDenied error '
            'when MediaDevices.getUserMedia throws DomException '
            'with PermissionDeniedError', (tester) async {
          when(() => mediaDevices.getUserMedia(any()))
              .thenThrow(FakeDomException('PermissionDeniedError'));

          expect(
            () => cameraService.getMediaStreamForOptions(
              CameraOptions(),
              cameraId: cameraId,
            ),
            throwsA(
              isA<CameraWebException>()
                  .having((e) => e.cameraId, 'cameraId', cameraId)
                  .having(
                      (e) => e.code, 'code', CameraErrorCode.permissionDenied),
            ),
          );
        });

        testWidgets(
            'with type error '
            'when MediaDevices.getUserMedia throws DomException '
            'with TypeError', (tester) async {
          when(() => mediaDevices.getUserMedia(any()))
              .thenThrow(FakeDomException('TypeError'));

          expect(
            () => cameraService.getMediaStreamForOptions(
              CameraOptions(),
              cameraId: cameraId,
            ),
            throwsA(
              isA<CameraWebException>()
                  .having((e) => e.cameraId, 'cameraId', cameraId)
                  .having((e) => e.code, 'code', CameraErrorCode.type),
            ),
          );
        });

        testWidgets(
            'with abort error '
            'when MediaDevices.getUserMedia throws DomException '
            'with AbortError', (tester) async {
          when(() => mediaDevices.getUserMedia(any()))
              .thenThrow(FakeDomException('AbortError'));

          expect(
            () => cameraService.getMediaStreamForOptions(
              CameraOptions(),
              cameraId: cameraId,
            ),
            throwsA(
              isA<CameraWebException>()
                  .having((e) => e.cameraId, 'cameraId', cameraId)
                  .having((e) => e.code, 'code', CameraErrorCode.abort),
            ),
          );
        });

        testWidgets(
            'with security error '
            'when MediaDevices.getUserMedia throws DomException '
            'with SecurityError', (tester) async {
          when(() => mediaDevices.getUserMedia(any()))
              .thenThrow(FakeDomException('SecurityError'));

          expect(
            () => cameraService.getMediaStreamForOptions(
              CameraOptions(),
              cameraId: cameraId,
            ),
            throwsA(
              isA<CameraWebException>()
                  .having((e) => e.cameraId, 'cameraId', cameraId)
                  .having((e) => e.code, 'code', CameraErrorCode.security),
            ),
          );
        });

        testWidgets(
            'with unknown error '
            'when MediaDevices.getUserMedia throws DomException '
            'with an unknown error', (tester) async {
          when(() => mediaDevices.getUserMedia(any()))
              .thenThrow(FakeDomException('Unknown'));

          expect(
            () => cameraService.getMediaStreamForOptions(
              CameraOptions(),
              cameraId: cameraId,
            ),
            throwsA(
              isA<CameraWebException>()
                  .having((e) => e.cameraId, 'cameraId', cameraId)
                  .having((e) => e.code, 'code', CameraErrorCode.unknown),
            ),
          );
        });

        testWidgets(
            'with unknown error '
            'when MediaDevices.getUserMedia throws an unknown exception',
            (tester) async {
          when(() => mediaDevices.getUserMedia(any())).thenThrow(Exception());

          expect(
            () => cameraService.getMediaStreamForOptions(
              CameraOptions(),
              cameraId: cameraId,
            ),
            throwsA(
              isA<CameraWebException>()
                  .having((e) => e.cameraId, 'cameraId', cameraId)
                  .having((e) => e.code, 'code', CameraErrorCode.unknown),
            ),
          );
        });
      });
    });

    group('getZoomLevelCapabilityForCamera', () {
      late Camera camera;
      late List<MediaStreamTrack> videoTracks;

      setUp(() {
        camera = MockCamera();
        videoTracks = [MockMediaStreamTrack(), MockMediaStreamTrack()];

        when(() => camera.textureId).thenReturn(0);
        when(() => camera.stream).thenReturn(FakeMediaStream(videoTracks));

        cameraService.jsUtil = jsUtil;
      });

      testWidgets(
          'returns the zoom level capability '
          'based on the first video track', (tester) async {
        when(mediaDevices.getSupportedConstraints).thenReturn({
          'zoom': true,
        });

        when(videoTracks.first.getCapabilities).thenReturn({
          'zoom': js_util.jsify({
            'min': 100,
            'max': 400,
            'step': 2,
          }),
        });

        final zoomLevelCapability =
            cameraService.getZoomLevelCapabilityForCamera(camera);

        expect(zoomLevelCapability.minimum, equals(100.0));
        expect(zoomLevelCapability.maximum, equals(400.0));
        expect(zoomLevelCapability.videoTrack, equals(videoTracks.first));
      });

      group('throws CameraWebException', () {
        testWidgets(
            'with zoomLevelNotSupported error '
            'when there are no media devices', (tester) async {
          when(() => navigator.mediaDevices).thenReturn(null);

          expect(
            () => cameraService.getZoomLevelCapabilityForCamera(camera),
            throwsA(
              isA<CameraWebException>()
                  .having(
                    (e) => e.cameraId,
                    'cameraId',
                    camera.textureId,
                  )
                  .having(
                    (e) => e.code,
                    'code',
                    CameraErrorCode.zoomLevelNotSupported,
                  ),
            ),
          );
        });

        testWidgets(
            'with zoomLevelNotSupported error '
            'when the zoom level is not supported '
            'in the browser', (tester) async {
          when(mediaDevices.getSupportedConstraints).thenReturn({
            'zoom': false,
          });

          when(videoTracks.first.getCapabilities).thenReturn({
            'zoom': {
              'min': 100,
              'max': 400,
              'step': 2,
            },
          });

          expect(
            () => cameraService.getZoomLevelCapabilityForCamera(camera),
            throwsA(
              isA<CameraWebException>()
                  .having(
                    (e) => e.cameraId,
                    'cameraId',
                    camera.textureId,
                  )
                  .having(
                    (e) => e.code,
                    'code',
                    CameraErrorCode.zoomLevelNotSupported,
                  ),
            ),
          );
        });

        testWidgets(
            'with zoomLevelNotSupported error '
            'when the zoom level is not supported '
            'by the camera', (tester) async {
          when(mediaDevices.getSupportedConstraints).thenReturn({
            'zoom': true,
          });

          when(videoTracks.first.getCapabilities).thenReturn({});

          expect(
            () => cameraService.getZoomLevelCapabilityForCamera(camera),
            throwsA(
              isA<CameraWebException>()
                  .having(
                    (e) => e.cameraId,
                    'cameraId',
                    camera.textureId,
                  )
                  .having(
                    (e) => e.code,
                    'code',
                    CameraErrorCode.zoomLevelNotSupported,
                  ),
            ),
          );
        });

        testWidgets(
            'with notStarted error '
            'when the camera stream has not been initialized', (tester) async {
          when(mediaDevices.getSupportedConstraints).thenReturn({
            'zoom': true,
          });

          // Create a camera stream with no video tracks.
          when(() => camera.stream).thenReturn(FakeMediaStream([]));

          expect(
            () => cameraService.getZoomLevelCapabilityForCamera(camera),
            throwsA(
              isA<CameraWebException>()
                  .having(
                    (e) => e.cameraId,
                    'cameraId',
                    camera.textureId,
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

    group('getFacingModeForVideoTrack', () {
      setUp(() {
        cameraService.jsUtil = jsUtil;
      });

      testWidgets(
          'throws PlatformException '
          'with notSupported error '
          'when there are no media devices', (tester) async {
        when(() => navigator.mediaDevices).thenReturn(null);

        expect(
          () =>
              cameraService.getFacingModeForVideoTrack(MockMediaStreamTrack()),
          throwsA(
            isA<PlatformException>().having(
              (e) => e.code,
              'code',
              CameraErrorCode.notSupported.toString(),
            ),
          ),
        );
      });

      testWidgets(
          'returns null '
          'when the facing mode is not supported', (tester) async {
        when(mediaDevices.getSupportedConstraints).thenReturn({
          'facingMode': false,
        });

        final facingMode =
            cameraService.getFacingModeForVideoTrack(MockMediaStreamTrack());

        expect(facingMode, isNull);
      });

      group('when the facing mode is supported', () {
        late MediaStreamTrack videoTrack;

        setUp(() {
          videoTrack = MockMediaStreamTrack();

          when(() => jsUtil.hasProperty(videoTrack, 'getCapabilities'))
              .thenReturn(true);

          when(mediaDevices.getSupportedConstraints).thenReturn({
            'facingMode': true,
          });
        });

        testWidgets(
            'returns an appropriate facing mode '
            'based on the video track settings', (tester) async {
          when(videoTrack.getSettings).thenReturn({'facingMode': 'user'});

          final facingMode =
              cameraService.getFacingModeForVideoTrack(videoTrack);

          expect(facingMode, equals('user'));
        });

        testWidgets(
            'returns an appropriate facing mode '
            'based on the video track capabilities '
            'when the facing mode setting is empty', (tester) async {
          when(videoTrack.getSettings).thenReturn({});
          when(videoTrack.getCapabilities).thenReturn({
            'facingMode': ['environment', 'left']
          });

          when(() => jsUtil.hasProperty(videoTrack, 'getCapabilities'))
              .thenReturn(true);

          final facingMode =
              cameraService.getFacingModeForVideoTrack(videoTrack);

          expect(facingMode, equals('environment'));
        });

        testWidgets(
            'returns null '
            'when the facing mode setting '
            'and capabilities are empty', (tester) async {
          when(videoTrack.getSettings).thenReturn({});
          when(videoTrack.getCapabilities).thenReturn({'facingMode': []});

          final facingMode =
              cameraService.getFacingModeForVideoTrack(videoTrack);

          expect(facingMode, isNull);
        });

        testWidgets(
            'returns null '
            'when the facing mode setting is empty and '
            'the video track capabilities are not supported', (tester) async {
          when(videoTrack.getSettings).thenReturn({});

          when(() => jsUtil.hasProperty(videoTrack, 'getCapabilities'))
              .thenReturn(false);

          final facingMode =
              cameraService.getFacingModeForVideoTrack(videoTrack);

          expect(facingMode, isNull);
        });
      });
    });

    group('mapFacingModeToLensDirection', () {
      testWidgets(
          'returns front '
          'when the facing mode is user', (tester) async {
        expect(
          cameraService.mapFacingModeToLensDirection('user'),
          equals(CameraLensDirection.front),
        );
      });

      testWidgets(
          'returns back '
          'when the facing mode is environment', (tester) async {
        expect(
          cameraService.mapFacingModeToLensDirection('environment'),
          equals(CameraLensDirection.back),
        );
      });

      testWidgets(
          'returns external '
          'when the facing mode is left', (tester) async {
        expect(
          cameraService.mapFacingModeToLensDirection('left'),
          equals(CameraLensDirection.external),
        );
      });

      testWidgets(
          'returns external '
          'when the facing mode is right', (tester) async {
        expect(
          cameraService.mapFacingModeToLensDirection('right'),
          equals(CameraLensDirection.external),
        );
      });
    });

    group('mapFacingModeToCameraType', () {
      testWidgets(
          'returns user '
          'when the facing mode is user', (tester) async {
        expect(
          cameraService.mapFacingModeToCameraType('user'),
          equals(CameraType.user),
        );
      });

      testWidgets(
          'returns environment '
          'when the facing mode is environment', (tester) async {
        expect(
          cameraService.mapFacingModeToCameraType('environment'),
          equals(CameraType.environment),
        );
      });

      testWidgets(
          'returns user '
          'when the facing mode is left', (tester) async {
        expect(
          cameraService.mapFacingModeToCameraType('left'),
          equals(CameraType.user),
        );
      });

      testWidgets(
          'returns user '
          'when the facing mode is right', (tester) async {
        expect(
          cameraService.mapFacingModeToCameraType('right'),
          equals(CameraType.user),
        );
      });
    });

    group('mapResolutionPresetToSize', () {
      testWidgets(
          'returns 4096x2160 '
          'when the resolution preset is max', (tester) async {
        expect(
          cameraService.mapResolutionPresetToSize(ResolutionPreset.max),
          equals(Size(4096, 2160)),
        );
      });

      testWidgets(
          'returns 4096x2160 '
          'when the resolution preset is ultraHigh', (tester) async {
        expect(
          cameraService.mapResolutionPresetToSize(ResolutionPreset.ultraHigh),
          equals(Size(4096, 2160)),
        );
      });

      testWidgets(
          'returns 1920x1080 '
          'when the resolution preset is veryHigh', (tester) async {
        expect(
          cameraService.mapResolutionPresetToSize(ResolutionPreset.veryHigh),
          equals(Size(1920, 1080)),
        );
      });

      testWidgets(
          'returns 1280x720 '
          'when the resolution preset is high', (tester) async {
        expect(
          cameraService.mapResolutionPresetToSize(ResolutionPreset.high),
          equals(Size(1280, 720)),
        );
      });

      testWidgets(
          'returns 720x480 '
          'when the resolution preset is medium', (tester) async {
        expect(
          cameraService.mapResolutionPresetToSize(ResolutionPreset.medium),
          equals(Size(720, 480)),
        );
      });

      testWidgets(
          'returns 320x240 '
          'when the resolution preset is low', (tester) async {
        expect(
          cameraService.mapResolutionPresetToSize(ResolutionPreset.low),
          equals(Size(320, 240)),
        );
      });
    });

    group('mapDeviceOrientationToOrientationType', () {
      testWidgets(
          'returns portraitPrimary '
          'when the device orientation is portraitUp', (tester) async {
        expect(
          cameraService.mapDeviceOrientationToOrientationType(
            DeviceOrientation.portraitUp,
          ),
          equals(OrientationType.portraitPrimary),
        );
      });

      testWidgets(
          'returns landscapePrimary '
          'when the device orientation is landscapeLeft', (tester) async {
        expect(
          cameraService.mapDeviceOrientationToOrientationType(
            DeviceOrientation.landscapeLeft,
          ),
          equals(OrientationType.landscapePrimary),
        );
      });

      testWidgets(
          'returns portraitSecondary '
          'when the device orientation is portraitDown', (tester) async {
        expect(
          cameraService.mapDeviceOrientationToOrientationType(
            DeviceOrientation.portraitDown,
          ),
          equals(OrientationType.portraitSecondary),
        );
      });

      testWidgets(
          'returns landscapeSecondary '
          'when the device orientation is landscapeRight', (tester) async {
        expect(
          cameraService.mapDeviceOrientationToOrientationType(
            DeviceOrientation.landscapeRight,
          ),
          equals(OrientationType.landscapeSecondary),
        );
      });
    });

    group('mapOrientationTypeToDeviceOrientation', () {
      testWidgets(
          'returns portraitUp '
          'when the orientation type is portraitPrimary', (tester) async {
        expect(
          cameraService.mapOrientationTypeToDeviceOrientation(
            OrientationType.portraitPrimary,
          ),
          equals(DeviceOrientation.portraitUp),
        );
      });

      testWidgets(
          'returns landscapeLeft '
          'when the orientation type is landscapePrimary', (tester) async {
        expect(
          cameraService.mapOrientationTypeToDeviceOrientation(
            OrientationType.landscapePrimary,
          ),
          equals(DeviceOrientation.landscapeLeft),
        );
      });

      testWidgets(
          'returns portraitDown '
          'when the orientation type is portraitSecondary', (tester) async {
        expect(
          cameraService.mapOrientationTypeToDeviceOrientation(
            OrientationType.portraitSecondary,
          ),
          equals(DeviceOrientation.portraitDown),
        );
      });

      testWidgets(
          'returns portraitDown '
          'when the orientation type is portraitSecondary', (tester) async {
        expect(
          cameraService.mapOrientationTypeToDeviceOrientation(
            OrientationType.portraitSecondary,
          ),
          equals(DeviceOrientation.portraitDown),
        );
      });

      testWidgets(
          'returns landscapeRight '
          'when the orientation type is landscapeSecondary', (tester) async {
        expect(
          cameraService.mapOrientationTypeToDeviceOrientation(
            OrientationType.landscapeSecondary,
          ),
          equals(DeviceOrientation.landscapeRight),
        );
      });

      testWidgets(
          'returns portraitUp '
          'for an unknown orientation type', (tester) async {
        expect(
          cameraService.mapOrientationTypeToDeviceOrientation(
            'unknown',
          ),
          equals(DeviceOrientation.portraitUp),
        );
      });
    });
  });
}

class JSNoSuchMethodError implements Exception {}
