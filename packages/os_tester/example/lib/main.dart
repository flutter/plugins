// Copyright 2019, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:os_tester/os_tester.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  State createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  String _text = 'TEST';

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('OSTester example app'),
        ),
        body: Center(
          child: RaisedButton(
            onPressed: () {
              setState(() {
                _text = 'pass';
              });
            },
            child: Text(_text),
          ),
        ),
      ),
    );
  }
}
