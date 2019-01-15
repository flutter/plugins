// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.

import 'package:flutter/foundation.dart';
import 'billing_client_wrapper.dart';

/// Dart wrapper around [`com.android.billingclient.api.SkuDetails`](https://developer.android.com/reference/com/android/billingclient/api/SkuDetails).
class SkuDetailsWrapper {
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
  static SkuDetailsWrapper fromMap(Map<String, dynamic> map) =>
      SkuDetailsWrapper(
          description: map['description'],
          freeTrialPeriod: map['freeTrialPeriod'],
          introductoryPrice: map['introductoryPrice'],
          introductoryPriceMicros: map['introductoryPriceMicros'],
          introductoryPriceCycles: map['introductoryPriceCycles'],
          introductoryPricePeriod: map['introductoryPricePeriod'],
          price: map['price'],
          priceAmountMicros: map['priceAmountMicros'],
          priceCurrencyCode: map['priceCurrencyCode'],
          sku: map['sku'],
          subscriptionPeriod: map['subscriptionPeriod'],
          title: map['title'],
          type: SkuType.fromString(map['type']),
          isRewarded: map['isRewarded']);

  final String description;
  final String freeTrialPeriod;
  final String introductoryPrice;
  final String introductoryPriceMicros;
  final String introductoryPriceCycles;
  final String introductoryPricePeriod;
  final String price;
  final int priceAmountMicros;
  final String priceCurrencyCode;
  final String sku;
  final String subscriptionPeriod;
  final String title;
  final SkuType type;
  final bool isRewarded;

  @override
  bool operator ==(dynamic other) =>
      other is SkuDetailsWrapper &&
      other.description == description &&
      other.freeTrialPeriod == freeTrialPeriod &&
      other.introductoryPrice == introductoryPrice &&
      other.introductoryPriceMicros == introductoryPriceMicros &&
      other.introductoryPriceCycles == introductoryPriceCycles &&
      other.introductoryPricePeriod == introductoryPricePeriod &&
      other.price == price &&
      other.priceAmountMicros == priceAmountMicros &&
      other.sku == sku &&
      other.subscriptionPeriod == subscriptionPeriod &&
      other.title == title &&
      other.type == type &&
      other.isRewarded == isRewarded;

  @override
  int get hashCode =>
      description.hashCode +
      freeTrialPeriod.hashCode +
      introductoryPrice.hashCode +
      introductoryPriceMicros.hashCode +
      introductoryPriceCycles.hashCode +
      introductoryPricePeriod.hashCode +
      price.hashCode +
      priceAmountMicros.hashCode +
      sku.hashCode +
      subscriptionPeriod.hashCode +
      title.hashCode +
      type.hashCode +
      isRewarded.hashCode;
}

/// Translation of [`com.android.billingclient.api.SkuDetailsResponseListener`](https://developer.android.com/reference/com/android/billingclient/api/SkuDetailsResponseListener.html).
///
/// Returned as a datatype in a future instead of existing as a callback.
class SkuDetailsResponseWrapper {
  SkuDetailsResponseWrapper({@required this.responseCode, this.skuDetailsList});
  static SkuDetailsResponseWrapper fromMap(Map<String, dynamic> map) {
    final List<SkuDetailsWrapper> skuDetailsList = List.castFrom<dynamic,
            Map<dynamic, dynamic>>(map['skuDetailsList'])
        .map((Map<dynamic, dynamic> uncast) => uncast.cast<String, dynamic>())
        .map((Map<String, dynamic> entry) => SkuDetailsWrapper.fromMap(entry))
        .toList();
    return SkuDetailsResponseWrapper(
        responseCode: map['responseCode'], skuDetailsList: skuDetailsList);
  }

  final int responseCode;
  final List<SkuDetailsWrapper> skuDetailsList;
}
