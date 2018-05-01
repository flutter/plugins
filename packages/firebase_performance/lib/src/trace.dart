// Copyright 2017, the Flutter project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of firebase_performance;

/// Trace allows you to set beginning and end of a certain action in your app.
class Trace {
  Trace._(this._id, this._name) {
    assert(_name != null, "Name is null.");
    assert(!_name.startsWith(new RegExp(r'[_\s]')),
        "Name '$_name' starts with an underscore or space.");
    assert(!_name.contains(new RegExp(r'[_\s]$')),
        "Name '$_name' ends with an underscore or space.");
    assert(_name.length <= maxTraceNameLength,
        "Name '$_name' has length greater than $maxTraceNameLength.");
  }

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

  final int _id;
  final String _name;

  bool _hasStarted = false;
  bool _hasStopped = false;

  final HashMap<String, int> _counters = new HashMap<String, int>();
  final HashMap<String, String> _attributes = new HashMap<String, String>();

  /// Map of all the attributes added to this trace.
  Map<String, String> get attributes => Map<String, String>.from(_attributes);

  /// Starts this trace.
  Future<void> start() {
    assert(!_hasStarted, "Trace has already been started.");

    _hasStarted = true;
    return FirebasePerformance.channel
        .invokeMethod('Trace#start', <String, dynamic>{
      'id': _id,
      'name': _name,
    });
  }

  /// Stops this trace.
  Future<void> stop() {
    assert(!_hasStopped, "Trace has already been stopped.");
    assert(_hasStarted, "Trace has not been started.");

    final Map<String, dynamic> data = <String, dynamic>{
      'id': _id,
      'name': _name,
      'counters': _counters,
      'attributes': _attributes,
    };

    _hasStopped = true;
    return FirebasePerformance.channel.invokeMethod('Trace#stop', data);
  }

  /// Increments the counter in this trace with the given [name] by given value.
  ///
  /// Increments the counter in this trace with the given name by given value.
  /// If a counter does not already exist, a new one will be created. If the
  /// trace has not been started or has already been stopped, returns
  /// immediately without taking action.
  ///
  /// [name]: Name of the counter to be incremented. Requires no leading or
  /// trailing whitespace, no leading underscore _ character, max length of
  /// [maxCounterKeyLength] characters.
  ///
  /// [incrementBy]: Amount by which the counter has to be incremented.
  void incrementCounter(String name, [int incrementBy = 1]) {
    assert(!_hasStopped, "Trace has already been stopped.");
    assert(name != null, "Counter name is null.");
    assert(!name.startsWith(new RegExp(r'[_\s]')),
    "Counter name '$name' starts with an underscore or space.");
    assert(!name.contains(new RegExp(r'[_\s]$')),
    "Counter name '$name' ends with an underscore or space.");
    assert(name.length <= maxCounterKeyLength,
    "Counter name '$name' has length greater than $maxCounterKeyLength.");

    _counters.putIfAbsent(name, () => 0);
    _counters[name] += incrementBy;
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
    assert(!_hasStopped, "Trace has already been stopped.");
    assert(!_hasStopped, "Trace has already been stopped.");
    assert(attribute != null, "Counter name is null.");
    assert(!attribute.startsWith(new RegExp(r'[_\s]')),
    "Attribute key '$attribute' starts with an underscore or space.");
    assert(!attribute.contains(new RegExp(r'[_\s]$')),
    "Atribute key '$attribute' ends with an underscore or space.");
    assert(attribute.length <= maxAttributeKeyLength,
    "Attribute key '$attribute' has length greater than $maxAttributeKeyLength.");
    assert(value.length <= maxAttributeValueLength,
    "Value '$value' has length greater than $maxAttributeValueLength.");
    assert(_attributes.length <= maxTraceCustomAttributes,
    "Maximum number of attributes ($maxTraceCustomAttributes) have already been added.");

    _attributes.putIfAbsent(attribute, () => value);
    _attributes[attribute] = value;
  }

  /// Removes an already added [attribute] from the [Trace].
  ///
  /// Removes an already added attribute from the Traces. If the trace has been
  /// stopped, this method returns without removing the attribute.
  void removeAttribute(String attribute) {
    assert(!_hasStopped, "Trace has already been stopped.");

    _attributes.remove(attribute);
  }

  /// Returns the value of an [attribute].
  String getAttribute(String attribute) => _attributes[attribute];
}
