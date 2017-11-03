// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:isolate';

import 'package:flutter/widgets.dart';
import 'package:android_alarm_manager/android_alarm_manager.dart';

void printHello() {
  final DateTime now = new DateTime.now();
  final int isolateId = Isolate.current.hashCode;
  print("[$now] Hello, world! isolate=$isolateId function='$printHello'");
}

void printGoodbye() {
  final DateTime now = new DateTime.now();
  final int isolateId = Isolate.current.hashCode;
  print("[$now] Goodbye, world! isolate=$isolateId function='$printGoodbye'");
}

void printOneShot() {
  final DateTime now = new DateTime.now();
  final int isolateId = Isolate.current.hashCode;
  print("[$now] Hello, once! isolate=$isolateId function='$printOneShot'");
}

Future<Null> main() async {
  final int helloAlarmID = 0;
  final int goodbyeAlarmID = 1;
  final int oneShotID = 2;
  runApp(const Center(
      child: const Text('Hello, world!', textDirection: TextDirection.ltr)));
  await AndroidAlarmManager.periodic(
      const Duration(minutes: 1), helloAlarmID, printHello);
  await AndroidAlarmManager.periodic(
      const Duration(minutes: 1), goodbyeAlarmID, printGoodbye);
  await AndroidAlarmManager.oneShot(
      const Duration(minutes: 1), oneShotID, printOneShot);
}
