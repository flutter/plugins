// Copyright 2019, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';
import 'dart:io';

import 'package:flutter_driver/flutter_driver.dart';
import 'package:video_player_example/main.dart' as app;

Future<void> main() async {
  final FlutterDriver driver = await FlutterDriver.connect();
  final String result =
      await driver.requestData(null, timeout: const Duration(minutes: 1));
  app.main();
  await driver.close();
  exit(result == 'pass' ? 0 : 1);
}
