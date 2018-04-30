// Copyright 2017, the Flutter project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:firebase_performance/firebase_performance.dart';

void main() => runApp(new MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => new _MyAppState();
}

class _MyAppState extends State<MyApp> {
  FirebasePerformance performance = FirebasePerformance.instance;
  bool _collectionEnabled;
  String _collectionEnabledString = 'Unknown status of performance collection.';
  String _message = '';

  @override
  void initState() {
    super.initState();
    _updatePerformanceCollectionEnabled();
  }

  Future<void> _updatePerformanceCollectionEnabled() async {
    String perfCollection;

    try {
      _collectionEnabled = await performance.isPerformanceCollectionEnabled();
      if (_collectionEnabled) {
        perfCollection = 'Performance collection is enabled.';
      } else {
        perfCollection = 'Performance collection is disabled.';
      }
    } on PlatformException {
      perfCollection = 'Failed to see status of performance collection.';
    }

    if (!mounted) return;

    setState(() {
      _collectionEnabledString = perfCollection;
    });
  }

  Future<void> _togglePerformanceCollection() async {
    await performance.setPerformanceCollectionEnabled(!_collectionEnabled);
    _updatePerformanceCollectionEnabled();
  }

  Future<void> _testTrace() async {
    final Trace trace = performance.newTrace("test");
    trace.incrementCounter("counter1", 16);
    trace.putAttribute("favorite_color", "blue");

    await trace.start();

    int sum = 0;
    for (int i = 0; i < 10000000; i++) {
      sum += i;
    }
    print(sum);

    await trace.stop();

    setState(() {
      _message = 'Trace sent!';
    });
  }

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      home: new Scaffold(
        appBar: new AppBar(
          title: const Text('Firebase Performance Example'),
        ),
        body: new Center(
            child: new Column(
          children: <Widget>[
            new Text(_collectionEnabledString),
            new RaisedButton(
              onPressed: _togglePerformanceCollection,
              child: const Text('Toggle Data Collection'),
            ),
            new RaisedButton(
              onPressed: _testTrace,
              child: const Text('Send Trace'),
            ),
            new Text(
              _message,
              style: const TextStyle(color: Colors.lightGreenAccent),
            )
          ],
        )),
      ),
    );
  }
}
