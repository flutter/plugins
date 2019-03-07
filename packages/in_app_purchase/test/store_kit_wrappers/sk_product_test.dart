// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:test/test.dart';
import 'package:in_app_purchase/src/store_kit_wrappers/sk_product_wrapper.dart';
import 'package:in_app_purchase/src/in_app_purchase_connection/product_details.dart';
import 'sk_test_stub_objects.dart';

void main() {

  group('product request wrapper test', () {

    test(
        'SKProductSubscriptionPeriodWrapper should have property values consistent with map',
        () {
      final SKProductSubscriptionPeriodWrapper wrapper =
          SKProductSubscriptionPeriodWrapper.fromJson(buildSubscriptionPeriodMap(dummySubscription));
      expect(wrapper, equals(dummySubscription));
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
          SKProductDiscountWrapper.fromJson(buildDiscountMap(dummyDiscount));
      expect(wrapper, equals(dummyDiscount));
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

    test('SKProductWrapper should have property values consistent with map',
        () {
      final SKProductWrapper wrapper = SKProductWrapper.fromJson(buildProductMap(dummyProductWrapper));
      expect(wrapper, equals(dummyProductWrapper));
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
      final SKProductWrapper wrapper = SKProductWrapper.fromJson(buildProductMap(dummyProductWrapper));
      final ProductDetails product = wrapper.toProductDetails();
      expect(product.title, wrapper.localizedTitle);
      expect(product.description, wrapper.localizedDescription);
      expect(product.id, wrapper.productIdentifier);
      expect(product.price,
          wrapper.priceLocale.currencySymbol + wrapper.price.toString());
    });

    test('SKProductResponse wrapper should match', () {
      final SkProductResponseWrapper wrapper =
          SkProductResponseWrapper.fromJson(buildProductResponseMap(dummyProductResponseWrapper));
      expect(wrapper, equals(dummyProductResponseWrapper));
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
      final PriceLocaleWrapper wrapper = PriceLocaleWrapper.fromJson(buildLocaleMap(dummyLocale));
      expect(wrapper, equals(dummyLocale));
    });
  });
}
