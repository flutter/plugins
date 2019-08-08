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
/// `start()` and `stop()`.
///
/// Data collected is automatically sent to the associated Firebase console
/// after stop() is called.
///
/// You can confirm that Performance Monitoring results appear in the Firebase
/// console. Results should appear within 12 hours.
///
/// It is highly recommended that one always calls `start()` and `stop()` on
/// each created [Trace] to not avoid leaking on the platform side.
class Trace extends PerformanceAttributes {
  Trace._(this._handle, this.name);

  /// Maximum allowed length of the name of a [Trace].
  static const int maxTraceNameLength = 100;

  final Map<String, int> _metrics = <String, int>{};

  @override
  bool _hasStarted = false;

  @override
  bool _hasStopped = false;

  @override
  final int _handle;

  /// Name representing this [Trace] on the Firebase Console.
  final String name;

  /// Starts this [Trace].
  ///
  /// Can only be called once.
  ///
  /// Using `await` with this method is only necessary when accurate timing
  /// is relevant.
  Future<void> start() {
    if (_hasStopped) return Future<void>.value(null);

    _hasStarted = true;
    return FirebasePerformance.channel.invokeMethod<void>(
      'Trace#start',
      <String, dynamic>{'handle': _handle},
    );
  }

  /// Stops this [Trace].
  ///
  /// Can only be called once and only after start() Data collected is
  /// automatically sent to the associated Firebase console after stop() is
  /// called. You can confirm that Performance Monitoring results appear in the
  /// Firebase console. Results should appear within 12 hours.
  ///
  /// Not necessary to use `await` with this method.
  Future<void> stop() {
    if (_hasStopped) return Future<void>.value(null);

    _hasStopped = true;
    return FirebasePerformance.channel.invokeMethod<void>(
      'Trace#stop',
      <String, dynamic>{'handle': _handle},
    );
  }

  /// Increments the metric with the given [name].
  ///
  /// If the metric does not exist, a new one will be created. If the [Trace] has
  /// not been started or has already been stopped, returns immediately without
  /// taking action.
  Future<void> incrementMetric(String name, int value) {
    if (!_hasStarted || _hasStopped) {
      return Future<void>.value(null);
    }

    _metrics.putIfAbsent(name, () => 0);
    _metrics[name] += value;
    return FirebasePerformance.channel.invokeMethod<void>(
      'Trace#incrementMetric',
      <String, dynamic>{'handle': _handle, 'name': name, 'value': value},
    );
  }

  /// Sets the [value] of the metric with the given [name].
  ///
  /// If a metric with the given name doesn't exist, a new one will be created.
  /// If the [Trace] has not been started or has already been stopped, returns
  /// immediately without taking action.
  Future<void> setMetric(String name, int value) {
    if (!_hasStarted || _hasStopped) return Future<void>.value(null);

    _metrics[name] = value;
    return FirebasePerformance.channel.invokeMethod<void>(
      'Trace#setMetric',
      <String, dynamic>{'handle': _handle, 'name': name, 'value': value},
    );
  }

  /// Gets the value of the metric with the given [name].
  ///
  /// If a metric with the given name doesn't exist, it is NOT created and a 0
  /// is returned.
  Future<int> getMetric(String name) {
    if (_hasStopped) return Future<int>.value(_metrics[name] ?? 0);

    return FirebasePerformance.channel.invokeMethod<int>(
      'Trace#getMetric',
      <String, dynamic>{'handle': _handle, 'name': name},
    );
  }
}
