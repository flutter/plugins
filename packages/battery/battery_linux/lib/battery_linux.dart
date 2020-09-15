// Copyright 2020 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:battery_platform_interface/battery_platform_interface.dart';
import 'package:dbus/dbus.dart';

/// The linux implementation of [BatteryPlatform]
///
/// This class implements the `package:battery` functionality for linux
class BatteryLinux extends BatteryPlatform {
  /// Registers this class as the default instance of [BatteryPlatform]
  static void register() {
    BatteryPlatform.instance = BatteryLinux();
  }

  DBusClient _client;
  DBusRemoteObject _object;

  DBusRemoteObject get _getDbusObject {
    if (_client == null) {
      _client = DBusClient.system();
      _object = DBusRemoteObject(
        _client,
        'org.freedesktop.UPower',
        DBusObjectPath('/org/freedesktop/UPower/devices/DisplayDevice'),
      );
    }
    return _object;
  }

  @override
  Future<int> batteryLevel() async {
    DBusValue level = await _getDbusObject.getProperty(
        'org.freedesktop.UPower.Device', 'Percentage');
    return level.toNative().toInt();
  }

  @override
  Stream<BatteryState> onBatteryStateChanged() async* {
    DBusValue state = await _getDbusObject.getProperty(
        'org.freedesktop.UPower.Device', 'State');
    yield _parseBatteryState(state.toNative());
    Stream<DBusPropertiesChangedSignal> stream =
        _object.subscribePropertiesChanged();
    await for (var signal in stream) {
      state = signal.changedProperties['State'];
      if (state != null) {
        yield _parseBatteryState(state.toNative());
      }
    }
  }
}

/// Method for parsing battery state.
BatteryState _parseBatteryState(int state) {
  switch (state) {
    case 1:
      return BatteryState.charging;
    case 2:
      return BatteryState.discharging;
    case 4:
      return BatteryState.full;
    default:
      throw ArgumentError('$state is not a valid BatteryState.');
  }
}
