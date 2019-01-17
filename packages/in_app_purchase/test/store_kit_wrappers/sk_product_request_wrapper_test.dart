// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:test/test.dart';
import 'package:in_app_purchase/src/store_kit_wrappers/sk_product_wrapper.dart';
import 'package:in_app_purchase/src/channel.dart';
import '../stub_in_app_purchase_platform.dart';

void main() {
  final StubInAppPurchasePlatform stubPlatform = StubInAppPurchasePlatform();

  final Map<String, dynamic> subMap = <String, dynamic>{
    'numberOfUnits': 0,
    'unit': 2
  };
  final Map<String, dynamic> discountMap = <String, dynamic>{
    'price': 1.0,
    'currencyCode': 'USD',
    'numberOfPeriods': 1,
    'paymentMode': 2,
    'subscriptionPeriod': subMap,
  };
  final Map<String, dynamic> productMap = <String, dynamic>{
    'productIdentifier': 'id',
    'localizedTitle': 'title',
    'localizedDescription': 'description',
    'currencyCode': 'USD',
    'downloadContentVersion': 'version',
    'subscriptionGroupIdentifier': 'com.group',
    'price': 1.0,
    'downloadable': true,
    'downloadContentLengths': <int>[1, 2],
    'subscriptionPeriod': subMap,
    'introductoryPrice': discountMap,
  };

  setUpAll(() =>
      channel.setMockMethodCallHandler(stubPlatform.fakeMethodCallHandler));

  group('canMakePayments', () {
    test(
        'SKProductSubscriptionPeriodWrapper should have property values consistent with map',
        () {
      final SKProductSubscriptionPeriodWrapper wrapper =
          SKProductSubscriptionPeriodWrapper.fromMap(subMap);
      expect(wrapper.numberOfUnits, subMap['numberOfUnits']);
      expect(wrapper.unit, SubscriptionPeriodUnit.values[subMap['unit']]);
    });

    test(
        'SKProductSubscriptionPeriodWrapper should have properties to be null if map is empty',
        () {
      final SKProductSubscriptionPeriodWrapper wrapper =
          SKProductSubscriptionPeriodWrapper.fromMap(<String, dynamic>{});
      expect(wrapper.numberOfUnits, null);
      expect(wrapper.unit, null);
    });

    test(
        'SKProductDiscountWrapper should have property values consistent with map',
        () {
      final SKProductDiscountWrapper wrapper =
          SKProductDiscountWrapper.fromMap(discountMap);
      expect(wrapper.price, discountMap['price']);
      expect(wrapper.currencyCode, discountMap['currencyCode']);
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
          SKProductDiscountWrapper.fromMap(<String, dynamic>{});
      expect(wrapper.price, null);
      expect(wrapper.currencyCode, null);
      expect(wrapper.numberOfPeriods, null);
      expect(wrapper.paymentMode, null);
      expect(wrapper.subscriptionPeriod, null);
    });

    test('SKProductWrapper should have property values consistent with map',
        () {
      final SKProductWrapper wrapper = SKProductWrapper.fromMap(productMap);
      expect(wrapper.productIdentifier, productMap['productIdentifier']);
      expect(wrapper.localizedTitle, productMap['localizedTitle']);
      expect(wrapper.localizedDescription, productMap['localizedDescription']);
      expect(wrapper.currencyCode, productMap['currencyCode']);
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
    });

    test(
        'SKProductDiscountWrapper should have properties to be null if map is empty',
        () {
      final SKProductWrapper wrapper =
          SKProductWrapper.fromMap(<String, dynamic>{});
      expect(wrapper.productIdentifier, null);
      expect(wrapper.localizedTitle, null);
      expect(wrapper.localizedDescription, null);
      expect(wrapper.currencyCode, null);
      expect(wrapper.downloadContentVersion, null);
      expect(wrapper.subscriptionGroupIdentifier, null);
      expect(wrapper.price, null);
      expect(wrapper.downloadable, null);
      expect(wrapper.subscriptionPeriod, null);
    });
  });

  group('getProductList api', () {
    test('platform call should get result', () async {
      stubPlatform.addResponse(
        name: 'getProductList',
        value: <Map<String, dynamic>>[productMap],
      );
      final List<SKProductWrapper> productList =
          await SKProductRequestHandler.getSKProductList(
        <String>['identifier1'],
      );
      expect(
        productList,
        isNotEmpty,
      );
      expect(
        productList.first.currencyCode,
        'USD',
      );
      expect(
        productList.first.currencyCode,
        isNot('USDA'),
      );
    });
  });
}
