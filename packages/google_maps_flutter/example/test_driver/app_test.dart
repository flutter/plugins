// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_driver/flutter_driver.dart';
import 'package:test/test.dart';

import 'device_golden_file_matcher.dart';

void main() {
  group('Google Maps App', () {
    final SerializableFinder userInterface = find.byValueKey('User interface');

    FlutterDriver driver;
    DeviceGoldenFileMatcher goldenFileMatcher;

    setUpAll(() async {
      driver = await FlutterDriver.connect();
      goldenFileMatcher = DeviceGoldenFileMatcher(driver);
    });

    tearDownAll(() async {
      if (driver != null) {
        driver.close();
      }
    });

    test('Basic Map Load', () async {
      await driver.waitFor(userInterface);
      await driver.tap(userInterface);

      await driver.waitUntilNoTransientCallbacks();

      // we need to wait for the map tiles to show.
      // This is different from map created.
      // TODO(iskakaushik) maybe maps sdk has a callback for this?
      await Future<dynamic>.delayed(Duration(seconds: 10));

      await goldenFileMatcher.matchGoldenAsync('basic_map_ui');
    });
  });
}
