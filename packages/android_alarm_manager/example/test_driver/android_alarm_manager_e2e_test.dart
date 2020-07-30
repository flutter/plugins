// Copyright 2019, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_driver/flutter_driver.dart';
import 'package:vm_service_client/vm_service_client.dart';

Future<StreamSubscription<VMIsolateRef>> resumeIsolatesOnPause(
    FlutterDriver driver) async {
  final VM vm = await driver.serviceClient.getVM();
  for (VMIsolateRef isolateRef in vm.isolates) {
    final VMIsolate isolate = await isolateRef.load();
    if (isolate.isPaused) {
      await isolate.resume();
    }
  }
  return driver.serviceClient.onIsolateRunnable
      .asBroadcastStream()
      .listen((VMIsolateRef isolateRef) async {
    final VMIsolate isolate = await isolateRef.load();
    if (isolate.isPaused) {
      await isolate.resume();
    }
  });
}

Future<void> main() async {
  final FlutterDriver driver = await FlutterDriver.connect();
  // flutter drive causes isolates to be paused on spawn. The background isolate
  // for this plugin will need to be resumed for the test to pass.
  final StreamSubscription<VMIsolateRef> subscription =
      await resumeIsolatesOnPause(driver);
  final String data = await driver.requestData(
    null,
    timeout: const Duration(minutes: 1),
  );
  await driver.close();
  await subscription.cancel();
  final Map<String, dynamic> result = jsonDecode(data);
  exit(result['result'] == 'true' ? 0 : 1);
}
