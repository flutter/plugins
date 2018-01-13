// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:package_info/package_info.dart' as package_info;

void main() {
  runApp(new MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Flutter Demo',
      theme: new ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: new MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => new _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String _version = 'Unknown';
  String _buildNumber = 'Unknown';
  String _packageName = 'Unknown';

  @override
  void initState() {
    super.initState();
    initPackageState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<Null> initPackageState() async {
    String version;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      version = await package_info.version;
    } on PlatformException {
      version = 'Failed to get version.';
    }

    String buildNumber;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      buildNumber = await package_info.buildNumber;
    } on PlatformException {
      buildNumber = 'Failed to get buildNumber.';
    }

    String packageName;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      packageName = await package_info.packageName;
    } on PlatformException {
      packageName = 'Failed to get packageName.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) {
      return;
    }

    setState(() {
      _version = version;
      _buildNumber = buildNumber;
      _packageName = packageName;
    });
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: const Text('Plugin example app'),
      ),
      body: new Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            new Text('App version is: $_version'),
            new Text('Build number is: $_buildNumber'),
            new Text('Package name is: $_packageName')
          ]),
    );
  }
}
