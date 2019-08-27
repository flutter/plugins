// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:android_alarm_manager/android_alarm_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

void printMessage(String msg) => print('[${DateTime.now()}] $msg');

void printPeriodic() => printMessage("Periodic!");

void printOneShot() => printMessage("One shot!");

final int periodicID = 0;
final int oneShotID = 1;

Future<void> main() async {
  // Start the AlarmManager service.
  await AndroidAlarmManager.initialize();

  printMessage("main run");
  runApp(MaterialApp(home: App()));
}

class App extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return AppState();
  }
}

class AppState extends State<App> {
  bool isPeriodicActive = false;
  bool isOneShotActive = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    AndroidAlarmManager.isAlarmActive(periodicID).then((bool value) {
      setState(() {
        isPeriodicActive = value;
      });
    });

    AndroidAlarmManager.isAlarmActive(oneShotID).then((bool value) {
      setState(() {
        isOneShotActive = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text("Periodic Alarm Status: $isPeriodicActive"),
              Text("OneShot Alarm Status: $isOneShotActive"),
              RaisedButton(
                onPressed: () async {
                  await AndroidAlarmManager.periodic(
                      const Duration(seconds: 5), periodicID, printPeriodic,
                      wakeup: true);
                  AndroidAlarmManager.isAlarmActive(periodicID).then(
                    (bool value) {
                      setState(() {
                        isPeriodicActive = value;
                      });
                    },
                  );
                },
                child: const Text("Start Periodic Alarm"),
              ),
              RaisedButton(
                onPressed: () async {
                  await AndroidAlarmManager.oneShot(
                      const Duration(seconds: 5), oneShotID, printOneShot,
                      wakeup: true);
                  AndroidAlarmManager.isAlarmActive(oneShotID).then(
                    (bool value) {
                      setState(
                        () {
                          isOneShotActive = value;
                        },
                      );
                    },
                  );
                },
                child: const Text("Start One Shot Alarm"),
              )
            ],
          ),
        ),
      ),
    );
  }
}
