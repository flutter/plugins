// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_driver/flutter_driver.dart';
import 'package:test/test.dart';

void main() {
  test('firebase_ml_vision', () async {
    final FlutterDriver driver = await FlutterDriver.connect();
    await driver.requestData(null, timeout: const Duration(minutes: 1));
    driver.close();
  });
}
