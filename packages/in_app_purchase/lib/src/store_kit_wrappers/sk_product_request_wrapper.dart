import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/src/in_app_purchase_connection/product.dart';
import '../channel.dart';

/// [SKProductRequestWrapper] wraps IOS SKProductRequest class to to retrive StoreKit product information in dart.
///
/// https://developer.apple.com/documentation/storekit/skproductsrequest?language=objc
class SKProductRequestWrapper {
  static MethodChannel _channel = Channel.instance;

  /// Get product list.
  ///
  /// [identifiers] is the product identifiers specified in Itunes Connect for the products that need to be retrived.
  ///
  /// Returns a future containing a list of [SKProduct] which then can be queried to get desired information.
  static Future<List<Product>> getProductList(List<String> identifiers) async {
    final List<Map<dynamic, dynamic>> productListSerilized =
        await _channel.invokeListMethod<Map<dynamic, dynamic>>(
      'getProductList',
      <String, Object>{
        'identifiers': identifiers,
      },
    );

    final List<Product> productList = <Product>[];
    for (Map<dynamic, dynamic> productJson in productListSerilized) {
      productList.add(Product(
        skProduct: SKProductWrapper.fromJson(productJson.cast<String, dynamic>()),
      ));
    }
    return productList;
  }
}

/// https://developer.apple.com/documentation/storekit/skproduct/2936884-subscriptionperiod?language=objc
class SKProductSubscriptionPeriodWrapper {
  SKProductSubscriptionPeriodWrapper(
      {@required this.numberOfUnits, @required this.unit});

  SKProductSubscriptionPeriodWrapper.fromJson(Map<String, dynamic> json)
      : numberOfUnits = json['numberOfUnits'],
        unit = json['unit'];

  final int numberOfUnits, unit;
}

/// https://developer.apple.com/documentation/storekit/skproductdiscount?language=objc
class SKProductDiscountWrapper {
  SKProductDiscountWrapper(
      {@required this.price,
      @required this.numberOfPeriods,
      @required this.paymentMode,
      @required this.subscriptionPeriod});

  SKProductDiscountWrapper.fromJson(Map<String, dynamic> json)
      : price = json['price'],
        numberOfPeriods = json['numberOfPeriods'],
        paymentMode = json['paymentMode'],
        subscriptionPeriod = json['subscriptionPeriod'] != null
            ? SKProductSubscriptionPeriodWrapper.fromJson(
                json['subscriptionPeriod'].cast<String, dynamic>())
            : null;

  final double price;
  final int numberOfPeriods, paymentMode;
  final SKProductSubscriptionPeriodWrapper subscriptionPeriod;
}

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

  SKProductWrapper.fromJson(Map<String, dynamic> json)
      : productIdentifier = json['productIdentifier'],
        localizedTitle = json['localizedTitle'],
        localizedDescription = json['localizedDescription'],
        currencyCode = json['currencyCode'],
        downloadContentVersion = json['downloadContentVersion'],
        subscriptionGroupIdentifier = json['subscriptionGroupIdentifier'],
        price = json['price'],
        downloadable = json['downloadable'],
        downloadContentLengths =
            List.castFrom<dynamic, int>(json['downloadContentLengths']),
        subscriptionPeriod = json['subscriptionPeriod'] != null
            ? SKProductSubscriptionPeriodWrapper.fromJson(
                json['subscriptionPeriod'].cast<String, dynamic>())
            : null,
        introductoryPrice = (json['introductoryPrice'] != null)
            ? SKProductDiscountWrapper.fromJson(json['introductoryPrice'].cast<String, dynamic>())
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
