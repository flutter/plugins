// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.

import 'package:test/test.dart';
import 'package:in_app_purchase/billing_client_wrappers.dart';
import 'package:in_app_purchase/src/billing_client_wrappers/enum_converters.dart';
import 'package:in_app_purchase/src/in_app_purchase_connection/product_details.dart';

final SkuDetailsWrapper dummyWrapper = SkuDetailsWrapper(
  description: 'description',
  freeTrialPeriod: 'freeTrialPeriod',
  introductoryPrice: 'introductoryPrice',
  introductoryPriceMicros: 'introductoryPriceMicros',
  introductoryPriceCycles: 'introductoryPriceCycles',
  introductoryPricePeriod: 'introductoryPricePeriod',
  price: 'price',
  priceAmountMicros: 1000,
  priceCurrencyCode: 'priceCurrencyCode',
  sku: 'sku',
  subscriptionPeriod: 'subscriptionPeriod',
  title: 'title',
  type: SkuType.inapp,
  isRewarded: true,
);

void main() {
  group('SkuDetailsWrapper', () {
    test('converts from map', () {
      final SkuDetailsWrapper expected = dummyWrapper;
      final SkuDetailsWrapper parsed =
          SkuDetailsWrapper.fromJson(buildSkuMap(expected));

      expect(parsed, equals(expected));
    });
  });

  group('SkuDetailsResponseWrapper', () {
    test('parsed from map', () {
      final BillingResponse responseCode = BillingResponse.ok;
      final List<SkuDetailsWrapper> skusDetails = <SkuDetailsWrapper>[
        dummyWrapper,
        dummyWrapper
      ];
      final SkuDetailsResponseWrapper expected = SkuDetailsResponseWrapper(
          responseCode: responseCode, skuDetailsList: skusDetails);

      final SkuDetailsResponseWrapper parsed =
          SkuDetailsResponseWrapper.fromJson(<String, dynamic>{
        'responseCode': BillingResponseConverter().toJson(responseCode),
        'skuDetailsList': <Map<String, dynamic>>[
          buildSkuMap(dummyWrapper),
          buildSkuMap(dummyWrapper)
        ]
      });

      expect(parsed.responseCode, equals(expected.responseCode));
      expect(parsed.skuDetailsList, containsAll(expected.skuDetailsList));
    });

    test('toProductDetails() should return correct Product object', () {
      final SkuDetailsWrapper wrapper =
          SkuDetailsWrapper.fromJson(buildSkuMap(dummyWrapper));
      final ProductDetails product = wrapper.toProductDetails();
      expect(product.title, wrapper.title);
      expect(product.description, wrapper.description);
      expect(product.id, wrapper.sku);
      expect(product.price, wrapper.price);
    });

    test('handles empty list of skuDetails', () {
      final BillingResponse responseCode = BillingResponse.error;
      final List<SkuDetailsWrapper> skusDetails = <SkuDetailsWrapper>[];
      final SkuDetailsResponseWrapper expected = SkuDetailsResponseWrapper(
          responseCode: responseCode, skuDetailsList: skusDetails);

      final SkuDetailsResponseWrapper parsed =
          SkuDetailsResponseWrapper.fromJson(<String, dynamic>{
        'responseCode': BillingResponseConverter().toJson(responseCode),
        'skuDetailsList': <Map<String, dynamic>>[]
      });

      expect(parsed.responseCode, equals(expected.responseCode));
      expect(parsed.skuDetailsList, containsAll(expected.skuDetailsList));
    });
  });
}

Map<String, dynamic> buildSkuMap(SkuDetailsWrapper original) {
  return <String, dynamic>{
    'description': original.description,
    'freeTrialPeriod': original.freeTrialPeriod,
    'introductoryPrice': original.introductoryPrice,
    'introductoryPriceMicros': original.introductoryPriceMicros,
    'introductoryPriceCycles': original.introductoryPriceCycles,
    'introductoryPricePeriod': original.introductoryPricePeriod,
    'price': original.price,
    'priceAmountMicros': original.priceAmountMicros,
    'priceCurrencyCode': original.priceCurrencyCode,
    'sku': original.sku,
    'subscriptionPeriod': original.subscriptionPeriod,
    'title': original.title,
    'type': original.type.toString().substring(8),
    'isRewarded': original.isRewarded,
  };
}
