// Copyright 2018, the Flutter project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:firebase_in_app_messaging/firebase_in_app_messaging.dart';

void main() {
  runApp(MaterialApp(
    title: 'App Messaging Example',
    home: _MainScreen(),
  ));
}

class _MainScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _MainScreenState();
}

class _MainScreenState extends State<_MainScreen> {
  String _message = "Waiting for messages...";

  @override
  void initState() {
    FirebaseInAppMessaging.instance.setMessagingDisplay(
      (InAppMessagingDisplayMessage message, InAppMessagingDisplayDelegate delegate) {
        setState(() {
          _message = 'Message: $message';
        });
      },
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('App Messaging Example'),
        ),
        body: Center(
          child: Text(_message),
        ),
      ),
    );
  }
}
