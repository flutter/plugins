// Copyright 2019, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';
import 'dart:io';

import 'package:flutter_driver/flutter_driver.dart';

Future<StreamSubscription> resumeIsolatesOnPause(FlutterDriver driver) async {
    final vm = await driver.serviceClient.getVM();
    for (final isolateRef in vm.isolates) {
      final isolate = await isolateRef.load();
      if (isolate.isPaused) {
        isolate.resume();
      }
    }
    return driver.serviceClient.onIsolateRunnable
        .asBroadcastStream()
        .listen((isolateRef) async {
      final isolate = await isolateRef.load();
      if (isolate.isPaused) {
        isolate.resume();
      }
    });
}

Future<void> main() async {
  final FlutterDriver driver = await FlutterDriver.connect();
  // flutter drive causes isolates to be paused on spawn. The background isolate
  // for this plugin will need to be resumed for the test to pass.
  final subscription = await resumeIsolatesOnPause(driver);
  final String result =
      await driver.requestData(null, timeout: const Duration(minutes: 2));
  driver.close();
  subscription.cancel();
  exit(result == 'pass' ? 0 : 1);
}
