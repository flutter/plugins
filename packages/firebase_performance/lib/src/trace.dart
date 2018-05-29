// Copyright 2018, the Flutter project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of firebase_performance;

/// Trace allows you to set beginning and end of a certain action in your app.
class Trace extends PerformanceAttributable {
  Trace._(this._handle, this._name) {
    assert(_name != null);
    assert(!_name.startsWith(new RegExp(r'[_\s]')));
    assert(!_name.contains(new RegExp(r'[_\s]$')));
    assert(_name.length <= maxTraceNameLength);
  }

  /// Maximum allowed length of the name of a [Trace].
  static const int maxTraceNameLength = 100;

  final int _handle;
  final String _name;

  bool _hasStarted = false;
  bool _hasStopped = false;

  final HashMap<String, int> _counters = new HashMap<String, int>();

  /// Starts this trace.
  ///
  /// Using ```await``` with this method is only necessary when accurate timing
  /// is relevant.
  Future<void> start() {
    assert(!_hasStarted);

    _hasStarted = true;
    return FirebasePerformance.channel
        .invokeMethod('Trace#start', <String, dynamic>{
      'handle': _handle,
      'name': _name,
    });
  }

  /// Stops this trace.
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
    return FirebasePerformance.channel.invokeMethod('Trace#stop', data);
  }

  /// Increments the counter with the given [name] by [incrementBy].
  ///
  /// The counter is incremented by 1 if [incrementBy] was not passed. If a
  /// counter does not already exist, a new one will be created. If the trace
  /// has not been started or has already been stopped, returns immediately
  /// without taking action.
  ///
  /// The name of the counter requires no leading or
  /// trailing whitespace, no leading underscore _ character, and max length of
  /// 32 characters.
  void incrementCounter(String name, [int incrementBy = 1]) {
    assert(!_hasStopped);
    assert(name != null);
    assert(!name.startsWith(new RegExp(r'[_\s]')));
    assert(!name.contains(new RegExp(r'[_\s]$')));
    assert(name.length <= 32);

    _counters.putIfAbsent(name, () => 0);
    _counters[name] += incrementBy;
  }

  /// Sets a String [value] for the specified [attribute].
  ///
  /// Updates the value of the attribute if the attribute already exists. If the
  /// trace has been stopped, this method returns without adding the attribute.
  /// The maximum number of attributes that can be added to a Trace are
  /// [PerformanceAttributable.maxTraceCustomAttributes].
  ///
  /// Name of the attribute has max length of
  /// [PerformanceAttributable.maxAttributeKeyLength] characters. Value of the
  /// attribute has max length of
  /// [PerformanceAttributable.maxAttributeValueLength] characters.
  @override
  void putAttribute(String attribute, String value) {
    assert(!_hasStopped);
    super.putAttribute(attribute, value);
  }

  /// Removes an already added [attribute].
  ///
  /// If the trace has been stopped, this method throws an assertion
  /// error.
  @override
  void removeAttribute(String attribute) {
    assert(!_hasStopped);
    super.removeAttribute(attribute);
  }
}
