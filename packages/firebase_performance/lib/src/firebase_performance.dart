// Copyright 2017, the Flutter project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of firebase_performance;

/// The Firebase Performance API.
class FirebasePerformance {
  final MethodChannel _channel;

  /// Singleton of [FirebasePerformance].
  static final FirebasePerformance instance = new FirebasePerformance.private(
      const MethodChannel('plugins.flutter.io/firebase_performance'));

  /// We don't want people to extend this class, but implementing its interface,
  /// e.g. in tests, is OK.
  @visibleForTesting
  FirebasePerformance.private(MethodChannel platformChannel)
      : _channel = platformChannel;

  /// Determines whether performance monitoring is enabled or disabled.
  Future<bool> isPerformanceCollectionEnabled() async {
    final bool isEnabled = await _channel
        .invokeMethod('FirebasePerformance#isPerformanceCollectionEnabled');
    return isEnabled;
  }

  /// Enables or disables performance monitoring.
  Future<Null> setPerformanceCollectionEnabled(bool enabled) async {
    await _channel.invokeMethod(
        'FirebasePerformance#setPerformanceCollectionEnabled', enabled);
  }

  Future<Null> _traceStart(Trace trace) async {
    await _channel.invokeMethod('Trace#start', trace._id);
  }

  Future<Null> _traceStop(Trace trace) async {
    final Map<String, dynamic> data = <String, dynamic>{
      'id': trace._id,
      'name': trace.name,
      'counters': trace.counters,
      'attributes': trace.attributes,
    };

    await _channel.invokeMethod('Trace#stop', data);
  }

  /// Creates a [Trace] object with given [name].
  Future<Trace> newTrace(String name) async {
    final int id = await _channel.invokeMethod('FirebasePerformance#newTrace', name);
    return new Trace._(this, id, name);
  }

  /// Creates a [Trace] object with given [name] and start the trace.
  Future<Trace> startTrace(String name) async {
    final Trace trace = await newTrace(name);
    await trace.start();
    return trace;
  }
}
