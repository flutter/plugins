// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:battery_platform_interface/battery_platform_interface.dart';

import 'package:battery_platform_interface/method_channel/method_channel_battery.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('$MethodChannelBattery', () {
    late MethodChannelBattery methodChannelBattery;

    setUp(() async {
      methodChannelBattery = MethodChannelBattery();

      methodChannelBattery.channel
          .setMockMethodCallHandler((MethodCall methodCall) async {
        switch (methodCall.method) {
          case 'getBatteryLevel':
            return 90;
          default:
            return null;
        }
      });

      MethodChannel(methodChannelBattery.eventChannel.name)
          .setMockMethodCallHandler((MethodCall methodCall) async {
        switch (methodCall.method) {
          case 'listen':
            await _ambiguate(ServicesBinding.instance)!
                .defaultBinaryMessenger
                .handlePlatformMessage(
                  methodChannelBattery.eventChannel.name,
                  methodChannelBattery.eventChannel.codec
                      .encodeSuccessEnvelope('full'),
                  (_) {},
                );
            break;
          case 'cancel':
          default:
            return null;
        }
      });
    });

    /// Test for batetry level call.
    test('getBatteryLevel', () async {
      final int result = await methodChannelBattery.batteryLevel();
      expect(result, 90);
    });

    /// Test for battery changed state call.
    test('onBatteryChanged', () async {
      final BatteryState result =
          await methodChannelBattery.onBatteryStateChanged().first;
      expect(result, BatteryState.full);
    });
  });
}

/// This allows a value of type T or T? to be treated as a value of type T?.
///
/// We use this so that APIs that have become non-nullable can still be used
/// with `!` and `?` on the stable branch.
// TODO(ianh): Remove this once we roll stable in late 2021.
T? _ambiguate<T>(T? value) => value;
