// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:io';

import 'package:flutter_driver/flutter_driver.dart';
import 'package:test/test.dart';

Future<List<int>> _loadGolden(String assetName) async {
  final File file = File('test_assets/$assetName.png');

  if (!file.existsSync()) {
    throw Exception('Unable to find golden: ${file.absolute.path}');
  }

  return file.readAsBytes();
}

void main() {
  group('Google Maps App', () {
    final SerializableFinder userInterface = find.byValueKey('User interface');

    FlutterDriver driver;

    // Connect to the Flutter driver before running any tests
    setUpAll(() async {
      driver = await FlutterDriver.connect();
    });

    // Close the connection to the driver after the tests have completed
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

      final List<int> screenShotBytes = await driver.screenshot();
      final List<int> golden = await _loadGolden('basic_map_ui');

      expect(screenShotBytes, equals(golden));
    });
  });
}
