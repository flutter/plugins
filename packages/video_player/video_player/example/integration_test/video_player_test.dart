// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:video_player/video_player.dart';

const Duration _playDuration = Duration(seconds: 1);

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  late VideoPlayerController _controller;
  tearDown(() async => _controller.dispose());

  group('asset videos', () {
    setUp(() {
      _controller = VideoPlayerController.asset('assets/Butterfly-209.mp4');
    });

    testWidgets('can be initialized', (WidgetTester tester) async {
      await _controller.initialize();

      expect(_controller.value.isInitialized, true);
      expect(_controller.value.position, const Duration(seconds: 0));
      expect(_controller.value.isPlaying, false);
      expect(_controller.value.duration,
          const Duration(seconds: 7, milliseconds: 540));
    });

    testWidgets(
      'reports buffering status',
      (WidgetTester tester) async {
        VideoPlayerController networkController = VideoPlayerController.network(
          'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4',
        );
        await networkController.initialize();
        // Mute to allow playing without DOM interaction on Web.
        // See https://developers.google.com/web/updates/2017/09/autoplay-policy-changes
        await networkController.setVolume(0);
        final Completer<void> started = Completer();
        final Completer<void> ended = Completer();
        bool startedBuffering = false;
        bool endedBuffering = false;
        networkController.addListener(() {
          if (networkController.value.isBuffering && !startedBuffering) {
            startedBuffering = true;
            started.complete();
          }
          if (startedBuffering &&
              !networkController.value.isBuffering &&
              !endedBuffering) {
            endedBuffering = true;
            ended.complete();
          }
        });

        await networkController.play();
        await networkController.seekTo(const Duration(seconds: 5));
        await tester.pumpAndSettle(_playDuration);
        await networkController.pause();

        expect(networkController.value.isPlaying, false);
        expect(networkController.value.position,
            (Duration position) => position > const Duration(seconds: 0));

        await started;
        expect(startedBuffering, true);

        await ended;
        expect(endedBuffering, true);
      },
      skip: !(kIsWeb || defaultTargetPlatform == TargetPlatform.android),
    );

    testWidgets(
      'can be played',
      (WidgetTester tester) async {
        await _controller.initialize();
        // Mute to allow playing without DOM interaction on Web.
        // See https://developers.google.com/web/updates/2017/09/autoplay-policy-changes
        await _controller.setVolume(0);

        await _controller.play();
        await tester.pumpAndSettle(_playDuration);

        expect(_controller.value.isPlaying, true);
        expect(_controller.value.position,
            (Duration position) => position > const Duration(seconds: 0));
      },
    );

    testWidgets(
      'can seek',
      (WidgetTester tester) async {
        await _controller.initialize();

        await _controller.seekTo(const Duration(seconds: 3));

        expect(_controller.value.position, const Duration(seconds: 3));
      },
    );

    testWidgets(
      'can be paused',
      (WidgetTester tester) async {
        await _controller.initialize();
        // Mute to allow playing without DOM interaction on Web.
        // See https://developers.google.com/web/updates/2017/09/autoplay-policy-changes
        await _controller.setVolume(0);

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

    testWidgets('test video player view with local asset',
        (WidgetTester tester) async {
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

      await tester.pumpAndSettle();
      expect(_controller.value.isPlaying, true);
    }, skip: kIsWeb); // Web does not support local assets.
  });
}
