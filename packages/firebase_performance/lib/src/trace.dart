// Copyright 2017, the Flutter project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of firebase_performance;

class Trace {
  final FirebasePerformance _performance;
  /// Id used to sync traces with device platform code.
  final int _id;
  final String name;

  /// Map of all the counters added to this trace.
  final HashMap<String, int> counters = new HashMap<String, int>();
  /// Map of all the attributes added to this trace.
  final HashMap<String, String> attributes = new HashMap<String, String>();

  Trace._(this._performance, this._id, this.name);

  /// Starts this trace.
  Future<void> start() async {
    await _performance._traceStart(this);
  }

  /// Stops this trace.
  Future<void> stop() async {
    await _performance._traceStop(this);
  }

  /// Increments the counter in this trace with the given name by given value.
  void incrementCounter(String name, [int incrementBy = 1]) {
    counters.putIfAbsent(name, () => 0);
    counters[name] += incrementBy;
  }

  /// Sets a String value for the specified attribute.
  void putAttribute(String attribute, String value) {
    attributes.putIfAbsent(attribute, () => value);
    attributes[attribute] = value;
  }

  /// Removes an already added attribute from the Traces.
  void removeAttribute(String attribute) {
    attributes.remove(attribute);
  }

  /// Returns the value of an attribute.
  String getAttribute(String attribute) => attributes[attribute];
}