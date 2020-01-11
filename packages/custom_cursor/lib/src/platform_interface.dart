// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:custom_cursor/src/cursor_type.dart';
import 'package:meta/meta.dart' show required;
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'method_channel.dart';

/// The interface that implementations of url_launcher must implement.
///
/// Platform implementations should extend this class rather than implement it as `url_launcher`
/// does not consider newly added methods to be breaking changes. Extending this class
/// (using `extends`) ensures that the subclass will get the default implementation, while
/// platform implementations that `implements` this interface will be broken by newly added
/// [CustomCursorPlatform] methods.
abstract class CustomCursorPlatform extends PlatformInterface {
  /// Constructs a CustomCursorPlatform.
  CustomCursorPlatform() : super(token: _token);

  static final Object _token = Object();

  static CustomCursorPlatform _instance = MethodChannelCustomCursor();

  /// The default instance of [CustomCursorPlatform] to use.
  ///
  /// Defaults to [MethodChannelCustomCursor].
  static CustomCursorPlatform get instance => _instance;

  /// Platform-specific plugins should set this with their own platform-specific
  /// class that extends [CustomCursorPlatform] when they register themselves.
  // TODO(amirh): Extract common platform interface logic.
  // https://github.com/flutter/flutter/issues/43368
  static set instance(CustomCursorPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  /// Returns `true` if this platform is able to reset the cursor.
  Future<bool> resetCursor() {
    throw UnimplementedError('resetCursor() has not been implemented.');
  }

  /// Returns `true` if this platform is able to hide the cursor.
  Future<bool> hideCursor() {
    throw UnimplementedError('hideCursor() has not been implemented.');
  }

  /// Returns `true` if this platform is able to unhide the cursor.
  Future<bool> showCursor() {
    throw UnimplementedError('showCursor() has not been implemented.');
  }

  /// Returns `true` if this platform is able to set the cursor.
  Future<bool> setCursor(CursorType value) {
    throw UnimplementedError('setCursor() has not been implemented.');
  }

  /// Returns `true` if this platform is able to set the cursor.
  Future<bool> setMacOSCursor(MacOSCursor value) {
    throw UnimplementedError('setMacOSCursor() has not been implemented.');
  }

  /// Returns `true` if this platform is able to set the cursor.
  Future<bool> setWebCursor(WebCursor value) {
    throw UnimplementedError('setWebCursor() has not been implemented.');
  }
}
