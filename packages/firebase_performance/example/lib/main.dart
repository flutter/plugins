// Copyright 2018, the Flutter project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';

import 'package:http/http.dart';
import 'package:flutter/material.dart';

import 'package:firebase_performance/firebase_performance.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MetricHttpClient extends BaseClient {
  _MetricHttpClient(this._inner);

  final Client _inner;

  @override
  Future<StreamedResponse> send(BaseRequest request) async {
    final HttpMetric metric = FirebasePerformance.instance
        .newHttpMetric(request.url.toString(), HttpMethod.Get);

    await metric.start();

    StreamedResponse response;
    try {
      response = await _inner.send(request);
      metric
        ..responsePayloadSize = response.contentLength
        ..responseContentType = response.headers['Content-Type']
        ..requestPayloadSize = request.contentLength
        ..httpResponseCode = response.statusCode;
    } finally {
      await metric.stop();
    }

    return response;
  }
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
    trace.incrementMetric("metric1", 16);
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

    final _MetricHttpClient metricHttpClient = _MetricHttpClient(Client());

    final Request request = Request(
      "SEND",
      Uri.parse("https://www.google.com"),
    );

    metricHttpClient.send(request);

    setState(() {
      _httpMetricHasRan = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final TextStyle textStyle =
        const TextStyle(color: Colors.lightGreenAccent, fontSize: 25.0);
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Firebase Performance Example'),
        ),
        body: Center(
          child: Column(
            children: <Widget>[
              Text(_performanceCollectionMessage),
              RaisedButton(
                onPressed: _togglePerformanceCollection,
                child: const Text('Toggle Data Collection'),
              ),
              RaisedButton(
                onPressed: _testTrace,
                child: const Text('Run Trace'),
              ),
              Text(
                _traceHasRan ? 'Trace Ran!' : '',
                style: textStyle,
              ),
              RaisedButton(
                onPressed: _testHttpMetric,
                child: const Text('Run HttpMetric'),
              ),
              Text(
                _httpMetricHasRan ? 'HttpMetric Ran!' : '',
                style: textStyle,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
