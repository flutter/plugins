// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/foundation.dart';

/// Response type for a [startProductRequest] request.
///
/// Contains information about a list of products and a list of invalid product identifers.
/// this is a wrapper for StoreKit's [SKProductsResponse](https://developer.apple.com/documentation/storekit/skproductsresponse?language=objc).
class SkProductResponseWrapper {
  SkProductResponseWrapper(
      {@required this.products, @required this.invalidProductIdentifiers});

  /// constructor to build with a map
  ///
  /// Used for constructing the class with map passed from the OBJC layer.
  SkProductResponseWrapper.fromMap(Map<String, List<dynamic>> map)
      : products = _getListFromMapList(_getProductMapListFromResponseMap(map)),
        invalidProductIdentifiers =
            List.castFrom<dynamic, String>(map['invalidProductIdentifiers']);

  /// The list of the products.
  ///
  /// Can be null if the [SKProductRequestMaker]'s [startProductRequest] method does not pass correct [productIdentifiers].
  final List<SKProductWrapper> products;

  /// The list of invalid product identifier.
  ///
  /// If any of the product identifer in [productIdentifers] is invalid, it will be stored here. It can be null if all the product identifiers are valid.
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

/// A unit discription the length of a subscription period.
///
/// This is wrapper for StoreKit's
/// [SKProductPeriodUnit](https://developer.apple.com/documentation/storekit/skproductperiodunit?language=objc).
/// This is used as a property in the [SKProductSubscriptionPeriodWrapper].
/// The values of the enum options are matching the [SKProductPeriodUnit]'s values. Should there be an update or addition
/// in the [SKProductPeriodUnit], this need to be updated to match.
enum SubscriptionPeriodUnit {
  day,
  week,
  month,
  year,
}

/// A subscription period.
///
/// A period is defined by a [numberOfUnits] and a [unit], e.g for a 3 months period [numberOfUnits] is 3 and [unit] is a month.
/// It is used as a property in [SKProductDiscountWrapper] and [SKProductWrapper].
/// This is a wrapper for StoreKit's
/// [SKProductSubscriptionPeriod](https://developer.apple.com/documentation/storekit/skproductsubscriptionperiod?language=objc).
class SKProductSubscriptionPeriodWrapper {
  SKProductSubscriptionPeriodWrapper(
      {@required this.numberOfUnits, @required this.unit});

  /// The Constructor to build with a map.
  ///
  /// Used for constructing the class with the map passed from the OBJC layer.
  /// The [map] parameter should not be null.
  SKProductSubscriptionPeriodWrapper.fromMap(Map<String, dynamic> map)
      : numberOfUnits = map['numberOfUnits'],
        unit = (map['unit'] != null)
            ? SubscriptionPeriodUnit.values[map['unit']]
            : null;

  /// The number of a certain units to represent the period, the unit is defined in the unit property.
  ///
  /// This should have a value >= 0.
  final int numberOfUnits;

  /// The unit that combined with numberOfUnits to define the length of the subscripton.
  final SubscriptionPeriodUnit unit;
}

/// A payment mode to describe how the discounted price is paid.
///
/// This is a wrapper for StoreKit's
/// [SKProductDiscountPaymentMode](https://developer.apple.com/documentation/storekit/skproductdiscountpaymentmode?language=objc).
/// This is used as a property in the [SKProductDiscountWrapper].
/// The values of the enum options are matching the [SKProductDiscountPaymentMode]'s values. Should there be an update or addition
/// in the [SKProductDiscountPaymentMode], this need to be updated to match.
enum ProductDiscountPaymentMode {
  /// Allows user to pay the discounted price at each payment period.
  payAsYouGo,

  /// Allows user to pay the discounted price upfront and receive the product for the rest of time that was paid for.
  payUpFront,

  /// User pays nothing during the discounted period.
  freeTrail,
}

/// A product discount.
///
/// Most of the fields are identical to OBJC SKProduct.
/// The only difference is instead of the locale object, we only exposed currencyCode for simplicity.
/// It is used as a property in [SKProductWrapper].
/// This is a wrapper for StoreKit's [SKProductDiscount]
/// (https://developer.apple.com/documentation/storekit/skproductdiscount?language=objc).
class SKProductDiscountWrapper {
  SKProductDiscountWrapper(
      {@required this.price,
      @required this.currencyCode,
      @required this.numberOfPeriods,
      @required this.paymentMode,
      @required this.subscriptionPeriod});

  /// Constructor to build with a map.
  ///
  /// Used for constructing the class with the map passed from the OBJC layer.
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
  /// The currencyCode for the price, e.g USD for U.S. dollars.
  final String currencyCode;

  /// The object represent the discount period.
  ///
  /// The value must be >= 0.
  final int numberOfPeriods;

  /// The payment mode for the discount.
  final ProductDiscountPaymentMode paymentMode;

  /// The object represents the subscription period for the discount.
  final SKProductSubscriptionPeriodWrapper subscriptionPeriod;
}

/// A product.
///
/// Most of the fields are identical to OBJC SKProduct.
/// The only difference is instead of the locale object, we only exposed currencyCode for simplicity.
/// This is a wrapper for StoreKit's [SKProduct]
/// (https://developer.apple.com/documentation/storekit/skproduct?language=objc).
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

  /// Constructor to build with a map
  ///
  /// Used for constructing the class with the map passed from the OBJC layer.
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
  /// This is defined in the Itunes Connect when you create the product.
  final String productIdentifier,

      /// The localizedTitle of the product.
      ///
      /// This is defined in the Itunes Connect when you create the product.
      localizedTitle,

      /// The localized description of the product.
      ///
      /// This is defined in the Itunes Connect when you create the product.
      localizedDescription,

      // TODO(cyanglaz): NSLocale is a complex object, want to see the actual need of getting this expanded to
      //                 a map. Matching android to only get the currencyCode for now.
      //                 https://github.com/flutter/flutter/issues/26610
      /// The currencyCode for the price, e.g USD for U.S. dollars.
      /// This is defined in the Itunes Connect when you create the product.
      currencyCode,

      /// The version of the downloadable content.
      ///
      /// This is only available when [downloadable] is true.
      downloadContentVersion,

      /// The subscription group identifer.
      subscriptionGroupIdentifier;

  /// The price of the product, in the currency that is defined in [currencyCode].
  final double price;

  /// If the AppStore has downloadable content for this product.
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
