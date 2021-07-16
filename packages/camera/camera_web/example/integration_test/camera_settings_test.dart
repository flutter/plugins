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

    group('getLensDirectionForVideoTrack', () {
      testWidgets(
          'throws CameraException '
          'with notSupported error '
          'when there are no media devices', (tester) async {
        when(() => navigator.mediaDevices).thenReturn(null);

        expect(
          () => settings.getLensDirectionForVideoTrack(MockMediaStreamTrack()),
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
          'returns external '
          'when the facing mode is not supported', (tester) async {
        when(mediaDevices.getSupportedConstraints).thenReturn({
          'facingMode': false,
        });

        final lensDirection =
            settings.getLensDirectionForVideoTrack(MockMediaStreamTrack());

        expect(
          lensDirection,
          equals(CameraLensDirection.external),
        );
      });

      group('when the facing mode is supported', () {
        setUp(() {
          when(mediaDevices.getSupportedConstraints).thenReturn({
            'facingMode': true,
          });
        });

        testWidgets(
            'returns appropriate lens direction '
            'based on the video track settings', (tester) async {
          final videoTrack = MockMediaStreamTrack();

          when(videoTrack.getSettings).thenReturn({'facingMode': 'user'});

          final lensDirection =
              settings.getLensDirectionForVideoTrack(videoTrack);

          expect(
            lensDirection,
            equals(CameraLensDirection.front),
          );
        });

        testWidgets(
            'returns appropriate lens direction '
            'based on the video track capabilities '
            'when the facing mode setting is empty', (tester) async {
          final videoTrack = MockMediaStreamTrack();

          when(videoTrack.getSettings).thenReturn({});
          when(videoTrack.getCapabilities).thenReturn({
            'facingMode': ['environment', 'left']
          });

          final lensDirection =
              settings.getLensDirectionForVideoTrack(videoTrack);

          expect(
            lensDirection,
            equals(CameraLensDirection.back),
          );
        });

        testWidgets(
            'returns external '
            'when the facing mode setting '
            'and capabilities are empty', (tester) async {
          final videoTrack = MockMediaStreamTrack();

          when(videoTrack.getSettings).thenReturn({});
          when(videoTrack.getCapabilities).thenReturn({'facingMode': []});

          final lensDirection =
              settings.getLensDirectionForVideoTrack(videoTrack);

          expect(
            lensDirection,
            equals(CameraLensDirection.external),
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
          CameraLensDirection.front,
        );
      });

      testWidgets(
          'returns back '
          'when the facing mode is environment', (tester) async {
        expect(
          settings.mapFacingModeToLensDirection('environment'),
          CameraLensDirection.back,
        );
      });

      testWidgets(
          'returns external '
          'when the facing mode is left', (tester) async {
        expect(
          settings.mapFacingModeToLensDirection('left'),
          CameraLensDirection.external,
        );
      });

      testWidgets(
          'returns external '
          'when the facing mode is right', (tester) async {
        expect(
          settings.mapFacingModeToLensDirection('right'),
          CameraLensDirection.external,
        );
      });
    });
  });
}
