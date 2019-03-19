// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:convert';
import 'dart:io';

import 'package:flutter_driver/flutter_driver.dart';
import 'package:test/test.dart';

// This needs `modelName` to be passed in as a handler in
// `enableFlutterDriverExtension` for the test app. Please look at
// `app.dart` as an example on how to do this.
class DeviceGoldenFileMatcher {
  DeviceGoldenFileMatcher(this.driver);

  final FlutterDriver driver;

  Future<List<int>> _loadGolden(String assetName, String modelName) async {
    final String fileName = 'test_assets/$modelName/$assetName.png';
    final File file = File(fileName);

    if (!file.existsSync()) {
      print('Unable to find file $fileName, returning null bytes');
      return null;
    }

    return file.readAsBytes();
  }

  Future<void> matchGoldenAsync(String assetName) async {
    final List<int> screenShotBytes = await driver.screenshot();
    final String modelName = await driver.requestData('modelName');
    final List<int> golden = await _loadGolden(assetName, modelName);

    if (golden == null) {
      // The golden file does not exist. Printing the base64.
      print('No golden found for model: $modelName, got:');
      print(base64.encode(screenShotBytes));

      fail('Please update the golden for $modelName.');
    } else {
      expect(screenShotBytes, equals(golden));
    }
  }
}
