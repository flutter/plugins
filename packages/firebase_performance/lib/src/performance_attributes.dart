// Copyright 2018, the Flutter project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of firebase_performance;

/// Abstract class that allows adding/removing attributes to any object.
///
/// Enforces constraints for adding attributes and values required by
/// FirebasePerformance API. See [putAttribute].
abstract class PerformanceAttributes {
  /// Maximum allowed length of a key passed to [putAttribute].
  static const int maxAttributeKeyLength = 40;

  /// Maximum allowed length of a value passed to [putAttribute].
  static const int maxAttributeValueLength = 100;

  /// Maximum allowed number of attributes that can be added.
  static const int maxCustomAttributes = 5;

  final Map<String, String> _attributes = <String, String>{};

  /// Copy of all the attributes added.
  Map<String, String> get attributes => Map<String, String>.from(_attributes);

  /// Sets a String [value] for the specified [attribute].
  ///
  /// Updates the value of the attribute if the attribute already exists.
  /// The maximum number of attributes that can be added are
  /// [maxCustomAttributes].
  ///
  /// Name of the attribute has max length of [maxAttributeKeyLength]
  /// characters. Value of the attribute has max length of
  /// [maxAttributeValueLength] characters.
  void putAttribute(String attribute, String value) {
    assert(attribute != null);
    assert(!attribute.startsWith(RegExp(r'[_\s]')));
    assert(!attribute.contains(RegExp(r'[_\s]$')));
    assert(attribute.length <= maxAttributeKeyLength);
    assert(value.length <= maxAttributeValueLength);
    assert(_attributes.length < maxCustomAttributes);

    _attributes[attribute] = value;
  }

  /// Removes an already added [attribute].
  void removeAttribute(String attribute) {
    _attributes.remove(attribute);
  }

  /// Returns the value of an [attribute].
  String getAttribute(String attribute) => _attributes[attribute];
}
