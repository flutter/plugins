// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:battery_linux/battery_linux.dart';
import 'package:battery_platform_interface/battery_platform_interface.dart';
import 'package:test/test.dart';
import 'package:mockito/mockito.dart';

void main() {
  group('battery', () {
    BatteryLinux batteryLinux;
    MockBatteryPlatform fakePlatform;
    setUp(() async {
      fakePlatform = MockBatteryPlatform();
      batteryLinux = fakePlatform;
    });
    test('batteryLevel', () async {
      int result = await batteryLinux.batteryLevel();
      expect(result, 42);
    });
    test('onBatteryStateChanged', () async {
      BatteryState result = await batteryLinux.onBatteryStateChanged().first;
      expect(result, BatteryState.full);
    });
  });
}

class MockBatteryPlatform extends Mock implements BatteryLinux {
  Future<int> batteryLevel() async {
    return 42;
  }

  Stream<BatteryState> onBatteryStateChanged() {
    StreamController<BatteryState> result = StreamController<BatteryState>();
    result.add(BatteryState.full);
    return result.stream;
  }
}
