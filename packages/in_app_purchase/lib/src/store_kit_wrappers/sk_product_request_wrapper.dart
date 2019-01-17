// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter/foundation.dart';
import '../channel.dart';

/// [SKProductRequestWrapper] wraps IOS SKProductRequest class to to retrive StoreKit product information in dart.
///
/// https://developer.apple.com/documentation/storekit/skproductsrequest?language=objc
class SKProductRequestWrapper {
  /// Get product list.
  ///
  /// [identifiers] is the product identifiers specified in Itunes Connect for the products that need to be retrived.
  ///
  /// Returns a future containing a list of [SKProduct] which then can be queried to get desired information.
  static Future<List<SKProductWrapper>> getSKProductList(
      List<String> identifiers) async {
    final List<Map<dynamic, dynamic>> productListSerilized =
        await channel.invokeListMethod<Map<dynamic, dynamic>>(
      'getProductList',
      <String, Object>{
        'identifiers': identifiers,
      },
    );

    final List<SKProductWrapper> productList = <SKProductWrapper>[];
    for (Map<dynamic, dynamic> productMap in productListSerilized) {
      productList.add(SKProductWrapper.fromMap(
        productMap.cast<String, dynamic>(),
      ));
    }
    return productList;
  }
}

/// A unit discription the length of a subscription period. 
/// 
/// This is wrapper of StoreKit's [SKProductPeriodUnit](https://developer.apple.com/documentation/storekit/skproductperiodunit?language=objc).
enum SubscriptionPeriodUnit {
  day,
  week,
  month,
  year,
} 

/// A subscription period.
///
/// A period is defined by a [numberOfUnits] and a [unit], e.g for a 3 months period [numberOfUnits] is 3 and [unit] is a month.
///
/// This is a wrapper for StoreKit's [SKProductSubscriptionPeriod](https://developer.apple.com/documentation/storekit/skproductsubscriptionperiod?language=objc).
class SKProductSubscriptionPeriodWrapper {
  SKProductSubscriptionPeriodWrapper(
      {@required this.numberOfUnits, @required this.unit});

  /// Constructor to build with a map.
  ///
  /// Used for constructing the class with the map passed from the OBJC layer.
  SKProductSubscriptionPeriodWrapper.fromMap(Map<String, dynamic> map)
      : numberOfUnits = map['numberOfUnits'],
        unit = (map['unit']!=null)?SubscriptionPeriodUnit.values[map['unit']]:null;

  /// The number of a certain units to represent the period, the unit is defined in the unit property.
  final int numberOfUnits;
  /// The unit that combined with numberOfUnits to define the length of the subscripton.
  final SubscriptionPeriodUnit unit;
}

/// A payment mode to describe how the discounted price is paid.
/// 
/// [PayAsYouGo] allows user to pay the discounted price at each payment period.
/// [PayUpFront] allows user to pay the discounted price upfront and receive the product for the rest of time that was paid for.
/// [FreeTrail] user pays nothing during the discounted period. 
/// This is a wrapper for StoreKit's [SKProductDiscountPaymentMode](https://developer.apple.com/documentation/storekit/skproductdiscountpaymentmode?language=objc).
enum ProductDiscountPaymentMode {
  PayAsYouGo,
  PayUpFront,
  FreeTrail,
}

/// A product discount.
///
/// Most of the fields are identical to OBJC SKProduct.
/// The only difference is instead of the locale object, we only exposed currencyCode for simplicity. #26610.
/// This is a wrapper for StoreKit's [SKProductDiscount](https://developer.apple.com/documentation/storekit/skproductdiscount?language=objc).
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
  SKProductDiscountWrapper.fromMap(Map<String, dynamic> map)
      : price = map['price'],
        currencyCode = map['currencyCode'],
        numberOfPeriods = map['numberOfPeriods'],
        paymentMode = (map['paymentMode'] != null)?ProductDiscountPaymentMode.values[map['paymentMode']]:null,
        subscriptionPeriod = map['subscriptionPeriod'] != null
            ? SKProductSubscriptionPeriodWrapper.fromMap(
                map['subscriptionPeriod'].cast<String, dynamic>())
            : null;

  /// The discounted price, in the currency that is defined in [currencyCode].
  final double price;
  /// The currencyCode for the price, e.g USD for U.S. dollars. 
  final String currencyCode;
  /// The object represent the discount period.
  final int numberOfPeriods;
  /// The payment mode for the discount.
  final ProductDiscountPaymentMode paymentMode;
  /// The object represents the subscription period for the discount.
  final SKProductSubscriptionPeriodWrapper subscriptionPeriod;
}

/// A product.
///
/// Most of the fields are identical to OBJC SKProduct.
/// The only difference is instead of the locale object, we only exposed currencyCode for simplicity. #26610.
/// This is a wrapper for StoreKit's [SKProduct](https://developer.apple.com/documentation/storekit/skproduct?language=objc).
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
  SKProductWrapper.fromMap(Map<String, dynamic> map)
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
  
  ///The unique identifier of the product.
  final String productIdentifier,
  /// The localizedTitle of the product.
      localizedTitle,
  /// The localized description of the product.
      localizedDescription,
  /// The currencyCode for the price, e.g USD for U.S. dollars. 
      currencyCode,
  /// The downloadContentVersion, can be null if the product is not a download content.
      downloadContentVersion,
  /// 
      subscriptionGroupIdentifier;
  /// The price of the product, in the currency that is defined in [currencyCode].
  final double price;
  /// If the AppStore has downloadable content for this product.
  final bool downloadable;
  /// 
  final List<int> downloadContentLengths;
  /// The object represents the subscription period of the product.
  final SKProductSubscriptionPeriodWrapper subscriptionPeriod;
  /// The object represents the introductory price of the product. 
  final SKProductDiscountWrapper introductoryPrice;
}
