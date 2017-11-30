// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:meta/meta.dart';

final MethodChannel _channel = const MethodChannel('flutter.io/videoPlayer')
  // This will clear all open videos on the platform when a full restart is
  // performed.
  ..invokeMethod("init");

class DurationRange {
  DurationRange(this.start, this.end);

  final Duration start;
  final Duration end;

  double startFraction(Duration duration) {
    return start.inMilliseconds / duration.inMilliseconds;
  }

  double endFraction(Duration duration) {
    return end.inMilliseconds / duration.inMilliseconds;
  }
}

class VideoPlayerValue {
  final Duration duration;
  final Duration position;
  final List<DurationRange> buffered;
  final bool isPlaying;
  final bool isLooping;
  final double volume;
  final String errorDescription;

  VideoPlayerValue({
    @required this.duration,
    this.position: const Duration(),
    this.buffered: const <DurationRange>[],
    this.isPlaying: false,
    this.isLooping: false,
    this.volume: 1.0,
    this.errorDescription,
  });

  VideoPlayerValue.uninitialized() : this(duration: null);

  VideoPlayerValue.erroneous(String errorDescription)
      : this(duration: null, errorDescription: errorDescription);

  bool get initialized => duration != null;
  bool get isErroneous => errorDescription != null;

  VideoPlayerValue copyWith({
    Duration duration,
    Duration position,
    List<DurationRange> buffered,
    bool isPlaying,
    bool isLooping,
    double volume,
    String errorDescription,
  }) {
    return new VideoPlayerValue(
      duration: duration ?? this.duration,
      position: position ?? this.position,
      buffered: buffered ?? this.buffered,
      isPlaying: isPlaying ?? this.isPlaying,
      isLooping: isLooping ?? this.isLooping,
      volume: volume ?? this.volume,
      errorDescription: errorDescription ?? this.errorDescription,
    );
  }
}

/// Controls a platform video player, and provides updates when the state is
/// changing.
///
/// Instances must be initialized with initialize.
///
/// The video is displayed in a Flutter app by creating a [VideoPlayer] widget.
///
/// To reclaim the resources used by the player call [dispose].
///
/// After [dispose] all further calls are ignored.
class VideoPlayerController extends ValueNotifier<VideoPlayerValue> {
  int _textureId;
  final String uri;
  Timer timer;
  bool isDisposed = false;
  Completer<Null> _creatingCompleter;
  StreamSubscription<Map<String, dynamic>> _eventSubscription;
  _VideoAppLifeCycleObserver _lifeCycleObserver;

  VideoPlayerController(this.uri) : super(new VideoPlayerValue(duration: null));

  Future<Null> initialize() async {
    _lifeCycleObserver = new _VideoAppLifeCycleObserver(this);
    _lifeCycleObserver.initialize();
    _creatingCompleter = new Completer<Null>();
    final Map<String, dynamic> response = await _channel.invokeMethod(
      'create',
      <String, dynamic>{'dataSource': uri},
    );
    _textureId = response["textureId"];
    _creatingCompleter.complete(null);

    DurationRange toDurationRange(List<int> values) {
      return new DurationRange(
        new Duration(milliseconds: values[0]),
        new Duration(milliseconds: values[1]),
      );
    }

    void eventListener(Map<String, dynamic> event) {
      if (event["event"] == "initialized") {
        value = value.copyWith(
          duration: new Duration(milliseconds: event["duration"]),
        );
        _applyLooping();
        _applyVolume();
        _applyPlayPause();
      } else if (event["event"] == "completed") {
        value = value.copyWith(isPlaying: false);
        timer?.cancel();
      } else if (event["event"] == "bufferingUpdate") {
        final List<List<int>> bufferedValues = event["values"];
        value = value.copyWith(
          buffered: bufferedValues.map(toDurationRange).toList(),
        );
      }
    }

    void errorListener(PlatformException e) {
      value = new VideoPlayerValue.erroneous(e.message);
      timer?.cancel();
    }

    _eventSubscription = _eventChannelFor(_textureId)
        .receiveBroadcastStream()
        .listen(eventListener, onError: errorListener);
  }

  EventChannel _eventChannelFor(int textureId) {
    return new EventChannel("flutter.io/videoPlayer/videoEvents$textureId");
  }

  @override
  Future<Null> dispose() async {
    if (_creatingCompleter != null) {
      await _creatingCompleter.future;
      if (!isDisposed) {
        timer?.cancel();
        await _eventSubscription?.cancel();
        await _channel.invokeMethod(
          'dispose',
          <String, dynamic>{'textureId': _textureId},
        );
      }
      _lifeCycleObserver.dispose();
    }
    isDisposed = true;
    super.dispose();
  }

  Future<Null> play() async {
    value = value.copyWith(isPlaying: true);
    await _applyPlayPause();
  }

  Future<Null> setLooping(bool looping) async {
    value = value.copyWith(isLooping: looping);
    await _applyLooping();
  }

  Future<Null> pause() async {
    value = value.copyWith(isPlaying: false);
    await _applyPlayPause();
  }

  Future<Null> _applyLooping() async {
    if (!value.initialized || isDisposed) {
      return;
    }
    _channel.invokeMethod(
      'setLooping',
      <String, dynamic>{'textureId': _textureId, 'looping': value.isLooping},
    );
  }

  Future<Null> _applyPlayPause() async {
    if (!value.initialized || isDisposed) {
      return;
    }
    if (value.isPlaying) {
      await _channel.invokeMethod(
        'play',
        <String, dynamic>{'textureId': _textureId},
      );
      timer = new Timer.periodic(
        const Duration(milliseconds: 500),
        (Timer timer) async {
          final Duration newPosition = await position;
          value = value.copyWith(position: newPosition);
        },
      );
    } else {
      timer?.cancel();
      await _channel.invokeMethod(
        'pause',
        <String, dynamic>{'textureId': _textureId},
      );
    }
  }

  Future<Null> _applyVolume() async {
    if (!value.initialized || isDisposed) {
      return;
    }
    await _channel.invokeMethod(
      'setVolume',
      <String, dynamic>{'textureId': _textureId, 'volume': value.volume},
    );
  }

  /// The position in the current video.
  Future<Duration> get position async {
    if (isDisposed) {
      return null;
    }
    return new Duration(
      milliseconds: await _channel.invokeMethod(
        'position',
        <String, dynamic>{'textureId': _textureId},
      ),
    );
  }

  Future<Null> seekTo(Duration moment) async {
    if (isDisposed) {
      return;
    }
    if (moment > value.duration) {
      moment = value.duration;
    } else if (moment < const Duration()) {
      moment = const Duration();
    }
    await _channel.invokeMethod('seekTo', <String, dynamic>{
      'textureId': _textureId,
      'location': moment.inMilliseconds,
    });
    value = value.copyWith(position: moment);
  }

  /// Sets the audio volume of [this].
  ///
  /// [volume] indicates a value between 0.0 (silent) and 1.0 (full volume) on a
  /// linear scale.
  Future<Null> setVolume(double volume) async {
    value = value.copyWith(volume: volume.clamp(0.0, 1.0));
    await _applyVolume();
  }
}

class _VideoAppLifeCycleObserver extends WidgetsBindingObserver {
  bool _wasPlayingBeforePause = false;
  final VideoPlayerController _controller;

  _VideoAppLifeCycleObserver(this._controller);

  void initialize() {
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.paused:
        _wasPlayingBeforePause = _controller.value.isPlaying;
        _controller.pause();
        break;
      case AppLifecycleState.resumed:
        if (_wasPlayingBeforePause) {
          _controller.play();
        }
        break;
      default:
    }
  }

  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
  }
}

/// Displays the video controlled by [controller].
class VideoPlayer extends StatelessWidget {
  final VideoPlayerController controller;

  VideoPlayer(this.controller);

  @override
  Widget build(BuildContext context) {
    return controller._textureId == null
        ? new Container()
        : new Texture(textureId: controller._textureId);
  }
}

class VideoProgressColors {
  final Paint playedPaint;
  final Paint bufferedPaint;
  final Paint handlePaint;
  final Paint disabledPaint;

  VideoProgressColors({
    Color playedColor: const Color.fromRGBO(255, 0, 0, 0.7),
    Color bufferedColor: const Color.fromRGBO(30, 30, 200, 0.2),
    Color handleColor: const Color.fromRGBO(200, 200, 200, 1.0),
    Color disabledColor: const Color.fromRGBO(200, 200, 200, 0.5),
  })
      : playedPaint = new Paint()..color = playedColor,
        bufferedPaint = new Paint()..color = bufferedColor,
        handlePaint = new Paint()..color = handleColor,
        disabledPaint = new Paint()..color = disabledColor;
}

/// Displays the play/buffering status of the video controlled by [controller].
class VideoProgressBar extends StatefulWidget {
  final VideoPlayerController controller;
  final VideoProgressColors colors;

  VideoProgressBar(this.controller, {VideoProgressColors colors})
      : colors = colors ?? new VideoProgressColors();

  @override
  _VideoProgressBarState createState() {
    return new _VideoProgressBarState();
  }
}

class _VideoProgressBarState extends State<VideoProgressBar> {
  VoidCallback listener;

  bool _controllerWasPlaying = false;

  _VideoProgressBarState() {
    listener = () {
      setState(() {});
    };
  }

  VideoPlayerController get controller => widget.controller;

  @override
  void initState() {
    super.initState();
    controller.addListener(listener);
  }

  @override
  void deactivate() {
    controller.removeListener(listener);
    super.deactivate();
  }

  @override
  Widget build(BuildContext context) {
    void seekToRelativePosition(Offset globalPosition) {
      final RenderBox box = context.findRenderObject();
      final Offset tapPos = box.globalToLocal(globalPosition);
      final double relative = tapPos.dx / box.size.width;
      final Duration position = controller.value.duration * relative;
      controller.seekTo(position);
    }

    return new GestureDetector(
      child: (controller.value.isErroneous)
          ? new Text(controller.value.errorDescription)
          : new CustomPaint(
              painter: new ProgressBarPainter(controller.value, widget.colors),
            ),
      onHorizontalDragStart: (DragStartDetails details) {
        if (!controller.value.initialized) {
          return;
        }
        _controllerWasPlaying = controller.value.isPlaying;
        if (_controllerWasPlaying) {
          controller.pause();
        }
      },
      onHorizontalDragUpdate: (DragUpdateDetails details) {
        if (!controller.value.initialized) {
          return;
        }
        seekToRelativePosition(details.globalPosition);
      },
      onHorizontalDragEnd: (DragEndDetails details) {
        if (_controllerWasPlaying) {
          controller.play();
        }
      },
      onTapDown: (TapDownDetails details) {
        if (!controller.value.initialized) {
          return;
        }
        seekToRelativePosition(details.globalPosition);
      },
    );
  }
}

class ProgressBarPainter extends CustomPainter {
  VideoPlayerValue value;
  VideoProgressColors colors;
  ProgressBarPainter(this.value, this.colors);

  @override
  bool shouldRepaint(CustomPainter painter) {
    return true;
  }

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
      new Rect.fromPoints(
        const Offset(0.0, 0.0),
        new Offset(size.width, size.height),
      ),
      colors.disabledPaint,
    );
    if (!value.initialized) {
      return;
    }
    final double playedPart = value.position.inMilliseconds /
        value.duration.inMilliseconds *
        size.width;
    for (DurationRange range in value.buffered) {
      final double start = range.startFraction(value.duration) * size.width;
      final double end = range.endFraction(value.duration) * size.width;
      canvas.drawRect(
        new Rect.fromPoints(
          new Offset(start, 0.0),
          new Offset(end, size.height),
        ),
        colors.bufferedPaint,
      );
    }
    canvas.drawRect(
      new Rect.fromPoints(Offset.zero, new Offset(playedPart, size.height)),
      colors.playedPaint,
    );
    canvas.drawCircle(
      new Offset(playedPart, size.height / 2),
      size.height / 2,
      colors.handlePaint,
    );
  }
}
