// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
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

  @override
  String toString() => '$runtimeType(start: $start, end: $end)';
}

class VideoPlayerValue {
  final Duration duration;
  final Duration position;
  final List<DurationRange> buffered;
  final bool isPlaying;
  final bool isLooping;
  final double volume;
  final String errorDescription;
  final Size size;

  VideoPlayerValue({
    @required this.duration,
    this.size,
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
  double get aspectRatio => size.width / size.height;

  VideoPlayerValue copyWith({
    Duration duration,
    Size size,
    Duration position,
    List<DurationRange> buffered,
    bool isPlaying,
    bool isLooping,
    double volume,
    String errorDescription,
  }) {
    return new VideoPlayerValue(
      duration: duration ?? this.duration,
      size: size ?? this.size,
      position: position ?? this.position,
      buffered: buffered ?? this.buffered,
      isPlaying: isPlaying ?? this.isPlaying,
      isLooping: isLooping ?? this.isLooping,
      volume: volume ?? this.volume,
      errorDescription: errorDescription ?? this.errorDescription,
    );
  }

  @override
  String toString() {
    return '$runtimeType('
        'duration: $duration, '
        'size: $size, '
        'position: $position, '
        'buffered: [${buffered.join(', ')}], '
        'isplaying: $isPlaying, '
        'isLooping: $isLooping, '
        'volume: $volume, '
        'errorDescription: $errorDescription)';
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

    void eventListener(dynamic event) {
      final Map<String, dynamic> map = event;
      if (map["event"] == "initialized") {
        value = value.copyWith(
          duration: new Duration(milliseconds: map["duration"]),
          size: new Size(map["width"].toDouble(), map["height"].toDouble()),
        );
        _applyLooping();
        _applyVolume();
        _applyPlayPause();
      } else if (map["event"] == "completed") {
        value = value.copyWith(isPlaying: false);
        timer?.cancel();
      } else if (map["event"] == "bufferingUpdate") {
        final List<List<int>> bufferedValues = map["values"];
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
        isDisposed = true;
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
          if (isDisposed) {
            return;
          }
          final Duration newPosition = await position;
          if (isDisposed) {
            return;
          }
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
  final Color playedColor;
  final Color bufferedColor;
  final Color backgroundColor;

  VideoProgressColors({
    this.playedColor: const Color.fromRGBO(255, 0, 0, 0.7),
    this.bufferedColor: const Color.fromRGBO(50, 50, 200, 0.2),
    this.backgroundColor: const Color.fromRGBO(200, 200, 200, 0.5),
  });
}

class _VideoScrubber extends StatefulWidget {
  final Widget child;
  final VideoPlayerController controller;

  _VideoScrubber({
    @required this.child,
    @required this.controller,
  });

  @override
  _VideoScrubberState createState() => new _VideoScrubberState();
}

class _VideoScrubberState extends State<_VideoScrubber> {
  bool _controllerWasPlaying = false;

  VideoPlayerController get controller => widget.controller;

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
      behavior: HitTestBehavior.opaque,
      child: widget.child,
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

/// Displays the play/buffering status of the video controlled by [controller].
///
/// If [allowScrubbing] is true, this widget will detect taps and drags and
/// seek the video accordingly.
///
/// [padding] allows to specify some extra padding around the progress indicator
/// that will also detect the gestures.
class VideoProgressIndicator extends StatefulWidget {
  final VideoPlayerController controller;
  final VideoProgressColors colors;
  final bool allowScrubbing;
  final EdgeInsets padding;

  VideoProgressIndicator(
    this.controller, {
    VideoProgressColors colors,
    this.allowScrubbing,
    this.padding: const EdgeInsets.only(top: 5.0),
  })
      : colors = colors ?? new VideoProgressColors();

  @override
  _VideoProgressIndicatorState createState() =>
      new _VideoProgressIndicatorState();
}

class _VideoProgressIndicatorState extends State<VideoProgressIndicator> {
  VoidCallback listener;

  _VideoProgressIndicatorState() {
    listener = () {
      if (!mounted) {
        return;
      }
      setState(() {});
    };
  }

  VideoPlayerController get controller => widget.controller;
  VideoProgressColors get colors => widget.colors;

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
    Widget progressIndicator;
    if (controller.value.initialized) {
      final int duration = controller.value.duration.inMilliseconds;
      final int position = controller.value.position.inMilliseconds;

      int maxBuffering = 0;
      for (DurationRange range in controller.value.buffered) {
        final int end = range.end.inMilliseconds;
        if (end > maxBuffering) {
          maxBuffering = end;
        }
      }

      progressIndicator = new Stack(
        fit: StackFit.passthrough,
        children: <Widget>[
          new LinearProgressIndicator(
            value: maxBuffering / duration,
            valueColor: new AlwaysStoppedAnimation<Color>(colors.bufferedColor),
            backgroundColor: colors.backgroundColor,
          ),
          new LinearProgressIndicator(
            value: position / duration,
            valueColor: new AlwaysStoppedAnimation<Color>(colors.playedColor),
            backgroundColor: Colors.transparent,
          ),
        ],
      );
    } else {
      progressIndicator = new LinearProgressIndicator(
        value: null,
        valueColor: new AlwaysStoppedAnimation<Color>(colors.playedColor),
        backgroundColor: colors.backgroundColor,
      );
    }
    final Widget paddedProgressIndicator = new Padding(
      padding: widget.padding,
      child: progressIndicator,
    );
    if (widget.allowScrubbing) {
      return new _VideoScrubber(
        child: paddedProgressIndicator,
        controller: controller,
      );
    } else {
      return paddedProgressIndicator;
    }
  }
}
