// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter/services.dart';
import 'package:meta/meta.dart' show visibleForTesting;

/// Indicates the current battery state.
enum BatteryState { full, charging, discharging }

class Battery {
  factory Battery() {
    if (_instance == null) {
      final MethodChannel methodChannel =
          const MethodChannel('plugins.flutter.io/battery');
      final EventChannel eventChannel =
          const EventChannel('plugins.flutter.io/charging');
      _instance = Battery.private(methodChannel, eventChannel);
    }
    return _instance;
  }

  @visibleForTesting
  Battery.private(this._methodChannel, this._eventChannel);

  static Battery _instance;

  final MethodChannel _methodChannel;
  final EventChannel _eventChannel;
  Stream<BatteryState> _onBatteryStateChanged;

  /// Returns the current battery level in percent.
  Future<int> get batteryLevel => _methodChannel
      // TODO(amirh): remove this on when the invokeMethod update makes it to stable Flutter.
      // https://github.com/flutter/flutter/issues/26431
      // ignore: strong_mode_implicit_dynamic_method
      .invokeMethod('getBatteryLevel')
      .then<int>((dynamic result) => result);

  /// Fires whenever the battery state changes.
  Stream<BatteryState> get onBatteryStateChanged {
    if (_onBatteryStateChanged == null) {
      _onBatteryStateChanged = _eventChannel
          .receiveBroadcastStream()
          .map((dynamic event) => _parseBatteryState(event));
    }
    return _onBatteryStateChanged;
  }
}

BatteryState _parseBatteryState(String state) {
  switch (state) {
    case 'full':
      return BatteryState.full;
    case 'charging':
      return BatteryState.charging;
    case 'discharging':
      return BatteryState.discharging;
    default:
      throw ArgumentError('$state is not a valid BatteryState.');
  }
}
