// Copyright 2018, the Flutter project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of firebase_performance;

/// Trace allows you to set the beginning and end of a custom trace in your app.
///
/// A trace is a report of performance data associated with some of the
/// code in your app. You can have multiple custom traces, and it is
/// possible to have more than one custom trace running at a time. Each custom
/// trace can have multiple counters and attributes added to help measure
/// performance related events. A trace also measures the time between calling
/// start() and stop().
///
/// Data collected is automatically sent to the associated Firebase console
/// after stop() is called.
///
/// You can confirm that Performance Monitoring results appear in the Firebase
/// console. Results should appear within 12 hours.
class Trace extends PerformanceAttributes {
  Trace._(this._handle, this._name) {
    assert(_name != null);
    assert(!_name.startsWith(RegExp(r'[_\s]')));
    assert(!_name.contains(RegExp(r'[_\s]$')));
    assert(_name.length <= maxTraceNameLength);
  }

  /// Maximum allowed length of the name of a [Trace].
  static const int maxTraceNameLength = 100;

  final int _handle;
  final String _name;

  bool _hasStarted = false;
  bool _hasStopped = false;

  final HashMap<String, int> _counters = HashMap<String, int>();

  /// Starts this trace.
  ///
  /// Can only be called once, otherwise assertion error is thrown.
  ///
  /// Using ```await``` with this method is only necessary when accurate timing
  /// is relevant.
  Future<void> start() {
    assert(!_hasStarted);

    _hasStarted = true;
    return FirebasePerformance.channel
        // TODO(amirh): remove this on when the invokeMethod update makes it to stable Flutter.
        // https://github.com/flutter/flutter/issues/26431
        // ignore: strong_mode_implicit_dynamic_method
        .invokeMethod('Trace#start', <String, dynamic>{
      'handle': _handle,
      'name': _name,
    });
  }

  /// Stops this trace.
  ///
  /// Can only be called once and only after start(), otherwise assertion error
  /// is thrown. Data collected is automatically sent to the associated Firebase
  /// console after stop() is called.
  ///
  /// Not necessary to use ```await``` with this method.
  Future<void> stop() {
    assert(!_hasStopped);
    assert(_hasStarted);

    final Map<String, dynamic> data = <String, dynamic>{
      'handle': _handle,
      'name': _name,
      'counters': _counters,
      'attributes': _attributes,
    };

    _hasStopped = true;
    // TODO(amirh): remove this on when the invokeMethod update makes it to stable Flutter.
    // https://github.com/flutter/flutter/issues/26431
    // ignore: strong_mode_implicit_dynamic_method
    return FirebasePerformance.channel.invokeMethod('Trace#stop', data);
  }

  /// Increments the counter with the given [name] by [incrementBy].
  ///
  /// The counter is incremented by 1 if [incrementBy] was not passed. If a
  /// counter does not already exist, a new one will be created. If the trace
  /// has not been started or has already been stopped, an assertion error is
  /// thrown.
  ///
  /// The name of the counter requires no leading or
  /// trailing whitespace, no leading underscore _ character, and max length of
  /// 32 characters.
  void incrementCounter(String name, [int incrementBy = 1]) {
    assert(!_hasStopped);
    assert(name != null);
    assert(!name.startsWith(RegExp(r'[_\s]')));
    assert(!name.contains(RegExp(r'[_\s]$')));
    assert(name.length <= 32);

    _counters.putIfAbsent(name, () => 0);
    _counters[name] += incrementBy;
  }

  /// Sets a String [value] for the specified [attribute].
  ///
  /// If the trace has been stopped, this method throws an assertion
  /// error.
  ///
  /// See [PerformanceAttributes.putAttribute].
  @override
  void putAttribute(String attribute, String value) {
    assert(!_hasStopped);
    super.putAttribute(attribute, value);
  }

  /// Removes an already added [attribute].
  ///
  /// If the trace has been stopped, this method throws an assertion
  /// error.
  ///
  /// See [PerformanceAttributes.removeAttribute].
  @override
  void removeAttribute(String attribute) {
    assert(!_hasStopped);
    super.removeAttribute(attribute);
  }
}
