// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/foundation.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:in_app_purchase/src/in_app_purchase_connection/product_details.dart';

// WARNING: Changes to `@JsonSerializable` classes need to be reflected in the
// below generated file. Run `flutter packages pub run build_runner watch` to
// rebuild and watch for further changes.
part 'sk_product_wrapper.g.dart';

/// Dart wrapper around StoreKit's [SKProductsResponse](https://developer.apple.com/documentation/storekit/skproductsresponse?language=objc).
///
/// Represents the response object returned by [SKRequestMaker.startProductRequest].
/// Contains information about a list of products and a list of invalid product identifiers.
@JsonSerializable()
class SkProductResponseWrapper {
  SkProductResponseWrapper(
      {@required this.products, @required this.invalidProductIdentifiers});

  /// Constructing an instance from a map from the Objective-C layer.
  ///
  /// This method should only be used with `map` values returned by [SKRequestMaker.startProductRequest].
  /// The `map` parameter must not be null.
  factory SkProductResponseWrapper.fromJson(Map map) {
    assert(map != null);
    return _$SkProductResponseWrapperFromJson(map);
  }

  /// Stores all matching successfully found products.
  ///
  /// One product in this list matches one valid product identifier passed to the [SKRequestMaker.startProductRequest].
  /// Will be empty if the [SKRequestMaker.startProductRequest] method does not pass any correct product identifier.
  final List<SKProductWrapper> products;

  /// Stores product identifiers in the `productIdentifiers` from [SKRequestMaker.startProductRequest] that are not recognized by the App Store.
  ///
  /// The App Store will not recognize a product identifier unless certain criteria are met. A detailed list of the criteria can be
  /// found here https://developer.apple.com/documentation/storekit/skproductsresponse/1505985-invalidproductidentifiers?language=objc.
  /// Will be empty if all the product identifiers are valid.
  final List<String> invalidProductIdentifiers;
}

/// Dart wrapper around StoreKit's [SKProductPeriodUnit](https://developer.apple.com/documentation/storekit/skproductperiodunit?language=objc).
///
/// Used as a property in the [SKProductSubscriptionPeriodWrapper]. Minium is a day and maxium is a year.
// The values of the enum options are matching the [SKProductPeriodUnit]'s values. Should there be an update or addition
// in the [SKProductPeriodUnit], this need to be updated to match.
enum SubscriptionPeriodUnit {
  @JsonValue(0)
  day,
  @JsonValue(1)
  week,
  @JsonValue(2)
  month,
  @JsonValue(3)
  year,
}

/// Dart wrapper around StoreKit's [SKProductSubscriptionPeriod](https://developer.apple.com/documentation/storekit/skproductsubscriptionperiod?language=objc).
///
/// A period is defined by a [numberOfUnits] and a [unit], e.g for a 3 months period [numberOfUnits] is 3 and [unit] is a month.
/// It is used as a property in [SKProductDiscountWrapper] and [SKProductWrapper].
@JsonSerializable(nullable: true)
class SKProductSubscriptionPeriodWrapper {
  SKProductSubscriptionPeriodWrapper(
      {@required this.numberOfUnits, @required this.unit});

  /// Constructing an instance from a map from the Objective-C layer.
  ///
  /// This method should only be used with `map` values returned by [SKProductDiscountWrapper.fromJson] or [SKProductWrapper.fromJson].
  /// The `map` parameter must not be null.
  factory SKProductSubscriptionPeriodWrapper.fromJson(Map map) {
    assert(map != null &&
        (map['numberOfUnits'] == null || map['numberOfUnits'] > 0));
    return _$SKProductSubscriptionPeriodWrapperFromJson(map);
  }

  /// The number of [unit] units in this period.
  ///
  /// Must be greater than 0.
  final int numberOfUnits;

  /// The time unit used to specify the length of this period.
  final SubscriptionPeriodUnit unit;
}

/// Dart wrapper around StoreKit's [SKProductDiscountPaymentMode](https://developer.apple.com/documentation/storekit/skproductdiscountpaymentmode?language=objc).
///
/// This is used as a property in the [SKProductDiscountWrapper].
// The values of the enum options are matching the [SKProductDiscountPaymentMode]'s values. Should there be an update or addition
// in the [SKProductDiscountPaymentMode], this need to be updated to match.
enum ProductDiscountPaymentMode {
  /// Allows user to pay the discounted price at each payment period.
  @JsonValue(0)
  payAsYouGo,

  /// Allows user to pay the discounted price upfront and receive the product for the rest of time that was paid for.
  @JsonValue(1)
  payUpFront,

  /// User pays nothing during the discounted period.
  @JsonValue(2)
  freeTrail,
}

/// Dart wrapper around StoreKit's [SKProductDiscount](https://developer.apple.com/documentation/storekit/skproductdiscount?language=objc).
///
/// It is used as a property in [SKProductWrapper].
@JsonSerializable(nullable: true)
class SKProductDiscountWrapper {
  SKProductDiscountWrapper(
      {@required this.price,
      @required this.priceLocale,
      @required this.numberOfPeriods,
      @required this.paymentMode,
      @required this.subscriptionPeriod});

  /// Constructing an instance from a map from the Objective-C layer.
  ///
  /// This method should only be used with `map` values returned by [SKProductWrapper.fromJson].
  /// The `map` parameter must not be null.
  factory SKProductDiscountWrapper.fromJson(Map map) {
    assert(map != null);
    return _$SKProductDiscountWrapperFromJson(map);
  }

  /// The discounted price, in the currency that is defined in [priceLocale].
  final double price;

  /// Includes locale information about the price, e.g. `$` as the currency symbol for US locale.
  final PriceLocaleWrapper priceLocale;

  /// The object represent the discount period length.
  ///
  /// The value must be >= 0.
  final int numberOfPeriods;

  /// The object indicates how the discount price is charged.
  final ProductDiscountPaymentMode paymentMode;

  /// The object represents the duration of single subscription period for the discount.
  ///
  /// The [subscriptionPeriod] of the discount is independent of the product's [subscriptionPeriod],
  /// and their units and duration do not have to be matched.
  final SKProductSubscriptionPeriodWrapper subscriptionPeriod;
}

/// Dart wrapper around StoreKit's [SKProduct](https://developer.apple.com/documentation/storekit/skproduct?language=objc).
///
/// A list of [SKProductWrapper] is returned in the [SKRequestMaker.startProductRequest] method, and
/// should be stored for use when making a payment.
@JsonSerializable(nullable: true)
class SKProductWrapper {
  SKProductWrapper({
    @required this.productIdentifier,
    @required this.localizedTitle,
    @required this.localizedDescription,
    @required this.priceLocale,
    @required this.downloadContentVersion,
    @required this.subscriptionGroupIdentifier,
    @required this.price,
    @required this.downloadable,
    @required this.downloadContentLengths,
    @required this.subscriptionPeriod,
    @required this.introductoryPrice,
  });

  /// Constructing an instance from a map from the Objective-C layer.
  ///
  /// This method should only be used with `map` values returned by [SkProductResponseWrapper.fromJson].
  /// The `map` parameter must not be null.
  factory SKProductWrapper.fromJson(Map map) {
    assert(map != null);
    return _$SKProductWrapperFromJson(map);
  }

  /// The unique identifier of the product.
  final String productIdentifier;

  /// The localizedTitle of the product.
  ///
  /// It is localized based on the current locale.
  final String localizedTitle;

  /// The localized description of the product.
  ///
  /// It is localized based on the current locale.
  final String localizedDescription;

  /// Includes locale information about the price, e.g. `$` as the currency symbol for US locale.
  final PriceLocaleWrapper priceLocale;

  /// The version of the downloadable content.
  ///
  /// This is only available when [downloadable] is true.
  /// It is formatted as a series of integers separated by periods.
  final String downloadContentVersion;

  /// The subscription group identifier.
  ///
  /// A subscription group is a collection of subscription products.
  /// Check [SubscriptionGroup](https://developer.apple.com/app-store/subscriptions/) for more details about subscription group.
  final String subscriptionGroupIdentifier;

  /// The price of the product, in the currency that is defined in [priceLocale].
  final double price;

  /// Whether the AppStore has downloadable content for this product.
  ///
  /// [downloadContentVersion] and [downloadContentLengths] become available if this is true.
  final bool downloadable;

  /// The length of the downloadable content.
  ///
  /// This is only available when [downloadable] is true.
  /// Each element is the size of one of the downloadable files (in bytes).
  final List<int> downloadContentLengths;

  /// The object represents the subscription period of the product.
  ///
  /// Can be [null] is the product is not a subscription.
  final SKProductSubscriptionPeriodWrapper subscriptionPeriod;

  /// The object represents the duration of single subscription period.
  ///
  /// This is only available if you set up the introductory price in the App Store Connect, otherwise it will be null.
  /// Programmar is also responsible to determine if the user is eligible to receive it. See https://developer.apple.com/documentation/storekit/in-app_purchase/offering_introductory_pricing_in_your_app?language=objc
  /// for more details.
  /// The [subscriptionPeriod] of the discount is independent of the product's [subscriptionPeriod],
  /// and their units and duration do not have to be matched.
  final SKProductDiscountWrapper introductoryPrice;

  /// Method to convert to the wrapper to the consolidated [ProductDetails] class.
  ProductDetails toProductDetails() {
    return ProductDetails(
      id: productIdentifier,
      title: localizedTitle,
      description: localizedDescription,
      price: priceLocale.currencySymbol + price.toString(),
    );
  }
}

/// Object that indicates the locale of the price
///
/// It is a thin wrapper of [NSLocale](https://developer.apple.com/documentation/foundation/nslocale?language=objc).
// TODO(cyanglaz): NSLocale is a complex object, want to see the actual need of getting this expanded.
//                 Matching android to only get the currencySymbol for now.
//                 https://github.com/flutter/flutter/issues/26610
@JsonSerializable()
class PriceLocaleWrapper {
  PriceLocaleWrapper({@required this.currencySymbol});

  /// Constructing an instance from a map from the Objective-C layer.
  ///
  /// This method should only be used with `map` values returned by [SKProductWrapper.fromJson] and [SKProductDiscountWrapper.fromJson].
  /// The `map` parameter must not be null.
  factory PriceLocaleWrapper.fromJson(Map map) {
    assert(map != null);
    return _$PriceLocaleWrapperFromJson(map);
  }

  ///The currency symbol for the locale, e.g. $ for US locale.
  final String currencySymbol;
}
