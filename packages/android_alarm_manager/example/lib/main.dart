// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:android_alarm_manager/android_alarm_manager.dart';
import 'package:flutter/widgets.dart';

void printMessage(String msg) => print('[${DateTime.now()}] $msg');

void printPeriodic() => printMessage("Periodic!");
void printOneShot() => printMessage("One shot!");

Future<void> main() async {
  final int periodicID = 0;
  final int oneShotID = 1;

  // Start the AlarmManager service.
  await AndroidAlarmManager.initialize();

  printMessage("main run");
  runApp(const Center(
      child:
          Text('See device log for output', textDirection: TextDirection.ltr)));
  await AndroidAlarmManager.periodic(
      const Duration(seconds: 5), periodicID, printPeriodic,
      wakeup: true);
  await AndroidAlarmManager.oneShot(
      const Duration(seconds: 5), oneShotID, printOneShot);
}
