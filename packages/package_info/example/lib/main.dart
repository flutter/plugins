// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:package_info/package_info.dart';

void main() {
  runApp(new MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'PackageInfo Demo',
      theme: new ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: new MyHomePage(title: 'PackageInfo example app'),
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
  PackageInfo _packageInfo;

  @override
  void initState() {
    super.initState();
    initPackageState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<Null> initPackageState() async {
    PackageInfo.getInstance().then((PackageInfo packageInfo) {
      setState(() {
        _packageInfo = packageInfo;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: const Text('PackageInfo example app'),
      ),
      body: new Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            new Text(
                'Package name is: ${_packageInfo != null ? _packageInfo.packageName : ""}'),
            new Text(
                'App version is: ${_packageInfo != null ? _packageInfo.version : ""}'),
            new Text(
                'Build number is: ${_packageInfo != null ? _packageInfo.buildNumber : ""}'),
          ]),
    );
  }
}
