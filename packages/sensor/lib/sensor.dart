import 'dart:async';

import 'package:flutter/services.dart';

const EventChannel _accelerometerEventChannel =
    const EventChannel('plugins.flutter.io/accelerometer');

const EventChannel _gyroscopeEventChannel =
    const EventChannel('plugins.flutter.io/gyroscope');

Stream<List<double>> _accelerometerEvents;
Stream<List<double>> _gyroscopeEvents;

List<double> numToDouble(List<num> l) {
  return l.map((num v) => v.toDouble());
}

/// A broadcast stream of events from the device accelerometer.
Stream<List<double>> get accelerometerEvents {
  if (_accelerometerEvents == null) {
    _accelerometerEvents = _accelerometerEventChannel
        .receiveBroadcastStream()
        .map((List<num> l) => l.map((num v) => v.toDouble()).toList());
  }
  return _accelerometerEvents;
}

/// A broadcast stream of events from the device gyroscope.
Stream<List<double>> get gyroscopeEvents {
  if (_gyroscopeEvents == null) {
    _gyroscopeEvents = _gyroscopeEventChannel
        .receiveBroadcastStream()
        .map((List<num> l) => l.map((num v) => v.toDouble()).toList());
  }
  return _gyroscopeEvents;
}
