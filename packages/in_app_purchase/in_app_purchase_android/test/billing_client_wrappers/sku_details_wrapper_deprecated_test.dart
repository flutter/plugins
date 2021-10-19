// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// TODO(mvanbeusekom): Remove this file when the deprecated
//                     `SkuDetailsWrapper.introductoryPriceMicros` field is
//                     removed.

import 'package:flutter_test/flutter_test.dart';
import 'package:in_app_purchase_android/billing_client_wrappers.dart';

void main() {
  test(
      'Deprecated `introductoryPriceMicros` field reflects parameter from constructor',
      () {
    final SkuDetailsWrapper skuDetails = SkuDetailsWrapper(
      description: 'description',
      freeTrialPeriod: 'freeTrialPeriod',
      introductoryPrice: 'introductoryPrice',
      // ignore: deprecated_member_use_from_same_package
      introductoryPriceMicros: '990000',
      introductoryPriceCycles: 1,
      introductoryPricePeriod: 'introductoryPricePeriod',
      price: 'price',
      priceAmountMicros: 1000,
      priceCurrencyCode: 'priceCurrencyCode',
      priceCurrencySymbol: r'$',
      sku: 'sku',
      subscriptionPeriod: 'subscriptionPeriod',
      title: 'title',
      type: SkuType.inapp,
      originalPrice: 'originalPrice',
      originalPriceAmountMicros: 1000,
    );

    expect(skuDetails, isNotNull);
    expect(skuDetails.introductoryPriceAmountMicros, 0);
    // ignore: deprecated_member_use_from_same_package
    expect(skuDetails.introductoryPriceMicros, '990000');
  });

  test(
      '`introductoryPriceAmoutMicros` constructor parameter is reflected by deprecated `introductoryPriceMicros` and `introductoryPriceAmountMicros` fields',
      () {
    final SkuDetailsWrapper skuDetails = SkuDetailsWrapper(
      description: 'description',
      freeTrialPeriod: 'freeTrialPeriod',
      introductoryPrice: 'introductoryPrice',
      introductoryPriceAmountMicros: 990000,
      introductoryPriceCycles: 1,
      introductoryPricePeriod: 'introductoryPricePeriod',
      price: 'price',
      priceAmountMicros: 1000,
      priceCurrencyCode: 'priceCurrencyCode',
      priceCurrencySymbol: r'$',
      sku: 'sku',
      subscriptionPeriod: 'subscriptionPeriod',
      title: 'title',
      type: SkuType.inapp,
      originalPrice: 'originalPrice',
      originalPriceAmountMicros: 1000,
    );

    expect(skuDetails, isNotNull);
    expect(skuDetails.introductoryPriceAmountMicros, 990000);
    // ignore: deprecated_member_use_from_same_package
    expect(skuDetails.introductoryPriceMicros, '990000');
  });
}
