// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:ui' show hashValues;

import 'package:flutter/foundation.dart';
import 'package:json_annotation/json_annotation.dart';

part 'sk_storefront_wrapper.g.dart';

/// Contains the location and unique identifier of an Apple App Store storefront.
///
/// Dart wrapper around StoreKit's
/// [SKStorefront](https://developer.apple.com/documentation/storekit/skstorefront?language=objc).
@JsonSerializable(createToJson: true)
@immutable
class SKStorefrontWrapper {
  /// Creates a new [SKStorefrontWrapper] with the provided information.
  // TODO(stuartmorgan): Temporarily ignore const warning in other parts of the
  // federated package, and remove this.
  // ignore: prefer_const_constructors_in_immutables
  SKStorefrontWrapper({
    required this.countryCode,
    required this.identifier,
  });

  /// Constructs an instance of the [SKStorefrontWrapper] from a key value map
  /// of data.
  ///
  /// The map needs to have named string keys with values matching the names and
  /// types of all of the members on this class. The `map` parameter must not be
  /// null.
  factory SKStorefrontWrapper.fromJson(Map<String, dynamic> map) {
    return _$SKStorefrontWrapperFromJson(map);
  }

  /// The three-letter code representing the country or region associated with
  /// the App Store storefront.
  final String countryCode;

  /// A value defined by Apple that uniquely identifies an App Store storefront.
  final String identifier;

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) {
      return true;
    }
    if (other.runtimeType != runtimeType) {
      return false;
    }
    return other is SKStorefrontWrapper &&
        other.countryCode == countryCode &&
        other.identifier == identifier;
  }

  @override
  int get hashCode => hashValues(
        countryCode,
        identifier,
      );

  @override
  String toString() => _$SKStorefrontWrapperToJson(this).toString();

  /// Converts the instance to a key value map which can be used to serialize
  /// to JSON format.
  Map<String, dynamic> toMap() => _$SKStorefrontWrapperToJson(this);
}
