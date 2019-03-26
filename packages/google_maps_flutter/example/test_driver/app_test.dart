// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_driver/flutter_driver.dart';
import 'package:test/test.dart';

void main() {
  group('Google Maps App', () {
    final SerializableFinder userInterface = find.byValueKey('User interface');

    FlutterDriver driver;

    setUpAll(() async {
      driver = await FlutterDriver.connect();
    });

    tearDownAll(() async {
      if (driver != null) {
        driver.close();
      }
    });

    Future<void> assertActions(String expectedActions) async {
      final String actions = await driver.requestData('getRecordedActions');
      expect(actions, equals(expectedActions));
    }

    test('Test Compass Enable/Disable', () async {
      await driver.waitFor(userInterface);
      await driver.tap(userInterface);
      await driver.waitUntilNoTransientCallbacks();

      final SerializableFinder compassButton = find.byValueKey('compassButton');

      await driver.requestData('startRecordingActions');
      await driver.waitFor(compassButton);
      await driver.tap(compassButton);
      await driver.waitUntilNoTransientCallbacks();
      await assertActions('setCompassEnabled false');
      await driver.requestData('clearRecordedActions');

      await driver.requestData('startRecordingActions');
      await driver.tap(compassButton);
      await driver.waitUntilNoTransientCallbacks();
      await assertActions('setCompassEnabled true');
      await driver.requestData('clearRecordedActions');
    });
  });
}
