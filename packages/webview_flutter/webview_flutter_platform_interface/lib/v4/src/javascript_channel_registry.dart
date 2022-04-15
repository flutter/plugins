// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:meta/meta.dart';

import 'types/javascript_channel.dart';
import 'types/javascript_message.dart';

/// Utility class for managing named JavaScript channels and forwarding incoming
/// messages on the correct channel.
@sealed
class JavaScriptChannelRegistry {
  /// Constructs a [JavaScriptChannelRegistry] initializing it with the given
  /// set of [JavaScriptChannel]s.
  JavaScriptChannelRegistry(Set<JavaScriptChannel>? channels) {
    updateJavaScriptChannelsFromSet(channels);
  }

  /// Maps a channel name to a channel.
  final Map<String, JavaScriptChannel> channels = <String, JavaScriptChannel>{};

  /// Invoked when a JavaScript channel message is received.
  void onJavaScriptChannelMessage(String channel, String message) {
    final JavaScriptChannel? javaScriptChannel = channels[channel];

    if (javaScriptChannel == null) {
      throw ArgumentError('No channel registered with name $channel.');
    }

    javaScriptChannel.onMessageReceived(JavaScriptMessage(message: message));
  }

  /// Updates the set of [JavaScriptChannel]s with the new set.
  void updateJavaScriptChannelsFromSet(Set<JavaScriptChannel>? channels) {
    this.channels.clear();
    if (channels == null) {
      return;
    }

    for (final JavaScriptChannel channel in channels) {
      this.channels[channel.name] = channel;
    }
  }
}
