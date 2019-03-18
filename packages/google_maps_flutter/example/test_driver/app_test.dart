// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:convert';
import 'dart:io';

import 'package:device_info/device_info.dart';
import 'package:flutter_driver/flutter_driver.dart';
import 'package:test/test.dart';

final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();

Future<String> _modelString() async {
  if (Platform.isAndroid) {
    final AndroidDeviceInfo androidInfo = await _deviceInfo.androidInfo;
    return androidInfo.model;
  } else if (Platform.isIOS) {
    final IosDeviceInfo iosInfo = await _deviceInfo.iosInfo;
    return iosInfo.model;
  } else {
    return Platform.operatingSystem;
  }
}

Future<List<int>> _loadGolden(String assetName) async {
  final String modelString = await _modelString();
  final String fileName = 'test_assets/$modelString/$assetName.png';
  final File file = File(fileName);

  if (!file.existsSync()) {
    print('Unable to find file $fileName, returning null bytes');
    return null;
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

      if (golden == null) {
        // The golden file does not exist. Printing the base64.
        print('No golden found for model: ${_modelString()}, got:');
        print(base64.encode(screenShotBytes));

        fail('Please update the golden for the above device.');
      } else {
        expect(screenShotBytes, equals(golden));
      }
    });
  });
}
