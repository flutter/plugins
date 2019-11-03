// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeController extends ValueNotifier<VideoPlayerValue>
    implements VideoPlayerController {
  FakeController() : super(VideoPlayerValue(duration: null));

  @override
  Future<void> dispose() async {
    super.dispose();
  }

  @override
  int textureId;

  @override
  String get dataSource => '';
  @override
  DataSourceType get dataSourceType => DataSourceType.file;
  @override
  String get package => null;
  @override
  Future<Duration> get position async => value.position;

  @override
  Future<void> seekTo(Duration moment) async {}
  @override
  Future<void> setVolume(double volume) async {}
  @override
  Future<void> initialize() async {}
  @override
  Future<void> pause() async {}
  @override
  Future<void> play() async {}
  @override
  Future<void> setLooping(bool looping) async {}

  @override
  VideoFormat get formatHint => null;
}

void main() {
  testWidgets('update texture', (WidgetTester tester) async {
    final FakeController controller = FakeController();
    await tester.pumpWidget(VideoPlayer(controller));
    expect(find.byType(Texture), findsNothing);

    controller.textureId = 123;
    controller.value = controller.value.copyWith(
      duration: const Duration(milliseconds: 100),
    );

    await tester.pump();
    expect(find.byType(Texture), findsOneWidget);
  });

  testWidgets('update controller', (WidgetTester tester) async {
    final FakeController controller1 = FakeController();
    controller1.textureId = 101;
    await tester.pumpWidget(VideoPlayer(controller1));
    expect(
        find.byWidgetPredicate(
          (Widget widget) => widget is Texture && widget.textureId == 101,
        ),
        findsOneWidget);

    final FakeController controller2 = FakeController();
    controller2.textureId = 102;
    await tester.pumpWidget(VideoPlayer(controller2));
    expect(
        find.byWidgetPredicate(
          (Widget widget) => widget is Texture && widget.textureId == 102,
        ),
        findsOneWidget);
  });

  group('VideoPlayerController', () {
    FakeVideoPlayerPlatform fakeVideoPlayerPlatform;

    setUp(() {
      fakeVideoPlayerPlatform = FakeVideoPlayerPlatform();
    });

    test('initialize asset', () async {
      final VideoPlayerController controller = VideoPlayerController.asset(
        'a.avi',
      );
      await controller.initialize();

      expect(
          fakeVideoPlayerPlatform.dataSourceDescriptions[0], <String, dynamic>{
        'asset': 'a.avi',
        'package': null,
      });
    });

    test('initialize network', () async {
      final VideoPlayerController controller = VideoPlayerController.network(
        'https://127.0.0.1',
      );
      await controller.initialize();

      expect(
          fakeVideoPlayerPlatform.dataSourceDescriptions[0], <String, dynamic>{
        'uri': 'https://127.0.0.1',
        'formatHint': null,
      });
    });

    test('initialize network with hint', () async {
      final VideoPlayerController controller = VideoPlayerController.network(
          'https://127.0.0.1',
          formatHint: VideoFormat.dash);
      await controller.initialize();

      expect(
          fakeVideoPlayerPlatform.dataSourceDescriptions[0], <String, dynamic>{
        'uri': 'https://127.0.0.1',
        'formatHint': 'dash',
      });
    });

    test('initialize file', () async {
      final VideoPlayerController controller =
          VideoPlayerController.file(File('a.avi'));
      await controller.initialize();

      expect(
          fakeVideoPlayerPlatform.dataSourceDescriptions[0], <String, dynamic>{
        'uri': 'file://a.avi',
      });
    });
  });
}

class FakeVideoPlayerPlatform {
  FakeVideoPlayerPlatform() {
    _channel.setMockMethodCallHandler(onMethodCall);
  }

  final MethodChannel _channel = const MethodChannel('flutter.io/videoPlayer');

  Completer<bool> initialized = Completer<bool>();
  List<Map<String, dynamic>> dataSourceDescriptions = <Map<String, dynamic>>[];
  int nextTextureId = 0;

  Future<dynamic> onMethodCall(MethodCall call) {
    switch (call.method) {
      case 'init':
        initialized.complete(true);
        break;
      case 'create':
        FakeVideoEventStream(
            nextTextureId, 100, 100, const Duration(seconds: 1));
        final Map<dynamic, dynamic> dataSource = call.arguments;
        dataSourceDescriptions.add(dataSource.cast<String, dynamic>());
        return Future<Map<String, int>>.sync(() {
          return <String, int>{
            'textureId': nextTextureId++,
          };
        });
        break;
      case 'setLooping':
        break;
      case 'setVolume':
        break;
      case 'pause':
        break;
      default:
        throw UnimplementedError(
            '${call.method} is not implemented by the FakeVideoPlayerPlatform');
    }
    return Future<void>.sync(() {});
  }
}

class FakeVideoEventStream {
  FakeVideoEventStream(this.textureId, this.width, this.height, this.duration) {
    eventsChannel = FakeEventsChannel(
        'flutter.io/videoPlayer/videoEvents$textureId', onListen);
  }

  int textureId;
  int width;
  int height;
  Duration duration;
  FakeEventsChannel eventsChannel;

  void onListen() {
    final Map<String, dynamic> initializedEvent = <String, dynamic>{
      'event': 'initialized',
      'duration': duration.inMilliseconds,
      'width': width,
      'height': height,
    };
    eventsChannel.sendEvent(initializedEvent);
  }
}

class FakeEventsChannel {
  FakeEventsChannel(String name, this.onListen) {
    eventsMethodChannel = MethodChannel(name);
    eventsMethodChannel.setMockMethodCallHandler(onMethodCall);
  }

  MethodChannel eventsMethodChannel;
  VoidCallback onListen;

  Future<dynamic> onMethodCall(MethodCall call) {
    switch (call.method) {
      case 'listen':
        onListen();
        break;
    }
    return Future<void>.sync(() {});
  }

  void sendEvent(dynamic event) {
    // TODO(jackson): This has been deprecated and should be replaced
    // with `ServicesBinding.instance.defaultBinaryMessenger` when it's
    // available on all the versions of Flutter that we test.
    // ignore: deprecated_member_use
    defaultBinaryMessenger.handlePlatformMessage(
        eventsMethodChannel.name,
        const StandardMethodCodec().encodeSuccessEnvelope(event),
        (ByteData data) {});
  }
}
