// Copyright 2019, the Chromium project authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// TODO(cyanglaz): Remove once https://github.com/flutter/flutter/issues/59879 is fixed.
// @dart = 2.9

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter_driver/flutter_driver.dart';

Future<void> main() async {
  final FlutterDriver driver = await FlutterDriver.connect();
  final String data =
      await driver.requestData(null, timeout: const Duration(minutes: 1));
  await driver.close();
  final Map<String, dynamic> result = jsonDecode(data);
  exit(result['result'] == 'true' ? 0 : 1);
}
