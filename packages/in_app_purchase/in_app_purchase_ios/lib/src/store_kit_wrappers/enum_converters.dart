// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:in_app_purchase_platform_interface/in_app_purchase_platform_interface.dart';
import 'package:json_annotation/json_annotation.dart';

import '../../store_kit_wrappers.dart';

part 'enum_converters.g.dart';

/// Serializer for [SKPaymentTransactionStateWrapper].
///
/// Use these in `@JsonSerializable()` classes by annotating them with
/// `@SKTransactionStatusConverter()`.
class SKTransactionStatusConverter
    implements JsonConverter<SKPaymentTransactionStateWrapper, int?> {
  /// Default const constructor.
  const SKTransactionStatusConverter();

  @override
  SKPaymentTransactionStateWrapper fromJson(int? json) {
    if (json == null) {
      return SKPaymentTransactionStateWrapper.unspecified;
    }
    return _$enumDecode<SKPaymentTransactionStateWrapper, dynamic>(
        _$SKPaymentTransactionStateWrapperEnumMap
            .cast<SKPaymentTransactionStateWrapper, dynamic>(),
        json);
  }

  /// Converts an [SKPaymentTransactionStateWrapper] to a [PurchaseStatus].
  PurchaseStatus toPurchaseStatus(SKPaymentTransactionStateWrapper object) {
    switch (object) {
      case SKPaymentTransactionStateWrapper.purchasing:
      case SKPaymentTransactionStateWrapper.deferred:
        return PurchaseStatus.pending;
      case SKPaymentTransactionStateWrapper.purchased:
        return PurchaseStatus.purchased;
      case SKPaymentTransactionStateWrapper.restored:
        return PurchaseStatus.restored;
      case SKPaymentTransactionStateWrapper.failed:
      case SKPaymentTransactionStateWrapper.unspecified:
        return PurchaseStatus.error;
    }
  }

  @override
  int toJson(SKPaymentTransactionStateWrapper object) =>
      _$SKPaymentTransactionStateWrapperEnumMap[object]!;
}

/// Serializer for [SKSubscriptionPeriodUnit].
///
/// Use these in `@JsonSerializable()` classes by annotating them with
/// `@SKSubscriptionPeriodUnitConverter()`.
class SKSubscriptionPeriodUnitConverter
    implements JsonConverter<SKSubscriptionPeriodUnit, int?> {
  /// Default const constructor.
  const SKSubscriptionPeriodUnitConverter();

  @override
  SKSubscriptionPeriodUnit fromJson(int? json) {
    if (json == null) {
      return SKSubscriptionPeriodUnit.day;
    }
    return _$enumDecode<SKSubscriptionPeriodUnit, dynamic>(
        _$SKSubscriptionPeriodUnitEnumMap
            .cast<SKSubscriptionPeriodUnit, dynamic>(),
        json);
  }

  @override
  int toJson(SKSubscriptionPeriodUnit object) =>
      _$SKSubscriptionPeriodUnitEnumMap[object]!;
}

/// Serializer for [SKProductDiscountPaymentMode].
///
/// Use these in `@JsonSerializable()` classes by annotating them with
/// `@SKProductDiscountPaymentModeConverter()`.
class SKProductDiscountPaymentModeConverter
    implements JsonConverter<SKProductDiscountPaymentMode, int?> {
  /// Default const constructor.
  const SKProductDiscountPaymentModeConverter();

  @override
  SKProductDiscountPaymentMode fromJson(int? json) {
    if (json == null) {
      return SKProductDiscountPaymentMode.payAsYouGo;
    }
    return _$enumDecode<SKProductDiscountPaymentMode, dynamic>(
        _$SKProductDiscountPaymentModeEnumMap
            .cast<SKProductDiscountPaymentMode, dynamic>(),
        json);
  }

  @override
  int toJson(SKProductDiscountPaymentMode object) =>
      _$SKProductDiscountPaymentModeEnumMap[object]!;
}

// Define a class so we generate serializer helper methods for the enums
// See https://github.com/google/json_serializable.dart/issues/778
@JsonSerializable()
class _SerializedEnums {
  late SKPaymentTransactionStateWrapper response;
  late SKSubscriptionPeriodUnit unit;
  late SKProductDiscountPaymentMode discountPaymentMode;
}
