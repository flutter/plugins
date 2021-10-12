// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:in_app_purchase_android/src/types/google_play_product_details.dart';
import 'package:test/test.dart';
import 'package:in_app_purchase_android/billing_client_wrappers.dart';
import 'package:in_app_purchase_android/src/billing_client_wrappers/enum_converters.dart';

final SkuDetailsWrapper dummySkuDetails = SkuDetailsWrapper(
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

void main() {
  group('SkuDetailsWrapper', () {
    test('converts from map', () {
      final SkuDetailsWrapper expected = dummySkuDetails;
      final SkuDetailsWrapper parsed =
          SkuDetailsWrapper.fromJson(buildSkuMap(expected));

      expect(parsed, equals(expected));
    });
  });

  group('SkuDetailsResponseWrapper', () {
    test('parsed from map', () {
      final BillingResponse responseCode = BillingResponse.ok;
      const String debugMessage = 'dummy message';
      final List<SkuDetailsWrapper> skusDetails = <SkuDetailsWrapper>[
        dummySkuDetails,
        dummySkuDetails
      ];
      BillingResultWrapper result = BillingResultWrapper(
          responseCode: responseCode, debugMessage: debugMessage);
      final SkuDetailsResponseWrapper expected = SkuDetailsResponseWrapper(
          billingResult: result, skuDetailsList: skusDetails);

      final SkuDetailsResponseWrapper parsed =
          SkuDetailsResponseWrapper.fromJson(<String, dynamic>{
        'billingResult': <String, dynamic>{
          'responseCode': BillingResponseConverter().toJson(responseCode),
          'debugMessage': debugMessage,
        },
        'skuDetailsList': <Map<String, dynamic>>[
          buildSkuMap(dummySkuDetails),
          buildSkuMap(dummySkuDetails)
        ]
      });

      expect(parsed.billingResult, equals(expected.billingResult));
      expect(parsed.skuDetailsList, containsAll(expected.skuDetailsList));
    });

    test('toProductDetails() should return correct Product object', () {
      final SkuDetailsWrapper wrapper =
          SkuDetailsWrapper.fromJson(buildSkuMap(dummySkuDetails));
      final GooglePlayProductDetails product =
          GooglePlayProductDetails.fromSkuDetails(wrapper);
      expect(product.title, wrapper.title);
      expect(product.description, wrapper.description);
      expect(product.id, wrapper.sku);
      expect(product.price, wrapper.price);
      expect(product.skuDetails, wrapper);
    });

    test('handles empty list of skuDetails', () {
      final BillingResponse responseCode = BillingResponse.error;
      const String debugMessage = 'dummy message';
      final List<SkuDetailsWrapper> skusDetails = <SkuDetailsWrapper>[];
      BillingResultWrapper billingResult = BillingResultWrapper(
          responseCode: responseCode, debugMessage: debugMessage);
      final SkuDetailsResponseWrapper expected = SkuDetailsResponseWrapper(
          billingResult: billingResult, skuDetailsList: skusDetails);

      final SkuDetailsResponseWrapper parsed =
          SkuDetailsResponseWrapper.fromJson(<String, dynamic>{
        'billingResult': <String, dynamic>{
          'responseCode': BillingResponseConverter().toJson(responseCode),
          'debugMessage': debugMessage,
        },
        'skuDetailsList': <Map<String, dynamic>>[]
      });

      expect(parsed.billingResult, equals(expected.billingResult));
      expect(parsed.skuDetailsList, containsAll(expected.skuDetailsList));
    });

    test('fromJson creates an object with default values', () {
      final SkuDetailsResponseWrapper skuDetails =
          SkuDetailsResponseWrapper.fromJson(<String, dynamic>{});
      expect(
          skuDetails.billingResult,
          equals(BillingResultWrapper(
              responseCode: BillingResponse.error,
              debugMessage: kInvalidBillingResultErrorMessage)));
      expect(skuDetails.skuDetailsList, isEmpty);
    });
  });

  group('BillingResultWrapper', () {
    test('fromJson on empty map creates an object with default values', () {
      final BillingResultWrapper billingResult =
          BillingResultWrapper.fromJson(<String, dynamic>{});
      expect(billingResult.debugMessage, kInvalidBillingResultErrorMessage);
      expect(billingResult.responseCode, BillingResponse.error);
    });

    test('fromJson on null creates an object with default values', () {
      final BillingResultWrapper billingResult =
          BillingResultWrapper.fromJson(null);
      expect(billingResult.debugMessage, kInvalidBillingResultErrorMessage);
      expect(billingResult.responseCode, BillingResponse.error);
    });
  });
}

Map<String, dynamic> buildSkuMap(SkuDetailsWrapper original) {
  return <String, dynamic>{
    'description': original.description,
    'freeTrialPeriod': original.freeTrialPeriod,
    'introductoryPrice': original.introductoryPrice,
    'introductoryPriceAmountMicros': original.introductoryPriceAmountMicros,
    'introductoryPriceCycles': original.introductoryPriceCycles,
    'introductoryPricePeriod': original.introductoryPricePeriod,
    'price': original.price,
    'priceAmountMicros': original.priceAmountMicros,
    'priceCurrencyCode': original.priceCurrencyCode,
    'priceCurrencySymbol': original.priceCurrencySymbol,
    'sku': original.sku,
    'subscriptionPeriod': original.subscriptionPeriod,
    'title': original.title,
    'type': original.type.toString().substring(8),
    'originalPrice': original.originalPrice,
    'originalPriceAmountMicros': original.originalPriceAmountMicros,
  };
}
