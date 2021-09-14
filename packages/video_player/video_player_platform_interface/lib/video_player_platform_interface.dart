// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:meta/meta.dart' show visibleForTesting;

import 'method_channel_video_player.dart';

/// The interface that implementations of video_player must implement.
///
/// Platform implementations should extend this class rather than implement it as `video_player`
/// does not consider newly added methods to be breaking changes. Extending this class
/// (using `extends`) ensures that the subclass will get the default implementation, while
/// platform implementations that `implements` this interface will be broken by newly added
/// [VideoPlayerPlatform] methods.
abstract class VideoPlayerPlatform {
  /// Only mock implementations should set this to true.
  ///
  /// Mockito mocks are implementing this class with `implements` which is forbidden for anything
  /// other than mocks (see class docs). This property provides a backdoor for mockito mocks to
  /// skip the verification that the class isn't implemented with `implements`.
  @visibleForTesting
  bool get isMock => false;

  static VideoPlayerPlatform _instance = MethodChannelVideoPlayer();

  /// The default instance of [VideoPlayerPlatform] to use.
  ///
  /// Platform-specific plugins should override this with their own
  /// platform-specific class that extends [VideoPlayerPlatform] when they
  /// register themselves.
  ///
  /// Defaults to [MethodChannelVideoPlayer].
  static VideoPlayerPlatform get instance => _instance;

  // TODO(amirh): Extract common platform interface logic.
  // https://github.com/flutter/flutter/issues/43368
  static set instance(VideoPlayerPlatform instance) {
    if (!instance.isMock) {
      try {
        instance._verifyProvidesDefaultImplementations();
      } on NoSuchMethodError catch (_) {
        throw AssertionError(
            'Platform interfaces must not be implemented with `implements`');
      }
    }
    _instance = instance;
  }

  /// Initializes the platform interface and disposes all existing players.
  ///
  /// This method is called when the plugin is first initialized
  /// and on every full restart.
  Future<void> init() {
    throw UnimplementedError('init() has not been implemented.');
  }

  /// Clears one video.
  Future<void> dispose(int textureId) {
    throw UnimplementedError('dispose() has not been implemented.');
  }

  /// Creates an instance of a video player and returns its textureId.
  Future<int?> create(DataSource dataSource) {
    throw UnimplementedError('create() has not been implemented.');
  }

  /// Returns a Stream of [VideoEventType]s.
  Stream<VideoEvent> videoEventsFor(int textureId) {
    throw UnimplementedError('videoEventsFor() has not been implemented.');
  }

  /// Sets the looping attribute of the video.
  Future<void> setLooping(int textureId, bool looping) {
    throw UnimplementedError('setLooping() has not been implemented.');
  }

  /// Starts the video playback.
  Future<void> play(int textureId) {
    throw UnimplementedError('play() has not been implemented.');
  }

  /// Stops the video playback.
  Future<void> pause(int textureId) {
    throw UnimplementedError('pause() has not been implemented.');
  }

  /// Sets the volume to a range between 0.0 and 1.0.
  Future<void> setVolume(int textureId, double volume) {
    throw UnimplementedError('setVolume() has not been implemented.');
  }

  /// Sets the video position to a [Duration] from the start.
  Future<void> seekTo(int textureId, Duration position) {
    throw UnimplementedError('seekTo() has not been implemented.');
  }

  /// Sets the playback speed to a [speed] value indicating the playback rate.
  Future<void> setPlaybackSpeed(int textureId, double speed) {
    throw UnimplementedError('setPlaybackSpeed() has not been implemented.');
  }

  /// Gets the video position as [Duration] from the start.
  Future<Duration> getPosition(int textureId) {
    throw UnimplementedError('getPosition() has not been implemented.');
  }

  /// Returns a widget displaying the video with a given textureID.
  Widget buildView(int textureId) {
    throw UnimplementedError('buildView() has not been implemented.');
  }

  /// Sets the audio mode to mix with other sources
  Future<void> setMixWithOthers(bool mixWithOthers) {
    throw UnimplementedError('setMixWithOthers() has not been implemented.');
  }

  // This method makes sure that VideoPlayer isn't implemented with `implements`.
  //
  // See class doc for more details on why implementing this class is forbidden.
  //
  // This private method is called by the instance setter, which fails if the class is
  // implemented with `implements`.
  void _verifyProvidesDefaultImplementations() {}
}

/// Description of the data source used to create an instance of
/// the video player.
class DataSource {
  /// Constructs an instance of [DataSource].
  ///
  /// The [sourceType] is always required.
  ///
  /// The [uri] argument takes the form of `'https://example.com/video.mp4'` or
  /// `'file://${file.path}'`.
  ///
  /// The [formatHint] argument can be null.
  ///
  /// The [asset] argument takes the form of `'assets/video.mp4'`.
  ///
  /// The [package] argument must be non-null when the asset comes from a
  /// package and null otherwise.
  DataSource({
    required this.sourceType,
    this.uri,
    this.formatHint,
    this.asset,
    this.package,
    this.httpHeaders = const {},
  });

  /// The way in which the video was originally loaded.
  ///
  /// This has nothing to do with the video's file type. It's just the place
  /// from which the video is fetched from.
  final DataSourceType sourceType;

  /// The URI to the video file.
  ///
  /// This will be in different formats depending on the [DataSourceType] of
  /// the original video.
  final String? uri;

  /// **Android only**. Will override the platform's generic file format
  /// detection with whatever is set here.
  final VideoFormat? formatHint;

  /// HTTP headers used for the request to the [uri].
  /// Only for [DataSourceType.network] videos.
  /// Always empty for other video types.
  Map<String, String> httpHeaders;

  /// The name of the asset. Only set for [DataSourceType.asset] videos.
  final String? asset;

  /// The package that the asset was loaded from. Only set for
  /// [DataSourceType.asset] videos.
  final String? package;
}

/// The way in which the video was originally loaded.
///
/// This has nothing to do with the video's file type. It's just the place
/// from which the video is fetched from.
enum DataSourceType {
  /// The video was included in the app's asset files.
  asset,

  /// The video was downloaded from the internet.
  network,

  /// The video was loaded off of the local filesystem.
  file,

  /// The video is available via contentUri. Android only.
  contentUri,
}

/// The file format of the given video.
enum VideoFormat {
  /// Dynamic Adaptive Streaming over HTTP, also known as MPEG-DASH.
  dash,

  /// HTTP Live Streaming.
  hls,

  /// Smooth Streaming.
  ss,

  /// Any format other than the other ones defined in this enum.
  other,
}

/// Event emitted from the platform implementation.
class VideoEvent {
  /// Creates an instance of [VideoEvent].
  ///
  /// The [eventType] argument is required.
  ///
  /// Depending on the [eventType], the [duration], [size] and [buffered]
  /// arguments can be null.
  VideoEvent({
    required this.eventType,
    this.duration,
    this.size,
    this.buffered,
  });

  /// The type of the event.
  final VideoEventType eventType;

  /// Duration of the video.
  ///
  /// Only used if [eventType] is [VideoEventType.initialized].
  final Duration? duration;

  /// Size of the video.
  ///
  /// Only used if [eventType] is [VideoEventType.initialized].
  final Size? size;

  /// Buffered parts of the video.
  ///
  /// Only used if [eventType] is [VideoEventType.bufferingUpdate].
  final List<DurationRange>? buffered;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is VideoEvent &&
            runtimeType == other.runtimeType &&
            eventType == other.eventType &&
            duration == other.duration &&
            size == other.size &&
            listEquals(buffered, other.buffered);
  }

  @override
  int get hashCode =>
      eventType.hashCode ^
      duration.hashCode ^
      size.hashCode ^
      buffered.hashCode;
}

/// Type of the event.
///
/// Emitted by the platform implementation when the video is initialized or
/// completed or to communicate buffering events.
enum VideoEventType {
  /// The video has been initialized.
  initialized,

  /// The playback has ended.
  completed,

  /// Updated information on the buffering state.
  bufferingUpdate,

  /// The video started to buffer.
  bufferingStart,

  /// The video stopped to buffer.
  bufferingEnd,

  /// An unknown event has been received.
  unknown,
}

/// Describes a discrete segment of time within a video using a [start] and
/// [end] [Duration].
class DurationRange {
  /// Trusts that the given [start] and [end] are actually in order. They should
  /// both be non-null.
  DurationRange(this.start, this.end);

  /// The beginning of the segment described relative to the beginning of the
  /// entire video. Should be shorter than or equal to [end].
  ///
  /// For example, if the entire video is 4 minutes long and the range is from
  /// 1:00-2:00, this should be a `Duration` of one minute.
  final Duration start;

  /// The end of the segment described as a duration relative to the beginning of
  /// the entire video. This is expected to be non-null and longer than or equal
  /// to [start].
  ///
  /// For example, if the entire video is 4 minutes long and the range is from
  /// 1:00-2:00, this should be a `Duration` of two minutes.
  final Duration end;

  /// Assumes that [duration] is the total length of the video that this
  /// DurationRange is a segment form. It returns the percentage that [start] is
  /// through the entire video.
  ///
  /// For example, assume that the entire video is 4 minutes long. If [start] has
  /// a duration of one minute, this will return `0.25` since the DurationRange
  /// starts 25% of the way through the video's total length.
  double startFraction(Duration duration) {
    return start.inMilliseconds / duration.inMilliseconds;
  }

  /// Assumes that [duration] is the total length of the video that this
  /// DurationRange is a segment form. It returns the percentage that [start] is
  /// through the entire video.
  ///
  /// For example, assume that the entire video is 4 minutes long. If [end] has a
  /// duration of two minutes, this will return `0.5` since the DurationRange
  /// ends 50% of the way through the video's total length.
  double endFraction(Duration duration) {
    return end.inMilliseconds / duration.inMilliseconds;
  }

  @override
  String toString() => '$runtimeType(start: $start, end: $end)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DurationRange &&
          runtimeType == other.runtimeType &&
          start == other.start &&
          end == other.end;

  @override
  int get hashCode => start.hashCode ^ end.hashCode;
}

/// [VideoPlayerOptions] can be optionally used to set additional player settings
class VideoPlayerOptions {
  /// Set this to true to mix the video players audio with other audio sources.
  /// The default value is false
  ///
  /// Note: This option will be silently ignored in the web platform (there is
  /// currently no way to implement this feature in this platform).
  final bool mixWithOthers;

  /// set additional optional player settings
  VideoPlayerOptions({this.mixWithOthers = false});
}
