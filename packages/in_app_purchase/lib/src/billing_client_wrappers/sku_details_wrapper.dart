// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.

import 'dart:ui' show hashValues;
import 'package:flutter/foundation.dart';
import 'package:json_annotation/json_annotation.dart';
import 'billing_client_wrapper.dart';
import 'enum_converters.dart';

// WARNING: Changes to `@JsonSerializable` classes need to be reflected in the
// below generated file. Run `flutter packages pub run build_runner watch` to
// rebuild and watch for further changes.
part 'sku_details_wrapper.g.dart';

/// Dart wrapper around [`com.android.billingclient.api.SkuDetails`](https://developer.android.com/reference/com/android/billingclient/api/SkuDetails).
///
/// Contains the details of an available product in Google Play Billing.
@JsonSerializable()
@SkuTypeConverter()
class SkuDetailsWrapper {
  @visibleForTesting
  SkuDetailsWrapper({
    @required this.description,
    @required this.freeTrialPeriod,
    @required this.introductoryPrice,
    @required this.introductoryPriceMicros,
    @required this.introductoryPriceCycles,
    @required this.introductoryPricePeriod,
    @required this.price,
    @required this.priceAmountMicros,
    @required this.priceCurrencyCode,
    @required this.sku,
    @required this.subscriptionPeriod,
    @required this.title,
    @required this.type,
    @required this.isRewarded,
  });

  /// Constructs an instance of this from a key value map of data.
  ///
  /// The map needs to have named string keys with values matching the names and
  /// types of all of the members on this class.
  @visibleForTesting
  factory SkuDetailsWrapper.fromJson(Map map) =>
      _$SkuDetailsWrapperFromJson(map);

  final String description;

  /// Trial period in ISO 8601 format.
  final String freeTrialPeriod;

  /// Introductory price, only applies to [SkuType.subs]. Formatted ("$0.99").
  final String introductoryPrice;

  /// [introductoryPrice] in micro-units 990000
  final String introductoryPriceMicros;

  /// The number of billing perios that [introductoryPrice] is valid for ("2").
  final String introductoryPriceCycles;

  /// The billing period of [introductoryPrice], in ISO 8601 format.
  final String introductoryPricePeriod;

  /// Formatted with currency symbol ("$0.99").
  final String price;

  /// [price] in micro-units ("990000").
  final int priceAmountMicros;

  /// [price] ISO 4217 currency code.
  final String priceCurrencyCode;

  /// The product ID in Google Play Console.
  final String sku;

  /// Applies to [SkuType.subs], formatted in ISO 8601.
  final String subscriptionPeriod;
  final String title;

  /// The [SkuType] of the product.
  final SkuType type;

  /// False if the product is paid.
  final bool isRewarded;

  @override
  bool operator ==(dynamic other) {
    if (other.runtimeType != runtimeType) {
      return false;
    }

    final SkuDetailsWrapper typedOther = other;
    return typedOther is SkuDetailsWrapper &&
        typedOther.description == description &&
        typedOther.freeTrialPeriod == freeTrialPeriod &&
        typedOther.introductoryPrice == introductoryPrice &&
        typedOther.introductoryPriceMicros == introductoryPriceMicros &&
        typedOther.introductoryPriceCycles == introductoryPriceCycles &&
        typedOther.introductoryPricePeriod == introductoryPricePeriod &&
        typedOther.price == price &&
        typedOther.priceAmountMicros == priceAmountMicros &&
        typedOther.sku == sku &&
        typedOther.subscriptionPeriod == subscriptionPeriod &&
        typedOther.title == title &&
        typedOther.type == type &&
        typedOther.isRewarded == isRewarded;
  }

  @override
  int get hashCode {
    return hashValues(
        description.hashCode,
        freeTrialPeriod.hashCode,
        introductoryPrice.hashCode,
        introductoryPriceMicros.hashCode,
        introductoryPriceCycles.hashCode,
        introductoryPricePeriod.hashCode,
        price.hashCode,
        priceAmountMicros.hashCode,
        sku.hashCode,
        subscriptionPeriod.hashCode,
        title.hashCode,
        type.hashCode,
        isRewarded.hashCode);
  }
}

/// Translation of [`com.android.billingclient.api.SkuDetailsResponseListener`](https://developer.android.com/reference/com/android/billingclient/api/SkuDetailsResponseListener.html).
///
/// Returned by [BillingClient.querySkuDetails].
@JsonSerializable()
@BillingResponseConverter()
class SkuDetailsResponseWrapper {
  @visibleForTesting
  SkuDetailsResponseWrapper({@required this.responseCode, this.skuDetailsList});

  /// Constructs an instance of this from a key value map of data.
  ///
  /// The map needs to have named string keys with values matching the names and
  /// types of all of the members on this class.
  factory SkuDetailsResponseWrapper.fromJson(Map<String, dynamic> map) =>
      _$SkuDetailsResponseWrapperFromJson(map);

  /// The final status of the [BillingClient.querySkuDetails] call.
  final BillingResponse responseCode;

  /// A list of [SkuDetailsWrapper] matching the query to [BillingClient.querySkuDetails].
  final List<SkuDetailsWrapper> skuDetailsList;

  @override
  bool operator ==(dynamic other) {
    if (other.runtimeType != runtimeType) {
      return false;
    }

    final SkuDetailsResponseWrapper typedOther = other;
    return typedOther is SkuDetailsResponseWrapper &&
        typedOther.responseCode == responseCode &&
        typedOther.skuDetailsList == skuDetailsList;
  }

  @override
  int get hashCode => hashValues(responseCode, skuDetailsList);
}
