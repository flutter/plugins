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

  @visibleForTesting
  MethodChannel get methodChannel;
  bool get _hasStarted;
  bool get _hasStopped;

  /// Sets a String [value] for the specified [attribute].
  ///
  /// Updates the value of the attribute if the attribute already exists.
  /// The maximum number of attributes that can be added are
  /// [maxCustomAttributes].
  ///
  /// Name of the attribute has max length of [maxAttributeKeyLength]
  /// characters. Value of the attribute has max length of
  /// [maxAttributeValueLength] characters.
  Future<void> putAttribute(String attribute, String value) {
    if (!_hasStarted ||
        _hasStopped ||
        attribute.length > maxAttributeKeyLength ||
        value.length > maxAttributeValueLength ||
        _attributes.length == 5) {
      return Future<void>.value(null);
    }

    _attributes[attribute] = value;
    return methodChannel.invokeMethod<void>(
      '$PerformanceAttributes#putAttribute',
      <String, String>{'attribute': attribute, 'value': value},
    );
  }

  /// Removes an already added [attribute].
  Future<void> removeAttribute(String attribute) {
    if (!_hasStarted || _hasStopped) return Future<void>.value(null);

    _attributes.remove(attribute);
    return methodChannel.invokeMethod<void>(
      '$PerformanceAttributes#removeAttribute',
      attribute,
    );
  }

  /// All attributes added.
  Future<Map<String, String>> getAttributes() {
    if (_hasStopped) {
      return Future<Map<String, String>>.value(Map<String, String>.unmodifiable(
        _attributes,
      ));
    }

    return methodChannel.invokeMapMethod<String, String>(
      '$PerformanceAttributes#getAttributes',
    );
  }
}
