// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:video_player/video_player.dart';

const Duration _playDuration = Duration(seconds: 1);

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets(
    'can substitute one controller by another without crashing',
    (WidgetTester tester) async {
      // Use WebM for web to allow CI to use Chromium.
      const String videoAssetKey =
          kIsWeb ? 'assets/Butterfly-209.webm' : 'assets/Butterfly-209.mp4';

      final VideoPlayerController controller = VideoPlayerController.asset(
        videoAssetKey,
      );
      final VideoPlayerController another = VideoPlayerController.asset(
        videoAssetKey,
      );
      await controller.initialize();
      await another.initialize();
      await controller.setVolume(0);
      await another.setVolume(0);

      final Completer<void> started = Completer<void>();
      final Completer<void> ended = Completer<void>();

      another.addListener(() {
        if (another.value.isBuffering && !started.isCompleted) {
          started.complete();
        }
        if (started.isCompleted &&
            !another.value.isBuffering &&
            !ended.isCompleted) {
          ended.complete();
        }
      });

      // Inject a widget with `controller`...
      await tester.pumpWidget(renderVideoWidget(controller));
      await controller.play();
      await tester.pumpAndSettle(_playDuration);
      await controller.pause();

      // Disposing controller causes the Widget to crash in the next line
      // (Issue https://github.com/flutter/flutter/issues/90046)
      await controller.dispose();

      // Now replace it with `another` controller...
      await tester.pumpWidget(renderVideoWidget(another));
      await another.play();
      await another.seekTo(const Duration(seconds: 5));
      await tester.pumpAndSettle(_playDuration);
      await another.pause();

      // Expect that `another` played.
      expect(another.value.position,
          (Duration position) => position > const Duration(seconds: 0));

      await expectLater(started.future, completes);
      await expectLater(ended.future, completes);
    },
    skip: !(kIsWeb || defaultTargetPlatform == TargetPlatform.android),
  );
}

Widget renderVideoWidget(VideoPlayerController controller) {
  return Material(
    elevation: 0,
    child: Directionality(
      textDirection: TextDirection.ltr,
      child: Center(
        child: AspectRatio(
          key: const Key('same'),
          aspectRatio: controller.value.aspectRatio,
          child: VideoPlayer(controller),
        ),
      ),
    ),
  );
}
