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
  bool _collectionEnabled;
  String _collectionEnabledString = 'Unknown status of performance collection.';

  @override
  initState() {
    super.initState();
    isPerformanceCollectionEnabled();
  }

  Future<void> isPerformanceCollectionEnabled() async {
    String perfCollection;

    try {
      _collectionEnabled = await FirebasePerformance.isPerformanceCollectionEnabled();
      if (_collectionEnabled) {
        perfCollection = 'Performance collection is enabled.';
      } else {
        perfCollection = 'Performance collection is disabled.';
      }
    } on PlatformException {
      perfCollection = 'Failed to see if performance collection is enabled.';
    }

    if (!mounted)
      return new Future<void>.value(null);
    
    setState(() {
      _collectionEnabledString = perfCollection;
    });
  }

  Future<void> togglePerformanceCollection() async {
    await FirebasePerformance.setPerformanceCollectionEnabled(!_collectionEnabled);
    isPerformanceCollectionEnabled();
  }

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      home: new Scaffold(
        appBar: new AppBar(
          title: new Text('Firebase Performance Example'),
        ),
        body: new Center(
          child: new Column(
            children: <Widget>[
              new Text(_collectionEnabledString),
              new MaterialButton(
                  onPressed: togglePerformanceCollection,
                  child: new Text('Toggle Data Collection'),
              )
            ],
          )
        ),
      ),
    );
  }
}
