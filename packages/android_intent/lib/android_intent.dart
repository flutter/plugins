// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter/services.dart';
import 'package:meta/meta.dart';
import 'package:platform/platform.dart';

const String kChannelName = 'plugins.flutter.io/android_intent';

/// Flutter plugin for launching arbitrary Android Intents.
class AndroidIntent {
  /// Builds an Android intent with the following parameters
  /// [action] refers to the action parameter of the intent.
  /// [category] refers to the category of the intent, can be null.
  /// [data] refers to the string format of the URI that will be passed to
  /// intent.
  /// [arguments] is the map that will be converted into an extras bundle and
  /// passed to the intent.
  const AndroidIntent({
    @required this.action,
    this.category,
    this.data,
    this.arguments,
    this.package,
    Platform platform,
  })  : assert(action != null),
        _platform = platform ?? const LocalPlatform();

  final String action;
  final String category;
  final String data;
  final Map<String, dynamic> arguments;
  final String package;
  static final MethodChannel _channel = const MethodChannel(kChannelName);
  final Platform _platform;

  /// Launch the intent.
  ///
  /// This works only on Android platforms. Please guard the call so that your
  /// iOS app does not crash. Checked mode will throw an assert exception.
  Future<void> launch() async {
    assert(_platform.isAndroid);
    final Map<String, dynamic> args = <String, dynamic>{'action': action};
    if (category != null) {
      args['category'] = category;
    }
    if (data != null) {
      args['data'] = data;
    }
    if (arguments != null) {
      args['arguments'] = arguments;
    }
    if (package != null) {
      args['package'] = package;
    }
    // TODO(amirh): remove this on when the invokeMethod update makes it to stable Flutter.
    // https://github.com/flutter/flutter/issues/26431
    // ignore: strong_mode_implicit_dynamic_method
    await _channel.invokeMethod('launch', args);
  }

  static Future<Map<dynamic, dynamic>> getIntentExtras() async {
    final Map<dynamic, dynamic> extras =
        await _channel.invokeMethod('getIntentExtras');
    return extras;
  }

  static Future<String> getIntentData() async {
    final String data = await _channel.invokeMethod('getIntentData');
    return data;
  }
}
