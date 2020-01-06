// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:ui';

import 'package:android_alarm_manager/android_alarm_manager.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  String invalidCallback(String foo) => foo;
  void validCallback(int id) => null;

  const MethodChannel testChannel = MethodChannel(
      'plugins.flutter.io/android_alarm_manager', JSONMethodCodec());
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    testChannel.setMockMethodCallHandler((MethodCall call) => null);
  });

  test('${AndroidAlarmManager.initialize}', () async {
    testChannel.setMockMethodCallHandler((MethodCall call) async {
      assert(call.method == 'AlarmService.start');
      return true;
    });

    final bool initialized = await AndroidAlarmManager.initialize();

    expect(initialized, isTrue);
  });

  group('${AndroidAlarmManager.oneShotAt}', () {
    test('validates input', () async {
      final DateTime validTime = DateTime.utc(1993);
      final int validId = 1;

      // Callback should take a single int param.
      await expectLater(
          () => AndroidAlarmManager.oneShotAt(
              validTime, validId, invalidCallback),
          throwsAssertionError);

      // ID should be less than 32 bits.
      await expectLater(
          () => AndroidAlarmManager.oneShotAt(
              validTime, 2147483648, validCallback),
          throwsAssertionError);
    });

    test('sends arguments to the platform', () async {
      final DateTime alarm = DateTime(1993);
      const int rawHandle = 4;
      AndroidAlarmManager.setTestOverides(
          getCallbackHandle: (Function _) =>
              CallbackHandle.fromRawHandle(rawHandle));

      final int id = 1;
      final bool alarmClock = true;
      final bool allowWhileIdle = true;
      final bool exact = true;
      final bool wakeup = true;
      final bool rescheduleOnReboot = true;

      testChannel.setMockMethodCallHandler((MethodCall call) async {
        expect(call.method, 'Alarm.oneShotAt');
        expect(call.arguments[0], id);
        expect(call.arguments[1], alarmClock);
        expect(call.arguments[2], allowWhileIdle);
        expect(call.arguments[3], exact);
        expect(call.arguments[4], wakeup);
        expect(call.arguments[5], alarm.millisecondsSinceEpoch);
        expect(call.arguments[6], rescheduleOnReboot);
        expect(call.arguments[7], rawHandle);
        return true;
      });

      final bool result = await AndroidAlarmManager.oneShotAt(
          alarm, id, validCallback,
          alarmClock: alarmClock,
          allowWhileIdle: allowWhileIdle,
          exact: exact,
          wakeup: wakeup,
          rescheduleOnReboot: rescheduleOnReboot);

      expect(result, isTrue);
    });
  });

  test('${AndroidAlarmManager.oneShot} calls through to oneShotAt', () async {
    final DateTime now = DateTime(1993);
    const int rawHandle = 4;
    AndroidAlarmManager.setTestOverides(
        now: () => now,
        getCallbackHandle: (Function _) =>
            CallbackHandle.fromRawHandle(rawHandle));

    const Duration alarm = Duration(seconds: 1);
    final int id = 1;
    final bool alarmClock = true;
    final bool allowWhileIdle = true;
    final bool exact = true;
    final bool wakeup = true;
    final bool rescheduleOnReboot = true;

    testChannel.setMockMethodCallHandler((MethodCall call) async {
      expect(call.method, 'Alarm.oneShotAt');
      expect(call.arguments[0], id);
      expect(call.arguments[1], alarmClock);
      expect(call.arguments[2], allowWhileIdle);
      expect(call.arguments[3], exact);
      expect(call.arguments[4], wakeup);
      expect(
          call.arguments[5], now.millisecondsSinceEpoch + alarm.inMilliseconds);
      expect(call.arguments[6], rescheduleOnReboot);
      expect(call.arguments[7], rawHandle);
      return true;
    });

    final bool result = await AndroidAlarmManager.oneShot(
        alarm, id, validCallback,
        alarmClock: alarmClock,
        allowWhileIdle: allowWhileIdle,
        exact: exact,
        wakeup: wakeup,
        rescheduleOnReboot: rescheduleOnReboot);

    expect(result, isTrue);
  });

  group('${AndroidAlarmManager.periodic}', () {
    test('validates input', () async {
      const Duration validDuration = Duration(seconds: 0);
      final int validId = 1;

      // Callback should take a single int param.
      await expectLater(
          () => AndroidAlarmManager.periodic(
              validDuration, validId, invalidCallback),
          throwsAssertionError);

      // ID should be less than 32 bits.
      await expectLater(
          () => AndroidAlarmManager.periodic(
              validDuration, 2147483648, validCallback),
          throwsAssertionError);
    });

    test('sends arguments through to the platform', () async {
      final DateTime now = DateTime(1993);
      const int rawHandle = 4;
      AndroidAlarmManager.setTestOverides(
          now: () => now,
          getCallbackHandle: (Function _) =>
              CallbackHandle.fromRawHandle(rawHandle));

      final int id = 1;
      final bool exact = true;
      final bool wakeup = true;
      final bool rescheduleOnReboot = true;
      const Duration period = Duration(seconds: 1);

      testChannel.setMockMethodCallHandler((MethodCall call) async {
        expect(call.method, 'Alarm.periodic');
        expect(call.arguments[0], id);
        expect(call.arguments[1], exact);
        expect(call.arguments[2], wakeup);
        expect(call.arguments[3],
            (now.millisecondsSinceEpoch + period.inMilliseconds));
        expect(call.arguments[4], period.inMilliseconds);
        expect(call.arguments[5], rescheduleOnReboot);
        expect(call.arguments[6], rawHandle);
        return true;
      });

      final bool result = await AndroidAlarmManager.periodic(
        period,
        id,
        (int id) => null,
        exact: exact,
        wakeup: wakeup,
        rescheduleOnReboot: rescheduleOnReboot,
      );

      expect(result, isTrue);
    });
  });

  test('${AndroidAlarmManager.cancel}', () async {
    final int id = 1;
    testChannel.setMockMethodCallHandler((MethodCall call) async {
      assert(call.method == 'Alarm.cancel' && call.arguments[0] == id);
      return true;
    });

    final bool canceled = await AndroidAlarmManager.cancel(id);

    expect(canceled, isTrue);
  });
}
