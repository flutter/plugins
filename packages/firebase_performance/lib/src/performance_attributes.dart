// Copyright 2018, the Flutter project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of firebase_performance;

/// Abstract class that allows adding/removing attributes to an object.
abstract class PerformanceAttributes {
  /// Maximum allowed length of a key passed to [putAttribute].
  static const int maxAttributeKeyLength = 40;

  /// Maximum allowed length of a value passed to [putAttribute].
  static const int maxAttributeValueLength = 100;

  /// Maximum allowed number of attributes that can be added.
  static const int maxCustomAttributes = 5;

  final Map<String, String> _attributes = <String, String>{};

  bool get _hasStarted;
  bool get _hasStopped;

  int get _handle;

  /// Sets a String [value] for the specified attribute with [name].
  ///
  /// Updates the value of the attribute if the attribute already exists.
  /// The maximum number of attributes that can be added are
  /// [maxCustomAttributes]. An attempt to add more than [maxCustomAttributes]
  /// to this object will return without adding the attribute.
  ///
  /// Name of the attribute has max length of [maxAttributeKeyLength]
  /// characters. Value of the attribute has max length of
  /// [maxAttributeValueLength] characters. If the name has a length greater
  /// than [maxAttributeKeyLength] or the value has a length greater than
  /// [maxAttributeValueLength], this method will return without adding
  /// anything.
  ///
  /// If this object has been stopped, this method returns without adding the
  /// attribute.
  Future<void> putAttribute(String name, String value) {
    if (_hasStopped ||
        name.length > maxAttributeKeyLength ||
        value.length > maxAttributeValueLength ||
        _attributes.length == maxCustomAttributes) {
      return Future<void>.value(null);
    }

    _attributes[name] = value;
    return FirebasePerformance.channel.invokeMethod<void>(
      '$PerformanceAttributes#putAttribute',
      <String, dynamic>{
        'handle': _handle,
        'name': name,
        'value': value,
      },
    );
  }

  /// Removes an already added attribute.
  ///
  /// If this object has been stopped, this method returns without removing the
  /// attribute.
  Future<void> removeAttribute(String name) {
    if (_hasStopped) return Future<void>.value(null);

    _attributes.remove(name);
    return FirebasePerformance.channel.invokeMethod<void>(
      '$PerformanceAttributes#removeAttribute',
      <String, dynamic>{'handle': _handle, 'name': name},
    );
  }

  /// Returns the value of an attribute.
  ///
  /// Returns `null` if an attribute with this [name] has not been added.
  String getAttribute(String name) => _attributes[name];

  /// All attributes added.
  Future<Map<String, String>> getAttributes() {
    if (_hasStopped) {
      return Future<Map<String, String>>.value(
        Map<String, String>.unmodifiable(_attributes),
      );
    }

    return FirebasePerformance.channel.invokeMapMethod<String, String>(
      '$PerformanceAttributes#getAttributes',
      <String, dynamic>{'handle': _handle},
    );
  }
}
