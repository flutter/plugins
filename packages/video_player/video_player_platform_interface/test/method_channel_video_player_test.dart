// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:ui';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:video_player_platform_interface/messages.dart';
import 'package:video_player_platform_interface/method_channel_video_player.dart';
import 'package:video_player_platform_interface/test.dart';
import 'package:video_player_platform_interface/video_player_platform_interface.dart';

class _ApiLogger implements TestHostVideoPlayerApi {
  final List<String> log = [];
  TextureMessage? textureMessage;
  CreateMessage? createMessage;
  PositionMessage? positionMessage;
  TrackSelectionsMessage? trackSelectionsMessage;
  LoopingMessage? loopingMessage;
  VolumeMessage? volumeMessage;
  PlaybackSpeedMessage? playbackSpeedMessage;
  MixWithOthersMessage? mixWithOthersMessage;

  @override
  TextureMessage create(CreateMessage arg) {
    log.add('create');
    createMessage = arg;
    return TextureMessage()..textureId = 3;
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
    return PositionMessage()..position = 234;
  }

  @override
  void seekTo(PositionMessage arg) {
    log.add('seekTo');
    positionMessage = arg;
  }

  @override
  TrackSelectionsMessage trackSelections(TextureMessage arg) {
    log.add('trackSelections');
    textureMessage = arg;
    return TrackSelectionsMessage()
      ..trackSelections = [
        {
          'trackId': '203',
          'trackType': 2,
          'isUnknown': false,
          'isAuto': false,
          'isSelected': true,
          'rolesFlag': -1,
          'width': 2048,
          'height': 1080,
          'bitrate': -1,
        },
        {
          'trackId': '121',
          'trackType': 1,
          'isUnknown': false,
          'isAuto': false,
          'isSelected': false,
          'language': 'English',
          'label': '',
          'rolesFlag': -1,
          'channelCount': 1,
          'bitrate': -1,
        },
        {
          'trackId': '310',
          'trackType': 3,
          'isUnknown': false,
          'isAuto': false,
          'isSelected': false,
          'language': 'Persian',
          'label': '',
          'rolesFlag': -1,
        },
        {
          'trackId': '100',
          'trackType': 1,
          'isUnknown': true,
          'isAuto': false,
          'isSelected': false,
        },
        {
          'trackId': '1',
          'trackType': 2,
          'unknown': false,
          'isAuto': true,
          'isSelected': false,
        }
      ];
  }

  @override
  void setTrackSelection(TrackSelectionsMessage arg) {
    log.add('setTrackSelection');
    trackSelectionsMessage = arg;
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
  });

  group('$MethodChannelVideoPlayer', () {
    final MethodChannelVideoPlayer player = MethodChannelVideoPlayer();
    late _ApiLogger log;

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
      expect(log.textureMessage?.textureId, 1);
    });

    test('create with asset', () async {
      final int? textureId = await player.create(DataSource(
        sourceType: DataSourceType.asset,
        asset: 'someAsset',
        package: 'somePackage',
      ));
      expect(log.log.last, 'create');
      expect(log.createMessage?.asset, 'someAsset');
      expect(log.createMessage?.packageName, 'somePackage');
      expect(textureId, 3);
    });

    test('create with network', () async {
      final int? textureId = await player.create(DataSource(
        sourceType: DataSourceType.network,
        uri: 'someUri',
        formatHint: VideoFormat.dash,
      ));
      expect(log.log.last, 'create');
      expect(log.createMessage?.asset, null);
      expect(log.createMessage?.uri, 'someUri');
      expect(log.createMessage?.packageName, null);
      expect(log.createMessage?.formatHint, 'dash');
      expect(log.createMessage?.httpHeaders, {});
      expect(textureId, 3);
    });

    test('create with network (some headers)', () async {
      final int? textureId = await player.create(DataSource(
        sourceType: DataSourceType.network,
        uri: 'someUri',
        httpHeaders: {'Authorization': 'Bearer token'},
      ));
      expect(log.log.last, 'create');
      expect(log.createMessage?.asset, null);
      expect(log.createMessage?.uri, 'someUri');
      expect(log.createMessage?.packageName, null);
      expect(log.createMessage?.formatHint, null);
      expect(log.createMessage?.httpHeaders, {'Authorization': 'Bearer token'});
      expect(textureId, 3);
    });

    test('create with file', () async {
      final int? textureId = await player.create(DataSource(
        sourceType: DataSourceType.file,
        uri: 'someUri',
      ));
      expect(log.log.last, 'create');
      expect(log.createMessage?.uri, 'someUri');
      expect(textureId, 3);
    });

    test('setLooping', () async {
      await player.setLooping(1, true);
      expect(log.log.last, 'setLooping');
      expect(log.loopingMessage?.textureId, 1);
      expect(log.loopingMessage?.isLooping, true);
    });

    test('play', () async {
      await player.play(1);
      expect(log.log.last, 'play');
      expect(log.textureMessage?.textureId, 1);
    });

    test('pause', () async {
      await player.pause(1);
      expect(log.log.last, 'pause');
      expect(log.textureMessage?.textureId, 1);
    });

    test('setMixWithOthers', () async {
      await player.setMixWithOthers(true);
      expect(log.log.last, 'setMixWithOthers');
      expect(log.mixWithOthersMessage?.mixWithOthers, true);

      await player.setMixWithOthers(false);
      expect(log.log.last, 'setMixWithOthers');
      expect(log.mixWithOthersMessage?.mixWithOthers, false);
    });

    test('setVolume', () async {
      await player.setVolume(1, 0.7);
      expect(log.log.last, 'setVolume');
      expect(log.volumeMessage?.textureId, 1);
      expect(log.volumeMessage?.volume, 0.7);
    });

    test('setPlaybackSpeed', () async {
      await player.setPlaybackSpeed(1, 1.5);
      expect(log.log.last, 'setPlaybackSpeed');
      expect(log.playbackSpeedMessage?.textureId, 1);
      expect(log.playbackSpeedMessage?.speed, 1.5);
    });

    test('seekTo', () async {
      await player.seekTo(1, const Duration(milliseconds: 12345));
      expect(log.log.last, 'seekTo');
      expect(log.positionMessage?.textureId, 1);
      expect(log.positionMessage?.position, 12345);
    });

    test('getPosition', () async {
      final Duration position = await player.getPosition(1);
      expect(log.log.last, 'position');
      expect(log.textureMessage?.textureId, 1);
      expect(position, const Duration(milliseconds: 234));
    });

    test('getTrackSelections', () async {
      final List<TrackSelection> trackSelections =
          await player.getTrackSelections(1);
      expect(log.log.last, 'trackSelections');
      expect(log.textureMessage?.textureId, 1);
      expect(
          trackSelections[0],
          TrackSelection(
            trackId: '203',
            trackType: TrackSelectionType.video,
            trackName: '2048 × 1080',
            isSelected: true,
            size: Size(2048.0, 1080.0),
          ));
      expect(
          trackSelections[1],
          TrackSelection(
            trackId: '121',
            trackType: TrackSelectionType.audio,
            trackName: 'English, Stereo',
            isSelected: false,
            language: 'English',
            channelCount: 1,
          ));
      expect(
          trackSelections[2],
          TrackSelection(
            trackId: '310',
            trackType: TrackSelectionType.text,
            trackName: 'Persian',
            isSelected: false,
            language: 'Persian',
          ));
      expect(
          trackSelections[3],
          TrackSelection(
            trackId: '100',
            trackType: TrackSelectionType.audio,
            trackName: 'Unknown',
            isSelected: false,
          ));
      expect(
          trackSelections[4],
          TrackSelection(
            trackId: '1',
            trackType: TrackSelectionType.video,
            trackName: 'Auto',
            isSelected: false,
          ));
    });

    test('setTrackSelection', () async {
      await player.setTrackSelection(
        1,
        TrackSelection(
          trackId: '1',
          trackType: TrackSelectionType.video,
          trackName: 'Auto',
          isSelected: false,
        ),
      );
      expect(log.log.last, 'setTrackSelection');
      expect(log.trackSelectionsMessage?.textureId, 1);
      expect(log.trackSelectionsMessage?.trackId, '1');
    });

    test('videoEventsFor', () async {
      ServicesBinding.instance?.defaultBinaryMessenger.setMockMessageHandler(
        "flutter.io/videoPlayer/videoEvents123",
        (ByteData? message) async {
          final MethodCall methodCall =
              const StandardMethodCodec().decodeMethodCall(message);
          if (methodCall.method == 'listen') {
            await ServicesBinding.instance?.defaultBinaryMessenger
                .handlePlatformMessage(
                    "flutter.io/videoPlayer/videoEvents123",
                    const StandardMethodCodec()
                        .encodeSuccessEnvelope(<String, dynamic>{
                      'event': 'initialized',
                      'duration': 98765,
                      'width': 1920,
                      'height': 1080,
                    }),
                    (ByteData? data) {});

            await ServicesBinding.instance?.defaultBinaryMessenger
                .handlePlatformMessage(
                    "flutter.io/videoPlayer/videoEvents123",
                    const StandardMethodCodec()
                        .encodeSuccessEnvelope(<String, dynamic>{
                      'event': 'completed',
                    }),
                    (ByteData? data) {});

            await ServicesBinding.instance?.defaultBinaryMessenger
                .handlePlatformMessage(
                    "flutter.io/videoPlayer/videoEvents123",
                    const StandardMethodCodec()
                        .encodeSuccessEnvelope(<String, dynamic>{
                      'event': 'bufferingUpdate',
                      'values': <List<dynamic>>[
                        <int>[0, 1234],
                        <int>[1235, 4000],
                      ],
                    }),
                    (ByteData? data) {});

            await ServicesBinding.instance?.defaultBinaryMessenger
                .handlePlatformMessage(
                    "flutter.io/videoPlayer/videoEvents123",
                    const StandardMethodCodec()
                        .encodeSuccessEnvelope(<String, dynamic>{
                      'event': 'bufferingStart',
                    }),
                    (ByteData? data) {});

            await ServicesBinding.instance?.defaultBinaryMessenger
                .handlePlatformMessage(
                    "flutter.io/videoPlayer/videoEvents123",
                    const StandardMethodCodec()
                        .encodeSuccessEnvelope(<String, dynamic>{
                      'event': 'bufferingEnd',
                    }),
                    (ByteData? data) {});

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
              eventType: VideoEventType.initialized,
              duration: const Duration(milliseconds: 98765),
              size: const Size(1920, 1080),
            ),
            VideoEvent(eventType: VideoEventType.completed),
            VideoEvent(
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
            VideoEvent(eventType: VideoEventType.bufferingStart),
            VideoEvent(eventType: VideoEventType.bufferingEnd),
          ]));
    });
  });
}
