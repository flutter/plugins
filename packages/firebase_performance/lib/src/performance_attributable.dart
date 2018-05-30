// Copyright 2018, the Flutter project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of firebase_performance;

/// Defines the interface that allows adding/removing attributes to any object.
abstract class PerformanceAttributable {
  /// Maximum allowed length of a key passed to [putAttribute].
  static const int maxAttributeKeyLength = 40;

  /// Maximum allowed length of a value passed to [putAttribute].
  static const int maxAttributeValueLength = 100;

  /// Maximum allowed number of attributes that can be added.
  static const int maxTraceCustomAttributes = 5;

  final HashMap<String, String> _attributes = new HashMap<String, String>();

  /// All the attributes added to this trace.
  Map<String, String> get attributes =>
      Map<String, String>.unmodifiable(_attributes);

  /// Sets a String [value] for the specified [attribute].
  ///
  /// Updates the value of the attribute if the attribute already exists. If the
  /// trace has been stopped, this method returns without adding the attribute.
  /// The maximum number of attributes that can be added to a Trace are
  /// [maxTraceCustomAttributes].
  ///
  /// Name of the attribute has max length of [maxAttributeKeyLength]
  /// characters. Value of the attribute has max length of
  /// [maxAttributeValueLength] characters.
  void putAttribute(String attribute, String value) {
    assert(attribute != null);
    assert(!attribute.startsWith(new RegExp(r'[_\s]')));
    assert(!attribute.contains(new RegExp(r'[_\s]$')));
    assert(attribute.length <= maxAttributeKeyLength);
    assert(value.length <= maxAttributeValueLength);
    assert(_attributes.length < maxTraceCustomAttributes);

    _attributes.putIfAbsent(attribute, () => value);
    _attributes[attribute] = value;
  }

  /// Removes an already added [attribute].
  ///
  /// If the trace has been stopped, this method throws an assertion
  /// error.
  void removeAttribute(String attribute) {
    _attributes.remove(attribute);
  }

  /// Returns the value of an [attribute].
  String getAttribute(String attribute) => _attributes[attribute];
}
