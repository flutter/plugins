// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_player_avfoundation/video_player_avfoundation.dart';
// TODO(stuartmorgan): Remove the use of MiniController in tests, as that is
// testing test code; tests should instead be written directly against the
// platform interface. (These tests were copied from the app-facing package
// during federation and minimally modified, which is why they currently use the
// controller.)
import 'package:video_player_example/mini_controller.dart';
import 'package:video_player_platform_interface/video_player_platform_interface.dart';

const Duration _playDuration = Duration(seconds: 1);

const String _videoAssetKey = 'assets/Butterfly-209.mp4';

// Returns the URL to load an asset from this example app as a network source.
//
// TODO(stuartmorgan): Convert this to a local `HttpServer` that vends the
// assets directly, https://github.com/flutter/flutter/issues/95420
String getUrlForAssetAsNetworkSource(String assetKey) {
  return 'https://github.com/flutter/plugins/blob/'
      // This hash can be rolled forward to pick up newly-added assets.
      'cb381ced070d356799dddf24aca38ce0579d3d7b'
      '/packages/video_player/video_player/example/'
      '$assetKey'
      '?raw=true';
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late MiniController _controller;
  tearDown(() async => _controller.dispose());

  group('asset videos', () {
    setUp(() {
      _controller = MiniController.asset(_videoAssetKey);
    });

    testWidgets('registers expected implementation',
        (WidgetTester tester) async {
      AVFoundationVideoPlayer.registerWith();
      expect(VideoPlayerPlatform.instance, isA<AVFoundationVideoPlayer>());
    });

    testWidgets('can be initialized', (WidgetTester tester) async {
      await _controller.initialize();

      expect(_controller.value.isInitialized, true);
      expect(await _controller.position, Duration.zero);
      expect(_controller.value.duration,
          const Duration(seconds: 7, milliseconds: 540));
    });

    testWidgets('can be played', (WidgetTester tester) async {
      await _controller.initialize();

      await _controller.play();
      await tester.pumpAndSettle(_playDuration);

      expect(await _controller.position, greaterThan(Duration.zero));
    });

    testWidgets('can seek', (WidgetTester tester) async {
      await _controller.initialize();

      await _controller.seekTo(const Duration(seconds: 3));

      // TODO(stuartmorgan): Switch to _controller.position once seekTo is
      // fixed on the native side to wait for completion, so this is testing
      // the native code rather than the MiniController position cache.
      expect(_controller.value.position, const Duration(seconds: 3));
    });

    testWidgets('can be paused', (WidgetTester tester) async {
      await _controller.initialize();

      // Play for a second, then pause, and then wait a second.
      await _controller.play();
      await tester.pumpAndSettle(_playDuration);
      await _controller.pause();
      final Duration pausedPosition = (await _controller.position)!;
      await tester.pumpAndSettle(_playDuration);

      // Verify that we stopped playing after the pause.
      // TODO(stuartmorgan): Investigate why this has a slight discrepency, and
      // fix it if possible. Is AVPlayer's pause method internally async?
      const Duration allowableDelta = Duration(milliseconds: 10);
      expect(await _controller.position,
          lessThan(pausedPosition + allowableDelta));
    });
  });

  group('file-based videos', () {
    setUp(() async {
      // Load the data from the asset.
      final String tempDir = (await getTemporaryDirectory()).path;
      final ByteData bytes = await rootBundle.load(_videoAssetKey);

      // Write it to a file to use as a source.
      final String filename = _videoAssetKey.split('/').last;
      final File file = File('$tempDir/$filename');
      await file.writeAsBytes(bytes.buffer.asInt8List());

      _controller = MiniController.file(file);
    });

    testWidgets('test video player using static file() method as constructor',
        (WidgetTester tester) async {
      await _controller.initialize();

      await _controller.play();
      await tester.pumpAndSettle(_playDuration);

      expect(await _controller.position, greaterThan(Duration.zero));
    });
  });

  group('network videos', () {
    setUp(() {
      final String videoUrl = getUrlForAssetAsNetworkSource(_videoAssetKey);
      _controller = MiniController.network(videoUrl);
    });

    testWidgets('reports buffering status', (WidgetTester tester) async {
      await _controller.initialize();

      final Completer<void> started = Completer<void>();
      final Completer<void> ended = Completer<void>();
      _controller.addListener(() {
        if (!started.isCompleted && _controller.value.isBuffering) {
          started.complete();
        }
        if (started.isCompleted &&
            !_controller.value.isBuffering &&
            !ended.isCompleted) {
          ended.complete();
        }
      });

      await _controller.play();
      await _controller.seekTo(const Duration(seconds: 5));
      await tester.pumpAndSettle(_playDuration);
      await _controller.pause();

      // TODO(stuartmorgan): Switch to _controller.position once seekTo is
      // fixed on the native side to wait for completion, so this is testing
      // the native code rather than the MiniController position cache.
      expect(_controller.value.position, greaterThan(Duration.zero));

      await expectLater(started.future, completes);
      await expectLater(ended.future, completes);
    },
        // TODO(stuartmorgan): Skipped on iOS without explanation in main
        // package. Needs investigation.
        skip: true);

    testWidgets('live stream duration != 0', (WidgetTester tester) async {
      final MiniController livestreamController = MiniController.network(
        'https://flutter.github.io/assets-for-api-docs/assets/videos/hls/bee.m3u8',
      );
      await livestreamController.initialize();

      expect(livestreamController.value.isInitialized, true);
      // Live streams should have either a positive duration or C.TIME_UNSET if the duration is unknown
      // See https://exoplayer.dev/doc/reference/com/google/android/exoplayer2/Player.html#getDuration--
      expect(livestreamController.value.duration,
          (Duration duration) => duration != Duration.zero);
    });
  });
}
