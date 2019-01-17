// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.

import 'package:test/test.dart';
import 'package:in_app_purchase/billing_client_wrappers.dart';

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
  type: SkuType.INAPP,
  isRewarded: true,
);

void main() {
  group('SkuDetailsWrapper', () {
    test('converts from map', () {
      final SkuDetailsWrapper expected = dummyWrapper;
      final SkuDetailsWrapper parsed =
          SkuDetailsWrapper.fromMap(buildSkuMap(expected));

      expect(parsed, equals(expected));
    });
  });

  group('SkuDetailsResponseWrapper', () {
    test('parsed from map', () {
      final BillingResponse responseCode = BillingResponse.OK;
      final List<SkuDetailsWrapper> skusDetails = <SkuDetailsWrapper>[
        dummyWrapper,
        dummyWrapper
      ];
      final SkuDetailsResponseWrapper expected = SkuDetailsResponseWrapper(
          responseCode: responseCode, skuDetailsList: skusDetails);

      final SkuDetailsResponseWrapper parsed =
          SkuDetailsResponseWrapper.fromMap(<String, dynamic>{
        'responseCode': int.parse(responseCode.toString()),
        'skuDetailsList': <Map<String, dynamic>>[
          buildSkuMap(dummyWrapper),
          buildSkuMap(dummyWrapper)
        ]
      });

      expect(parsed.responseCode, equals(expected.responseCode));
      expect(parsed.skuDetailsList, containsAll(expected.skuDetailsList));
    });

    test('handles empty list of skuDetails', () {
      final BillingResponse responseCode = BillingResponse.ERROR;
      final List<SkuDetailsWrapper> skusDetails = <SkuDetailsWrapper>[];
      final SkuDetailsResponseWrapper expected = SkuDetailsResponseWrapper(
          responseCode: responseCode, skuDetailsList: skusDetails);

      final SkuDetailsResponseWrapper parsed =
          SkuDetailsResponseWrapper.fromMap(<String, dynamic>{
        'responseCode': int.parse(responseCode.toString()),
        'skuDetailsList': <Map<String, dynamic>>[]
      });

      expect(parsed.responseCode, equals(expected.responseCode));
      expect(parsed.skuDetailsList, containsAll(expected.skuDetailsList));
    });
  });
}

Map<String, dynamic> buildSkuMap(SkuDetailsWrapper original) =>
    <String, dynamic>{
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
      'type': original.type.toString(),
      'isRewarded': original.isRewarded,
    };
