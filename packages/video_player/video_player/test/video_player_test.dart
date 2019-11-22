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
import 'package:video_player_platform_interface/video_player_platform_interface.dart';

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

    group('initialize', () {
      test('asset', () async {
        final VideoPlayerController controller = VideoPlayerController.asset(
          'a.avi',
        );
        await controller.initialize();

        expect(
            fakeVideoPlayerPlatform.dataSourceDescriptions[0],
            <String, dynamic>{
              'asset': 'a.avi',
              'package': null,
            });
      });

      test('network', () async {
        final VideoPlayerController controller = VideoPlayerController.network(
          'https://127.0.0.1',
        );
        await controller.initialize();

        expect(
            fakeVideoPlayerPlatform.dataSourceDescriptions[0],
            <String, dynamic>{
              'uri': 'https://127.0.0.1',
              'formatHint': null,
            });
      });

      test('network with hint', () async {
        final VideoPlayerController controller = VideoPlayerController.network(
            'https://127.0.0.1',
            formatHint: VideoFormat.dash);
        await controller.initialize();

        expect(
            fakeVideoPlayerPlatform.dataSourceDescriptions[0],
            <String, dynamic>{
              'uri': 'https://127.0.0.1',
              'formatHint': 'dash',
            });
      });

      test('file', () async {
        final VideoPlayerController controller =
            VideoPlayerController.file(File('a.avi'));
        await controller.initialize();

        expect(
            fakeVideoPlayerPlatform.dataSourceDescriptions[0],
            <String, dynamic>{
              'uri': 'file://a.avi',
            });
      });
    });

    test('dispose', () async {
      final VideoPlayerController controller = VideoPlayerController.network(
        'https://127.0.0.1',
      );
      expect(controller.textureId, isNull);
      expect(await controller.position, const Duration(seconds: 0));
      controller.initialize();

      await controller.dispose();

      expect(controller.textureId, isNotNull);
      expect(await controller.position, isNull);
    });

    test('play', () async {
      final VideoPlayerController controller = VideoPlayerController.network(
        'https://127.0.0.1',
      );
      await controller.initialize();
      expect(controller.value.isPlaying, isFalse);
      await controller.play();

      expect(controller.value.isPlaying, isTrue);
      expect(fakeVideoPlayerPlatform.calls.last.method, 'play');
    });

    test('setLooping', () async {
      final VideoPlayerController controller = VideoPlayerController.network(
        'https://127.0.0.1',
      );
      await controller.initialize();
      expect(controller.value.isLooping, isFalse);
      await controller.setLooping(true);

      expect(controller.value.isLooping, isTrue);
    });

    test('pause', () async {
      final VideoPlayerController controller = VideoPlayerController.network(
        'https://127.0.0.1',
      );
      await controller.initialize();
      await controller.play();
      expect(controller.value.isPlaying, isTrue);

      await controller.pause();

      expect(controller.value.isPlaying, isFalse);
      expect(fakeVideoPlayerPlatform.calls.last.method, 'pause');
    });

    group('seekTo', () {
      test('works', () async {
        final VideoPlayerController controller = VideoPlayerController.network(
          'https://127.0.0.1',
        );
        await controller.initialize();
        expect(await controller.position, const Duration(seconds: 0));

        await controller.seekTo(const Duration(milliseconds: 500));

        expect(await controller.position, const Duration(milliseconds: 500));
      });

      test('clamps values that are too high or low', () async {
        final VideoPlayerController controller = VideoPlayerController.network(
          'https://127.0.0.1',
        );
        await controller.initialize();
        expect(await controller.position, const Duration(seconds: 0));

        await controller.seekTo(const Duration(seconds: 100));
        expect(await controller.position, const Duration(seconds: 1));

        await controller.seekTo(const Duration(seconds: -100));
        expect(await controller.position, const Duration(seconds: 0));
      });
    });

    group('setVolume', () {
      test('works', () async {
        final VideoPlayerController controller = VideoPlayerController.network(
          'https://127.0.0.1',
        );
        await controller.initialize();
        expect(controller.value.volume, 1.0);

        const double volume = 0.5;
        await controller.setVolume(volume);

        expect(controller.value.volume, volume);
      });

      test('clamps values that are too high or low', () async {
        final VideoPlayerController controller = VideoPlayerController.network(
          'https://127.0.0.1',
        );
        await controller.initialize();
        expect(controller.value.volume, 1.0);

        await controller.setVolume(-1);
        expect(controller.value.volume, 0.0);

        await controller.setVolume(11);
        expect(controller.value.volume, 1.0);
      });
    });

    group('Platform callbacks', () {
      testWidgets('playing completed', (WidgetTester tester) async {
        final VideoPlayerController controller = VideoPlayerController.network(
          'https://127.0.0.1',
        );
        await controller.initialize();
        expect(controller.value.isPlaying, isFalse);
        await controller.play();
        expect(controller.value.isPlaying, isTrue);
        final FakeVideoEventStream fakeVideoEventStream =
            fakeVideoPlayerPlatform.streams[controller.textureId];
        assert(fakeVideoEventStream != null);

        fakeVideoEventStream.eventsChannel
            .sendEvent(<String, dynamic>{'event': 'completed'});
        await tester.pumpAndSettle();

        expect(controller.value.isPlaying, isFalse);
        expect(controller.value.position, controller.value.duration);
      });

      testWidgets('buffering status', (WidgetTester tester) async {
        final VideoPlayerController controller = VideoPlayerController.network(
          'https://127.0.0.1',
        );
        await controller.initialize();
        expect(controller.value.isBuffering, false);
        expect(controller.value.buffered, isEmpty);
        final FakeVideoEventStream fakeVideoEventStream =
            fakeVideoPlayerPlatform.streams[controller.textureId];
        assert(fakeVideoEventStream != null);

        fakeVideoEventStream.eventsChannel
            .sendEvent(<String, dynamic>{'event': 'bufferingStart'});
        await tester.pumpAndSettle();
        expect(controller.value.isBuffering, isTrue);

        const Duration bufferStart = Duration(seconds: 0);
        const Duration bufferEnd = Duration(milliseconds: 500);
        fakeVideoEventStream.eventsChannel.sendEvent(<String, dynamic>{
          'event': 'bufferingUpdate',
          'values': <List<int>>[
            <int>[bufferStart.inMilliseconds, bufferEnd.inMilliseconds]
          ],
        });
        await tester.pumpAndSettle();
        expect(controller.value.isBuffering, isTrue);
        expect(controller.value.buffered.length, 1);
        expect(controller.value.buffered[0].toString(),
            DurationRange(bufferStart, bufferEnd).toString());

        fakeVideoEventStream.eventsChannel
            .sendEvent(<String, dynamic>{'event': 'bufferingEnd'});
        await tester.pumpAndSettle();
        expect(controller.value.isBuffering, isFalse);
      });
    });
  });

  group('DurationRange', () {
    test('uses given values', () {
      const Duration start = Duration(seconds: 2);
      const Duration end = Duration(seconds: 8);

      final DurationRange range = DurationRange(start, end);

      expect(range.start, start);
      expect(range.end, end);
      expect(range.toString(), contains('start: $start, end: $end'));
    });

    test('calculates fractions', () {
      const Duration start = Duration(seconds: 2);
      const Duration end = Duration(seconds: 8);
      const Duration total = Duration(seconds: 10);

      final DurationRange range = DurationRange(start, end);

      expect(range.startFraction(total), .2);
      expect(range.endFraction(total), .8);
    });
  });

  group('VideoPlayerValue', () {
    test('uninitialized()', () {
      final VideoPlayerValue uninitialized = VideoPlayerValue.uninitialized();

      expect(uninitialized.duration, isNull);
      expect(uninitialized.position, equals(const Duration(seconds: 0)));
      expect(uninitialized.buffered, isEmpty);
      expect(uninitialized.isPlaying, isFalse);
      expect(uninitialized.isLooping, isFalse);
      expect(uninitialized.isBuffering, isFalse);
      expect(uninitialized.volume, 1.0);
      expect(uninitialized.errorDescription, isNull);
      expect(uninitialized.size, isNull);
      expect(uninitialized.size, isNull);
      expect(uninitialized.initialized, isFalse);
      expect(uninitialized.hasError, isFalse);
      expect(uninitialized.aspectRatio, 1.0);
    });

    test('erroneous()', () {
      const String errorMessage = 'foo';
      final VideoPlayerValue error = VideoPlayerValue.erroneous(errorMessage);

      expect(error.duration, isNull);
      expect(error.position, equals(const Duration(seconds: 0)));
      expect(error.buffered, isEmpty);
      expect(error.isPlaying, isFalse);
      expect(error.isLooping, isFalse);
      expect(error.isBuffering, isFalse);
      expect(error.volume, 1.0);
      expect(error.errorDescription, errorMessage);
      expect(error.size, isNull);
      expect(error.size, isNull);
      expect(error.initialized, isFalse);
      expect(error.hasError, isTrue);
      expect(error.aspectRatio, 1.0);
    });

    test('toString()', () {
      const Duration duration = Duration(seconds: 5);
      const Size size = Size(400, 300);
      const Duration position = Duration(seconds: 1);
      final List<DurationRange> buffered = <DurationRange>[
        DurationRange(const Duration(seconds: 0), const Duration(seconds: 4))
      ];
      const bool isPlaying = true;
      const bool isLooping = true;
      const bool isBuffering = true;
      const double volume = 0.5;

      final VideoPlayerValue value = VideoPlayerValue(
          duration: duration,
          size: size,
          position: position,
          buffered: buffered,
          isPlaying: isPlaying,
          isLooping: isLooping,
          isBuffering: isBuffering,
          volume: volume);

      expect(value.toString(),
          'VideoPlayerValue(duration: 0:00:05.000000, size: Size(400.0, 300.0), position: 0:00:01.000000, buffered: [DurationRange(start: 0:00:00.000000, end: 0:00:04.000000)], isPlaying: true, isLooping: true, isBuffering: truevolume: 0.5, errorDescription: null)');
    });

    test('copyWith()', () {
      final VideoPlayerValue original = VideoPlayerValue.uninitialized();
      final VideoPlayerValue exactCopy = original.copyWith();

      expect(exactCopy.toString(), original.toString());
    });
  });

  test('VideoProgressColors', () {
    const Color playedColor = Color.fromRGBO(0, 0, 255, 0.75);
    const Color bufferedColor = Color.fromRGBO(0, 255, 0, 0.5);
    const Color backgroundColor = Color.fromRGBO(255, 255, 0, 0.25);

    final VideoProgressColors colors = VideoProgressColors(
        playedColor: playedColor,
        bufferedColor: bufferedColor,
        backgroundColor: backgroundColor);

    expect(colors.playedColor, playedColor);
    expect(colors.bufferedColor, bufferedColor);
    expect(colors.backgroundColor, backgroundColor);
  });
}

class FakeVideoPlayerPlatform {
  FakeVideoPlayerPlatform() {
    _channel.setMockMethodCallHandler(onMethodCall);
  }

  final MethodChannel _channel = const MethodChannel('flutter.io/videoPlayer');

  Completer<bool> initialized = Completer<bool>();
  List<MethodCall> calls = <MethodCall>[];
  List<Map<String, dynamic>> dataSourceDescriptions = <Map<String, dynamic>>[];
  final Map<int, FakeVideoEventStream> streams = <int, FakeVideoEventStream>{};
  int nextTextureId = 0;
  final Map<int, Duration> _positions = <int, Duration>{};

  Future<dynamic> onMethodCall(MethodCall call) {
    calls.add(call);
    switch (call.method) {
      case 'init':
        initialized.complete(true);
        break;
      case 'create':
        streams[nextTextureId] = FakeVideoEventStream(
            nextTextureId, 100, 100, const Duration(seconds: 1));
        final Map<dynamic, dynamic> dataSource = call.arguments;
        dataSourceDescriptions.add(dataSource.cast<String, dynamic>());
        return Future<Map<String, int>>.sync(() {
          return <String, int>{
            'textureId': nextTextureId++,
          };
        });
        break;
      case 'position':
        final Duration position = _positions[call.arguments['textureId']] ??
            const Duration(seconds: 0);
        return Future<int>.value(position.inMilliseconds);
        break;
      case 'seekTo':
        _positions[call.arguments['textureId']] =
            Duration(milliseconds: call.arguments['location']);
        break;
      case 'dispose':
      case 'pause':
      case 'play':
      case 'setLooping':
      case 'setVolume':
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
