// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:video_player_web/src/duration_utils.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('convertNumVideoDurationToPluginDuration', () {
    testWidgets('Finite value converts to milliseconds',
        (WidgetTester _) async {
      final Duration? result = convertNumVideoDurationToPluginDuration(1.5);
      final Duration? zero = convertNumVideoDurationToPluginDuration(0.0001);

      expect(result, isNotNull);
      expect(result!.inMilliseconds, equals(1500));
      expect(zero, equals(Duration.zero));
    });

    testWidgets('Finite value rounds 3rd decimal value',
        (WidgetTester _) async {
      final Duration? result =
          convertNumVideoDurationToPluginDuration(1.567899089087);
      final Duration? another =
          convertNumVideoDurationToPluginDuration(1.567199089087);

      expect(result, isNotNull);
      expect(result!.inMilliseconds, equals(1568));
      expect(another!.inMilliseconds, equals(1567));
    });

    testWidgets('Infinite value returns magic constant',
        (WidgetTester _) async {
      final Duration? result =
          convertNumVideoDurationToPluginDuration(double.infinity);

      expect(result, isNotNull);
      expect(result, equals(jsCompatibleTimeUnset));
      expect(result!.inMilliseconds, equals(-9007199254740990));
    });

    testWidgets('NaN value returns null', (WidgetTester _) async {
      final Duration? result =
          convertNumVideoDurationToPluginDuration(double.nan);

      expect(result, isNull);
    });
  });
}
