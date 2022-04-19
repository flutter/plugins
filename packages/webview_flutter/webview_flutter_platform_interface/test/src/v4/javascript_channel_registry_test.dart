// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:webview_flutter_platform_interface/v4/src/javascript_channel_registry.dart';
import 'package:webview_flutter_platform_interface/v4/src/types/types.dart';

void main() {
  final Map<String, String> _log = <String, String>{};
  final Set<JavaScriptChannel> _channels = <JavaScriptChannel>{
    JavaScriptChannel(
      name: 'js_channel_1',
      onMessageReceived: (JavaScriptMessage message) =>
          _log['js_channel_1'] = message.message,
    ),
    JavaScriptChannel(
      name: 'js_channel_2',
      onMessageReceived: (JavaScriptMessage message) =>
          _log['js_channel_2'] = message.message,
    ),
    JavaScriptChannel(
      name: 'js_channel_3',
      onMessageReceived: (JavaScriptMessage message) =>
          _log['js_channel_3'] = message.message,
    ),
  };

  tearDown(() {
    _log.clear();
  });

  test('ctor should initialize with channels.', () {
    final JavaScriptChannelRegistry registry =
        JavaScriptChannelRegistry(_channels);

    expect(registry.channels.length, 3);
    for (final JavaScriptChannel channel in _channels) {
      expect(registry.channels[channel.name], channel);
    }
  });

  test('onJavaScriptChannelMessage should forward message on correct channel.',
      () {
    final JavaScriptChannelRegistry registry =
        JavaScriptChannelRegistry(_channels);

    registry.onJavaScriptChannelMessage(
      'js_channel_2',
      'test message on channel 2',
    );

    expect(
        _log,
        containsPair(
          'js_channel_2',
          'test message on channel 2',
        ));
  });

  test(
      'onJavaScriptChannelMessage should throw ArgumentError when message arrives on non-existing channel.',
      () {
    final JavaScriptChannelRegistry registry =
        JavaScriptChannelRegistry(_channels);

    expect(
        () => registry.onJavaScriptChannelMessage(
              'js_channel_4',
              'test message on channel 2',
            ),
        throwsA(
          isA<ArgumentError>().having((ArgumentError error) => error.message,
              'message', 'No channel registered with name js_channel_4.'),
        ));
  });

  test(
      'updateJavaScriptChannelsFromSet should clear all channels when null is supplied.',
      () {
    final JavaScriptChannelRegistry registry =
        JavaScriptChannelRegistry(_channels);

    expect(registry.channels.length, 3);

    registry.updateJavaScriptChannelsFromSet(null);

    expect(registry.channels, isEmpty);
  });

  test('updateJavaScriptChannelsFromSet should update registry with new set.',
      () {
    final JavaScriptChannelRegistry registry =
        JavaScriptChannelRegistry(_channels);

    expect(registry.channels.length, 3);

    final Set<JavaScriptChannel> newChannels = <JavaScriptChannel>{
      JavaScriptChannel(
        name: 'new_js_channel_1',
        onMessageReceived: (JavaScriptMessage message) =>
            _log['new_js_channel_1'] = message.message,
      ),
      JavaScriptChannel(
        name: 'new_js_channel_2',
        onMessageReceived: (JavaScriptMessage message) =>
            _log['new_js_channel_2'] = message.message,
      ),
    };

    registry.updateJavaScriptChannelsFromSet(newChannels);

    expect(registry.channels.length, 2);
    for (final JavaScriptChannel channel in newChannels) {
      expect(registry.channels[channel.name], channel);
    }
  });
}
