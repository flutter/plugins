// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

const String _backgroundName =
    'plugins.flutter.io/android_alarm_manager_background';

void _alarmManagerCallbackDispatcher() {
  const MethodChannel _channel =
      const MethodChannel(_backgroundName, const JSONMethodCodec());
  final Map<String, Function> _callbackCache = new Map<String, Function>();
  WidgetsFlutterBinding.ensureInitialized();
  _channel.setMethodCallHandler((MethodCall call) async {
    final args = call.arguments;
    // args[0].runtimeType == List<dynamic>
    // pair[0] = closure name
    // pair[1] = closure library path
    // pair[2] = closure containing class
    final pair = args.cast<String>();
    final cacheKey = pair.join('@');
    Function closure;
    // To avoid making repeated lookups of our callback, store the resulting
    // closure in a cache based on the closure name and its library path.
    if (_callbackCache.containsKey(cacheKey)) {
      closure = _callbackCache[cacheKey];
    } else {
      // PluginUtilities.getClosureByName performs a lookup based on the name
      // of a closure as well as its library Uri.
      closure = PluginUtilities.getClosureByName(
          name: pair[0],
          libraryPath: pair[1],
          className: (pair[2] == 'null') ? null : pair[2]);

      if (closure == null) {
        print('Could not find closure: ${pair[0]} in ${pair[1]}.');
        print('Either ${pair[0]} does not exist or it is an instance method.');
        exit(-1);
      }
      _callbackCache[cacheKey] = closure;
    }
    assert(
        closure != null, 'Could not find closure: ${pair[0]} in ${pair[1]}.');
    closure();
  });
}

/// A Flutter plugin for registering Dart callbacks with the Android
/// AlarmManager service.
///
/// See the example/ directory in this package for sample usage.
class AndroidAlarmManager {
  static const String _channelName = 'plugins.flutter.io/android_alarm_manager';
  static const MethodChannel _channel =
      MethodChannel(_channelName, JSONMethodCodec());

  /// Starts the [AndroidAlarmManager] service. This must be called before
  /// setting any alarms.
  ///
  /// Returns a [Future] that resolves to `true` on success and `false` on
  /// failure.
  static Future<bool> initialize() async {
    final String functionName =
        PluginUtilities.getNameOfFunction(_alarmManagerCallbackDispatcher);
    final String libraryPath = PluginUtilities
        .getPathForFunctionLibrary(_alarmManagerCallbackDispatcher);
    if (functionName == null) {
      return false;
    }
    final dynamic r = await _channel.invokeMethod(
        'AlarmService.start', <dynamic>[functionName, libraryPath]);
    return r ?? false;
  }

  /// Schedules a one-shot timer to run `callback` after time `delay`.
  ///
  /// The `callback` will run whether or not the main application is running or
  /// in the foreground. It will run in the Isolate owned by the
  /// AndroidAlarmManager service.
  ///
  /// `callback` must be either a top-level function or a static method from a
  /// class.
  ///
  /// The timer is uniquely identified by `id`. Calling this function again
  /// again with the same `id` will cancel and replace the existing timer.
  ///
  /// If `exact` is passed as `true`, the timer will be created with Android's
  /// `AlarmManager.setRepeating`. When `exact` is `false` (the default), the
  /// timer will be created with `AlarmManager.setInexactRepeating`.
  ///
  /// If `wakeup` is passed as `true`, the device will be woken up when the
  /// alarm fires. If `wakeup` is false (the default), the device will not be
  /// woken up to service the alarm.
  ///
  /// Returns a [Future] that resolves to `true` on success and `false` on
  /// failure.
  static Future<bool> oneShot(
    Duration delay,
    int id,
    dynamic Function() callback, {
    bool exact = false,
    bool wakeup = false,
  }) async {
    final int now = new DateTime.now().millisecondsSinceEpoch;
    final int first = now + delay.inMilliseconds;
    final String functionName = PluginUtilities.getNameOfFunction(callback);
    final String className = PluginUtilities.getNameOfFunctionClass(callback);
    final String libraryPath =
        PluginUtilities.getPathForFunctionLibrary(callback);

    if (functionName == null) {
      return false;
    }

    if (libraryPath == null) {
      return false;
    }

    final dynamic r = await _channel.invokeMethod('Alarm.oneShot', <dynamic>[
      id,
      exact,
      wakeup,
      first,
      functionName,
      className,
      libraryPath
    ]);
    return (r == null) ? false : r;
  }

  /// Schedules a repeating timer to run `callback` with period `duration`.
  ///
  /// The `callback` will run whether or not the main application is running or
  /// in the foreground. It will run in the Isolate owned by the
  /// AndroidAlarmManager service.
  ///
  /// `callback` must be either a top-level function or a static method from a
  /// class.
  ///
  /// The repeating timer is uniquely identified by `id`. Calling this function
  /// again with the same `id` will cancel and replace the existing timer.
  ///
  /// If `exact` is passed as `true`, the timer will be created with Android's
  /// `AlarmManager.setRepeating`. When `exact` is `false` (the default), the
  /// timer will be created with `AlarmManager.setInexactRepeating`.
  ///
  /// If `wakeup` is passed as `true`, the device will be woken up when the
  /// alarm fires. If `wakeup` is false (the default), the device will not be
  /// woken up to service the alarm.
  ///
  /// Returns a [Future] that resolves to `true` on success and `false` on
  /// failure.
  static Future<bool> periodic(
    Duration duration,
    int id,
    dynamic Function() callback, {
    bool exact = false,
    bool wakeup = false,
  }) async {
    final int now = new DateTime.now().millisecondsSinceEpoch;
    final int period = duration.inMilliseconds;
    final int first = now + period;
    final String functionName = PluginUtilities.getNameOfFunction(callback);
    final String className = PluginUtilities.getNameOfFunctionClass(callback);
    final String libraryPath =
        PluginUtilities.getPathForFunctionLibrary(callback);

    if (functionName == null) {
      return false;
    }

    if (libraryPath == null) {
      return false;
    }

    final dynamic r = await _channel.invokeMethod('Alarm.periodic', <dynamic>[
      id,
      exact,
      wakeup,
      first,
      period,
      functionName,
      className,
      libraryPath
    ]);
    return (r == null) ? false : r;
  }

  /// Cancels a timer.
  ///
  /// If a timer has been scheduled with `id`, then this function will cancel
  /// it.
  ///
  /// Returns a [Future] that resolves to `true` on success and `false` on
  /// failure.
  static Future<bool> cancel(int id) async {
    final dynamic r =
        await _channel.invokeMethod('Alarm.cancel', <dynamic>[id]);
    return (r == null) ? false : r;
  }
}
