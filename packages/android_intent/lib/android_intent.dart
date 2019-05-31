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
  final String action;
  final String category;
  final String data;
  final Map<String, dynamic> arguments;
  final String package;
  final MethodChannel _channel;
  final Platform _platform;

  /// Builds an Android intent with the following parameters
  /// [action] refers to the action parameter of the intent.
  /// [category] refers to the category of the intent, can be null.
  /// [data] refers to the string format of the URI that will be passed to
  /// intent.
  /// [arguments] is the map that will be converted into an extras bundle and
  /// passed to the intent.
  /// [package] refers to the package parameter of the intent, can be null.
  /// [componentName] refers to the component name of the intent, can be null.
  /// If not null, then [package] but also be provided.
  const AndroidIntent({
    @required this.action,
    this.category,
    this.data,
    this.arguments,
    this.package,
    this.componentName,
    Platform platform,
  })  : assert(action != null),
        _channel = const MethodChannel(kChannelName),
        _platform = platform ?? const LocalPlatform();

<<<<<<< HEAD
=======
  final String action;
  final String category;
  final String data;
  final Map<String, dynamic> arguments;
  final String package;
  final String componentName;
  final MethodChannel _channel;
  final Platform _platform;

>>>>>>> 0f80e7380086ceed3c61c05dc431a41d2c32253a
  /// Launch the intent.
  ///
  /// This works only on Android platforms. Please guard the call so that your
  /// iOS app does not crash. Checked mode will throw an assert exception.
  Future<Null> launch() async {
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
      if (componentName != null) {
        args['componentName'] = componentName;
      }
    }
    await _channel.invokeMethod('launch', args);
  }
}
