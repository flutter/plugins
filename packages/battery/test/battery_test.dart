// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:async/async.dart';
import 'package:flutter/services.dart';
import 'package:test/test.dart';
import 'package:battery/battery.dart';
import 'package:mockito/mockito.dart';

void main() {
  MockMethodChannel methodChannel;
  MockEventChannel eventChannel;
  Battery battery;

  setUp(() {
    methodChannel = MockMethodChannel();
    eventChannel = MockEventChannel();
    battery = Battery.private(methodChannel, eventChannel);
  });

  test('batteryLevel', () async {
    when(methodChannel.invokeMethod('getBatteryLevel'))
        .thenAnswer((Invocation invoke) => Future<int>.value(42));
    expect(await battery.batteryLevel, 42);
  });

  group('battery state', () {
    StreamController<String> controller;

    setUp(() {
      controller = StreamController<String>();
      when(eventChannel.receiveBroadcastStream())
          .thenAnswer((Invocation invoke) => controller.stream);
    });

    tearDown(() {
      controller.close();
    });

    test('calls receiveBroadcastStream once', () {
      battery.onBatteryStateChanged;
      battery.onBatteryStateChanged;
      battery.onBatteryStateChanged;
      verify(eventChannel.receiveBroadcastStream()).called(1);
    });

    test('receive values', () async {
      final StreamQueue<BatteryState> queue =
          StreamQueue<BatteryState>(battery.onBatteryStateChanged);

      controller.add("full");
      expect(await queue.next, BatteryState.full);

      controller.add("discharging");
      expect(await queue.next, BatteryState.discharging);

      controller.add("charging");
      expect(await queue.next, BatteryState.charging);

      controller.add("illegal");
      expect(queue.next, throwsArgumentError);
    });
  });
}

class MockMethodChannel extends Mock implements MethodChannel {}

class MockEventChannel extends Mock implements EventChannel {}
