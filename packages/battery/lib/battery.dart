// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter/services.dart';
import 'package:meta/meta.dart' show visibleForTesting;

/// Indicates the current battery state.
enum BatteryState {
  /// The battery is completely full of energy.
  full,

  /// The battery is currently storing energy.
  charging,

  /// The battery is currently losing energy.
  discharging
}

/// API for accessing information about the battery of the device the Flutter
/// app is currently running on.
class Battery {
  /// Initializes the plugin and starts listening for potential platform events.
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

  /// This constructor is only used for testing and shouldn't be accessed by
  /// users of the plugin. It may break or change at any time.
  @visibleForTesting
  Battery.private(this._methodChannel, this._eventChannel);

  static Battery _instance;

  final MethodChannel _methodChannel;
  final EventChannel _eventChannel;
  Stream<BatteryState> _onBatteryStateChanged;

  /// Returns the current battery level in percent.
  Future<int> get batteryLevel => _methodChannel
      .invokeMethod<int>('getBatteryLevel')
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
