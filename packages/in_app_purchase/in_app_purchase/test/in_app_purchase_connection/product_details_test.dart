// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase/src/store_kit_wrappers/sk_product_wrapper.dart';

void main() {
  group('Constructor Tests', () {
    test(
        'fromSkProduct should correctly parse data from a SKProductWrapper instance.',
        () {
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
      expect(productDetails.id, equals(dummyProductWrapper.productIdentifier));
      expect(productDetails.title, equals(dummyProductWrapper.localizedTitle));
      expect(productDetails.description,
          equals(dummyProductWrapper.localizedDescription));
      expect(productDetails.rawPrice, equals(13.37));
      expect(productDetails.currencyCode,
          equals(dummyProductWrapper.priceLocale.currencyCode));
      expect(productDetails.skProduct, equals(dummyProductWrapper));
      expect(productDetails.skuDetail, isNull);
    });

    test(
        'fromSkuDetails should correctly parse data from a SkuDetailsWrapper instance',
        () {
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
      expect(productDetails.id, equals(dummyDetailWrapper.sku));
      expect(productDetails.title, equals(dummyDetailWrapper.title));
      expect(
          productDetails.description, equals(dummyDetailWrapper.description));
      expect(productDetails.price, equals(dummyDetailWrapper.price));
      expect(productDetails.rawPrice, equals(13.37));
      expect(productDetails.currencyCode,
          equals(dummyDetailWrapper.priceCurrencyCode));
      expect(productDetails.skProduct, isNull);
      expect(productDetails.skuDetail, equals(dummyDetailWrapper));
    });
  });
}
