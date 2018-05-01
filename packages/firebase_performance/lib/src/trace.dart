// Copyright 2017, the Flutter project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of firebase_performance;

/// Trace allows you to set beginning and end of a certain action in your app.
class Trace {
  Trace._(this._id, this._name) {
    assert(
        _name != null, "Trace name is invalid. (Trace name must not be null)");
    assert(!_name.startsWith(new RegExp(r'[_\s]')),
        "Trace '$_name' is invalid. (Trace name must not start with '_' or space)");
    assert(!_name.contains(new RegExp(r'[_\s]$')),
        "Trace '$_name' is invalid. (Trace name must not end with '_' or space)");
    assert(_name.length <= maxTraceNameLength,
        "Trace '$_name' is invalid. (Trace name must not exceed $maxTraceNameLength characters)");
  }

  /// Maximum allowed length of the Key of the [Trace] attribute.
  static const int maxAttributeKeyLength = 40;

  /// Maximum allowed length of the Value of the [Trace] attribute.
  static const int maxAttributeValueLength = 100;

  /// Maximum allowed number of attributes allowed in a trace.
  static const int maxTraceCustomAttributes = 5;

  /// Maximum allowed length of the name of the [Trace].
  static const int maxTraceNameLength = 100;

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
    assert(!_hasStarted,
        "Trace '$_name' has already started, should not start again!");

    _hasStarted = true;
    return FirebasePerformance.channel
        .invokeMethod('Trace#start', <String, dynamic>{
      'id': _id,
      'name': _name,
    });
  }

  /// Stops this trace.
  Future<void> stop() {
    assert(!_hasStopped,
        "Trace '$_name' has already stopped, should not stop again!");
    assert(
        _hasStarted, "Trace '$_name' has not been started so unable to stop!");

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
    assert(!_hasStopped,
        "Connot increment counter $name. Trace '$_name' has already stopped!");
    assert(name != null,
        "Cannot increment counter. Counter name is invalid. (Counter name must not be null)");
    assert(!name.startsWith(new RegExp(r'[_\s]')),
        "Cannot increment counter $name. Counter name is invalid. (Counter name must not start with '_' or space)");
    assert(!name.contains(new RegExp(r'[_\s]$')),
        "Cannot increment counter $name. Counter name is invalid. (Counter name must not end with '_' or space)");
    assert(name.length <= 32,
        "Cannot increment counter $name. Counter name is invalid. (Counter name must not exceed 32 characters)");

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
    assert(!_hasStopped,
        "Can not set attriubte $attribute. Trace '$_name' has already stopped!");
    assert(attribute != null,
        "Can not set attriubte. Attribute name is invalid. (Attribute name must not be null)");
    assert(!attribute.startsWith(new RegExp(r'[_\s]')),
        "Can not set attriubte $attribute. Attribute name is invalid. (Attribute name must not start with '_' or space)");
    assert(!attribute.contains(new RegExp(r'[_\s]$')),
        "Can not set attriubte $attribute. Attribute name is invalid. (Attribute name must not end with '_' or space)");
    assert(attribute.length <= maxAttributeKeyLength,
        "Can not set attriubte $attribute. Attribute name is invalid. (Attribute name must not exceed $maxAttributeKeyLength characters)");
    assert(value.length <= maxAttributeValueLength,
        "Can not set attriubte $attribute with value $value. Value is invalid. (Value must not exceed $maxAttributeValueLength characters)");
    assert(_attributes.length < maxTraceCustomAttributes,
        "Can not set attriubte $attribute with value $value. (Exceeds max limit of number of attributes - $maxTraceCustomAttributes");

    _attributes.putIfAbsent(attribute, () => value);
    _attributes[attribute] = value;
  }

  /// Removes an already added [attribute] from the [Trace].
  ///
  /// Removes an already added attribute from the Traces. If the trace has been
  /// stopped, this method returns without removing the attribute.
  void removeAttribute(String attribute) {
    assert(!_hasStopped,
        "Can not remove attriubte $attribute. Trace '$_name' has already stopped!");

    _attributes.remove(attribute);
  }

  /// Returns the value of an [attribute].
  String getAttribute(String attribute) => _attributes[attribute];
}
