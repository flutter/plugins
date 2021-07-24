// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:in_app_purchase_platform_interface/in_app_purchase_platform_interface.dart';
import 'package:json_annotation/json_annotation.dart';

import '../../billing_client_wrappers.dart';

part 'enum_converters.g.dart';

/// Serializer for [BillingResponse].
///
/// Use these in `@JsonSerializable()` classes by annotating them with
/// `@BillingResponseConverter()`.
class BillingResponseConverter implements JsonConverter<BillingResponse, int?> {
  /// Default const constructor.
  const BillingResponseConverter();

  @override
  BillingResponse fromJson(int? json) {
    if (json == null) {
      return BillingResponse.error;
    }
    return _$enumDecode<BillingResponse, dynamic>(
        _$BillingResponseEnumMap.cast<BillingResponse, dynamic>(), json);
  }

  @override
  int toJson(BillingResponse object) => _$BillingResponseEnumMap[object]!;
}

/// Serializer for [SkuType].
///
/// Use these in `@JsonSerializable()` classes by annotating them with
/// `@SkuTypeConverter()`.
class SkuTypeConverter implements JsonConverter<SkuType, String?> {
  /// Default const constructor.
  const SkuTypeConverter();

  @override
  SkuType fromJson(String? json) {
    if (json == null) {
      return SkuType.inapp;
    }
    return _$enumDecode<SkuType, dynamic>(
        _$SkuTypeEnumMap.cast<SkuType, dynamic>(), json);
  }

  @override
  String toJson(SkuType object) => _$SkuTypeEnumMap[object]!;
}

/// Serializer for [ProrationMode].
///
/// Use these in `@JsonSerializable()` classes by annotating them with
/// `@ProrationModeConverter()`.
class ProrationModeConverter implements JsonConverter<ProrationMode, int?> {
  /// Default const constructor.
  const ProrationModeConverter();

  @override
  ProrationMode fromJson(int? json) {
    if (json == null) {
      return ProrationMode.unknownSubscriptionUpgradeDowngradePolicy;
    }
    return _$enumDecode<ProrationMode, dynamic>(
        _$ProrationModeEnumMap.cast<ProrationMode, dynamic>(), json);
  }

  @override
  int toJson(ProrationMode object) => _$ProrationModeEnumMap[object]!;
}

/// Serializer for [PurchaseStateWrapper].
///
/// Use these in `@JsonSerializable()` classes by annotating them with
/// `@PurchaseStateConverter()`.
class PurchaseStateConverter
    implements JsonConverter<PurchaseStateWrapper, int?> {
  /// Default const constructor.
  const PurchaseStateConverter();

  @override
  PurchaseStateWrapper fromJson(int? json) {
    if (json == null) {
      return PurchaseStateWrapper.unspecified_state;
    }
    return _$enumDecode<PurchaseStateWrapper, dynamic>(
        _$PurchaseStateWrapperEnumMap.cast<PurchaseStateWrapper, dynamic>(),
        json);
  }

  @override
  int toJson(PurchaseStateWrapper object) =>
      _$PurchaseStateWrapperEnumMap[object]!;

  /// Converts the purchase state stored in `object` to a [PurchaseStatus].
  ///
  /// [PurchaseStateWrapper.unspecified_state] is mapped to [PurchaseStatus.error].
  PurchaseStatus toPurchaseStatus(PurchaseStateWrapper object) {
    switch (object) {
      case PurchaseStateWrapper.pending:
        return PurchaseStatus.pending;
      case PurchaseStateWrapper.purchased:
        return PurchaseStatus.purchased;
      case PurchaseStateWrapper.unspecified_state:
        return PurchaseStatus.error;
    }
  }
}

/// Serializer for [BillingClientFeature].
///
/// Use these in `@JsonSerializable()` classes by annotating them with
/// `@BillingClientFeatureConverter()`.
class BillingClientFeatureConverter
    implements JsonConverter<BillingClientFeature, String> {
  /// Default const constructor.
  const BillingClientFeatureConverter();

  @override
  BillingClientFeature fromJson(String json) {
    return _$enumDecode<BillingClientFeature, dynamic>(
        _$BillingClientFeatureEnumMap.cast<BillingClientFeature, dynamic>(),
        json);
  }

  @override
  String toJson(BillingClientFeature object) =>
      _$BillingClientFeatureEnumMap[object]!;
}

// Define a class so we generate serializer helper methods for the enums
@JsonSerializable()
class _SerializedEnums {
  late BillingResponse response;
  late SkuType type;
  late PurchaseStateWrapper purchaseState;
  late ProrationMode prorationMode;
  late BillingClientFeature billingClientFeature;
}
