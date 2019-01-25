// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/foundation.dart';

/// Dart wrapper around StoreKit's [SKProductsResponse](https://developer.apple.com/documentation/storekit/skproductsresponse?language=objc).
///
/// Represents the response object returned by [startProductRequest].
/// Contains information about a list of products and a list of invalid product identifers.
class SkProductResponseWrapper {
  SkProductResponseWrapper(
      {@required this.products, @required this.invalidProductIdentifiers});

  /// Used for constructing the class with map passed from the OBJC layer.
  ///
  /// The [map] parameter should not be null.
  SkProductResponseWrapper.fromMap(Map<String, List<dynamic>> map)
      : products = _getListFromMapList(_getProductMapListFromResponseMap(map)),
        invalidProductIdentifiers =
            List.castFrom<dynamic, String>(map['invalidProductIdentifiers']);

  /// Stores all matching successfully found products.
  ///
  /// Will be empty if the [SKProductRequestMaker]'s [startProductRequest] method does not pass any correct product identifer.
  final List<SKProductWrapper> products;

  /// Stores any product identifer in [productIdentifers] that does not match a product.
  ///
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
/// Used as a property in the [SKProductSubscriptionPeriodWrapper].
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

  /// Used for constructing the class with the map passed from the OBJC layer.
  ///
  /// The [map] parameter should not be null.
  SKProductSubscriptionPeriodWrapper.fromMap(Map<String, dynamic> map)
      : numberOfUnits = map['numberOfUnits'],
        unit = (map['unit'] != null)
            ? SubscriptionPeriodUnit.values[map['unit']]
            : null;

  /// The number of a certain units to represent the period, the unit is defined in the [unit] property.
  ///
  /// This should have a value >= 0.
  final int numberOfUnits;

  /// The unit that combined with [numberOfUnits] to define the length of the subscripton.
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

  /// Used for constructing the class with the map passed from the OBJC layer.
  ///
  /// The [map] parameter should not be null.
  SKProductDiscountWrapper.fromMap(Map<String, dynamic> map)
      : price = map['price'],
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

  /// The payment mode for the discount. Check [ProductDiscountPaymentMode] for more details on each payment mode.
  final ProductDiscountPaymentMode paymentMode;

  /// The object represents the subscription period for the discount. Check [SKProductSubscriptionPeriodWrapper] for more details.
  final SKProductSubscriptionPeriodWrapper subscriptionPeriod;
}

/// Dart wrapper around StoreKit's [SKProduct](https://developer.apple.com/documentation/storekit/skproduct?language=objc).
///
/// Most of the fields are identical to OBJC SKProduct.
/// The only difference is instead of the locale object, we only exposed currencyCode for simplicity.
/// A list of [SKProductWrapper] is returned in the [SKProductRequestMaker]'s [startProductRequest] method, and
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

  /// Used for constructing the class with the map passed from the OBJC layer.
  ///
  /// The [map] parameter should not be null.
  SKProductWrapper.fromMap(Map<dynamic, dynamic> map)
      : productIdentifier = map['productIdentifier'],
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
  ///
  /// Defined in the App Store Connect when you create the product.
  final String productIdentifier,

      /// The localizedTitle of the product.
      ///
      /// Defined in the App Store Connect when you create the product.
      localizedTitle,

      /// The localized description of the product.
      ///
      /// Defined in the App Store Connect when you create the product.
      localizedDescription,

      // TODO(cyanglaz): NSLocale is a complex object, want to see the actual need of getting this expanded to
      //                 a map. Matching android to only get the currencyCode for now.
      //                 https://github.com/flutter/flutter/issues/26610
      /// The currencyCode for the price, e.g USD for U.S. dollars.
      /// Defined in the App Store Connect when you create the product.
      currencyCode,

      /// The version of the downloadable content.
      ///
      /// This is only available when [downloadable] is true.
      downloadContentVersion,

      /// The subscription group identifer.
      ///
      /// A subscription group is a collection of subscription products.
      /// Check [SubscriptionGroup](https://developer.apple.com/app-store/subscriptions/) for more details about subscription group.
      subscriptionGroupIdentifier;

  /// The price of the product, in the currency that is defined in [currencyCode].
  final double price;

  /// Whether the AppStore has downloadable content for this product.
  ///
  /// [downloadContentVersion] and [downloadContentLengths] become available if this is true.
  final bool downloadable;

  /// The length of the downloadable content.
  ///
  /// This is only available when [downloadable] is true.
  final List<int> downloadContentLengths;

  /// The object represents the subscription period of the product.
  final SKProductSubscriptionPeriodWrapper subscriptionPeriod;

  /// The object represents the introductory price of the product.
  final SKProductDiscountWrapper introductoryPrice;
}
