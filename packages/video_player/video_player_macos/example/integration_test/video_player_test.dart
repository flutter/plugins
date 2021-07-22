// Copyright 2019, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// TODO(amirh): Remove this once flutter_driver supports null safety.
// https://github.com/flutter/flutter/issues/71379
// @dart = 2.9
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:video_player/video_player.dart';

const Duration _playDuration = Duration(seconds: 1);

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  VideoPlayerController _controller;
  tearDown(() async => _controller.dispose());

  group('network videos', () {
    setUp(() {
      _controller = VideoPlayerController.network(
        'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4',
      );
    });

    testWidgets('can be initialized', (WidgetTester tester) async {
      await _controller.initialize();

      expect(_controller.value.isInitialized, true);
      expect(_controller.value.position, const Duration(seconds: 0));
      expect(_controller.value.isPlaying, false);
      expect(_controller.value.duration,
          const Duration(seconds: 4, milliseconds: 036));
    });

    testWidgets('can be played', (WidgetTester tester) async {
      await _controller.initialize();
      await _controller.play();
      await tester.pumpAndSettle(_playDuration);

      expect(_controller.value.isPlaying, true);
      expect(_controller.value.position,
          (Duration position) => position > const Duration(seconds: 0));
    });

    testWidgets('can seek', (WidgetTester tester) async {
      await _controller.initialize();

      await _controller.seekTo(const Duration(seconds: 3));

      expect(_controller.value.position, const Duration(seconds: 3));
    });

    testWidgets(
      'can be paused',
      (WidgetTester tester) async {
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
      },
    );

    testWidgets('reports buffering status', (WidgetTester tester) async {
      await _controller.initialize();
      final Completer<void> started = Completer();
      final Completer<void> ended = Completer();
      bool startedBuffering = false;
      bool endedBuffering = false;
      _controller.addListener(
        () {
          if (_controller.value.isBuffering && !startedBuffering) {
            startedBuffering = true;
            started.complete();
          }
          if (startedBuffering &&
              !_controller.value.isBuffering &&
              !endedBuffering) {
            endedBuffering = true;
            ended.complete();
          }
        },
      );

      await _controller.play();
      await _controller.seekTo(const Duration(seconds: 5));
      await tester.pumpAndSettle(_playDuration);
      await _controller.pause();

      expect(_controller.value.isPlaying, false);
      expect(_controller.value.position,
          (Duration position) => position > const Duration(seconds: 0));

      await started;
      expect(startedBuffering, true);

      await ended;
      expect(endedBuffering, true);
    });

    testWidgets('can show video player', (WidgetTester tester) async {
      Future<bool> started() async {
        await _controller.initialize();
        await _controller.play();
        return true;
      }

      await tester.pumpWidget(Material(
        elevation: 0,
        child: Directionality(
          textDirection: TextDirection.ltr,
          child: Center(
            child: FutureBuilder<bool>(
              future: started(),
              builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
                if (snapshot.data == true) {
                  return AspectRatio(
                    aspectRatio: _controller.value.aspectRatio,
                    child: VideoPlayer(_controller),
                  );
                } else {
                  return const Text('waiting for video to load');
                }
              },
            ),
          ),
        ),
      ));

      await tester.pumpAndSettle(_playDuration);
      expect(_controller.value.isPlaying, true);
    });
  });
}
