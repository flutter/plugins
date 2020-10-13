import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:video_player/video_player.dart';
import 'package:video_player_platform_interface/method_channel_video_player.dart';
import 'package:video_player_platform_interface/video_player_platform_interface.dart';

VideoEvent createVideoEvent({
  bool isIndefiniteStream,
}) {
  if (isIndefiniteStream) {
    return (VideoEvent(
      eventType: VideoEventType.initialized,
      duration: Duration(seconds: 0),
      isDurationIndefinite: true,
    ));
  } else {
    return (VideoEvent(
      eventType: VideoEventType.unknown,
      duration: Duration(seconds: 0),
      isDurationIndefinite: false,
    ));
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Mock videoEvent', () {
    final log = <MethodCall>[];

    MethodChannelVideoPlayer methodChannelVideoPlayer;

    StreamSubscription videoEventStreamSubscription;
    VideoPlayerController _controller;

    setUp(() async {
      methodChannelVideoPlayer = MethodChannelVideoPlayer();

      _controller = VideoPlayerController.network('https://127.0.0.1');

      // Configure mock implementation for the EventChannel
      MethodChannel(methodChannelVideoPlayer
              .eventChannelFor(_controller.textureId)
              .name)
          .setMockMethodCallHandler((methodCall) async {
        log.add(methodCall);
        switch (methodCall.method) {
          case 'listen':
            await ServicesBinding.instance.defaultBinaryMessenger
                .handlePlatformMessage(
                    methodChannelVideoPlayer
                        .eventChannelFor(_controller.textureId)
                        .name,
                    methodChannelVideoPlayer
                        .eventChannelFor(_controller.textureId)
                        .codec
                        .encodeSuccessEnvelope(
                            createVideoEvent(isIndefiniteStream: true)),
                    (_) {});
            break;
          case 'cancel':
            break;
          default:
            return null;
        }
      });
    });

    tearDownAll(() async {
      await videoEventStreamSubscription.cancel();
    });

    test('Indefinite stream', () {

      expect(_controller.value.isDurationIndefinite, true);
    });
  });
}
