// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:ui';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:video_player_platform_interface/messages.dart';
import 'package:video_player_platform_interface/method_channel_video_player.dart';
import 'package:video_player_platform_interface/video_player_platform_interface.dart';

class _ApiLogger implements TestHostVideoPlayerApi {
  final List<String> log = [];
  TextureMessage textureMessage;
  CreateMessage createMessage;
  DataSourceMessage dataSourceMessage;
  PositionMessage positionMessage;
  LoopingMessage loopingMessage;
  VolumeMessage volumeMessage;
  PlaybackSpeedMessage playbackSpeedMessage;
  MixWithOthersMessage mixWithOthersMessage;

  @override
  TextureMessage create(CreateMessage arg) {
    log.add('create');
    createMessage = arg;
    return TextureMessage()
      ..textureId = 3;
  }

  void setDataSource(DataSourceMessage arg) {
    log.add('setDataSource');
    dataSourceMessage = arg;
  }

  @override
  void dispose(TextureMessage arg) {
    log.add('dispose');
    textureMessage = arg;
  }

  @override
  void initialize() {
    log.add('init');
  }

  @override
  void pause(TextureMessage arg) {
    log.add('pause');
    textureMessage = arg;
  }

  @override
  void play(TextureMessage arg) {
    log.add('play');
    textureMessage = arg;
  }

  @override
  void setMixWithOthers(MixWithOthersMessage arg) {
    log.add('setMixWithOthers');
    mixWithOthersMessage = arg;
  }

  @override
  PositionMessage position(TextureMessage arg) {
    log.add('position');
    textureMessage = arg;
    return PositionMessage()
      ..position = 234;
  }

  @override
  void seekTo(PositionMessage arg) {
    log.add('seekTo');
    positionMessage = arg;
  }

  @override
  void setLooping(LoopingMessage arg) {
    log.add('setLooping');
    loopingMessage = arg;
  }

  @override
  void setVolume(VolumeMessage arg) {
    log.add('setVolume');
    volumeMessage = arg;
  }

  @override
  void setPlaybackSpeed(PlaybackSpeedMessage arg) {
    log.add('setPlaybackSpeed');
    playbackSpeedMessage = arg;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('$VideoPlayerPlatform', () {
    test('$MethodChannelVideoPlayer() is the default instance', () {
      expect(VideoPlayerPlatform.instance,
          isInstanceOf<MethodChannelVideoPlayer>());
    });

    test('Cannot be implemented with `implements`', () {
      expect(() {
        VideoPlayerPlatform.instance = ImplementsVideoPlayerPlatform();
      }, throwsA(isInstanceOf<AssertionError>()));
    });

    test('Can be mocked with `implements`', () {
      final ImplementsVideoPlayerPlatform mock =
      ImplementsVideoPlayerPlatform();
      when(mock.isMock).thenReturn(true);
      VideoPlayerPlatform.instance = mock;
    });

    test('Can be extended', () {
      VideoPlayerPlatform.instance = ExtendsVideoPlayerPlatform();
    });
  });

  group('$MethodChannelVideoPlayer', () {
    final MethodChannelVideoPlayer player = MethodChannelVideoPlayer();
    _ApiLogger log;

    setUp(() {
      log = _ApiLogger();
      TestHostVideoPlayerApi.setup(log);
    });

    test('init', () async {
      await player.init();
      expect(
        log.log.last,
        'init',
      );
    });

    test('dispose', () async {
      await player.dispose(1);
      expect(log.log.last, 'dispose');
      expect(log.textureMessage.textureId, 1);
    });

    test('create controller and set asset data source', () async {
      final int textureId = await player.create();
      expect(log.log.last, 'create');

      await player.setDataSource(
        textureId,
        DataSource(
          sourceType: DataSourceType.asset,
          asset: 'someAsset',
          package: 'somePackage',
        ),);
      expect(log.log.last, 'setDataSource');
      // nested data source?
      expect(log.dataSourceMessage.key, 'somePackage:someAsset');
      expect(log.dataSourceMessage.asset, 'someAsset');
      expect(log.dataSourceMessage.packageName, 'somePackage');
      expect(textureId, 3);
    });

    test('create controller and set network data source', () async {
      final int textureId = await player.create();
      expect(log.log.last, 'create');

      await player.setDataSource(
        textureId,
          DataSource(
        sourceType: DataSourceType.network,
        uri: 'someUri',
        formatHint: VideoFormat.dash,
      ),);
      expect(log.log.last, 'setDataSource');
      // nested data source?
      expect(log.dataSourceMessage.key, 'someUri:dash');
      expect(log.dataSourceMessage.uri, 'someUri');
      expect(log.dataSourceMessage.formatHint, 'dash');
      expect(textureId, 3);
    });

    test('create with file', () async {
      final int textureId = await player.create();
      expect(log.log.last, 'create');

      await player.setDataSource(
          textureId,
          DataSource(
        sourceType: DataSourceType.file,
        uri: 'someUri',
      ),);

      expect(log.log.last, 'setDataSource');
      // nested data source?

      expect(log.dataSourceMessage.key, 'someUri');
      expect(log.dataSourceMessage.uri, 'someUri');
      expect(textureId, 3);
    });

    test('setLooping', () async {
      await player.setLooping(1, true);
      expect(log.log.last, 'setLooping');
      expect(log.loopingMessage.textureId, 1);
      expect(log.loopingMessage.isLooping, true);
    });

    test('play', () async {
      await player.play(1);
      expect(log.log.last, 'play');
      expect(log.textureMessage.textureId, 1);
    });

    test('pause', () async {
      await player.pause(1);
      expect(log.log.last, 'pause');
      expect(log.textureMessage.textureId, 1);
    });

    test('setMixWithOthers', () async {
      await player.setMixWithOthers(true);
      expect(log.log.last, 'setMixWithOthers');
      expect(log.mixWithOthersMessage.mixWithOthers, true);

      await player.setMixWithOthers(false);
      expect(log.log.last, 'setMixWithOthers');
      expect(log.mixWithOthersMessage.mixWithOthers, false);
    });

    test('setVolume', () async {
      await player.setVolume(1, 0.7);
      expect(log.log.last, 'setVolume');
      expect(log.volumeMessage.textureId, 1);
      expect(log.volumeMessage.volume, 0.7);
    });

    test('setPlaybackSpeed', () async {
      await player.setPlaybackSpeed(1, 1.5);
      expect(log.log.last, 'setPlaybackSpeed');
      expect(log.playbackSpeedMessage.textureId, 1);
      expect(log.playbackSpeedMessage.speed, 1.5);
    });

    test('seekTo', () async {
      await player.seekTo(1, const Duration(milliseconds: 12345));
      expect(log.log.last, 'seekTo');
      expect(log.positionMessage.textureId, 1);
      expect(log.positionMessage.position, 12345);
    });

    test('getPosition', () async {
      final Duration position = await player.getPosition(1);
      expect(log.log.last, 'position');
      expect(log.textureMessage.textureId, 1);
      expect(position, const Duration(milliseconds: 234));
    });

    test('videoEventsFor', () async {
      String key = "key";
      // TODO(cbenhagen): This has been deprecated and should be replaced
      // with `ServicesBinding.instance.defaultBinaryMessenger` when it's
      // available on all the versions of Flutter that we test.
      // ignore: deprecated_member_use
      defaultBinaryMessenger.setMockMessageHandler(
        "flutter.io/videoPlayer/videoEvents123",
            (ByteData message) async {
          final MethodCall methodCall =
          const StandardMethodCodec().decodeMethodCall(message);
          if (methodCall.method == 'listen') {
            // TODO(cbenhagen): This has been deprecated and should be replaced
            // with `ServicesBinding.instance.defaultBinaryMessenger` when it's
            // available on all the versions of Flutter that we test.
            // ignore: deprecated_member_use
            await defaultBinaryMessenger.handlePlatformMessage(
                "flutter.io/videoPlayer/videoEvents123",
                const StandardMethodCodec()
                    .encodeSuccessEnvelope(<String, dynamic>{
                  'key': key,
                  'event': 'initialized',
                  'duration': 98765,
                  'width': 1920,
                  'height': 1080,
                }),
                    (ByteData data) {});

            // TODO(cbenhagen): This has been deprecated and should be replaced
            // with `ServicesBinding.instance.defaultBinaryMessenger` when it's
            // available on all the versions of Flutter that we test.
            // ignore: deprecated_member_use
            await defaultBinaryMessenger.handlePlatformMessage(
                "flutter.io/videoPlayer/videoEvents123",
                const StandardMethodCodec()
                    .encodeSuccessEnvelope(<String, dynamic>{
                  'key': key,
                  'event': 'completed',
                }),
                    (ByteData data) {});

            // TODO(cbenhagen): This has been deprecated and should be replaced
            // with `ServicesBinding.instance.defaultBinaryMessenger` when it's
            // available on all the versions of Flutter that we test.
            // ignore: deprecated_member_use
            await defaultBinaryMessenger.handlePlatformMessage(
                "flutter.io/videoPlayer/videoEvents123",
                const StandardMethodCodec()
                    .encodeSuccessEnvelope(<String, dynamic>{
                  'key': key,
                  'event': 'bufferingUpdate',
                  'values': <List<dynamic>>[
                    <int>[0, 1234],
                    <int>[1235, 4000],
                  ],
                }),
                    (ByteData data) {});

            // TODO(cbenhagen): This has been deprecated and should be replaced
            // with `ServicesBinding.instance.defaultBinaryMessenger` when it's
            // available on all the versions of Flutter that we test.
            // ignore: deprecated_member_use
            await defaultBinaryMessenger.handlePlatformMessage(
                "flutter.io/videoPlayer/videoEvents123",
                const StandardMethodCodec()
                    .encodeSuccessEnvelope(<String, dynamic>{
                  'key': key,
                  'event': 'bufferingStart',
                }),
                    (ByteData data) {});

            // TODO(cbenhagen): This has been deprecated and should be replaced
            // with `ServicesBinding.instance.defaultBinaryMessenger` when it's
            // available on all the versions of Flutter that we test.
            // ignore: deprecated_member_use
            await defaultBinaryMessenger.handlePlatformMessage(
                "flutter.io/videoPlayer/videoEvents123",
                const StandardMethodCodec()
                    .encodeSuccessEnvelope(<String, dynamic>{
                  'key': key,
                  'event': 'bufferingEnd',
                }),
                    (ByteData data) {});

            return const StandardMethodCodec().encodeSuccessEnvelope(null);
          } else if (methodCall.method == 'cancel') {
            return const StandardMethodCodec().encodeSuccessEnvelope(null);
          } else {
            fail('Expected listen or cancel');
          }
        },
      );
      expect(
          player.videoEventsFor(123),
          emitsInOrder(<dynamic>[
            VideoEvent(
              key: key,
              eventType: VideoEventType.initialized,
              duration: const Duration(milliseconds: 98765),
              size: const Size(1920, 1080),
            ),
            VideoEvent(
              key: key,
              eventType: VideoEventType.completed,
            ),
            VideoEvent(
                key: key,
                eventType: VideoEventType.bufferingUpdate,
                buffered: <DurationRange>[
                  DurationRange(
                    const Duration(milliseconds: 0),
                    const Duration(milliseconds: 1234),
                  ),
                  DurationRange(
                    const Duration(milliseconds: 1235),
                    const Duration(milliseconds: 4000),
                  ),
                ]),
            VideoEvent(
              key: key,
              eventType: VideoEventType.bufferingStart,
            ),
            VideoEvent(
              key: key,
              eventType: VideoEventType.bufferingEnd,
            ),
          ]));
    });
  });
}

class ImplementsVideoPlayerPlatform extends Mock
    implements VideoPlayerPlatform {}

class ExtendsVideoPlayerPlatform extends VideoPlayerPlatform {}
