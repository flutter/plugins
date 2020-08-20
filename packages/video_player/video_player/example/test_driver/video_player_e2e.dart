// Copyright 2019, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';
import 'package:integration_test/integration_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:video_player/video_player.dart';

const Duration _playDuration = Duration(seconds: 1);

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  VideoPlayerController _controller;
  tearDown(() async => _controller.dispose());

  group('asset videos', () {
    setUp(() {
      _controller = VideoPlayerController.asset('assets/Butterfly-209.mp4');
    });

    testWidgets('can be initialized', (WidgetTester tester) async {
      await _controller.initialize();

      expect(_controller.value.initialized, true);
      expect(_controller.value.position, const Duration(seconds: 0));
      expect(_controller.value.isPlaying, false);
      expect(_controller.value.duration,
          const Duration(seconds: 7, milliseconds: 540));
    });

    testWidgets('can be played', (WidgetTester tester) async {
      await _controller.initialize();

      await _controller.play();
      await tester.pumpAndSettle(_playDuration);

      expect(_controller.value.isPlaying, true);
      expect(_controller.value.position,
          (Duration position) => position > const Duration(seconds: 0));
    }, skip: Platform.isIOS);

    testWidgets('can seek', (WidgetTester tester) async {
      await _controller.initialize();

      await _controller.seekTo(const Duration(seconds: 3));

      expect(_controller.value.position, const Duration(seconds: 3));
    }, skip: Platform.isIOS);

    testWidgets('can be paused', (WidgetTester tester) async {
      await _controller.initialize();

      // Play for a second, then pause, and then wait a second.
      await _controller.play();
      await tester.pumpAndSettle(_playDuration);
      await _controller.pause();
      final Duration pausedPosition = _controller.value.position;
      await tester.pumpAndSettle(_playDuration);

      // Verify that we stopped playing after the pause.
      expect(_controller.value.isPlaying, false);
      expect(_controller.value.position, pausedPosition);
    }, skip: Platform.isIOS);
  });
}
