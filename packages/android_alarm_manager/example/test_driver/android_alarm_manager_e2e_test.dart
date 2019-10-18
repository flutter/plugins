// Copyright 2019, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:flutter_driver/flutter_driver.dart';

Future<void> main() async {
  final FlutterDriver driver = await FlutterDriver.connect();
  print('SETTING UP DRIVER');
  final subscription = driver.serviceClient.onIsolateRunnable
      .asBroadcastStream()
      .listen((isolateRef) async {
    print('isolate started: ${isolateRef.name}');
    final isolate = await isolateRef.load();
    if (isolate.isPaused) {
      isolate.resume();
      print(
          'resuming isolate: ${isolateRef.numberAsString}:${isolateRef.name}');
    }
  });
  final String result =
      await driver.requestData(null, timeout: const Duration(minutes: 1));
  subscription.cancel();
  driver.close();
  exit(result == 'pass' ? 0 : 1);
}
