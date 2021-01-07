// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:battery_platform_interface/battery_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:test/test.dart';
import 'package:battery/battery.dart';
import 'package:mockito/mockito.dart';

void main() {
  group('battery', () {
    Battery battery;
    MockBatteryPlatform fakePlatform;
    setUp(() async {
      fakePlatform = MockBatteryPlatform();
      BatteryPlatform.instance = fakePlatform;
      battery = Battery();
    });
    test('batteryLevel', () async {
      int result = await battery.batteryLevel;
      expect(result, 42);
    });
    test('onBatteryStateChanged', () async {
      BatteryState result = await battery.onBatteryStateChanged.first;
      expect(result, BatteryState.full);
    });
  });
}

class MockBatteryPlatform extends Mock
    with MockPlatformInterfaceMixin
    implements BatteryPlatform {
  Future<int> batteryLevel() async {
    return 42;
  }

  Stream<BatteryState> onBatteryStateChanged() {
    StreamController<BatteryState> result = StreamController<BatteryState>();
    result.add(BatteryState.full);
    return result.stream;
  }
}
