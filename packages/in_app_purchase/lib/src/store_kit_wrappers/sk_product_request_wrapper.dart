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

/// This class wraps the IOS SKProductSubscriptionPeriod class
///
/// It contains the same field in SKProductSubscriptionPeriod class
/// https://developer.apple.com/documentation/storekit/skproduct/2936884-subscriptionperiod?language=objc
class SKProductSubscriptionPeriodWrapper {
  SKProductSubscriptionPeriodWrapper(
      {@required this.numberOfUnits, @required this.unit});

  /// Constructor to build with a map
  ///
  /// Used for constructing the class with the map passed from the OBJC layer.
  SKProductSubscriptionPeriodWrapper.fromMap(Map<String, dynamic> map)
      : numberOfUnits = map['numberOfUnits'],
        unit = map['unit'];

  final int numberOfUnits, unit;
}

/// This class wraps the IOS SKProductDiscount class
///
/// It contains the same field in SKProductDiscount class
/// https://developer.apple.com/documentation/storekit/skproductdiscount?language=objc
class SKProductDiscountWrapper {
  SKProductDiscountWrapper(
      {@required this.price,
      @required this.numberOfPeriods,
      @required this.paymentMode,
      @required this.subscriptionPeriod});

  /// Constructor to build with a map
  ///
  /// Used for constructing the class with the map passed from the OBJC layer.
  SKProductDiscountWrapper.fromMap(Map<String, dynamic> map)
      : price = map['price'],
        numberOfPeriods = map['numberOfPeriods'],
        paymentMode = map['paymentMode'],
        subscriptionPeriod = map['subscriptionPeriod'] != null
            ? SKProductSubscriptionPeriodWrapper.fromMap(
                map['subscriptionPeriod'].cast<String, dynamic>())
            : null;

  final double price;
  final int numberOfPeriods, paymentMode;
  final SKProductSubscriptionPeriodWrapper subscriptionPeriod;
}

/// This class wraps the IOS SKProduct class
///
/// Most of the fields are the same as in OBJC SKProduct
/// The only difference is instead of the locale object, we only exposed currencyCode for simplicity.
/// https://developer.apple.com/documentation/storekit/skproduct?language=objc
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

  final String productIdentifier,
      localizedTitle,
      localizedDescription,
      currencyCode,
      downloadContentVersion,
      subscriptionGroupIdentifier;
  final double price;
  final bool downloadable;
  final List<int> downloadContentLengths;
  final SKProductSubscriptionPeriodWrapper subscriptionPeriod;
  final SKProductDiscountWrapper introductoryPrice;
}
