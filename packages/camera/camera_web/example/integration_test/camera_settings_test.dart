// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:html';
import 'dart:ui';

import 'package:camera_platform_interface/camera_platform_interface.dart';
import 'package:camera_web/src/camera_settings.dart';
import 'package:camera_web/src/types/types.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mocktail/mocktail.dart';

import 'helpers/helpers.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('CameraSettings', () {
    const cameraId = 0;

    late Window window;
    late Navigator navigator;
    late MediaDevices mediaDevices;
    late CameraSettings settings;

    setUp(() async {
      window = MockWindow();
      navigator = MockNavigator();
      mediaDevices = MockMediaDevices();

      when(() => window.navigator).thenReturn(navigator);
      when(() => navigator.mediaDevices).thenReturn(mediaDevices);

      settings = CameraSettings()..window = window;
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

        await settings.getMediaStreamForOptions(options);

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
          () => settings.getMediaStreamForOptions(CameraOptions()),
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
            () => settings.getMediaStreamForOptions(
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
            () => settings.getMediaStreamForOptions(
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
            () => settings.getMediaStreamForOptions(
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
            () => settings.getMediaStreamForOptions(
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
            () => settings.getMediaStreamForOptions(
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
            () => settings.getMediaStreamForOptions(
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
            () => settings.getMediaStreamForOptions(
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
            () => settings.getMediaStreamForOptions(
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
            () => settings.getMediaStreamForOptions(
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
            () => settings.getMediaStreamForOptions(
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
            () => settings.getMediaStreamForOptions(
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
            () => settings.getMediaStreamForOptions(
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
            () => settings.getMediaStreamForOptions(
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

    group('getFacingModeForVideoTrack', () {
      testWidgets(
          'throws PlatformException '
          'with notSupported error '
          'when there are no media devices', (tester) async {
        when(() => navigator.mediaDevices).thenReturn(null);

        expect(
          () => settings.getFacingModeForVideoTrack(MockMediaStreamTrack()),
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
            settings.getFacingModeForVideoTrack(MockMediaStreamTrack());

        expect(
          facingMode,
          equals(null),
        );
      });

      group('when the facing mode is supported', () {
        setUp(() {
          when(mediaDevices.getSupportedConstraints).thenReturn({
            'facingMode': true,
          });
        });

        testWidgets(
            'returns an appropriate facing mode '
            'based on the video track settings', (tester) async {
          final videoTrack = MockMediaStreamTrack();

          when(videoTrack.getSettings).thenReturn({'facingMode': 'user'});

          final facingMode = settings.getFacingModeForVideoTrack(videoTrack);

          expect(
            facingMode,
            equals('user'),
          );
        });

        testWidgets(
            'returns an appropriate facing mode '
            'based on the video track capabilities '
            'when the facing mode setting is empty', (tester) async {
          final videoTrack = MockMediaStreamTrack();

          when(videoTrack.getSettings).thenReturn({});
          when(videoTrack.getCapabilities).thenReturn({
            'facingMode': ['environment', 'left']
          });

          final facingMode = settings.getFacingModeForVideoTrack(videoTrack);

          expect(
            facingMode,
            equals('environment'),
          );
        });

        testWidgets(
            'returns null '
            'when the facing mode setting '
            'and capabilities are empty', (tester) async {
          final videoTrack = MockMediaStreamTrack();

          when(videoTrack.getSettings).thenReturn({});
          when(videoTrack.getCapabilities).thenReturn({'facingMode': []});

          final facingMode = settings.getFacingModeForVideoTrack(videoTrack);

          expect(
            facingMode,
            equals(null),
          );
        });

        testWidgets(
            'returns null '
            'when the facing mode setting is empty and '
            'the video track capabilities are not supported', (tester) async {
          final videoTrack = MockMediaStreamTrack();

          when(videoTrack.getSettings).thenReturn({});
          when(videoTrack.getCapabilities).thenThrow(JSNoSuchMethodError());

          final facingMode = settings.getFacingModeForVideoTrack(videoTrack);

          expect(
            facingMode,
            equals(null),
          );
        });

        testWidgets(
            'throws PlatformException '
            'with unknown error '
            'when getting the video track capabilities '
            'throws an unknown error', (tester) async {
          final videoTrack = MockMediaStreamTrack();

          when(videoTrack.getSettings).thenReturn({});
          when(videoTrack.getCapabilities).thenThrow(Exception('Unknown'));

          expect(
            () => settings.getFacingModeForVideoTrack(videoTrack),
            throwsA(
              isA<PlatformException>().having(
                (e) => e.code,
                'code',
                CameraErrorCode.unknown.toString(),
              ),
            ),
          );
        });
      });
    });

    group('mapFacingModeToLensDirection', () {
      testWidgets(
          'returns front '
          'when the facing mode is user', (tester) async {
        expect(
          settings.mapFacingModeToLensDirection('user'),
          equals(CameraLensDirection.front),
        );
      });

      testWidgets(
          'returns back '
          'when the facing mode is environment', (tester) async {
        expect(
          settings.mapFacingModeToLensDirection('environment'),
          equals(CameraLensDirection.back),
        );
      });

      testWidgets(
          'returns external '
          'when the facing mode is left', (tester) async {
        expect(
          settings.mapFacingModeToLensDirection('left'),
          equals(CameraLensDirection.external),
        );
      });

      testWidgets(
          'returns external '
          'when the facing mode is right', (tester) async {
        expect(
          settings.mapFacingModeToLensDirection('right'),
          equals(CameraLensDirection.external),
        );
      });
    });

    group('mapFacingModeToCameraType', () {
      testWidgets(
          'returns user '
          'when the facing mode is user', (tester) async {
        expect(
          settings.mapFacingModeToCameraType('user'),
          equals(CameraType.user),
        );
      });

      testWidgets(
          'returns environment '
          'when the facing mode is environment', (tester) async {
        expect(
          settings.mapFacingModeToCameraType('environment'),
          equals(CameraType.environment),
        );
      });

      testWidgets(
          'returns user '
          'when the facing mode is left', (tester) async {
        expect(
          settings.mapFacingModeToCameraType('left'),
          equals(CameraType.user),
        );
      });

      testWidgets(
          'returns user '
          'when the facing mode is right', (tester) async {
        expect(
          settings.mapFacingModeToCameraType('right'),
          equals(CameraType.user),
        );
      });
    });

    group('mapResolutionPresetToSize', () {
      testWidgets(
          'returns 3840x2160 '
          'when the resolution preset is max', (tester) async {
        expect(
          settings.mapResolutionPresetToSize(ResolutionPreset.max),
          equals(Size(3840, 2160)),
        );
      });

      testWidgets(
          'returns 3840x2160 '
          'when the resolution preset is ultraHigh', (tester) async {
        expect(
          settings.mapResolutionPresetToSize(ResolutionPreset.ultraHigh),
          equals(Size(3840, 2160)),
        );
      });

      testWidgets(
          'returns 1920x1080 '
          'when the resolution preset is veryHigh', (tester) async {
        expect(
          settings.mapResolutionPresetToSize(ResolutionPreset.veryHigh),
          equals(Size(1920, 1080)),
        );
      });

      testWidgets(
          'returns 1280x720 '
          'when the resolution preset is high', (tester) async {
        expect(
          settings.mapResolutionPresetToSize(ResolutionPreset.high),
          equals(Size(1280, 720)),
        );
      });

      testWidgets(
          'returns 720x480 '
          'when the resolution preset is medium', (tester) async {
        expect(
          settings.mapResolutionPresetToSize(ResolutionPreset.medium),
          equals(Size(720, 480)),
        );
      });

      testWidgets(
          'returns 320x240 '
          'when the resolution preset is low', (tester) async {
        expect(
          settings.mapResolutionPresetToSize(ResolutionPreset.low),
          equals(Size(320, 240)),
        );
      });
    });
  });
}

class JSNoSuchMethodError implements Exception {}
