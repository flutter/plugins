// Copyright 2017, the Flutter project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of firebase_performance;

/// Trace allows you to set beginning and end of a certain action in your app.
class Trace {
  /// Maximum allowed length of the Key of the [Trace] attribute.
  static const int maxAttributeKeyLength = 40;

  /// Maximum allowed length of the Value of the [Trace] attribute.
  static const int maxAttributeValueLength = 100;

  /// Maximum allowed number of attributes allowed in a trace.
  static const int maxTraceCustomAttributes = 5;

  /// Maximum allowed length of the name of the [Trace].
  static const int maxTraceNameLength = 100;

  /// Maximum allowed length of the Key of the [Trace] counter.
  static const int maxCounterKeyLength = 32;

  final FirebasePerformance _performance;

  /// Id used to sync traces with device platform code.
  final int _id;
  bool _hasStarted = false;
  bool _hasStopped = false;

  /// Name of this [Trace].
  final String name;

  /// Map of all the counters added to this trace.
  final HashMap<String, int> counters = new HashMap<String, int>();

  /// Map of all the attributes added to this trace.
  final HashMap<String, String> attributes = new HashMap<String, String>();

  Trace._(this._performance, this._id, this.name);

  /// If start() has been called on this [Trace].
  bool get hasStarted => _hasStarted;

  /// If stop() has been called after start() for this [Trace].
  bool get hasStopped => _hasStopped;

  /// Starts this trace.
  Future<Null> start() async {
    if (_hasStarted) {
      _printError('start', "it has already been started!");
      return;
    }

    await _performance._traceStart(this);
    _hasStarted = true;
  }

  /// Stops this trace.
  Future<Null> stop() async {
    if (_hasStarted && !hasStopped) {
      await _performance._traceStop(this);
      _hasStopped = true;
    } else if (_hasStopped) {
      _printError('stop', "it's been stopped!");
    } else {
      _printError('stop', "it has not been started!");
    }
  }

  /// Increments the counter in this trace with the given [name] by given value.
  ///
  /// Increments the counter in this trace with the given name by given value.
  /// If a counter does not already exist, a new one will be created. If the
  /// trace has not been started or has already been stopped, returns
  /// immediately without taking action.
  ///
  /// [name]: Name of the counter to be incremented. Requires no leading or
  /// trailing whitespace, no leading underscore [_] character, max length of
  /// [maxCounterKeyLength] characters.
  ///
  /// [incrementBy]: Amount by which the counter has to be incremented.
  void incrementCounter(String name, [int incrementBy = 1]) {
    if (hasStopped) {
      _printError('incrementCounter', "it's been stopped!");
      return;
    }

    counters.putIfAbsent(name, () => 0);
    counters[name] += incrementBy;
  }

  /// Sets a String [value] for the specified [attribute].
  ///
  /// Sets a String value for the specified attribute. Updates the value of the
  /// attribute if the attribute already exists. If the trace has been stopped,
  /// this method returns without adding the attribute. The maximum number of
  /// attributes that can be added to a Trace are [maxTraceCustomAttributes].
  ///
  /// [attribute]: Name of the attribute. Max length of [maxAttributeKeyLength]
  /// characters.
  ///
  /// [value]: Value of the attribute. Max length of [maxAttributeValueLength]
  /// characters.
  void putAttribute(String attribute, String value) {
    if (hasStopped) {
      _printError('putAttribute', "it's been stopped!");
      return;
    }

    attributes.putIfAbsent(attribute, () => value);
    attributes[attribute] = value;
  }

  /// Removes an already added [attribute] from the Trace.
  ///
  /// Removes an already added attribute from the Traces. If the trace has been
  /// stopped, this method returns without removing the attribute.
  ///
  /// [attribute]: Name of the attribute to be removed from the running Traces.
  void removeAttribute(String attribute) {
    if (hasStopped) {
      _printError('removeAttribute', "it's been stopped!");
      return;
    }

    attributes.remove(attribute);
  }

  /// Returns the value of an [attribute].
  ///
  /// [attribute]: Name of the attribute to fetch the value for.
  String getAttribute(String attribute) => attributes[attribute];

  void _printError(String method, String reason) {
    print(
        "FirbasePerformance: Can't '$method()' for trace '$name' because $reason!");
  }
}
