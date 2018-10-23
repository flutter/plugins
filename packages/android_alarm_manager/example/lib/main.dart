// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:isolate';

import 'package:android_alarm_manager/android_alarm_manager.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';

final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
FirebaseUser firebaseUser;

Future<void> ensureFirebaseUser() async {
  if (firebaseUser == null) {
    firebaseUser = await firebaseAuth.currentUser();
    if (firebaseUser == null) {
      firebaseUser = await firebaseAuth.signInAnonymously();
    }
  }
}

class HelloMessage {
  HelloMessage(this._now, this._msg, this._isolate, this._user, this._token);

  final DateTime _now;
  final String _msg;
  final int _isolate;
  final FirebaseUser _user;
  final String _token;

  @override
  String toString() {
    return "[$_now] $_msg "
        "isolate=$_isolate "
        "user='$_user' "
        "token=$_token";
  }
}

void printHelloMessage(String msg) {
  ensureFirebaseUser().then((_) {
    firebaseUser.getIdToken().then((String idToken) {
      print(HelloMessage(
        DateTime.now(),
        msg,
        Isolate.current.hashCode,
        firebaseUser,
        idToken,
      ));
    });
  });
}

void printHello() {
  printHelloMessage("Hello, world!");
}

void printGoodbye() {
  printHelloMessage("Goodbye, world!");
}

bool oneShotFired = false;

void printOneShot() {
  printHelloMessage("Hello, once!");
}

Future<void> main() async {
  final int helloAlarmID = 0;
  final int goodbyeAlarmID = 1;
  final int oneShotID = 2;

  // Start the AlarmManager service.
  await AndroidAlarmManager.initialize();

  printHelloMessage("Hello, main()!");
  runApp(const Center(
      child: Text('Hello, world!', textDirection: TextDirection.ltr)));
  await AndroidAlarmManager.periodic(
      const Duration(seconds: 5), helloAlarmID, printHello,
      wakeup: true);
  await AndroidAlarmManager.oneShot(
      const Duration(seconds: 5), goodbyeAlarmID, printGoodbye);
  if (!oneShotFired) {
    await AndroidAlarmManager.oneShot(
        const Duration(seconds: 5), oneShotID, printOneShot);
  }
}
