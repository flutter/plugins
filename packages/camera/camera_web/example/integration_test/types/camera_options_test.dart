// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:camera_web/src/types/camera_options.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('CameraOptions', () {
    testWidgets('serializes correctly', (tester) async {
      final cameraOptions = CameraOptions(
        audio: AudioConstraints(enabled: true),
        video: VideoConstraints(
          facingMode: FacingModeConstraint.exact(CameraType.user),
        ),
      );

      expect(
        cameraOptions.toJson(),
        equals({
          'audio': cameraOptions.audio.toJson(),
          'video': cameraOptions.video.toJson(),
        }),
      );
    });
  });

  group('AudioConstraints', () {
    testWidgets('serializes correctly', (tester) async {
      expect(
        AudioConstraints(enabled: true).toJson(),
        equals(true),
      );
    });
  });

  group('VideoConstraints', () {
    testWidgets('serializes correctly', (tester) async {
      final videoConstraints = VideoConstraints(
        facingMode: FacingModeConstraint.exact(CameraType.user),
        width: VideoSizeConstraint(ideal: 100, maximum: 100),
        height: VideoSizeConstraint(ideal: 50, maximum: 50),
        deviceId: 'deviceId',
      );

      expect(
        videoConstraints.toJson(),
        equals({
          'facingMode': videoConstraints.facingMode!.toJson(),
          'width': videoConstraints.width!.toJson(),
          'height': videoConstraints.height!.toJson(),
          'deviceId': 'deviceId',
        }),
      );
    });
  });

  group('FacingModeConstraint', () {
    group('ideal', () {
      testWidgets(
          'serializes correctly '
          'for environment camera type', (tester) async {
        expect(
          FacingModeConstraint(
            CameraType.environment,
          ).toJson(),
          equals({'ideal': 'environment'}),
        );
      });

      testWidgets(
          'serializes correctly '
          'for user camera type', (tester) async {
        expect(
          FacingModeConstraint(
            CameraType.user,
          ).toJson(),
          equals({'ideal': 'user'}),
        );
      });
    });

    group('exact', () {
      testWidgets(
          'serializes correctly '
          'for environment camera type', (tester) async {
        expect(
          FacingModeConstraint.exact(
            CameraType.environment,
          ).toJson(),
          equals({'exact': 'environment'}),
        );
      });

      testWidgets(
          'serializes correctly '
          'for user camera type', (tester) async {
        expect(
          FacingModeConstraint.exact(
            CameraType.user,
          ).toJson(),
          equals({'exact': 'user'}),
        );
      });
    });
  });

  group('VideoSizeConstraint ', () {
    testWidgets('serializes correctly', (tester) async {
      expect(
        VideoSizeConstraint(
          ideal: 400,
          minimum: 200,
          maximum: 400,
        ).toJson(),
        equals({
          'ideal': 400,
          'min': 200,
          'max': 400,
        }),
      );
    });
  });
}
