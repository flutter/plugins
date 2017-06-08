// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:android_intent/android_intent.dart';
import 'package:flutter/material.dart';
import 'package:platform/platform.dart';

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
      home: new MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    Widget body;
    if (const LocalPlatform().isAndroid) {
      body = new GestureDetector(
        child: new Center(child:
          new Text('Click here to launch play store with New York Times app.')),
        onTap: () {
            AndroidIntent intent = new AndroidIntent(
              action: 'action_view',
              data: 'https://play.google.com/store/apps/details?id=com.nytimes.android');
            intent.launch();
        });
    } else {
      body = new Center(child: new Text('This plugin only works with Android'));
    }
    return new Scaffold(
      appBar: new AppBar(
        title: new Text('Plugin example app'),
      ),
      body: body,
    );
  }
}
