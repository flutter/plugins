// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:quick_actions_platform_interface/types/types.dart';

import '../method_channel/method_channel_quick_actions.dart';

/// The interface that implementations of quick_actions must implement.
///
/// Platform implementations should extend this class rather than implement it as `quick_actions`
/// does not consider newly added methods to be breaking changes. Extending this class
/// (using `extends`) ensures that the subclass will get the default implementation, while
/// platform implementations that `implements` this interface will be broken by newly added
/// [QuickActionsPlatform] methods.
abstract class QuickActionsPlatform extends PlatformInterface {
  /// Constructs a QuickActionsPlatform.
  QuickActionsPlatform() : super(token: _token);

  static final Object _token = Object();

  static QuickActionsPlatform _instance = MethodChannelQuickActions();

  /// The default instance of [QuickActionsPlatform] to use.
  ///
  /// Defaults to [MethodChannelQuickActions].
  static QuickActionsPlatform get instance => _instance;

  /// Platform-specific plugins should set this with their own platform-specific
  /// class that extends [QuickActionsPlatform] when they register themselves.
  // TODO(amirh): Extract common platform interface logic.
  // https://github.com/flutter/flutter/issues/43368
  static set instance(QuickActionsPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  /// Initializes this plugin.
  ///
  /// Call this once before any further interaction with the plugin.
  Future<void> initialize(QuickActionHandler handler) async {
    throw UnimplementedError("initialize() has not been implemented.");
  }

  /// Sets the [ShortcutItem]s to become the app's quick actions.
  Future<void> setShortcutItems(List<ShortcutItem> items) async {
    throw UnimplementedError("setShortcutItems() has not been implemented.");
  }

  /// Removes all [ShortcutItem]s registered for the app.
  Future<void> clearShortcutItems() {
    throw UnimplementedError("clearShortcutItems() has not been implemented.");
  }
}
