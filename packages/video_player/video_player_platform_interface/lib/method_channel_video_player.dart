// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter/services.dart';

import 'video_player_platform_interface.dart';

const MethodChannel _channel = MethodChannel('flutter.io/videoPlayer');

/// An implementation of [VideoPlayerPlatform] that uses method channels.
class MethodChannelVideoPlayer extends VideoPlayerPlatform {
  @override
  Future<void> init() {
    return _channel.invokeMethod<void>('init');
  }

  @override
  Future<void> dispose(int textureId) {
    return _channel.invokeMethod<void>(
      'dispose',
      <String, dynamic>{'textureId': textureId},
    );
  }

  @override
  Future<int> create(DataSource dataSource) async {
    Map<String, dynamic> dataSourceDescription;

    switch (dataSource.sourceType) {
      case DataSourceType.asset:
        dataSourceDescription = <String, dynamic>{
          'asset': dataSource.asset,
          'package': dataSource.package,
        };
        break;
      case DataSourceType.network:
        dataSourceDescription = <String, dynamic>{
          'uri': dataSource.uri,
          'formatHint': _videoFormatStringMap[dataSource.formatHint]
        };
        break;
      case DataSourceType.file:
        dataSourceDescription = <String, dynamic>{'uri': dataSource.uri};
        break;
    }

    final Map<String, dynamic> response =
        await _channel.invokeMapMethod<String, dynamic>(
      'create',
      dataSourceDescription,
    );
    return response['textureId'];
  }

  @override
  Future<void> setLooping(int textureId, bool looping) {
    return _channel.invokeMethod<void>(
      'setLooping',
      <String, dynamic>{
        'textureId': textureId,
        'looping': looping,
      },
    );
  }

  @override
  Future<void> play(int textureId) {
    return _channel.invokeMethod<void>(
      'play',
      <String, dynamic>{'textureId': textureId},
    );
  }

  @override
  Future<void> pause(int textureId) {
    return _channel.invokeMethod<void>(
      'pause',
      <String, dynamic>{'textureId': textureId},
    );
  }

  @override
  Future<void> setVolume(int textureId, double volume) {
    return _channel.invokeMethod<void>(
      'setVolume',
      <String, dynamic>{
        'textureId': textureId,
        'volume': volume,
      },
    );
  }

  @override
  Future<void> seekTo(int textureId, int milliseconds) {
    return _channel.invokeMethod<void>(
      'seekTo',
      <String, dynamic>{
        'textureId': textureId,
        'location': milliseconds,
      },
    );
  }

  @override
  Future<Duration> getPosition(int textureId) async {
    return Duration(
      milliseconds: await _channel.invokeMethod<int>(
        'position',
        <String, dynamic>{'textureId': textureId},
      ),
    );
  }

  @override
  Stream<VideoEvent> videoEventsFor(int textureId) {
    return _eventChannelFor(textureId)
        .receiveBroadcastStream()
        .map((dynamic event) {
      final Map<dynamic, dynamic> map = event;
      switch (map['event']) {
        case 'initialized':
          return VideoEvent.initialized;
        case 'completed':
          return VideoEvent.completed;
        case 'bufferingUpdate':
          return VideoEvent.bufferingUpdate;
        case 'bufferingStart':
          return VideoEvent.bufferingStart;
        case 'bufferingEnd':
          return VideoEvent.bufferingEnd;
        default:
          return VideoEvent.unknown;
      }
    });
  }

  EventChannel _eventChannelFor(int textureId) {
    return EventChannel('flutter.io/videoPlayer/videoEvents$textureId');
  }

  static const Map<FormatHint, String> _videoFormatStringMap =
      <FormatHint, String>{
    FormatHint.ss: 'ss',
    FormatHint.hls: 'hls',
    FormatHint.dash: 'dash',
    FormatHint.other: 'other',
  };
}
