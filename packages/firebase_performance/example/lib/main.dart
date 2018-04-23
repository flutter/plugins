import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:firebase_performance/firebase_performance.dart';
jjjk
void main() => runApp(new MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => new _MyAppState();
}

class _MyAppState extends State<MyApp> {
  FirebasePerformance performance = FirebasePerformance.instance;
  bool _collectionEnabled;
  String _collectionEnabledString = 'Unknown status of performance collection.';

  @override
  void initState() {
    super.initState();
    isPerformanceCollectionEnabled();
  }

  Future<void> isPerformanceCollectionEnabled() async {
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

    if (!mounted) return new Future<void>.value(null);

    setState(() {
      _collectionEnabledString = perfCollection;
    });
  }

  Future<void> togglePerformanceCollection() async {
    await performance.setPerformanceCollectionEnabled(!_collectionEnabled);
    isPerformanceCollectionEnabled();
  }

  Future<void> testTrace() async {
    final Trace trace = await performance.newTrace("android-test");
    trace.incrementCounter("counter1", 16);

    if (defaultTargetPlatform == TargetPlatform.android) {
      trace.android.putAttribute("favorite_color", "blue");
    }
    await trace.start();

    int sum = 0;
    for (int i = 0; i < 10000000; i++) {
      sum += i;
    }
    await trace.stop();
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
              onPressed: togglePerformanceCollection,
              child: const Text('Toggle Data Collection'),
              color: Colors.blueAccent,
              textColor: Colors.white,
            ),
            new RaisedButton(
              onPressed: testTrace,
              child: const Text('Send Trace'),
              color: Colors.blueAccent,
              textColor: Colors.white,
            )
          ],
        )),
      ),
    );
  }
}
