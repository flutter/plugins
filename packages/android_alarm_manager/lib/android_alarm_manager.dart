// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter/services.dart';

/// A Flutter plugin for registering Dart callbacks with the Android
/// AlarmManager service.
///
/// See the example/ directory in this package for sample usage.
class AndroidAlarmManager {
  static const String _channelName = 'plugins.flutter.io/android_alarm_manager';
  static const MethodChannel _channel =
      MethodChannel(_channelName, JSONMethodCodec());

  /// Schedules a one-shot timer to run `callback` after time `delay`.
  ///
  /// The `callback` will run whether or not the main application is running or
  /// in the foreground. It will run in the same Isolate as the main application
  /// if one is available, otherwise a new Isolate will be created.
  ///
  /// `callback` must be a top-level function in the application's root library
  /// (that is, in the same library as the application's `main()` function).
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
    final String functionName = _nameOfFunction(callback);
    if (functionName == null) {
      return false;
    }
    final dynamic r = await _channel.invokeMethod(
        'Alarm.oneShot', <dynamic>[id, exact, wakeup, first, functionName]);
    return (r == null) ? false : r;
  }

  /// Schedules a repeating timer to run `callback` with period `duration`.
  ///
  /// The `callback` will run whether or not the main application is running or
  /// in the foreground. It will run in the same Isolate as the main application
  /// if one is available, otherwise a new Isolate will be created.
  ///
  /// `callback` must be a top-level function in the application's root library
  /// (that is, in the same library as the application's `main()` function).
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
    final String functionName = _nameOfFunction(callback);
    if (functionName == null) {
      return false;
    }
    final dynamic r = await _channel.invokeMethod('Alarm.periodic',
        <dynamic>[id, exact, wakeup, first, period, functionName]);
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

  // Extracts the name of a top-level function from the .toString() of its
  // closure-ization. The Java side of this plugin accepts the entrypoint into
  // Dart code as a string. However, the Dart side of this API can't use a
  // string to specify the entrypoint, otherwise it won't be visited by Dart's
  // AOT compiler.
  static String _nameOfFunction(dynamic Function() callback) {
    final String longName = callback.toString();
    final int functionIndex = longName.indexOf('Function');
    if (functionIndex == -1) return null;
    final int openQuote = longName.indexOf("'", functionIndex + 1);
    if (openQuote == -1) return null;
    final int closeQuote = longName.indexOf("'", openQuote + 1);
    if (closeQuote == -1) return null;
    return longName.substring(openQuote + 1, closeQuote);
  }
}
