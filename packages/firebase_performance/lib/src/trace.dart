// Copyright 2017, the Flutter project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of firebase_performance;

/// Trace allows you to set beginning and end of a certain action in your app.
class Trace {
  final FirebasePerformance _performance;

  /// Id used to sync traces with device platform code.
  final int _id;
  bool _hasStarted = false;
  bool _hasStopped = false;
  final String name;

  /// Map of all the counters added to this trace.
  final HashMap<String, int> counters = new HashMap<String, int>();

  /// Map of all the attributes added to this trace.
  final HashMap<String, String> attributes = new HashMap<String, String>();

  Trace._(this._performance, this._id, this.name);

  bool get hasStarted => _hasStarted;
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
  void incrementCounter(String name, [int incrementBy = 1]) {
    if (hasStopped) {
      _printError('incrementCounter', "it's been stopped!");
      return;
    }

    counters.putIfAbsent(name, () => 0);
    counters[name] += incrementBy;
  }

  /// Sets a String [value] for the specified [attribute].
  void putAttribute(String attribute, String value) {
    if (hasStopped) {
      _printError('putAttribute', "it's been stopped!");
      return;
    }

    attributes.putIfAbsent(attribute, () => value);
    attributes[attribute] = value;
  }

  /// Removes an already added [attribute] from the Trace.
  void removeAttribute(String attribute) {
    if (hasStopped) {
      _printError('removeAttribute', "it's been stopped!");
      return;
    }

    attributes.remove(attribute);
  }

  /// Returns the value of an [attribute].
  String getAttribute(String attribute) => attributes[attribute];

  void _printError(String method, String reason) {
    print(
        "FirbasePerformance: Can't '$method()' for trace '$name' because $reason!");
  }
}
