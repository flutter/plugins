// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:sensor/sensor.dart';

import 'snake.dart';

void main() {
  runApp(new MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Sensor Demo',
      theme: new ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: new MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  final String title;

  MyHomePage({Key key, this.title}) : super(key: key);

  @override
  _MyHomePageState createState() => new _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<double> _accelerometerValues;
  List<double> _gyroscopeValues;
  List<StreamSubscription<List<double>>> _streamSubscriptions =
      <StreamSubscription<List<double>>>[];

  @override
  Widget build(BuildContext context) {
    List<String> accelerometer =
        _accelerometerValues?.map((double v) => v.toStringAsFixed(1))?.toList();
    List<String> gyroscope =
        _gyroscopeValues?.map((double v) => v.toStringAsFixed(1))?.toList();

    return new Scaffold(
      appBar: new AppBar(
        title: const Text('Sensor Example'),
      ),
      body: new Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          new Center(
            child: new DecoratedBox(
              decoration: new BoxDecoration(
                border: new Border.all(width: 1.0, color: Colors.black38),
              ),
              child: new SizedBox(
                height: 200.0,
                width: 200.0,
                child: new Snake(),
              ),
            ),
          ),
          new Padding(
            child: new Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                new Text('Accelerometer: $accelerometer'),
              ],
            ),
            padding: new EdgeInsets.all(16.0),
          ),
          new Padding(
            child: new Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                new Text('Gyroscope: $gyroscope'),
              ],
            ),
            padding: new EdgeInsets.all(16.0),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    for (StreamSubscription<List<double>> subscription
        in _streamSubscriptions) {
      subscription.cancel();
    }
  }

  @override
  void initState() {
    super.initState();
    _streamSubscriptions.add(accelerometerEvents.listen((List<double> values) {
      setState(() {
        _accelerometerValues = values;
      });
    }));
    _streamSubscriptions.add(gyroscopeEvents.listen((List<double> values) {
      setState(() {
        _gyroscopeValues = values;
      });
    }));
  }
}
