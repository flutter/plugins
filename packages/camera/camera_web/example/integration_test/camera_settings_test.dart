// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:html';

import 'package:camera_platform_interface/camera_platform_interface.dart';
import 'package:camera_web/src/camera_settings.dart';
import 'package:camera_web/src/types/types.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mocktail/mocktail.dart';

import 'helpers/helpers.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('CameraSettings', () {
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

    group('getFacingModeForVideoTrack', () {
      testWidgets(
          'throws CameraException '
          'with notSupported error '
          'when there are no media devices', (tester) async {
        when(() => navigator.mediaDevices).thenReturn(null);

        expect(
          () => settings.getFacingModeForVideoTrack(MockMediaStreamTrack()),
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
            'throws CameraException '
            'with unknown error '
            'when getting the video track capabilities '
            'throws an unknown error', (tester) async {
          final videoTrack = MockMediaStreamTrack();

          when(videoTrack.getSettings).thenReturn({});
          when(videoTrack.getCapabilities).thenThrow(Exception('Unknown'));

          expect(
            () => settings.getFacingModeForVideoTrack(videoTrack),
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
  });
}

class JSNoSuchMethodError implements Exception {}
