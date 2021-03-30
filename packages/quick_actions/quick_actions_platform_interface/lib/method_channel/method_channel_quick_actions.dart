// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:meta/meta.dart' show visibleForTesting;
import 'package:quick_actions_platform_interface/types/types.dart';

import '../platform_interface/quick_actions_platform.dart';

final MethodChannel _channel =
    MethodChannel('plugins.flutter.io/quick_actions');

/// An implementation of [QuickActionsPlatform] that uses method channels.
class MethodChannelQuickActions extends QuickActionsPlatform {
  /// The MethodChannel that is being used by this implementation of the plugin.
  @visibleForTesting
  MethodChannel get channel => _channel;

  @override
  Future<void> initialize(QuickActionHandler handler) async {
    channel.setMethodCallHandler((MethodCall call) async {
      assert(call.method == 'launch');
      handler(call.arguments);
    });
    final String? action =
        await channel.invokeMethod<String?>('getLaunchAction');
    if (action != null) {
      handler(action);
    }
  }

  @override
  Future<void> setShortcutItems(List<ShortcutItem> items) async {
    final List<Map<String, String?>> itemsList =
        items.map(_serializeItem).toList();
    await channel.invokeMethod<void>('setShortcutItems', itemsList);
  }

  @override
  Future<void> clearShortcutItems() =>
      channel.invokeMethod<void>('clearShortcutItems');

  Map<String, String?> _serializeItem(ShortcutItem item) {
    return <String, String?>{
      'type': item.type,
      'localizedTitle': item.localizedTitle,
      'icon': item.icon,
    };
  }
}
