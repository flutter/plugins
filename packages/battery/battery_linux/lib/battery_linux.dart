// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:io';
import 'dart:async';

import 'package:battery_platform_interface/battery_platform_interface.dart';

/// The linux implementation of [BatteryPlatform]
///
/// This class implements the `package:battery` functionality for linux
class BatteryLinux extends BatteryPlatform {
  /// Registers this class as the default instance of [BatteryPlatform]
  static void register() {
    BatteryPlatform.instance = BatteryLinux();
  }

  /// Stores the path to battery info directory.
  /// This can be BAT0 or BAT1.
  String _path;

  /// Gets the path of battery info directory.
  Future<void> get _getBatteryPath async {
    _path = "/sys/class/power_supply/";
    Directory _directory = Directory("/sys/class/power_supply/BAT0");
    if (await _directory.exists()) {
      _path += "BAT0";
    } else {
      _path += "BAT1";
    }
  }

  @override
  Future<int> batteryLevel() async {
    if (_path == null) {
      await _getBatteryPath;
    }
    File file = File("$_path/capacity");
    return int.parse(await file.readAsString());
  }

  @override
  Stream<BatteryState> onBatteryStateChanged() async* {
    if (_path == null) {
      await _getBatteryPath;
    }
    File file = File("$_path/status");
    while (true) {
      await Future.delayed(Duration(seconds: 1));
      yield _parseBatteryState((await file.readAsString()).toLowerCase().trim());
    }
  }
}

/// Method for parsing battery state.
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
