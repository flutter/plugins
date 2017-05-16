import 'dart:async';

import 'package:flutter/services.dart';
import 'package:meta/meta.dart' show visibleForTesting;

/// Indicates the current battery state.
enum BatteryState { full, charging, discharging }

class Battery {
  factory Battery() {
    if (_instance == null) {
      MethodChannel methodChannel =
          const MethodChannel('plugins.flutter.io/battery');
      EventChannel eventChannel =
          const EventChannel('plugins.flutter.io/charging');
      _instance = new Battery.private(methodChannel, eventChannel);
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
  Future<int> get batteryLevel =>
      _methodChannel.invokeMethod('getBatteryLevel');

  /// Fires whenever the battery state changes.
  Stream<BatteryState> get onBatteryStateChanged {
    if (_onBatteryStateChanged == null) {
      _onBatteryStateChanged =
          _eventChannel.receiveBroadcastStream().map(_stringToBatteryStateEnum);
    }
    return _onBatteryStateChanged;
  }
}

BatteryState _stringToBatteryStateEnum(String state) {
  switch (state) {
    case 'full':
      return BatteryState.full;
    case 'charging':
      return BatteryState.charging;
    case 'discharging':
      return BatteryState.discharging;
    default:
      throw new ArgumentError('$state is not a valid BatteryState.');
  }
}
