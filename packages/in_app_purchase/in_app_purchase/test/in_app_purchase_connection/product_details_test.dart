// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase/src/store_kit_wrappers/sk_product_wrapper.dart';

void main() {
  group('Constructor Tests', () {
    test('fromSkProduct should correctly parse the price data', () {
      final SKProductWrapper dummyProductWrapper = SKProductWrapper(
        productIdentifier: 'id',
        localizedTitle: 'title',
        localizedDescription: 'description',
        priceLocale:
            SKPriceLocaleWrapper(currencySymbol: '\$', currencyCode: 'USD'),
        subscriptionGroupIdentifier: 'com.group',
        price: '13.37',
      );

      ProductDetails productDetails =
          ProductDetails.fromSKProduct(dummyProductWrapper);
      expect(productDetails.rawPrice, equals(13.37));
    });

    test('fromSkuDetails should correctly parse the price data', () {
      final SkuDetailsWrapper dummyDetailWrapper = SkuDetailsWrapper(
        description: 'description',
        freeTrialPeriod: 'freeTrialPeriod',
        introductoryPrice: 'introductoryPrice',
        introductoryPriceMicros: 'introductoryPriceMicros',
        introductoryPriceCycles: 1,
        introductoryPricePeriod: 'introductoryPricePeriod',
        price: '13.37',
        priceAmountMicros: 13370000,
        priceCurrencyCode: 'usd',
        sku: 'sku',
        subscriptionPeriod: 'subscriptionPeriod',
        title: 'title',
        type: SkuType.inapp,
        originalPrice: 'originalPrice',
        originalPriceAmountMicros: 1000,
      );

      ProductDetails productDetails =
          ProductDetails.fromSkuDetails(dummyDetailWrapper);
      expect(productDetails.rawPrice, equals(13.37));
    });
  });
}
