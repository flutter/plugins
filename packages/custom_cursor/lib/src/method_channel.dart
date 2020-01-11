// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter/services.dart';

import 'cursor_type.dart';
import 'platform_interface.dart';

const MethodChannel _channel = MethodChannel('custom_cursor');

/// An implementation of [CustomCursorPlatform] that uses method channels.
class MethodChannelCustomCursor extends CustomCursorPlatform {
  @override
  Future<bool> resetCursor() {
    return _channel.invokeMethod<bool>(
      'resetCursor',
    );
  }

  @override
  Future<bool> setCursor(CursorType value) {
    return _channel.invokeMethod<bool>(
      'setCursor',
      {
        "type": Cursor.getMacOSCursor(value),
        "update": false,
      },
    );
  }

  @override
  Future<bool> setMacOSCursor(MacOSCursor value) {
    return _channel.invokeMethod<bool>(
      'setCursor',
      {
        "type": value.value,
        "update": false,
      },
    );
  }

  @override
  Future<bool> hideCursor() {
    return _channel.invokeMethod<bool>(
      'hideCursor',
    );
  }

  @override
  Future<bool> showCursor() {
    return _channel.invokeMethod<bool>(
      'showCursor',
    );
  }
}
