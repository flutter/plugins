// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:test/test.dart';
import 'package:in_app_purchase/src/store_kit_wrappers/sk_product_wrapper.dart';
import 'package:in_app_purchase/src/in_app_purchase_connection/product_details.dart';

void main() {
  final Map<String, dynamic> localeMap = <String, dynamic>{
    'currencySymbol': '\$'
  };
  final Map<String, dynamic> subMap = <String, dynamic>{
    'numberOfUnits': 1,
    'unit': 2
  };
  final Map<String, dynamic> discountMap = <String, dynamic>{
    'price': 1.0,
    'priceLocale': localeMap,
    'numberOfPeriods': 1,
    'paymentMode': 2,
    'subscriptionPeriod': subMap,
  };
  final Map<String, dynamic> productMap = <String, dynamic>{
    'productIdentifier': 'id',
    'localizedTitle': 'title',
    'localizedDescription': 'description',
    'priceLocale': localeMap,
    'downloadContentVersion': 'version',
    'subscriptionGroupIdentifier': 'com.group',
    'price': 1.0,
    'downloadable': true,
    'downloadContentLengths': <int>[1, 2],
    'subscriptionPeriod': subMap,
    'introductoryPrice': discountMap,
  };

  final Map<String, List<dynamic>> productResponseMap = <String, List<dynamic>>{
    'products': <Map<String, dynamic>>[productMap],
    'invalidProductIdentifiers': <String>['123'],
  };

  group('product request wrapper test', () {
    void testMatchLocale(
        PriceLocaleWrapper wrapper, Map<String, dynamic> localeMap) {
      expect(wrapper.currencySymbol, localeMap['currencySymbol']);
    }

    test(
        'SKProductSubscriptionPeriodWrapper should have property values consistent with map',
        () {
      final SKProductSubscriptionPeriodWrapper wrapper =
          SKProductSubscriptionPeriodWrapper.fromJson(subMap);
      expect(wrapper.numberOfUnits, subMap['numberOfUnits']);
      expect(wrapper.unit, SubscriptionPeriodUnit.values[subMap['unit']]);
    });

    test(
        'SKProductSubscriptionPeriodWrapper should have properties to be null if map is empty',
        () {
      final SKProductSubscriptionPeriodWrapper wrapper =
          SKProductSubscriptionPeriodWrapper.fromJson(<String, dynamic>{});
      expect(wrapper.numberOfUnits, null);
      expect(wrapper.unit, null);
    });

    test(
        'SKProductDiscountWrapper should have property values consistent with map',
        () {
      final SKProductDiscountWrapper wrapper =
          SKProductDiscountWrapper.fromJson(discountMap);
      expect(wrapper.price, discountMap['price']);
      testMatchLocale(wrapper.priceLocale, discountMap['priceLocale']);
      expect(wrapper.numberOfPeriods, discountMap['numberOfPeriods']);
      expect(wrapper.paymentMode,
          ProductDiscountPaymentMode.values[discountMap['paymentMode']]);
      expect(
          wrapper.subscriptionPeriod.unit,
          SubscriptionPeriodUnit
              .values[discountMap['subscriptionPeriod']['unit']]);
      expect(wrapper.subscriptionPeriod.numberOfUnits,
          discountMap['subscriptionPeriod']['numberOfUnits']);
    });

    test(
        'SKProductDiscountWrapper should have properties to be null if map is empty',
        () {
      final SKProductDiscountWrapper wrapper =
          SKProductDiscountWrapper.fromJson(<String, dynamic>{});
      expect(wrapper.price, null);
      expect(wrapper.priceLocale, null);
      expect(wrapper.numberOfPeriods, null);
      expect(wrapper.paymentMode, null);
      expect(wrapper.subscriptionPeriod, null);
    });

    void testMatchingProductMap(
        SKProductWrapper wrapper, Map<String, dynamic> productMap) {
      expect(wrapper.productIdentifier, productMap['productIdentifier']);
      expect(wrapper.localizedTitle, productMap['localizedTitle']);
      testMatchLocale(wrapper.priceLocale, productMap['priceLocale']);
      expect(wrapper.localizedDescription, productMap['localizedDescription']);
      expect(
          wrapper.downloadContentVersion, productMap['downloadContentVersion']);
      expect(wrapper.subscriptionGroupIdentifier,
          productMap['subscriptionGroupIdentifier']);
      expect(wrapper.price, productMap['price']);
      expect(wrapper.downloadable, productMap['downloadable']);
      expect(
          wrapper.downloadContentLengths, productMap['downloadContentLengths']);
      expect(wrapper.introductoryPrice.price,
          productMap['introductoryPrice']['price']);
      expect(wrapper.introductoryPrice.numberOfPeriods,
          productMap['introductoryPrice']['numberOfPeriods']);
      expect(
          wrapper.introductoryPrice.paymentMode,
          ProductDiscountPaymentMode
              .values[productMap['introductoryPrice']['paymentMode']]);
      expect(
          wrapper.introductoryPrice.subscriptionPeriod.unit,
          SubscriptionPeriodUnit.values[productMap['introductoryPrice']
              ['subscriptionPeriod']['unit']]);
      expect(
          wrapper.introductoryPrice.subscriptionPeriod.numberOfUnits,
          productMap['introductoryPrice']['subscriptionPeriod']
              ['numberOfUnits']);
      expect(
          wrapper.subscriptionPeriod.unit,
          SubscriptionPeriodUnit
              .values[productMap['subscriptionPeriod']['unit']]);
      expect(wrapper.subscriptionPeriod.numberOfUnits,
          productMap['subscriptionPeriod']['numberOfUnits']);
      expect(wrapper.price, discountMap['price']);
    }

    test('SKProductWrapper should have property values consistent with map',
        () {
      final SKProductWrapper wrapper = SKProductWrapper.fromJson(productMap);
      testMatchingProductMap(wrapper, productMap);
    });

    test('SKProductWrapper should have properties to be null if map is empty',
        () {
      final SKProductWrapper wrapper =
          SKProductWrapper.fromJson(<String, dynamic>{});
      expect(wrapper.productIdentifier, null);
      expect(wrapper.localizedTitle, null);
      expect(wrapper.localizedDescription, null);
      expect(wrapper.priceLocale, null);
      expect(wrapper.downloadContentVersion, null);
      expect(wrapper.subscriptionGroupIdentifier, null);
      expect(wrapper.price, null);
      expect(wrapper.downloadable, null);
      expect(wrapper.subscriptionPeriod, null);
    });

    test('toProductDetails() should return correct Product object', () {
      final SKProductWrapper wrapper = SKProductWrapper.fromJson(productMap);
      final ProductDetails product = wrapper.toProductDetails();
      expect(product.title, wrapper.localizedTitle);
      expect(product.description, wrapper.localizedDescription);
      expect(product.id, wrapper.productIdentifier);
      expect(product.price,
          wrapper.priceLocale.currencySymbol + wrapper.price.toString());
    });

    test('SKProductResponse wrapper should match', () {
      final SkProductResponseWrapper wrapper =
          SkProductResponseWrapper.fromJson(productResponseMap);
      testMatchingProductMap(
          wrapper.products[0], productResponseMap['products'][0]);
      expect(wrapper.invalidProductIdentifiers,
          productResponseMap['invalidProductIdentifiers']);
    });
    test('SKProductResponse wrapper should default to empty list', () {
      final Map<String, List<dynamic>> productResponseMapEmptyList =
          <String, List<dynamic>>{
        'products': <Map<String, dynamic>>[],
        'invalidProductIdentifiers': <String>[],
      };
      final SkProductResponseWrapper wrapper =
          SkProductResponseWrapper.fromJson(productResponseMapEmptyList);
      expect(wrapper.products.length, 0);
      expect(wrapper.invalidProductIdentifiers.length, 0);
    });

    test('LocaleWrapper should have property values consistent with map', () {
      final PriceLocaleWrapper wrapper = PriceLocaleWrapper.fromJson(localeMap);
      testMatchLocale(wrapper, localeMap);
    });
  });
}
