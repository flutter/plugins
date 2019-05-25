// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:meta/meta.dart';

final MethodChannel _channel = const MethodChannel('flutter.io/audioPlayer')
// This will clear all open audios on the platform when a full restart is
// performed.
// TODO(amirh): remove this on when the invokeMethod update makes it to stable Flutter.
// https://github.com/flutter/flutter/issues/26431
// ignore: strong_mode_implicit_dynamic_method
  ..invokeMethod('init');

class AudioDurationRange {
  AudioDurationRange(this.start, this.end);

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

/// The duration, current position, buffering state, error state and settings
/// of a [AudioPlayerController].
class AudioPlayerValue {
  AudioPlayerValue({
    @required this.duration,
    this.size,
    this.position = const Duration(),
    this.buffered = const <AudioDurationRange>[],
    this.isPlaying = false,
    this.isLooping = false,
    this.isBuffering = false,
    this.volume = 1.0,
    this.speed = 1.0,
    this.errorDescription,
  });

  AudioPlayerValue.uninitialized() : this(duration: null);

  AudioPlayerValue.erroneous(String errorDescription)
      : this(duration: null, errorDescription: errorDescription);

  /// The total duration of the audio.
  ///
  /// Is null when [initialized] is false.
  final Duration duration;

  /// The current playback position.
  final Duration position;

  /// The currently buffered ranges.
  final List<AudioDurationRange> buffered;

  /// True if the audio is playing. False if it's paused.
  final bool isPlaying;

  /// True if the audio is looping.
  final bool isLooping;

  /// True if the audio is currently buffering.
  final bool isBuffering;

  /// The current volume of the playback.
  final double volume;

  /// The current speed of the playback.
  final double speed;

  /// A description of the error if present.
  ///
  /// If [hasError] is false this is [null].
  final String errorDescription;

  /// The [size] of the currently loaded audio.
  ///
  /// Is null when [initialized] is false.
  final Size size;

  bool get initialized => duration != null;

  bool get hasError => errorDescription != null;

  double get aspectRatio => size != null ? size.width / size.height : 1.0;

  AudioPlayerValue copyWith({
    Duration duration,
    Size size,
    Duration position,
    List<AudioDurationRange> buffered,
    bool isPlaying,
    bool isLooping,
    bool isBuffering,
    double volume,
    double speed,
    String errorDescription,
  }) {
    return AudioPlayerValue(
      duration: duration ?? this.duration,
      size: size ?? this.size,
      position: position ?? this.position,
      buffered: buffered ?? this.buffered,
      isPlaying: isPlaying ?? this.isPlaying,
      isLooping: isLooping ?? this.isLooping,
      isBuffering: isBuffering ?? this.isBuffering,
      volume: volume ?? this.volume,
      speed: speed ?? this.speed,
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
        'isPlaying: $isPlaying, '
        'isLooping: $isLooping, '
        'isBuffering: $isBuffering, '
        'volume: $volume, '
        'speed: $speed, '
        'errorDescription: $errorDescription)';
  }
}

enum DataSourceType { asset, network, file }

/// Controls a platform audio player, and provides updates when the state is
/// changing.
///
/// Instances must be initialized with initialize.
///
/// The audio is displayed in a Flutter app by creating a [AudioPlayer] widget.
///
/// To reclaim the resources used by the player call [dispose].
///
/// After [dispose] all further calls are ignored.
class AudioPlayerController extends ValueNotifier<AudioPlayerValue> {
  /// Constructs a [AudioPlayerController] playing a audio from an asset.
  ///
  /// The name of the asset is given by the [dataSource] argument and must not be
  /// null. The [package] argument must be non-null when the asset comes from a
  /// package and null otherwise.
  AudioPlayerController.asset(this.dataSource, {this.package})
      : dataSourceType = DataSourceType.asset,
        super(AudioPlayerValue(duration: null));

  /// Constructs a [AudioPlayerController] playing a audio from obtained from
  /// the network.
  ///
  /// The URI for the audio is given by the [dataSource] argument and must not be
  /// null.
  AudioPlayerController.network(this.dataSource)
      : dataSourceType = DataSourceType.network,
        package = null,
        super(AudioPlayerValue(duration: null));

  /// Constructs a [AudioPlayerController] playing a audio from a file.
  ///
  /// This will load the file from the file-URI given by:
  /// `'file://${file.path}'`.
  AudioPlayerController.file(File file)
      : dataSource = 'file://${file.path}',
        dataSourceType = DataSourceType.file,
        package = null,
        super(AudioPlayerValue(duration: null));

  int _textureId;
  final String dataSource;

  /// Describes the type of data source this [AudioPlayerController]
  /// is constructed with.
  final DataSourceType dataSourceType;

  final String package;
  Timer _timer;
  bool _isDisposed = false;
  Completer<void> _creatingCompleter;
  StreamSubscription<dynamic> _eventSubscription;
  _AudioAppLifeCycleObserver _lifeCycleObserver;

  @visibleForTesting
  int get textureId => _textureId;

  Future<void> initialize() async {
    _lifeCycleObserver = _AudioAppLifeCycleObserver(this);
    _lifeCycleObserver.initialize();
    _creatingCompleter = Completer<void>();
    Map<dynamic, dynamic> dataSourceDescription;
    switch (dataSourceType) {
      case DataSourceType.asset:
        dataSourceDescription = <String, dynamic>{
          'asset': dataSource,
          'package': package
        };
        break;
      case DataSourceType.network:
        dataSourceDescription = <String, dynamic>{'uri': dataSource};
        break;
      case DataSourceType.file:
        dataSourceDescription = <String, dynamic>{'uri': dataSource};
    }
    // TODO(amirh): remove this on when the invokeMethod update makes it to stable Flutter.
    // https://github.com/flutter/flutter/issues/26431
    // ignore: strong_mode_implicit_dynamic_method
    final Map<dynamic, dynamic> response = await _channel.invokeMethod(
      'create',
      dataSourceDescription,
    );
    _textureId = response['textureId'];
    _creatingCompleter.complete(null);
    final Completer<void> initializingCompleter = Completer<void>();

    AudioDurationRange toDurationRange(dynamic value) {
      final List<dynamic> pair = value;
      return AudioDurationRange(
        Duration(milliseconds: pair[0]),
        Duration(milliseconds: pair[1]),
      );
    }

    void eventListener(dynamic event) {
      final Map<dynamic, dynamic> map = event;
      switch (map['event']) {
        case 'initialized':
          value = value.copyWith(
            duration: Duration(milliseconds: map['duration']),
            size: Size(map['width']?.toDouble() ?? 0.0,
                map['height']?.toDouble() ?? 0.0),
          );
          initializingCompleter.complete(null);
          _applyLooping();
          _applyVolume();
          _applySpeed();
          _applyPlayPause();
          break;
        case 'completed':
          value = value.copyWith(isPlaying: false, position: value.duration);
          _timer?.cancel();
          break;
        case 'bufferingUpdate':
          final List<dynamic> values = map['values'];
          value = value.copyWith(
            buffered: values.map<AudioDurationRange>(toDurationRange).toList(),
          );
          break;
        case 'bufferingStart':
          value = value.copyWith(isBuffering: true);
          break;
        case 'bufferingEnd':
          value = value.copyWith(isBuffering: false);
          break;
      }
    }

    void errorListener(Object obj) {
      final PlatformException e = obj;
      value = AudioPlayerValue.erroneous(e.message);
      _timer?.cancel();
    }

    _eventSubscription = _eventChannelFor(_textureId)
        .receiveBroadcastStream()
        .listen(eventListener, onError: errorListener);
    return initializingCompleter.future;
  }

  EventChannel _eventChannelFor(int textureId) {
    return EventChannel('flutter.io/audioPlayer/audioEvents$textureId');
  }

  @override
  Future<void> dispose() async {
    if (_creatingCompleter != null) {
      await _creatingCompleter.future;
      if (!_isDisposed) {
        _isDisposed = true;
        _timer?.cancel();
        await _eventSubscription?.cancel();
        // TODO(amirh): remove this on when the invokeMethod update makes it to stable Flutter.
        // https://github.com/flutter/flutter/issues/26431
        // ignore: strong_mode_implicit_dynamic_method
        await _channel.invokeMethod(
          'dispose',
          <String, dynamic>{'textureId': _textureId},
        );
      }
      _lifeCycleObserver.dispose();
    }
    _isDisposed = true;
    super.dispose();
  }

  Future<void> play() async {
    value = value.copyWith(isPlaying: true);
    await _applyPlayPause();
  }

  Future<void> setLooping(bool looping) async {
    value = value.copyWith(isLooping: looping);
    await _applyLooping();
  }

  Future<void> pause() async {
    value = value.copyWith(isPlaying: false);
    await _applyPlayPause();
  }

  Future<void> _applyLooping() async {
    if (!value.initialized || _isDisposed) {
      return;
    }
    // TODO(amirh): remove this on when the invokeMethod update makes it to stable Flutter.
    // https://github.com/flutter/flutter/issues/26431
    // ignore: strong_mode_implicit_dynamic_method
    _channel.invokeMethod(
      'setLooping',
      <String, dynamic>{'textureId': _textureId, 'looping': value.isLooping},
    );
  }

  Future<void> _applyPlayPause() async {
    if (!value.initialized || _isDisposed) {
      return;
    }
    if (value.isPlaying) {
      // TODO(amirh): remove this on when the invokeMethod update makes it to stable Flutter.
      // https://github.com/flutter/flutter/issues/26431
      // ignore: strong_mode_implicit_dynamic_method
      await _channel.invokeMethod(
        'play',
        <String, dynamic>{'textureId': _textureId},
      );
      _timer = Timer.periodic(
        const Duration(milliseconds: 500),
        (Timer timer) async {
          if (_isDisposed) {
            return;
          }
          final Duration newPosition = await position;
          if (_isDisposed) {
            return;
          }
          value = value.copyWith(position: newPosition);
        },
      );
    } else {
      _timer?.cancel();
      // TODO(amirh): remove this on when the invokeMethod update makes it to stable Flutter.
      // https://github.com/flutter/flutter/issues/26431
      // ignore: strong_mode_implicit_dynamic_method
      await _channel.invokeMethod(
        'pause',
        <String, dynamic>{'textureId': _textureId},
      );
    }
  }

  Future<void> _applyVolume() async {
    if (!value.initialized || _isDisposed) {
      return;
    }
    // TODO(amirh): remove this on when the invokeMethod update makes it to stable Flutter.
    // https://github.com/flutter/flutter/issues/26431
    // ignore: strong_mode_implicit_dynamic_method
    await _channel.invokeMethod(
      'setVolume',
      <String, dynamic>{'textureId': _textureId, 'volume': value.volume},
    );
  }

  Future<void> _applySpeed() async {
    if (!value.initialized || _isDisposed) {
      return;
    }
    // TODO(amirh): remove this on when the invokeMethod update makes it to stable Flutter.
    // https://github.com/flutter/flutter/issues/26431
    // ignore: strong_mode_implicit_dynamic_method
    await _channel.invokeMethod(
      'setSpeed',
      <String, dynamic>{'textureId': _textureId, 'speed': value.speed},
    );
  }

  /// The position in the current audio.
  Future<Duration> get position async {
    if (_isDisposed) {
      return null;
    }
    return Duration(
      // TODO(amirh): remove this on when the invokeMethod update makes it to stable Flutter.
      // https://github.com/flutter/flutter/issues/26431
      // ignore: strong_mode_implicit_dynamic_method
      milliseconds: await _channel.invokeMethod(
        'position',
        <String, dynamic>{'textureId': _textureId},
      ),
    );
  }

  Future<void> seekTo(Duration moment) async {
    if (_isDisposed) {
      return;
    }
    if (moment > value.duration) {
      moment = value.duration;
    } else if (moment < const Duration()) {
      moment = const Duration();
    }
    // TODO(amirh): remove this on when the invokeMethod update makes it to stable Flutter.
    // https://github.com/flutter/flutter/issues/26431
    // ignore: strong_mode_implicit_dynamic_method
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
  Future<void> setVolume(double volume) async {
    value = value.copyWith(volume: volume.clamp(0.0, 1.0));
    await _applyVolume();
  }

  /// Sets the playback speed of [this].
  ///
  /// [speed] must be greater than zero.
  Future<void> setSpeed(double speed) async {
    if (speed <= 0.0) return;
    value = value.copyWith(speed: speed);
    await _applySpeed();
  }
}

class _AudioAppLifeCycleObserver extends Object with WidgetsBindingObserver {
  _AudioAppLifeCycleObserver(this._controller);

  bool _wasPlayingBeforePause = false;
  final AudioPlayerController _controller;

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

/// Displays the audio controlled by [controller].
class AudioPlayer extends StatefulWidget {
  AudioPlayer(this.controller);

  final AudioPlayerController controller;

  @override
  _AudioPlayerState createState() => _AudioPlayerState();
}

class _AudioPlayerState extends State<AudioPlayer> {
  _AudioPlayerState() {
    _listener = () {
      final int newTextureId = widget.controller.textureId;
      if (newTextureId != _textureId) {
        setState(() {
          _textureId = newTextureId;
        });
      }
    };
  }

  VoidCallback _listener;
  int _textureId;

  @override
  void initState() {
    super.initState();
    _textureId = widget.controller.textureId;
    // Need to listen for initialization events since the actual texture ID
    // becomes available after asynchronous initialization finishes.
    widget.controller.addListener(_listener);
  }

  @override
  void didUpdateWidget(AudioPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    oldWidget.controller.removeListener(_listener);
    _textureId = widget.controller.textureId;
    widget.controller.addListener(_listener);
  }

  @override
  void deactivate() {
    super.deactivate();
    widget.controller.removeListener(_listener);
  }

  @override
  Widget build(BuildContext context) {
    return _textureId == null ? Container() : Texture(textureId: _textureId);
  }
}

class AudioProgressColors {
  AudioProgressColors({
    this.playedColor = const Color.fromRGBO(255, 0, 0, 0.7),
    this.bufferedColor = const Color.fromRGBO(50, 50, 200, 0.2),
    this.backgroundColor = const Color.fromRGBO(200, 200, 200, 0.5),
  });

  final Color playedColor;
  final Color bufferedColor;
  final Color backgroundColor;
}

class _AudioScrubber extends StatefulWidget {
  _AudioScrubber({
    @required this.child,
    @required this.controller,
  });

  final Widget child;
  final AudioPlayerController controller;

  @override
  _AudioScrubberState createState() => _AudioScrubberState();
}

class _AudioScrubberState extends State<_AudioScrubber> {
  bool _controllerWasPlaying = false;

  AudioPlayerController get controller => widget.controller;

  @override
  Widget build(BuildContext context) {
    void seekToRelativePosition(Offset globalPosition) {
      final RenderBox box = context.findRenderObject();
      final Offset tapPos = box.globalToLocal(globalPosition);
      final double relative = tapPos.dx / box.size.width;
      final Duration position = controller.value.duration * relative;
      controller.seekTo(position);
    }

    return GestureDetector(
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

/// Displays the play/buffering status of the audio controlled by [controller].
///
/// If [allowScrubbing] is true, this widget will detect taps and drags and
/// seek the audio accordingly.
///
/// [padding] allows to specify some extra padding around the progress indicator
/// that will also detect the gestures.
class AudioProgressIndicator extends StatefulWidget {
  AudioProgressIndicator(
    this.controller, {
    AudioProgressColors colors,
    this.allowScrubbing,
    this.padding = const EdgeInsets.only(top: 5.0),
  }) : colors = colors ?? AudioProgressColors();

  final AudioPlayerController controller;
  final AudioProgressColors colors;
  final bool allowScrubbing;
  final EdgeInsets padding;

  @override
  _AudioProgressIndicatorState createState() => _AudioProgressIndicatorState();
}

class _AudioProgressIndicatorState extends State<AudioProgressIndicator> {
  _AudioProgressIndicatorState() {
    listener = () {
      if (!mounted) {
        return;
      }
      setState(() {});
    };
  }

  VoidCallback listener;

  AudioPlayerController get controller => widget.controller;

  AudioProgressColors get colors => widget.colors;

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
      for (AudioDurationRange range in controller.value.buffered) {
        final int end = range.end.inMilliseconds;
        if (end > maxBuffering) {
          maxBuffering = end;
        }
      }

      progressIndicator = Stack(
        fit: StackFit.passthrough,
        children: <Widget>[
          LinearProgressIndicator(
            value: maxBuffering / duration,
            valueColor: AlwaysStoppedAnimation<Color>(colors.bufferedColor),
            backgroundColor: colors.backgroundColor,
          ),
          LinearProgressIndicator(
            value: position / duration,
            valueColor: AlwaysStoppedAnimation<Color>(colors.playedColor),
            backgroundColor: Colors.transparent,
          ),
        ],
      );
    } else {
      progressIndicator = LinearProgressIndicator(
        value: null,
        valueColor: AlwaysStoppedAnimation<Color>(colors.playedColor),
        backgroundColor: colors.backgroundColor,
      );
    }
    final Widget paddedProgressIndicator = Padding(
      padding: widget.padding,
      child: progressIndicator,
    );
    if (widget.allowScrubbing) {
      return _AudioScrubber(
        child: paddedProgressIndicator,
        controller: controller,
      );
    } else {
      return paddedProgressIndicator;
    }
  }
}
