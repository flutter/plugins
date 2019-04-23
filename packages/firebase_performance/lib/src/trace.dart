// Copyright 2018, the Flutter project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of firebase_performance;

/// [Trace] allows you to set the beginning and end of a custom trace in your app.
///
/// A trace is a report of performance data associated with some of the
/// code in your app. You can have multiple custom traces, and it is
/// possible to have more than one custom trace running at a time. Each custom
/// trace can have multiple metrics and attributes added to help measure
/// performance related events. A trace also measures the time between calling
/// start() and stop().
///
/// Data collected is automatically sent to the associated Firebase console
/// after stop() is called.
///
/// You can confirm that Performance Monitoring results appear in the Firebase
/// console. Results should appear within 12 hours.
class Trace extends PerformanceAttributes {
  Trace._(this._channel);

  /// Maximum allowed length of the name of a [Trace].
  static const int maxTraceNameLength = 100;

  final MethodChannel _channel;

  @override
  MethodChannel get _methodChannel => _channel;

  /// Starts this [Trace] asynchronously.
  ///
  /// Can only be called once.
  ///
  /// Using ```await``` with this method is only necessary when accurate timing
  /// is relevant.
  Future<void> start() {
    return _channel.invokeMethod<void>('$Trace#start');
  }

  /// Stops this [Trace] asynchronously.
  ///
  /// Can only be called once and only after start() Data collected is
  /// automatically sent to the associated Firebase console after stop() is
  /// called. You can confirm that Performance Monitoring results appear in the
  /// Firebase console. Results should appear within 12 hours.
  ///
  /// Not necessary to use ```await``` with this method.
  Future<void> stop() {
    return _channel.invokeMethod<void>('$Trace#stop');
  }

  /// Increments the metric with the given name asynchronously.
  ///
  /// If the metric does not exist, a new one will be created. If the trace has
  /// not been started or has already been stopped, returns immediately without
  /// taking action.
  Future<void> incrementMetric(String name, int value) {
    return _channel.invokeMethod<void>(
      '$Trace#incrementMetric',
      <String, dynamic>{'name': name, 'value': value},
    );
  }

  /// Sets the value of the metric with the given name asynchronously.
  ///
  /// If a metric with the given name doesn't exist, a new one will be created.
  /// If the trace has not been started or has already been stopped, returns
  /// immediately without taking action.
  Future<void> putMetric(String name, int value) {
    return _channel.invokeMethod<void>(
      '$Trace#putMetric',
      <String, dynamic>{'name': name, 'value': value},
    );
  }

  /// Gets the value of the metric with the given name.
  ///
  /// If a metric with the given name doesn't exist, it is NOT created and a 0
  /// is returned.
  Future<int> getMetric(String name) {
    return _channel.invokeMethod<int>(
      '$Trace#getMetric',
      <String, dynamic>{'name': name},
    );
  }
}
