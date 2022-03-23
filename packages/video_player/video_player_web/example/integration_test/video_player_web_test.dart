// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:video_player_platform_interface/video_player_platform_interface.dart';
import 'package:video_player_web/video_player_web.dart';

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

// Use WebM for web to allow CI to use Chromium.
const String _videoAssetKey = 'assets/Butterfly-209.webm';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('VideoPlayer for Web', () {
    late Future<int> textureId;

    setUp(() {
      VideoPlayerPlatform.instance = VideoPlayerPlugin();
      textureId = VideoPlayerPlatform.instance
          .create(
            DataSource(
              sourceType: DataSourceType.network,
              uri: getUrlForAssetAsNetworkSource(_videoAssetKey),
            ),
          )
          .then((int? textureId) => textureId!);
    });

    testWidgets('can init', (WidgetTester tester) async {
      expect(VideoPlayerPlatform.instance.init(), completes);
    });

    testWidgets('can create from network', (WidgetTester tester) async {
      expect(
          VideoPlayerPlatform.instance.create(
            DataSource(
              sourceType: DataSourceType.network,
              uri: getUrlForAssetAsNetworkSource(_videoAssetKey),
            ),
          ),
          completion(isNonZero));
    });

    testWidgets('can create from asset', (WidgetTester tester) async {
      expect(
          VideoPlayerPlatform.instance.create(
            DataSource(
              sourceType: DataSourceType.asset,
              asset: 'videos/bee.mp4',
              package: 'bee_vids',
            ),
          ),
          completion(isNonZero));
    });

    testWidgets('cannot create from file', (WidgetTester tester) async {
      expect(
          VideoPlayerPlatform.instance.create(
            DataSource(
              sourceType: DataSourceType.file,
              uri: '/videos/bee.mp4',
            ),
          ),
          throwsUnimplementedError);
    });

    testWidgets('cannot create from content URI', (WidgetTester tester) async {
      expect(
          VideoPlayerPlatform.instance.create(
            DataSource(
              sourceType: DataSourceType.contentUri,
              uri: 'content://video',
            ),
          ),
          throwsUnimplementedError);
    });

    testWidgets('can dispose', (WidgetTester tester) async {
      expect(VideoPlayerPlatform.instance.dispose(await textureId), completes);
    });

    testWidgets('can set looping', (WidgetTester tester) async {
      expect(
        VideoPlayerPlatform.instance.setLooping(await textureId, true),
        completes,
      );
    });

    testWidgets('can play', (WidgetTester tester) async {
      // Mute video to allow autoplay (See https://goo.gl/xX8pDD)
      await VideoPlayerPlatform.instance.setVolume(await textureId, 0);
      expect(VideoPlayerPlatform.instance.play(await textureId), completes);
    });

    testWidgets('throws PlatformException when playing bad media',
        (WidgetTester tester) async {
      final int videoPlayerId = (await VideoPlayerPlatform.instance.create(
        DataSource(
          sourceType: DataSourceType.network,
          uri: getUrlForAssetAsNetworkSource('assets/__non_existent.webm'),
        ),
      ))!;

      final Stream<VideoEvent> eventStream =
          VideoPlayerPlatform.instance.videoEventsFor(videoPlayerId);

      // Mute video to allow autoplay (See https://goo.gl/xX8pDD)
      await VideoPlayerPlatform.instance.setVolume(videoPlayerId, 0);
      await VideoPlayerPlatform.instance.play(videoPlayerId);

      expect(() async {
        await eventStream.last;
      }, throwsA(isA<PlatformException>()));
    });
    testWidgets('signals bufferingEnd onCanPlayThrough',
        (WidgetTester tester) async {
      final int videoPlayerId = await textureId;
      final Stream<VideoEvent> eventStream =
          VideoPlayerPlatform.instance.videoEventsFor(videoPlayerId);

      await VideoPlayerPlatform.instance.setVolume(videoPlayerId, 0);
      await VideoPlayerPlatform.instance.play(videoPlayerId);

      // Let the video play, until we see a "bufferingStop" event (will be excluded!)
      final List<VideoEvent> events = await eventStream
          .timeout(const Duration(seconds: 5))
          .takeWhile(
              (VideoEvent e) => e.eventType != VideoEventType.bufferingEnd)
          .toList();

      await VideoPlayerPlatform.instance.pause(videoPlayerId);

      // The expected list of event types should look like this:
      // 1. bufferingStart,
      // 2. bufferingUpdate (videoElement.onWaiting),
      // 3. initialized (videoElement.onCanPlay),
      //   The next one is excluded from the stream by takeWhile:
      // 4. bufferingEnd (videoElement.onCanPlayThrough),
      expect(
          events.map((VideoEvent e) => e.eventType),
          equals(<VideoEventType>[
            VideoEventType.bufferingStart,
            VideoEventType.bufferingUpdate,
            VideoEventType.initialized,
            // VideoEventType.bufferingEnd
          ]));
    });

    testWidgets('can pause', (WidgetTester tester) async {
      expect(VideoPlayerPlatform.instance.pause(await textureId), completes);
    });

    testWidgets('can set volume', (WidgetTester tester) async {
      expect(
        VideoPlayerPlatform.instance.setVolume(await textureId, 0.8),
        completes,
      );
    });

    testWidgets('can set playback speed', (WidgetTester tester) async {
      expect(
        VideoPlayerPlatform.instance.setPlaybackSpeed(await textureId, 2.0),
        completes,
      );
    });

    testWidgets('can seek to position', (WidgetTester tester) async {
      expect(
        VideoPlayerPlatform.instance.seekTo(
          await textureId,
          const Duration(seconds: 1),
        ),
        completes,
      );
    });

    testWidgets('can get position', (WidgetTester tester) async {
      expect(VideoPlayerPlatform.instance.getPosition(await textureId),
          completion(isInstanceOf<Duration>()));
    });

    testWidgets('can get video event stream', (WidgetTester tester) async {
      expect(VideoPlayerPlatform.instance.videoEventsFor(await textureId),
          isInstanceOf<Stream<VideoEvent>>());
    });

    testWidgets('can build view', (WidgetTester tester) async {
      expect(VideoPlayerPlatform.instance.buildView(await textureId),
          isInstanceOf<Widget>());
    });

    testWidgets('ignores setting mixWithOthers', (WidgetTester tester) async {
      expect(VideoPlayerPlatform.instance.setMixWithOthers(true), completes);
      expect(VideoPlayerPlatform.instance.setMixWithOthers(false), completes);
    });
  });
}
