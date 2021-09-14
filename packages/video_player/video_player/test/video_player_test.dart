// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:video_player/video_player.dart';
import 'package:video_player_platform_interface/messages.dart';
import 'package:video_player_platform_interface/test.dart';
import 'package:video_player_platform_interface/video_player_platform_interface.dart';

class FakeController extends ValueNotifier<VideoPlayerValue>
    implements VideoPlayerController {
  FakeController() : super(VideoPlayerValue(duration: Duration.zero));

  @override
  Future<void> dispose() async {
    super.dispose();
  }

  @override
  int textureId = VideoPlayerController.kUninitializedTextureId;

  @override
  String get dataSource => '';

  @override
  Map<String, String> get httpHeaders => {};

  @override
  DataSourceType get dataSourceType => DataSourceType.file;

  @override
  String get package => '';

  @override
  Future<Duration> get position async => value.position;

  @override
  Future<void> seekTo(Duration moment) async {}

  @override
  Future<void> setVolume(double volume) async {}

  @override
  Future<void> setPlaybackSpeed(double speed) async {}

  @override
  Future<void> initialize() async {}

  @override
  Future<void> pause() async {}

  @override
  Future<void> play() async {}

  @override
  Future<void> setLooping(bool looping) async {}

  @override
  VideoFormat? get formatHint => null;

  @override
  Future<ClosedCaptionFile> get closedCaptionFile => _loadClosedCaption();

  @override
  VideoPlayerOptions? get videoPlayerOptions => null;
}

Future<ClosedCaptionFile> _loadClosedCaption() async =>
    _FakeClosedCaptionFile();

class _FakeClosedCaptionFile extends ClosedCaptionFile {
  @override
  List<Caption> get captions {
    return <Caption>[
      Caption(
        text: 'one',
        number: 0,
        start: Duration(milliseconds: 100),
        end: Duration(milliseconds: 200),
      ),
      Caption(
        text: 'two',
        number: 1,
        start: Duration(milliseconds: 300),
        end: Duration(milliseconds: 400),
      ),
    ];
  }
}

void main() {
  testWidgets('update texture', (WidgetTester tester) async {
    final FakeController controller = FakeController();
    await tester.pumpWidget(VideoPlayer(controller));
    expect(find.byType(Texture), findsNothing);

    controller.textureId = 123;
    controller.value = controller.value.copyWith(
      duration: const Duration(milliseconds: 100),
      isInitialized: true,
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

  group('ClosedCaption widget', () {
    testWidgets('uses a default text style', (WidgetTester tester) async {
      final String text = 'foo';
      await tester.pumpWidget(MaterialApp(home: ClosedCaption(text: text)));

      final Text textWidget = tester.widget<Text>(find.text(text));
      expect(textWidget.style!.fontSize, 36.0);
      expect(textWidget.style!.color, Colors.white);
    });

    testWidgets('uses given text and style', (WidgetTester tester) async {
      final String text = 'foo';
      final TextStyle textStyle = TextStyle(fontSize: 14.725);
      await tester.pumpWidget(MaterialApp(
        home: ClosedCaption(
          text: text,
          textStyle: textStyle,
        ),
      ));
      expect(find.text(text), findsOneWidget);

      final Text textWidget = tester.widget<Text>(find.text(text));
      expect(textWidget.style!.fontSize, textStyle.fontSize);
    });

    testWidgets('handles null text', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(home: ClosedCaption(text: null)));
      expect(find.byType(Text), findsNothing);
    });

    testWidgets('Passes text contrast ratio guidelines',
        (WidgetTester tester) async {
      final String text = 'foo';
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          backgroundColor: Colors.white,
          body: ClosedCaption(text: text),
        ),
      ));
      expect(find.text(text), findsOneWidget);

      await expectLater(tester, meetsGuideline(textContrastGuideline));
    }, skip: isBrowser);
  });

  group('VideoPlayerController', () {
    late FakeVideoPlayerPlatform fakeVideoPlayerPlatform;

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
            fakeVideoPlayerPlatform.dataSourceDescriptions[0].asset, 'a.avi');
        expect(fakeVideoPlayerPlatform.dataSourceDescriptions[0].packageName,
            null);
      });

      test('network', () async {
        final VideoPlayerController controller = VideoPlayerController.network(
          'https://127.0.0.1',
        );
        await controller.initialize();

        expect(
          fakeVideoPlayerPlatform.dataSourceDescriptions[0].uri,
          'https://127.0.0.1',
        );
        expect(
          fakeVideoPlayerPlatform.dataSourceDescriptions[0].formatHint,
          null,
        );
        expect(
          fakeVideoPlayerPlatform.dataSourceDescriptions[0].httpHeaders,
          {},
        );
      });

      test('network with hint', () async {
        final VideoPlayerController controller = VideoPlayerController.network(
          'https://127.0.0.1',
          formatHint: VideoFormat.dash,
        );
        await controller.initialize();

        expect(
          fakeVideoPlayerPlatform.dataSourceDescriptions[0].uri,
          'https://127.0.0.1',
        );
        expect(
          fakeVideoPlayerPlatform.dataSourceDescriptions[0].formatHint,
          'dash',
        );
        expect(
          fakeVideoPlayerPlatform.dataSourceDescriptions[0].httpHeaders,
          {},
        );
      });

      test('network with some headers', () async {
        final VideoPlayerController controller = VideoPlayerController.network(
          'https://127.0.0.1',
          httpHeaders: {'Authorization': 'Bearer token'},
        );
        await controller.initialize();

        expect(
          fakeVideoPlayerPlatform.dataSourceDescriptions[0].uri,
          'https://127.0.0.1',
        );
        expect(
          fakeVideoPlayerPlatform.dataSourceDescriptions[0].formatHint,
          null,
        );
        expect(
          fakeVideoPlayerPlatform.dataSourceDescriptions[0].httpHeaders,
          {'Authorization': 'Bearer token'},
        );
      });

      test('init errors', () async {
        final VideoPlayerController controller = VideoPlayerController.network(
          'http://testing.com/invalid_url',
        );
        try {
          late dynamic error;
          fakeVideoPlayerPlatform.forceInitError = true;
          await controller.initialize().catchError((dynamic e) => error = e);
          final PlatformException platformEx = error;
          expect(platformEx.code, equals('VideoError'));
        } finally {
          fakeVideoPlayerPlatform.forceInitError = false;
        }
      });

      test('file', () async {
        final VideoPlayerController controller =
            VideoPlayerController.file(File('a.avi'));
        await controller.initialize();

        expect(fakeVideoPlayerPlatform.dataSourceDescriptions[0].uri,
            'file://a.avi');
      });
    });

    test('contentUri', () async {
      final VideoPlayerController controller =
          VideoPlayerController.contentUri(Uri.parse('content://video'));
      await controller.initialize();

      expect(fakeVideoPlayerPlatform.dataSourceDescriptions[0].uri,
          'content://video');
    });

    test('dispose', () async {
      final VideoPlayerController controller = VideoPlayerController.network(
        'https://127.0.0.1',
      );
      expect(
          controller.textureId, VideoPlayerController.kUninitializedTextureId);
      expect(await controller.position, const Duration(seconds: 0));
      await controller.initialize();

      await controller.dispose();

      expect(controller.textureId, 0);
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

      // The two last calls will be "play" and then "setPlaybackSpeed". The
      // reason for this is that "play" calls "setPlaybackSpeed" internally.
      expect(
          fakeVideoPlayerPlatform
              .calls[fakeVideoPlayerPlatform.calls.length - 2],
          'play');
      expect(fakeVideoPlayerPlatform.calls.last, 'setPlaybackSpeed');
    });

    test('play before initialized does not call platform', () async {
      final VideoPlayerController controller = VideoPlayerController.network(
        'https://127.0.0.1',
      );
      expect(controller.value.isInitialized, isFalse);

      await controller.play();

      expect(fakeVideoPlayerPlatform.calls, isEmpty);
    });

    test('play restarts from beginning if video is at end', () async {
      final VideoPlayerController controller = VideoPlayerController.network(
        'https://127.0.0.1',
      );
      await controller.initialize();
      const Duration nonzeroDuration = Duration(milliseconds: 100);
      controller.value = controller.value.copyWith(duration: nonzeroDuration);
      await controller.seekTo(nonzeroDuration);
      expect(controller.value.isPlaying, isFalse);
      expect(controller.value.position, nonzeroDuration);

      await controller.play();

      expect(controller.value.isPlaying, isTrue);
      expect(controller.value.position, Duration.zero);
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
      expect(fakeVideoPlayerPlatform.calls.last, 'pause');
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

      test('before initialized does not call platform', () async {
        final VideoPlayerController controller = VideoPlayerController.network(
          'https://127.0.0.1',
        );
        expect(controller.value.isInitialized, isFalse);

        await controller.seekTo(const Duration(milliseconds: 500));

        expect(fakeVideoPlayerPlatform.calls, isEmpty);
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

    group('setPlaybackSpeed', () {
      test('works', () async {
        final VideoPlayerController controller = VideoPlayerController.network(
          'https://127.0.0.1',
        );
        await controller.initialize();
        expect(controller.value.playbackSpeed, 1.0);

        const double speed = 1.5;
        await controller.setPlaybackSpeed(speed);

        expect(controller.value.playbackSpeed, speed);
      });

      test('rejects negative values', () async {
        final VideoPlayerController controller = VideoPlayerController.network(
          'https://127.0.0.1',
        );
        await controller.initialize();
        expect(controller.value.playbackSpeed, 1.0);

        expect(() => controller.setPlaybackSpeed(-1), throwsArgumentError);
      });
    });

    group('caption', () {
      test('works when seeking', () async {
        final VideoPlayerController controller = VideoPlayerController.network(
          'https://127.0.0.1',
          closedCaptionFile: _loadClosedCaption(),
        );

        await controller.initialize();
        expect(controller.value.position, const Duration());
        expect(controller.value.caption.text, '');

        await controller.seekTo(const Duration(milliseconds: 100));
        expect(controller.value.caption.text, 'one');

        await controller.seekTo(const Duration(milliseconds: 250));
        expect(controller.value.caption.text, '');

        await controller.seekTo(const Duration(milliseconds: 300));
        expect(controller.value.caption.text, 'two');

        await controller.seekTo(const Duration(milliseconds: 500));
        expect(controller.value.caption.text, '');

        await controller.seekTo(const Duration(milliseconds: 300));
        expect(controller.value.caption.text, 'two');
      });
    });

    group('Platform callbacks', () {
      testWidgets('playing completed', (WidgetTester tester) async {
        final VideoPlayerController controller = VideoPlayerController.network(
          'https://127.0.0.1',
        );
        await controller.initialize();
        const Duration nonzeroDuration = Duration(milliseconds: 100);
        controller.value = controller.value.copyWith(duration: nonzeroDuration);
        expect(controller.value.isPlaying, isFalse);
        await controller.play();
        expect(controller.value.isPlaying, isTrue);
        final FakeVideoEventStream fakeVideoEventStream =
            fakeVideoPlayerPlatform.streams[controller.textureId]!;

        fakeVideoEventStream.eventsChannel
            .sendEvent(<String, dynamic>{'event': 'completed'});
        await tester.pumpAndSettle();

        expect(controller.value.isPlaying, isFalse);
        expect(controller.value.position, nonzeroDuration);
      });

      testWidgets('buffering status', (WidgetTester tester) async {
        final VideoPlayerController controller = VideoPlayerController.network(
          'https://127.0.0.1',
        );
        await controller.initialize();
        expect(controller.value.isBuffering, false);
        expect(controller.value.buffered, isEmpty);
        final FakeVideoEventStream fakeVideoEventStream =
            fakeVideoPlayerPlatform.streams[controller.textureId]!;

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

      expect(uninitialized.duration, equals(Duration.zero));
      expect(uninitialized.position, equals(Duration.zero));
      expect(uninitialized.caption, equals(Caption.none));
      expect(uninitialized.buffered, isEmpty);
      expect(uninitialized.isPlaying, isFalse);
      expect(uninitialized.isLooping, isFalse);
      expect(uninitialized.isBuffering, isFalse);
      expect(uninitialized.volume, 1.0);
      expect(uninitialized.playbackSpeed, 1.0);
      expect(uninitialized.errorDescription, isNull);
      expect(uninitialized.size, equals(Size.zero));
      expect(uninitialized.isInitialized, isFalse);
      expect(uninitialized.hasError, isFalse);
      expect(uninitialized.aspectRatio, 1.0);
    });

    test('erroneous()', () {
      const String errorMessage = 'foo';
      final VideoPlayerValue error = VideoPlayerValue.erroneous(errorMessage);

      expect(error.duration, equals(Duration.zero));
      expect(error.position, equals(Duration.zero));
      expect(error.caption, equals(Caption.none));
      expect(error.buffered, isEmpty);
      expect(error.isPlaying, isFalse);
      expect(error.isLooping, isFalse);
      expect(error.isBuffering, isFalse);
      expect(error.volume, 1.0);
      expect(error.playbackSpeed, 1.0);
      expect(error.errorDescription, errorMessage);
      expect(error.size, equals(Size.zero));
      expect(error.isInitialized, isFalse);
      expect(error.hasError, isTrue);
      expect(error.aspectRatio, 1.0);
    });

    test('toString()', () {
      const Duration duration = Duration(seconds: 5);
      const Size size = Size(400, 300);
      const Duration position = Duration(seconds: 1);
      const Caption caption = Caption(
          text: 'foo', number: 0, start: Duration.zero, end: Duration.zero);
      final List<DurationRange> buffered = <DurationRange>[
        DurationRange(const Duration(seconds: 0), const Duration(seconds: 4))
      ];
      const bool isInitialized = true;
      const bool isPlaying = true;
      const bool isLooping = true;
      const bool isBuffering = true;
      const double volume = 0.5;
      const double playbackSpeed = 1.5;

      final VideoPlayerValue value = VideoPlayerValue(
        duration: duration,
        size: size,
        position: position,
        caption: caption,
        buffered: buffered,
        isInitialized: isInitialized,
        isPlaying: isPlaying,
        isLooping: isLooping,
        isBuffering: isBuffering,
        volume: volume,
        playbackSpeed: playbackSpeed,
      );

      expect(
          value.toString(),
          'VideoPlayerValue(duration: 0:00:05.000000, '
          'size: Size(400.0, 300.0), '
          'position: 0:00:01.000000, '
          'caption: Caption(number: 0, start: 0:00:00.000000, end: 0:00:00.000000, text: foo), '
          'buffered: [DurationRange(start: 0:00:00.000000, end: 0:00:04.000000)], '
          'isInitialized: true, '
          'isPlaying: true, '
          'isLooping: true, '
          'isBuffering: true, '
          'volume: 0.5, '
          'playbackSpeed: 1.5, '
          'errorDescription: null)');
    });

    test('copyWith()', () {
      final VideoPlayerValue original = VideoPlayerValue.uninitialized();
      final VideoPlayerValue exactCopy = original.copyWith();

      expect(exactCopy.toString(), original.toString());
    });

    group('aspectRatio', () {
      test('640x480 -> 4:3', () {
        final value = VideoPlayerValue(
          isInitialized: true,
          size: Size(640, 480),
          duration: Duration(seconds: 1),
        );
        expect(value.aspectRatio, 4 / 3);
      });

      test('no size -> 1.0', () {
        final value = VideoPlayerValue(
          isInitialized: true,
          duration: Duration(seconds: 1),
        );
        expect(value.aspectRatio, 1.0);
      });

      test('height = 0 -> 1.0', () {
        final value = VideoPlayerValue(
          isInitialized: true,
          size: Size(640, 0),
          duration: Duration(seconds: 1),
        );
        expect(value.aspectRatio, 1.0);
      });

      test('width = 0 -> 1.0', () {
        final value = VideoPlayerValue(
          isInitialized: true,
          size: Size(0, 480),
          duration: Duration(seconds: 1),
        );
        expect(value.aspectRatio, 1.0);
      });

      test('negative aspect ratio -> 1.0', () {
        final value = VideoPlayerValue(
          isInitialized: true,
          size: Size(640, -480),
          duration: Duration(seconds: 1),
        );
        expect(value.aspectRatio, 1.0);
      });
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

  test('setMixWithOthers', () async {
    final VideoPlayerController controller = VideoPlayerController.file(
        File(''),
        videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true));
    await controller.initialize();
    expect(controller.videoPlayerOptions!.mixWithOthers, true);
  });
}

class FakeVideoPlayerPlatform extends TestHostVideoPlayerApi {
  FakeVideoPlayerPlatform() {
    TestHostVideoPlayerApi.setup(this);
  }

  Completer<bool> initialized = Completer<bool>();
  List<String> calls = <String>[];
  List<CreateMessage> dataSourceDescriptions = <CreateMessage>[];
  final Map<int, FakeVideoEventStream> streams = <int, FakeVideoEventStream>{};
  bool forceInitError = false;
  int nextTextureId = 0;
  final Map<int, Duration> _positions = <int, Duration>{};

  @override
  TextureMessage create(CreateMessage arg) {
    calls.add('create');
    streams[nextTextureId] = FakeVideoEventStream(
        nextTextureId, 100, 100, const Duration(seconds: 1), forceInitError);
    TextureMessage result = TextureMessage();
    result.textureId = nextTextureId++;
    dataSourceDescriptions.add(arg);
    return result;
  }

  @override
  void dispose(TextureMessage arg) {
    calls.add('dispose');
  }

  @override
  void initialize() {
    calls.add('init');
    initialized.complete(true);
  }

  @override
  void pause(TextureMessage arg) {
    calls.add('pause');
  }

  @override
  void play(TextureMessage arg) {
    calls.add('play');
  }

  @override
  PositionMessage position(TextureMessage arg) {
    calls.add('position');
    final Duration position =
        _positions[arg.textureId] ?? const Duration(seconds: 0);
    return PositionMessage()..position = position.inMilliseconds;
  }

  @override
  void seekTo(PositionMessage arg) {
    calls.add('seekTo');
    _positions[arg.textureId!] = Duration(milliseconds: arg.position!);
  }

  @override
  void setLooping(LoopingMessage arg) {
    calls.add('setLooping');
  }

  @override
  void setVolume(VolumeMessage arg) {
    calls.add('setVolume');
  }

  @override
  void setPlaybackSpeed(PlaybackSpeedMessage arg) {
    calls.add('setPlaybackSpeed');
  }

  @override
  void setMixWithOthers(MixWithOthersMessage arg) {
    calls.add('setMixWithOthers');
  }
}

class FakeVideoEventStream {
  FakeVideoEventStream(this.textureId, this.width, this.height, this.duration,
      this.initWithError) {
    eventsChannel = FakeEventsChannel(
        'flutter.io/videoPlayer/videoEvents$textureId', onListen);
  }

  int textureId;
  int width;
  int height;
  Duration duration;
  bool initWithError;
  late FakeEventsChannel eventsChannel;

  void onListen() {
    if (!initWithError) {
      eventsChannel.sendEvent(<String, dynamic>{
        'event': 'initialized',
        'duration': duration.inMilliseconds,
        'width': width,
        'height': height,
      });
    } else {
      eventsChannel.sendError('VideoError', 'Video player had error XYZ');
    }
  }
}

class FakeEventsChannel {
  FakeEventsChannel(String name, this.onListen) {
    eventsMethodChannel = MethodChannel(name);
    eventsMethodChannel.setMockMethodCallHandler(onMethodCall);
  }

  late MethodChannel eventsMethodChannel;
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
    _sendMessage(const StandardMethodCodec().encodeSuccessEnvelope(event));
  }

  void sendError(String code, [String? message, dynamic details]) {
    _sendMessage(const StandardMethodCodec().encodeErrorEnvelope(
      code: code,
      message: message,
      details: details,
    ));
  }

  void _sendMessage(ByteData data) {
    _ambiguate(ServicesBinding.instance)!
        .defaultBinaryMessenger
        .handlePlatformMessage(
            eventsMethodChannel.name, data, (ByteData? data) {});
  }
}

/// This allows a value of type T or T? to be treated as a value of type T?.
///
/// We use this so that APIs that have become non-nullable can still be used
/// with `!` and `?` on the stable branch.
// TODO(ianh): Remove this once we roll stable in late 2021.
T? _ambiguate<T>(T? value) => value;
