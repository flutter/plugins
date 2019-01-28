// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/foundation.dart';

/// Dart wrapper around StoreKit's [SKProductsResponse](https://developer.apple.com/documentation/storekit/skproductsresponse?language=objc).
///
/// Represents the response object returned by [SKRequestMaker.startProductRequest].
/// Contains information about a list of products and a list of invalid product identifiers.
class SkProductResponseWrapper {
  SkProductResponseWrapper(
      {@required this.products, @required this.invalidProductIdentifiers});

  /// Constructing an instance from a map from the Objective-C layer.
  ///
  /// This method should only be used with `map` values returned by [SKRequestMaker.startProductRequest].
  /// The `map` parameter must not be null.
  SkProductResponseWrapper.fromMap(Map<String, List<dynamic>> map)
      : assert(map != null),
        products = _getListFromMapList(_getProductMapListFromResponseMap(map)),
        invalidProductIdentifiers =
            List.castFrom<dynamic, String>(map['invalidProductIdentifiers']);

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

  static List<Map<dynamic, dynamic>> _getProductMapListFromResponseMap(
      Map<String, List<dynamic>> map) {
    return map['products'].cast<Map<dynamic, dynamic>>();
  }

  static List<SKProductWrapper> _getListFromMapList(
      List<Map<dynamic, dynamic>> mapList) {
    return mapList
        .map((Map<dynamic, dynamic> map) => SKProductWrapper.fromMap(map))
        .toList();
  }
}

/// Dart wrapper around StoreKit's [SKProductPeriodUnit](https://developer.apple.com/documentation/storekit/skproductperiodunit?language=objc).
///
/// Used as a property in the [SKProductSubscriptionPeriodWrapper]. Minium is a day and maxium is a year.
// The values of the enum options are matching the [SKProductPeriodUnit]'s values. Should there be an update or addition
// in the [SKProductPeriodUnit], this need to be updated to match.
enum SubscriptionPeriodUnit {
  day,
  week,
  month,
  year,
}

/// Dart wrapper around StoreKit's [SKProductSubscriptionPeriod](https://developer.apple.com/documentation/storekit/skproductsubscriptionperiod?language=objc).
///
/// A period is defined by a [numberOfUnits] and a [unit], e.g for a 3 months period [numberOfUnits] is 3 and [unit] is a month.
/// It is used as a property in [SKProductDiscountWrapper] and [SKProductWrapper].
class SKProductSubscriptionPeriodWrapper {
  SKProductSubscriptionPeriodWrapper(
      {@required this.numberOfUnits, @required this.unit});

  /// Constructing an instance from a map from the Objective-C layer.
  /// This method should only be used with `map` values returned by [SKProductDiscountWrapper.fromMap] or [SKProductWrapper.fromMap].
  /// The `map` parameter must not be null.
  SKProductSubscriptionPeriodWrapper.fromMap(Map<String, dynamic> map)
      : assert(map != null &&
            (map['numberOfUnits'] == null || map['numberOfUnits'] > 0)),
        numberOfUnits = map['numberOfUnits'],
        unit = (map['unit'] != null)
            ? SubscriptionPeriodUnit.values[map['unit']]
            : null;

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
  payAsYouGo,

  /// Allows user to pay the discounted price upfront and receive the product for the rest of time that was paid for.
  payUpFront,

  /// User pays nothing during the discounted period.
  freeTrail,
}

/// Dart wrapper around StoreKit's [SKProductDiscount](https://developer.apple.com/documentation/storekit/skproductdiscount?language=objc).
///
/// Most of the fields are identical to OBJC SKProduct.
/// The only difference is instead of the locale object, we only exposed currencyCode for simplicity.
/// It is used as a property in [SKProductWrapper].
class SKProductDiscountWrapper {
  SKProductDiscountWrapper(
      {@required this.price,
      @required this.currencyCode,
      @required this.numberOfPeriods,
      @required this.paymentMode,
      @required this.subscriptionPeriod});

  /// Constructing an instance from a map from the Objective-C layer.
  ///
  /// This method should only be used with `map` values returned by [SKProductWrapper.fromMap].
  /// The `map` parameter must not be null.
  SKProductDiscountWrapper.fromMap(Map<String, dynamic> map)
      : assert(map != null),
        price = map['price'],
        currencyCode = map['currencyCode'],
        numberOfPeriods = map['numberOfPeriods'],
        paymentMode = (map['paymentMode'] != null)
            ? ProductDiscountPaymentMode.values[map['paymentMode']]
            : null,
        subscriptionPeriod = map['subscriptionPeriod'] != null
            ? SKProductSubscriptionPeriodWrapper.fromMap(
                map['subscriptionPeriod'].cast<String, dynamic>())
            : null;

  /// The discounted price, in the currency that is defined in [currencyCode].
  final double price;

  // TODO(cyanglaz): NSLocale is a complex object, want to see the actual need of getting this expanded to
  //                 a map. Matching android to only get the currencyCode for now.
  //                 https://github.com/flutter/flutter/issues/26610
  /// The currencyCode for the [price], e.g USD for U.S. dollars.
  final String currencyCode;

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
/// Most of the fields are identical to OBJC SKProduct.
/// The only difference is instead of the locale object, we only exposed currencyCode for simplicity.
/// A list of [SKProductWrapper] is returned in the [SKRequestMaker.startProductRequest] method, and
/// should be stored for use when making a payment.
class SKProductWrapper {
  SKProductWrapper({
    @required this.productIdentifier,
    @required this.localizedTitle,
    @required this.localizedDescription,
    @required this.currencyCode,
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
  /// This method should only be used with `map` values returned by [SkProductResponseWrapper.fromMap].
  /// The `map` parameter must not be null.
  SKProductWrapper.fromMap(Map<dynamic, dynamic> map)
      : assert(map != null),
        productIdentifier = map['productIdentifier'],
        localizedTitle = map['localizedTitle'],
        localizedDescription = map['localizedDescription'],
        currencyCode = map['currencyCode'],
        downloadContentVersion = map['downloadContentVersion'],
        subscriptionGroupIdentifier = map['subscriptionGroupIdentifier'],
        price = map['price'],
        downloadable = map['downloadable'],
        downloadContentLengths =
            List.castFrom<dynamic, int>(map['downloadContentLengths']),
        subscriptionPeriod = map['subscriptionPeriod'] != null
            ? SKProductSubscriptionPeriodWrapper.fromMap(
                map['subscriptionPeriod'].cast<String, dynamic>())
            : null,
        introductoryPrice = (map['introductoryPrice'] != null)
            ? SKProductDiscountWrapper.fromMap(
                map['introductoryPrice'].cast<String, dynamic>())
            : null;

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

  // TODO(cyanglaz): NSLocale is a complex object, want to see the actual need of getting this expanded to
  //                 a map. Matching android to only get the currencyCode for now.
  //                 https://github.com/flutter/flutter/issues/26610
  /// The currencyCode for the price, e.g USD for U.S. dollars.
  final String currencyCode;

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

  /// The price of the product, in the currency that is defined in [currencyCode].
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
}
