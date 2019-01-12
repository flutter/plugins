import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';

const MethodChannel _channel =
    MethodChannel('plugins.flutter.io/in_app_purchase');

/// https://developer.apple.com/documentation/storekit/skproductsrequest?language=objc
class SKProductRequestWrapper {
  static Future<List<Map<dynamic, dynamic>>> getProductList(
      List<String> identifiers) async {
    return _channel.invokeListMethod<Map<dynamic, dynamic>>(
      'getProductList',
      <String, Object>{
        'identifiers': identifiers,
      },
    );
  }
}

/// https://developer.apple.com/documentation/storekit/skproduct/2936884-subscriptionperiod?language=objc
class SKProductSubscriptionPeriodWrapper {
  SKProductSubscriptionPeriodWrapper(
      {@required this.numberOfUnits, @required this.unit});

  SKProductSubscriptionPeriodWrapper.fromJson(Map<dynamic, dynamic> json)
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
      @required this.subscriptionPeriodWrapper});

  SKProductDiscountWrapper.fromJson(Map<dynamic, dynamic> json)
      : price = json['price'],
        numberOfPeriods = json['numberOfPeriods'],
        paymentMode = json['paymentMode'],
        subscriptionPeriodWrapper = json['subscriptionPeriod'] != null
            ? SKProductSubscriptionPeriodWrapper.fromJson(
                json['subscriptionPeriod'])
            : null;

  final double price;
  final int numberOfPeriods, paymentMode;
  final SKProductSubscriptionPeriodWrapper subscriptionPeriodWrapper;
}

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

  SKProductWrapper.fromJson(Map<dynamic, dynamic> json)
      : productIdentifier = json['productIdentifier'],
        localizedTitle = json['localizedTitle'],
        localizedDescription = json['localizedDescription'],
        currencyCode = json['currencyCode'],
        downloadContentVersion = json['downloadContentVersion'],
        subscriptionGroupIdentifier = json['subscriptionGroupIdentifier'],
        price = json['price'],
        downloadable = json['downloadable'],
        downloadContentLengths = json['downloadContentLengths'],
        subscriptionPeriod = json['subscriptionPeriod'] != null
            ? SKProductSubscriptionPeriodWrapper.fromJson(
                json['subscriptionPeriod'])
            : null,
        introductoryPrice = (json['introductoryPrice'] != null)
            ? SKProductDiscountWrapper.fromJson(json['introductoryPrice'])
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
