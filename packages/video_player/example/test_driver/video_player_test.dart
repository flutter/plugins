// Copyright 2019, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';
import 'package:flutter_driver/flutter_driver.dart';
import 'package:test/test.dart';

Future<void> main() async {
  final FlutterDriver driver = await FlutterDriver.connect();
  tearDownAll(() async {
    driver.close();
  });

  //TODO(cyanglaz): Use TabBar tabs to navigate between pages after https://github.com/flutter/flutter/issues/16991 is fixed.
  test('Push a page contains video and pop back, do not crash.', () async {
    if (Platform.isIOS) {
      final SerializableFinder pushTab = find.byValueKey('push_tab');
      await driver.waitFor(pushTab, timeout: const Duration(seconds: 10));
      await driver.tap(pushTab, timeout: const Duration(seconds: 10));
      await driver.waitForAbsent(pushTab, timeout: const Duration(seconds: 10));
      await driver.waitFor(pushTab, timeout: const Duration(seconds: 30));
      final Health health =
          await driver.checkHealth(timeout: const Duration(seconds: 10));
      expect(health.status, HealthStatus.ok);
    }
    final SerializableFinder pushTab = find.byValueKey('push_tab');
    await driver.waitFor(pushTab, timeout: const Duration(seconds: 10));
    await driver.tap(pushTab, timeout: const Duration(seconds: 10));
    await driver.waitForAbsent(pushTab, timeout: const Duration(seconds: 10));
    await driver.waitFor(pushTab, timeout: const Duration(seconds: 30));
    final Health health =
        await driver.checkHealth(timeout: const Duration(seconds: 10));
    expect(health.status, HealthStatus.ok);
  });
}
