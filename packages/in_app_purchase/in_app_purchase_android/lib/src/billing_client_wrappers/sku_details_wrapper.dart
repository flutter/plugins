// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/foundation.dart';
import 'package:json_annotation/json_annotation.dart';

import 'billing_client_wrapper.dart';

// WARNING: Changes to `@JsonSerializable` classes need to be reflected in the
// below generated file. Run `flutter packages pub run build_runner watch` to
// rebuild and watch for further changes.
part 'sku_details_wrapper.g.dart';

/// The error message shown when the map represents billing result is invalid from method channel.
///
/// This usually indicates a series underlining code issue in the plugin.
@visibleForTesting
const String kInvalidBillingResultErrorMessage =
    'Invalid billing result map from method channel.';

/// Dart wrapper around [`com.android.billingclient.api.SkuDetails`](https://developer.android.com/reference/com/android/billingclient/api/SkuDetails).
///
/// Contains the details of an available product in Google Play Billing.
@JsonSerializable()
@SkuTypeConverter()
@immutable
class SkuDetailsWrapper {
  /// Creates a [SkuDetailsWrapper] with the given purchase details.
  @visibleForTesting
  const SkuDetailsWrapper({
    required this.description,
    required this.freeTrialPeriod,
    required this.introductoryPrice,
    @Deprecated('Use `introductoryPriceAmountMicros` parameter instead')
        String introductoryPriceMicros = '',
    this.introductoryPriceAmountMicros = 0,
    required this.introductoryPriceCycles,
    required this.introductoryPricePeriod,
    required this.price,
    required this.priceAmountMicros,
    required this.priceCurrencyCode,
    required this.priceCurrencySymbol,
    required this.sku,
    required this.subscriptionPeriod,
    required this.title,
    required this.type,
    required this.originalPrice,
    required this.originalPriceAmountMicros,
  }) : _introductoryPriceMicros = introductoryPriceMicros;

  /// Constructs an instance of this from a key value map of data.
  ///
  /// The map needs to have named string keys with values matching the names and
  /// types of all of the members on this class.
  @visibleForTesting
  factory SkuDetailsWrapper.fromJson(Map<String, dynamic> map) =>
      _$SkuDetailsWrapperFromJson(map);

  final String _introductoryPriceMicros;

  /// Textual description of the product.
  @JsonKey(defaultValue: '')
  final String description;

  /// Trial period in ISO 8601 format.
  @JsonKey(defaultValue: '')
  final String freeTrialPeriod;

  /// Introductory price, only applies to [SkuType.subs]. Formatted ("$0.99").
  @JsonKey(defaultValue: '')
  final String introductoryPrice;

  /// [introductoryPrice] in micro-units 990000.
  ///
  /// Returns 0 if the SKU is not a subscription or doesn't have an introductory
  /// period.
  final int introductoryPriceAmountMicros;

  /// String representation of [introductoryPrice] in micro-units 990000
  @Deprecated('Use `introductoryPriceAmountMicros` instead.')
  @JsonKey(ignore: true)
  String get introductoryPriceMicros => _introductoryPriceMicros.isEmpty
      ? introductoryPriceAmountMicros.toString()
      : _introductoryPriceMicros;

  /// The number of subscription billing periods for which the user will be given the introductory price, such as 3.
  /// Returns 0 if the SKU is not a subscription or doesn't have an introductory period.
  @JsonKey(defaultValue: 0)
  final int introductoryPriceCycles;

  /// The billing period of [introductoryPrice], in ISO 8601 format.
  @JsonKey(defaultValue: '')
  final String introductoryPricePeriod;

  /// Formatted with currency symbol ("$0.99").
  @JsonKey(defaultValue: '')
  final String price;

  /// [price] in micro-units ("990000").
  @JsonKey(defaultValue: 0)
  final int priceAmountMicros;

  /// [price] ISO 4217 currency code.
  @JsonKey(defaultValue: '')
  final String priceCurrencyCode;

  /// [price] localized currency symbol
  /// For example, for the US Dollar, the symbol is "$" if the locale
  /// is the US, while for other locales it may be "US$".
  @JsonKey(defaultValue: '')
  final String priceCurrencySymbol;

  /// The product ID in Google Play Console.
  @JsonKey(defaultValue: '')
  final String sku;

  /// Applies to [SkuType.subs], formatted in ISO 8601.
  @JsonKey(defaultValue: '')
  final String subscriptionPeriod;

  /// The product's title.
  @JsonKey(defaultValue: '')
  final String title;

  /// The [SkuType] of the product.
  final SkuType type;

  /// The original price that the user purchased this product for.
  @JsonKey(defaultValue: '')
  final String originalPrice;

  /// [originalPrice] in micro-units ("990000").
  @JsonKey(defaultValue: 0)
  final int originalPriceAmountMicros;

  @override
  bool operator ==(Object other) {
    if (other.runtimeType != runtimeType) {
      return false;
    }

    return other is SkuDetailsWrapper &&
        other.description == description &&
        other.freeTrialPeriod == freeTrialPeriod &&
        other.introductoryPrice == introductoryPrice &&
        other.introductoryPriceAmountMicros == introductoryPriceAmountMicros &&
        other.introductoryPriceCycles == introductoryPriceCycles &&
        other.introductoryPricePeriod == introductoryPricePeriod &&
        other.price == price &&
        other.priceAmountMicros == priceAmountMicros &&
        other.sku == sku &&
        other.subscriptionPeriod == subscriptionPeriod &&
        other.title == title &&
        other.type == type &&
        other.originalPrice == originalPrice &&
        other.originalPriceAmountMicros == originalPriceAmountMicros;
  }

  @override
  int get hashCode {
    return Object.hash(
        description.hashCode,
        freeTrialPeriod.hashCode,
        introductoryPrice.hashCode,
        introductoryPriceAmountMicros.hashCode,
        introductoryPriceCycles.hashCode,
        introductoryPricePeriod.hashCode,
        price.hashCode,
        priceAmountMicros.hashCode,
        sku.hashCode,
        subscriptionPeriod.hashCode,
        title.hashCode,
        type.hashCode,
        originalPrice,
        originalPriceAmountMicros);
  }
}

/// Translation of [`com.android.billingclient.api.SkuDetailsResponseListener`](https://developer.android.com/reference/com/android/billingclient/api/SkuDetailsResponseListener.html).
///
/// Returned by [BillingClient.querySkuDetails].
@JsonSerializable()
@immutable
class SkuDetailsResponseWrapper {
  /// Creates a [SkuDetailsResponseWrapper] with the given purchase details.
  @visibleForTesting
  const SkuDetailsResponseWrapper(
      {required this.billingResult, required this.skuDetailsList});

  /// Constructs an instance of this from a key value map of data.
  ///
  /// The map needs to have named string keys with values matching the names and
  /// types of all of the members on this class.
  factory SkuDetailsResponseWrapper.fromJson(Map<String, dynamic> map) =>
      _$SkuDetailsResponseWrapperFromJson(map);

  /// The final result of the [BillingClient.querySkuDetails] call.
  final BillingResultWrapper billingResult;

  /// A list of [SkuDetailsWrapper] matching the query to [BillingClient.querySkuDetails].
  @JsonKey(defaultValue: <SkuDetailsWrapper>[])
  final List<SkuDetailsWrapper> skuDetailsList;

  @override
  bool operator ==(Object other) {
    if (other.runtimeType != runtimeType) {
      return false;
    }

    return other is SkuDetailsResponseWrapper &&
        other.billingResult == billingResult &&
        other.skuDetailsList == skuDetailsList;
  }

  @override
  int get hashCode => Object.hash(billingResult, skuDetailsList);
}

/// Params containing the response code and the debug message from the Play Billing API response.
@JsonSerializable()
@BillingResponseConverter()
@immutable
class BillingResultWrapper {
  /// Constructs the object with [responseCode] and [debugMessage].
  const BillingResultWrapper({required this.responseCode, this.debugMessage});

  /// Constructs an instance of this from a key value map of data.
  ///
  /// The map needs to have named string keys with values matching the names and
  /// types of all of the members on this class.
  factory BillingResultWrapper.fromJson(Map<String, dynamic>? map) {
    if (map == null || map.isEmpty) {
      return const BillingResultWrapper(
          responseCode: BillingResponse.error,
          debugMessage: kInvalidBillingResultErrorMessage);
    }
    return _$BillingResultWrapperFromJson(map);
  }

  /// Response code returned in the Play Billing API calls.
  final BillingResponse responseCode;

  /// Debug message returned in the Play Billing API calls.
  ///
  /// Defaults to `null`.
  /// This message uses an en-US locale and should not be shown to users.
  final String? debugMessage;

  @override
  bool operator ==(Object other) {
    if (other.runtimeType != runtimeType) {
      return false;
    }

    return other is BillingResultWrapper &&
        other.responseCode == responseCode &&
        other.debugMessage == debugMessage;
  }

  @override
  int get hashCode => Object.hash(responseCode, debugMessage);
}
