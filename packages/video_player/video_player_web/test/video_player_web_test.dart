// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
@TestOn('browser')

import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:video_player/video_player.dart';
import 'package:video_player_platform_interface/video_player_platform_interface.dart';
import 'package:video_player_web/video_player_web.dart';

void main() {
  group('VideoPlayer for Web', () {
    int textureId;

    setUp(() async {
      VideoPlayerPlatform.instance = VideoPlayerPlugin();
      textureId = await VideoPlayerPlatform.instance.create(
        DataSource(
            sourceType: DataSourceType.network,
            uri:
                'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4'),
      );
    });

    test('$VideoPlayerPlugin is the live instance', () {
      expect(VideoPlayerPlatform.instance, isA<VideoPlayerPlugin>());
    });

    test('can init', () {
      expect(VideoPlayerPlatform.instance.init(), completes);
    });

    test('can create from network', () {
      expect(
          VideoPlayerPlatform.instance.create(
            DataSource(
                sourceType: DataSourceType.network,
                uri:
                    'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4'),
          ),
          completion(isNonZero));
    });

    test('can create from asset', () {
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

    test('cannot create from file', () {
      expect(
          VideoPlayerPlatform.instance.create(
            DataSource(
              sourceType: DataSourceType.file,
              uri: '/videos/bee.mp4',
            ),
          ),
          throwsUnimplementedError);
    });

    test('can dispose', () {
      expect(VideoPlayerPlatform.instance.dispose(textureId), completes);
    });

    test('can set looping', () {
      expect(
          VideoPlayerPlatform.instance.setLooping(textureId, true), completes);
    });

    test('can play', () async {
      // Mute video to allow autoplay (See https://goo.gl/xX8pDD)
      await VideoPlayerPlatform.instance.setVolume(textureId, 0);
      expect(VideoPlayerPlatform.instance.play(textureId), completes);
    });

    test('throws PlatformException when playing bad media', () async {
      int videoPlayerId = await VideoPlayerPlatform.instance.create(
        DataSource(
            sourceType: DataSourceType.network,
            uri:
                'https://flutter.github.io/assets-for-api-docs/assets/videos/_non_existent_video.mp4'),
      );

      Stream<VideoEvent> eventStream =
          VideoPlayerPlatform.instance.videoEventsFor(videoPlayerId);

      // Mute video to allow autoplay (See https://goo.gl/xX8pDD)
      await VideoPlayerPlatform.instance.setVolume(videoPlayerId, 0);
      await VideoPlayerPlatform.instance.play(videoPlayerId);

      expect(eventStream, emitsError(isA<PlatformException>()));
    });

    test('can pause', () {
      expect(VideoPlayerPlatform.instance.pause(textureId), completes);
    });

    test('can set volume', () {
      expect(VideoPlayerPlatform.instance.setVolume(textureId, 0.8), completes);
    });

    test('can seek to position', () {
      expect(
          VideoPlayerPlatform.instance.seekTo(textureId, Duration(seconds: 1)),
          completes);
    });

    test('can get position', () {
      expect(VideoPlayerPlatform.instance.getPosition(textureId),
          completion(isInstanceOf<Duration>()));
    });

    test('can get video event stream', () {
      expect(VideoPlayerPlatform.instance.videoEventsFor(textureId),
          isInstanceOf<Stream<VideoEvent>>());
    });

    test('can build view', () {
      expect(VideoPlayerPlatform.instance.buildView(textureId),
          isInstanceOf<Widget>());
    });
  });
}
