// Copyright 2017, the Flutter project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';

import 'package:http/http.dart';
import 'package:flutter/material.dart';

import 'package:firebase_performance/firebase_performance.dart';

void main() => runApp(new MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => new _MyAppState();
}

class _MyAppState extends State<MyApp> {
  FirebasePerformance _performance = FirebasePerformance.instance;
  bool _isPerformanceCollectionEnabled = false;
  String _performanceCollectionMessage =
      'Unknown status of performance collection.';
  bool _traceHasRan = false;
  bool _httpMetricHasRan = false;

  @override
  void initState() {
    super.initState();
    _togglePerformanceCollection();
  }

  Future<void> _togglePerformanceCollection() async {
    await _performance
        .setPerformanceCollectionEnabled(!_isPerformanceCollectionEnabled);

    final bool isEnabled = await _performance.isPerformanceCollectionEnabled();
    setState(() {
      _isPerformanceCollectionEnabled = isEnabled;
      _performanceCollectionMessage = _isPerformanceCollectionEnabled
          ? 'Performance collection is enabled.'
          : 'Performance collection is disabled.';
    });
  }

  Future<void> _testTrace() async {
    setState(() {
      _traceHasRan = false;
    });

    final Trace trace = _performance.newTrace("test");
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
      _traceHasRan = true;
    });
  }

  Future<void> _testHttpMetric() async {
    setState(() {
      _httpMetricHasRan = false;
    });

    final HttpMetric metric = _performance.newHttpMetric(
        'https://jsonplaceholder.typicode.com/posts/1', HttpMethod.Get);

    await metric.start();

    final Response response =
        await get('https://jsonplaceholder.typicode.com/posts/1');
    metric.responsePayloadSize = response.contentLength;
    metric.responseContentType = 'application/json';
    metric.httpResponseCode = response.statusCode;

    await metric.stop();

    setState(() {
      _httpMetricHasRan = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final TextStyle textStyle =
        const TextStyle(color: Colors.lightGreenAccent, fontSize: 25.0);
    return new MaterialApp(
      home: new Scaffold(
        appBar: new AppBar(
          title: const Text('Firebase Performance Example'),
        ),
        body: new Center(
            child: new Column(
          children: <Widget>[
            new Text(_performanceCollectionMessage),
            new RaisedButton(
              onPressed: _togglePerformanceCollection,
              child: const Text('Toggle Data Collection'),
            ),
            new RaisedButton(
              onPressed: _testTrace,
              child: const Text('Run Trace'),
            ),
            new Text(
              _traceHasRan ? 'Trace Ran!' : '',
              style: textStyle,
            ),
            new RaisedButton(
              onPressed: _testHttpMetric,
              child: const Text('Run HttpMetric'),
            ),
            new Text(
              _httpMetricHasRan ? 'HttpMetric Ran!' : '',
              style: textStyle,
            ),
          ],
        )),
      ),
    );
  }
}
