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

  @visibleForTesting
  MethodChannel get methodChannel;

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
    return methodChannel.invokeMethod<void>(
      '$PerformanceAttributes#putAttribute',
      <String, String>{'attribute': attribute, 'value': value},
    );
  }

  /// Removes an already added [attribute].
  Future<void> removeAttribute(String attribute) {
    return methodChannel.invokeMethod<void>(
      '$PerformanceAttributes#removeAttribute',
      attribute,
    );
  }

  /// All [attribute]s added.
  Future<Map<String, String>> getAttributes() {
    return methodChannel.invokeMapMethod<String, String>(
      '$PerformanceAttributes#getAttributes',
    );
  }
}
