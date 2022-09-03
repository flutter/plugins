// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// TODO(stuartmorgan): Consider extracting this to a shared local (path-based)
// package for use in all implementation packages.

import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player_platform_interface/video_player_platform_interface.dart';

VideoPlayerPlatform? _cachedPlatform;

VideoPlayerPlatform get _platform {
  if (_cachedPlatform == null) {
    _cachedPlatform = VideoPlayerPlatform.instance;
    _cachedPlatform!.init();
  }
  return _cachedPlatform!;
}

/// The duration, current position, buffering state, error state and settings
/// of a [MiniController].
class VideoPlayerValue {
  /// Constructs a video with the given values. Only [duration] is required. The
  /// rest will initialize with default values when unset.
  VideoPlayerValue({
    required this.duration,
    this.size = Size.zero,
    this.position = Duration.zero,
    this.buffered = const <DurationRange>[],
    this.isInitialized = false,
    this.isPlaying = false,
    this.isBuffering = false,
    this.playbackSpeed = 1.0,
    this.errorDescription,
  });

  /// Returns an instance for a video that hasn't been loaded.
  VideoPlayerValue.uninitialized()
      : this(duration: Duration.zero, isInitialized: false);

  /// Returns an instance with the given [errorDescription].
  VideoPlayerValue.erroneous(String errorDescription)
      : this(
            duration: Duration.zero,
            isInitialized: false,
            errorDescription: errorDescription);

  /// The total duration of the video.
  ///
  /// The duration is [Duration.zero] if the video hasn't been initialized.
  final Duration duration;

  /// The current playback position.
  final Duration position;

  /// The currently buffered ranges.
  final List<DurationRange> buffered;

  /// True if the video is playing. False if it's paused.
  final bool isPlaying;

  /// True if the video is currently buffering.
  final bool isBuffering;

  /// The current speed of the playback.
  final double playbackSpeed;

  /// A description of the error if present.
  ///
  /// If [hasError] is false this is `null`.
  final String? errorDescription;

  /// The [size] of the currently loaded video.
  final Size size;

  /// Indicates whether or not the video has been loaded and is ready to play.
  final bool isInitialized;

  /// Indicates whether or not the video is in an error state. If this is true
  /// [errorDescription] should have information about the problem.
  bool get hasError => errorDescription != null;

  /// Returns [size.width] / [size.height].
  ///
  /// Will return `1.0` if:
  /// * [isInitialized] is `false`
  /// * [size.width], or [size.height] is equal to `0.0`
  /// * aspect ratio would be less than or equal to `0.0`
  double get aspectRatio {
    if (!isInitialized || size.width == 0 || size.height == 0) {
      return 1.0;
    }
    final double aspectRatio = size.width / size.height;
    if (aspectRatio <= 0) {
      return 1.0;
    }
    return aspectRatio;
  }

  /// Returns a new instance that has the same values as this current instance,
  /// except for any overrides passed in as arguments to [copyWidth].
  VideoPlayerValue copyWith({
    Duration? duration,
    Size? size,
    Duration? position,
    List<DurationRange>? buffered,
    bool? isInitialized,
    bool? isPlaying,
    bool? isBuffering,
    double? playbackSpeed,
    String? errorDescription,
  }) {
    return VideoPlayerValue(
      duration: duration ?? this.duration,
      size: size ?? this.size,
      position: position ?? this.position,
      buffered: buffered ?? this.buffered,
      isInitialized: isInitialized ?? this.isInitialized,
      isPlaying: isPlaying ?? this.isPlaying,
      isBuffering: isBuffering ?? this.isBuffering,
      playbackSpeed: playbackSpeed ?? this.playbackSpeed,
      errorDescription: errorDescription ?? this.errorDescription,
    );
  }
}

/// A very minimal version of `VideoPlayerController` for running the example
/// without relying on `video_player`.
class MiniController extends ValueNotifier<VideoPlayerValue> {
  /// Constructs a [MiniController] playing a video from an asset.
  ///
  /// The name of the asset is given by the [dataSource] argument and must not be
  /// null. The [package] argument must be non-null when the asset comes from a
  /// package and null otherwise.
  MiniController.asset(this.dataSource, {this.package})
      : dataSourceType = DataSourceType.asset,
        super(VideoPlayerValue(duration: Duration.zero));

  /// Constructs a [MiniController] playing a video from obtained from
  /// the network.
  MiniController.network(this.dataSource)
      : dataSourceType = DataSourceType.network,
        package = null,
        super(VideoPlayerValue(duration: Duration.zero));

  /// Constructs a [MiniController] playing a video from obtained from a file.
  MiniController.file(File file)
      : dataSource = 'file://${file.path}',
        dataSourceType = DataSourceType.file,
        package = null,
        super(VideoPlayerValue(duration: Duration.zero));

  /// The URI to the video file. This will be in different formats depending on
  /// the [DataSourceType] of the original video.
  final String dataSource;

  /// Describes the type of data source this [MiniController]
  /// is constructed with.
  final DataSourceType dataSourceType;

  /// Only set for [asset] videos. The package that the asset was loaded from.
  final String? package;

  Timer? _timer;
  Completer<void>? _creatingCompleter;
  StreamSubscription<dynamic>? _eventSubscription;

  /// The id of a texture that hasn't been initialized.
  @visibleForTesting
  static const int kUninitializedTextureId = -1;
  int _textureId = kUninitializedTextureId;

  /// This is just exposed for testing. It shouldn't be used by anyone depending
  /// on the plugin.
  @visibleForTesting
  int get textureId => _textureId;

  /// Attempts to open the given [dataSource] and load metadata about the video.
  Future<void> initialize() async {
    _creatingCompleter = Completer<void>();

    late DataSource dataSourceDescription;
    switch (dataSourceType) {
      case DataSourceType.asset:
        dataSourceDescription = DataSource(
          sourceType: DataSourceType.asset,
          asset: dataSource,
          package: package,
        );
        break;
      case DataSourceType.network:
        dataSourceDescription = DataSource(
          sourceType: DataSourceType.network,
          uri: dataSource,
        );
        break;
      case DataSourceType.file:
        dataSourceDescription = DataSource(
          sourceType: DataSourceType.file,
          uri: dataSource,
        );
        break;
      case DataSourceType.contentUri:
        dataSourceDescription = DataSource(
          sourceType: DataSourceType.contentUri,
          uri: dataSource,
        );
        break;
    }

    _textureId = (await _platform.create(dataSourceDescription)) ??
        kUninitializedTextureId;
    _creatingCompleter!.complete(null);
    final Completer<void> initializingCompleter = Completer<void>();

    void eventListener(VideoEvent event) {
      switch (event.eventType) {
        case VideoEventType.initialized:
          value = value.copyWith(
            duration: event.duration,
            size: event.size,
            isInitialized: event.duration != null,
          );
          initializingCompleter.complete(null);
          _platform.setVolume(_textureId, 1.0);
          _platform.setLooping(_textureId, true);
          _applyPlayPause();
          break;
        case VideoEventType.completed:
          pause().then((void pauseResult) => seekTo(value.duration));
          break;
        case VideoEventType.bufferingUpdate:
          value = value.copyWith(buffered: event.buffered);
          break;
        case VideoEventType.bufferingStart:
          value = value.copyWith(isBuffering: true);
          break;
        case VideoEventType.bufferingEnd:
          value = value.copyWith(isBuffering: false);
          break;
        case VideoEventType.unknown:
          break;
      }
    }

    void errorListener(Object obj) {
      final PlatformException e = obj as PlatformException;
      value = VideoPlayerValue.erroneous(e.message!);
      _timer?.cancel();
      if (!initializingCompleter.isCompleted) {
        initializingCompleter.completeError(obj);
      }
    }

    _eventSubscription = _platform
        .videoEventsFor(_textureId)
        .listen(eventListener, onError: errorListener);
    return initializingCompleter.future;
  }

  @override
  Future<void> dispose() async {
    if (_creatingCompleter != null) {
      await _creatingCompleter!.future;
      _timer?.cancel();
      await _eventSubscription?.cancel();
      await _platform.dispose(_textureId);
    }
    super.dispose();
  }

  /// Starts playing the video.
  Future<void> play() async {
    value = value.copyWith(isPlaying: true);
    await _applyPlayPause();
  }

  /// Pauses the video.
  Future<void> pause() async {
    value = value.copyWith(isPlaying: false);
    await _applyPlayPause();
  }

  Future<void> _applyPlayPause() async {
    _timer?.cancel();
    if (value.isPlaying) {
      await _platform.play(_textureId);

      _timer = Timer.periodic(
        const Duration(milliseconds: 500),
        (Timer timer) async {
          final Duration? newPosition = await position;
          if (newPosition == null) {
            return;
          }
          _updatePosition(newPosition);
        },
      );
      await _applyPlaybackSpeed();
    } else {
      await _platform.pause(_textureId);
    }
  }

  Future<void> _applyPlaybackSpeed() async {
    if (value.isPlaying) {
      await _platform.setPlaybackSpeed(
        _textureId,
        value.playbackSpeed,
      );
    }
  }

  /// The position in the current video.
  Future<Duration?> get position async {
    return await _platform.getPosition(_textureId);
  }

  /// Sets the video's current timestamp to be at [position].
  Future<void> seekTo(Duration position) async {
    if (position > value.duration) {
      position = value.duration;
    } else if (position < Duration.zero) {
      position = Duration.zero;
    }
    await _platform.seekTo(_textureId, position);
    _updatePosition(position);
  }

  /// Sets the playback speed.
  Future<void> setPlaybackSpeed(double speed) async {
    value = value.copyWith(playbackSpeed: speed);
    await _applyPlaybackSpeed();
  }

  void _updatePosition(Duration position) {
    value = value.copyWith(position: position);
  }

  @override
  void removeListener(VoidCallback listener) {
    super.removeListener(listener);
  }
}

/// Widget that displays the video controlled by [controller].
class VideoPlayer extends StatefulWidget {
  /// Uses the given [controller] for all video rendered in this widget.
  const VideoPlayer(this.controller, {Key? key}) : super(key: key);

  /// The [MiniController] responsible for the video being rendered in
  /// this widget.
  final MiniController controller;

  @override
  State<VideoPlayer> createState() => _VideoPlayerState();
}

class _VideoPlayerState extends State<VideoPlayer> {
  _VideoPlayerState() {
    _listener = () {
      final int newTextureId = widget.controller.textureId;
      if (newTextureId != _textureId) {
        setState(() {
          _textureId = newTextureId;
        });
      }
    };
  }

  late VoidCallback _listener;

  late int _textureId;

  @override
  void initState() {
    super.initState();
    _textureId = widget.controller.textureId;
    // Need to listen for initialization events since the actual texture ID
    // becomes available after asynchronous initialization finishes.
    widget.controller.addListener(_listener);
  }

  @override
  void didUpdateWidget(VideoPlayer oldWidget) {
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
    return _textureId == MiniController.kUninitializedTextureId
        ? Container()
        : _platform.buildView(_textureId);
  }
}

class _VideoScrubber extends StatefulWidget {
  const _VideoScrubber({
    required this.child,
    required this.controller,
  });

  final Widget child;
  final MiniController controller;

  @override
  _VideoScrubberState createState() => _VideoScrubberState();
}

class _VideoScrubberState extends State<_VideoScrubber> {
  MiniController get controller => widget.controller;

  @override
  Widget build(BuildContext context) {
    void seekToRelativePosition(Offset globalPosition) {
      final RenderBox box = context.findRenderObject()! as RenderBox;
      final Offset tapPos = box.globalToLocal(globalPosition);
      final double relative = tapPos.dx / box.size.width;
      final Duration position = controller.value.duration * relative;
      controller.seekTo(position);
    }

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      child: widget.child,
      onTapDown: (TapDownDetails details) {
        if (controller.value.isInitialized) {
          seekToRelativePosition(details.globalPosition);
        }
      },
    );
  }
}

/// Displays the play/buffering status of the video controlled by [controller].
class VideoProgressIndicator extends StatefulWidget {
  /// Construct an instance that displays the play/buffering status of the video
  /// controlled by [controller].
  const VideoProgressIndicator(this.controller, {Key? key}) : super(key: key);

  /// The [MiniController] that actually associates a video with this
  /// widget.
  final MiniController controller;

  @override
  State<VideoProgressIndicator> createState() => _VideoProgressIndicatorState();
}

class _VideoProgressIndicatorState extends State<VideoProgressIndicator> {
  _VideoProgressIndicatorState() {
    listener = () {
      if (mounted) {
        setState(() {});
      }
    };
  }

  late VoidCallback listener;

  MiniController get controller => widget.controller;

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
    const Color playedColor = Color.fromRGBO(255, 0, 0, 0.7);
    const Color bufferedColor = Color.fromRGBO(50, 50, 200, 0.2);
    const Color backgroundColor = Color.fromRGBO(200, 200, 200, 0.5);

    Widget progressIndicator;
    if (controller.value.isInitialized) {
      final int duration = controller.value.duration.inMilliseconds;
      final int position = controller.value.position.inMilliseconds;

      int maxBuffering = 0;
      for (final DurationRange range in controller.value.buffered) {
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
            valueColor: const AlwaysStoppedAnimation<Color>(bufferedColor),
            backgroundColor: backgroundColor,
          ),
          LinearProgressIndicator(
            value: position / duration,
            valueColor: const AlwaysStoppedAnimation<Color>(playedColor),
            backgroundColor: Colors.transparent,
          ),
        ],
      );
    } else {
      progressIndicator = const LinearProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(playedColor),
        backgroundColor: backgroundColor,
      );
    }
    return _VideoScrubber(
      controller: controller,
      child: Padding(
        padding: const EdgeInsets.only(top: 5.0),
        child: progressIndicator,
      ),
    );
  }
}
