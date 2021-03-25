// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:ui';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'messages.dart';
import 'video_player_platform_interface.dart';

/// An implementation of [VideoPlayerPlatform] that uses method channels.
class MethodChannelVideoPlayer extends VideoPlayerPlatform {
  VideoPlayerApi _api = VideoPlayerApi();

  @override
  Future<void> init() {
    return _api.initialize();
  }

  @override
  Future<void> dispose(int textureId) {
    return _api.dispose(TextureMessage()..textureId = textureId);
  }

  @override
  Future<int?> create(DataSource dataSource) async {
    CreateMessage message = CreateMessage();

    switch (dataSource.sourceType) {
      case DataSourceType.asset:
        message.asset = dataSource.asset;
        message.packageName = dataSource.package;
        break;
      case DataSourceType.network:
        message.uri = dataSource.uri;
        message.formatHint = _videoFormatStringMap[dataSource.formatHint];
        message.httpHeaders = dataSource.httpHeaders;
        break;
      case DataSourceType.file:
        message.uri = dataSource.uri;
        break;
    }

    TextureMessage response = await _api.create(message);
    return response.textureId;
  }

  @override
  Future<void> setLooping(int textureId, bool looping) {
    return _api.setLooping(LoopingMessage()
      ..textureId = textureId
      ..isLooping = looping);
  }

  @override
  Future<void> play(int textureId) {
    return _api.play(TextureMessage()..textureId = textureId);
  }

  @override
  Future<void> pause(int textureId) {
    return _api.pause(TextureMessage()..textureId = textureId);
  }

  @override
  Future<void> setVolume(int textureId, double volume) {
    return _api.setVolume(VolumeMessage()
      ..textureId = textureId
      ..volume = volume);
  }

  @override
  Future<void> setPlaybackSpeed(int textureId, double speed) {
    assert(speed > 0);

    return _api.setPlaybackSpeed(PlaybackSpeedMessage()
      ..textureId = textureId
      ..speed = speed);
  }

  @override
  Future<void> seekTo(int textureId, Duration position) {
    return _api.seekTo(PositionMessage()
      ..textureId = textureId
      ..position = position.inMilliseconds);
  }

  @override
  Future<Duration> getPosition(int textureId) async {
    PositionMessage response =
        await _api.position(TextureMessage()..textureId = textureId);
    return Duration(milliseconds: response.position!);
  }

  @override
  Future<List<TrackSelection>> getTrackSelections(
    int textureId, {
    TrackSelectionNameResource? trackSelectionNameResource,
  }) async {
    trackSelectionNameResource ??= TrackSelectionNameResource();
    TrackSelectionsMessage response =
        await _api.trackSelections(TextureMessage()..textureId = textureId);
    final List<TrackSelection> trackSelections = [];
    for (Object? trackSelectionObject in response.trackSelections!) {
      final trackSelectionMap = trackSelectionObject as Map<Object?, Object?>;
      final trackSelectionType =
          _intTrackSelectionTypeMap[trackSelectionMap['trackType']]!;
      final isUnknown = trackSelectionMap['isUnknown'] as bool;
      final isAuto = trackSelectionMap['isAuto'] as bool;
      final trackId = trackSelectionMap['trackId'] as String;
      final isSelected = trackSelectionMap['isSelected'] as bool;
      if (isUnknown || isAuto) {
        trackSelections.add(TrackSelection(
          trackId: trackId,
          trackType: trackSelectionType,
          trackName: isUnknown
              ? trackSelectionNameResource.trackUnknown
              : trackSelectionNameResource.trackAuto,
          isSelected: isSelected,
        ));
      } else {
        switch (trackSelectionType) {
          case TrackSelectionType.video:
            {
              final rolesFlag = trackSelectionMap['rolesFlag'] as int;
              final bitrate = trackSelectionMap['bitrate'] as int;
              final width = trackSelectionMap['width'] as int;
              final height = trackSelectionMap['height'] as int;
              final trackSelectionName = _joinWithSeparator([
                _buildRoleString(rolesFlag, trackSelectionNameResource),
                _buildVideoQualityOrResolutionString(
                    bitrate, width, height, trackSelectionNameResource),
              ], trackSelectionNameResource.trackItemListSeparator);
              trackSelections.add(TrackSelection(
                trackId: trackId,
                trackType: trackSelectionType,
                trackName: trackSelectionName.isEmpty
                    ? trackSelectionNameResource.trackUnknown
                    : trackSelectionName,
                isSelected: isSelected,
                size: width == -1 || height == -1
                    ? null
                    : Size(width.toDouble(), height.toDouble()),
                role: _toRoleType(rolesFlag),
                bitrate: bitrate == -1 ? null : bitrate,
              ));
              break;
            }
          case TrackSelectionType.audio:
            {
              final rolesFlag = trackSelectionMap['rolesFlag'] as int;
              final language = trackSelectionMap['language'] as String;
              final label = trackSelectionMap['label'] as String;
              final channelCount = trackSelectionMap['channelCount'] as int;
              final bitrate = trackSelectionMap['bitrate'] as int;
              final trackSelectionName = _joinWithSeparator([
                _buildLanguageOrLabelString(
                    language, rolesFlag, label, trackSelectionNameResource),
                _buildAudioChannelString(
                    channelCount, trackSelectionNameResource),
                _buildAvgBitrateString(bitrate, trackSelectionNameResource),
              ], trackSelectionNameResource.trackItemListSeparator);
              trackSelections.add(TrackSelection(
                trackId: trackId,
                trackType: trackSelectionType,
                trackName: trackSelectionName.isEmpty
                    ? trackSelectionNameResource.trackUnknown
                    : trackSelectionName,
                isSelected: isSelected,
                language: language.isEmpty ? null : language,
                label: label.isEmpty ? null : label,
                channel: _toChannelType(channelCount),
                role: _toRoleType(rolesFlag),
                bitrate: bitrate == -1 ? null : bitrate,
              ));
              break;
            }
          case TrackSelectionType.text:
            {
              final rolesFlag = trackSelectionMap['rolesFlag'] as int;
              final language = trackSelectionMap['language'] as String;
              final label = trackSelectionMap['label'] as String;
              final trackSelectionName = _buildLanguageOrLabelString(
                  language, rolesFlag, label, trackSelectionNameResource);
              trackSelections.add(TrackSelection(
                trackId: trackId,
                trackType: trackSelectionType,
                trackName: trackSelectionName.isEmpty
                    ? trackSelectionNameResource.trackUnknown
                    : trackSelectionName,
                isSelected: isSelected,
                language: language.isEmpty ? null : language,
                label: label.isEmpty ? null : label,
                role: _toRoleType(rolesFlag),
              ));
              break;
            }
        }
      }
    }
    return trackSelections;
  }

  @override
  Future<void> setTrackSelection(int textureId, TrackSelection trackSelection) {
    return _api.setTrackSelection(TrackSelectionsMessage()
      ..trackId = trackSelection.trackId
      ..textureId = textureId);
  }

  @override
  Stream<VideoEvent> videoEventsFor(int textureId) {
    return _eventChannelFor(textureId)
        .receiveBroadcastStream()
        .map((dynamic event) {
      final Map<dynamic, dynamic> map = event;
      switch (map['event']) {
        case 'initialized':
          return VideoEvent(
            eventType: VideoEventType.initialized,
            duration: Duration(milliseconds: map['duration']),
            size: Size(map['width']?.toDouble() ?? 0.0,
                map['height']?.toDouble() ?? 0.0),
          );
        case 'completed':
          return VideoEvent(
            eventType: VideoEventType.completed,
          );
        case 'bufferingUpdate':
          final List<dynamic> values = map['values'];

          return VideoEvent(
            buffered: values.map<DurationRange>(_toDurationRange).toList(),
            eventType: VideoEventType.bufferingUpdate,
          );
        case 'bufferingStart':
          return VideoEvent(eventType: VideoEventType.bufferingStart);
        case 'bufferingEnd':
          return VideoEvent(eventType: VideoEventType.bufferingEnd);
        default:
          return VideoEvent(eventType: VideoEventType.unknown);
      }
    });
  }

  @override
  Widget buildView(int textureId) {
    return Texture(textureId: textureId);
  }

  @override
  Future<void> setMixWithOthers(bool mixWithOthers) {
    return _api.setMixWithOthers(
      MixWithOthersMessage()..mixWithOthers = mixWithOthers,
    );
  }

  EventChannel _eventChannelFor(int textureId) {
    return EventChannel('flutter.io/videoPlayer/videoEvents$textureId');
  }

  static const Map<VideoFormat, String> _videoFormatStringMap =
      <VideoFormat, String>{
    VideoFormat.ss: 'ss',
    VideoFormat.hls: 'hls',
    VideoFormat.dash: 'dash',
    VideoFormat.other: 'other',
  };

  static const Map<int, TrackSelectionType> _intTrackSelectionTypeMap =
      <int, TrackSelectionType>{
    1: TrackSelectionType.audio,
    2: TrackSelectionType.video,
    3: TrackSelectionType.text,
  };

  TrackSelectionRoleType? _toRoleType(int rolesFlag) {
    switch (rolesFlag) {
      case 0:
        return TrackSelectionRoleType.alternate;
      case 1:
        return TrackSelectionRoleType.supplementary;
      case 2:
        return TrackSelectionRoleType.commentary;
      case 3:
        return TrackSelectionRoleType.closedCaptions;
    }
  }

  TrackSelectionChannelType? _toChannelType(int channelCount) {
    switch (channelCount) {
      case 1:
        return TrackSelectionChannelType.mono;
      case 2:
        return TrackSelectionChannelType.stereo;
      default:
        return TrackSelectionChannelType.surround;
    }
  }

  String _buildVideoQualityOrResolutionString(
    int bitrate,
    int width,
    int height,
    TrackSelectionNameResource trackSelectionNameResource,
  ) {
    const int bitrate1080p = 2800000;
    const int bitrate720p = 1600000;
    const int bitrate480p = 700000;
    const int bitrate360p = 530000;
    const int bitrate240p = 400000;
    const int bitrate160p = 300000;

    if (bitrate != -1 && bitrate <= bitrate160p) {
      return trackSelectionNameResource.trackBitrate160p;
    }
    if (bitrate != -1 && bitrate <= bitrate240p) {
      return trackSelectionNameResource.trackBitrate240p;
    }
    if (bitrate != -1 && bitrate <= bitrate360p) {
      return trackSelectionNameResource.trackBitrate360p;
    }
    if (bitrate != -1 && bitrate <= bitrate480p) {
      return trackSelectionNameResource.trackBitrate480p;
    }
    if (bitrate != -1 && bitrate <= bitrate720p) {
      return trackSelectionNameResource.trackBitrate720p;
    }
    if (bitrate != -1 && bitrate <= bitrate1080p) {
      return trackSelectionNameResource.trackBitrate1080p;
    }

    return _joinWithSeparator([
      _buildResolutionString(width, height, trackSelectionNameResource),
      _buildAvgBitrateString(bitrate, trackSelectionNameResource),
    ], trackSelectionNameResource.trackItemListSeparator);
  }

  String _buildResolutionString(int width, int height,
      TrackSelectionNameResource trackSelectionNameResource) {
    if (width == -1 || height == -1) {
      return '';
    }
    return [width, trackSelectionNameResource.trackResolutionSeparator, height]
        .join(' ');
  }

  String _buildAvgBitrateString(
      int bitrate, TrackSelectionNameResource trackSelectionNameResource) {
    if (bitrate == -1) {
      return '';
    }
    return [
      (bitrate / 1000000).toStringAsFixed(2),
      trackSelectionNameResource.trackBitrateMbps,
    ].join(' ');
  }

  String _buildLanguageOrLabelString(
    String language,
    int rolesFlag,
    String label,
    TrackSelectionNameResource trackSelectionNameResource,
  ) {
    String languageAndRole = _joinWithSeparator(
      [language, _buildRoleString(rolesFlag, trackSelectionNameResource)],
      trackSelectionNameResource.trackItemListSeparator,
    );
    return languageAndRole.isEmpty ? label : languageAndRole;
  }

  String _buildRoleString(
      int rolesFlag, TrackSelectionNameResource trackSelectionNameResource) {
    switch (rolesFlag) {
      case 0:
        return trackSelectionNameResource.trackRoleAlternate;
      case 1:
        return trackSelectionNameResource.trackRoleSupplementary;
      case 2:
        return trackSelectionNameResource.trackRoleCommentary;
      case 3:
        return trackSelectionNameResource.trackRoleClosedCaptions;
      default:
        return '';
    }
  }

  String _buildAudioChannelString(
      int channelCount, TrackSelectionNameResource trackSelectionNameResource) {
    if (channelCount == -1) {
      return '';
    }
    switch (channelCount) {
      case 1:
        return trackSelectionNameResource.trackMono;
      case 2:
        return trackSelectionNameResource.trackStereo;
      default:
        return trackSelectionNameResource.trackSurround;
    }
  }

  String _joinWithSeparator(List<String> names, String separator) {
    String jointNames = '';
    for (String name in names) {
      if (jointNames.isEmpty) {
        jointNames = name;
      } else if (name.isNotEmpty) {
        jointNames += [separator, name].join(' ');
      }
    }
    return jointNames;
  }

  DurationRange _toDurationRange(dynamic value) {
    final List<dynamic> pair = value;
    return DurationRange(
      Duration(milliseconds: pair[0]),
      Duration(milliseconds: pair[1]),
    );
  }
}
