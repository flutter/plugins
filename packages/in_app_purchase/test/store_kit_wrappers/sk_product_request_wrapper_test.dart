// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:test/test.dart';
import 'package:in_app_purchase/src/store_kit_wrappers/sk_product_request_wrapper.dart';
import 'package:in_app_purchase/src/channel.dart';
import 'package:flutter/services.dart';
import 'package:in_app_purchase/src/in_app_purchase_connection/product.dart';
import '../fake_platform_views_controller.dart';

void main() {
  final FakePlatformViewsController fakePlatformViewsController =
      FakePlatformViewsController();

  final Map<String, dynamic> subMap = <String, dynamic>{
    'numberOfUnits': 0,
    'unit': 1
  };
  final Map<String, dynamic> discountMap = <String, dynamic>{
    'price': 1.0,
    'numberOfPeriods': 1,
    'paymentMode': 1,
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

  setUpAll(() {
    Channel.override = SystemChannels.platform_views;
    SystemChannels.platform_views.setMockMethodCallHandler(
        fakePlatformViewsController.fakePlatformViewsMethodHandler);
  });

  group('canMakePayments', () {
    test(
        'SKProductSubscriptionPeriodWrapper should have property values consistent with map',
        () {
      final SKProductSubscriptionPeriodWrapper wrapper =
          SKProductSubscriptionPeriodWrapper.fromMap(subMap);
      expect(wrapper.numberOfUnits, 0);
      expect(wrapper.unit, 1);
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
      expect(wrapper.price, 1.0);
      expect(wrapper.numberOfPeriods, 1);
      expect(wrapper.paymentMode, 1);
      expect(wrapper.subscriptionPeriod.unit, 1);
      expect(wrapper.subscriptionPeriod.numberOfUnits, 0);
    });

    test(
        'SKProductDiscountWrapper should have properties to be null if map is empty',
        () {
      final SKProductDiscountWrapper wrapper =
          SKProductDiscountWrapper.fromMap(<String, dynamic>{});
      expect(wrapper.price, null);
      expect(wrapper.numberOfPeriods, null);
      expect(wrapper.paymentMode, null);
      expect(wrapper.subscriptionPeriod, null);
    });

    test('SKProductWrapper should have property values consistent with map',
        () {
      final SKProductWrapper wrapper = SKProductWrapper.fromMap(productMap);
      expect(wrapper.productIdentifier, 'id');
      expect(wrapper.localizedTitle, 'title');
      expect(wrapper.localizedDescription, 'description');
      expect(wrapper.currencyCode, 'USD');
      expect(wrapper.downloadContentVersion, 'version');
      expect(wrapper.subscriptionGroupIdentifier, 'com.group');
      expect(wrapper.price, 1.0);
      expect(wrapper.downloadable, true);
      expect(wrapper.downloadContentLengths, <int>[1, 2]);
      expect(wrapper.introductoryPrice.price, 1.0);
      expect(wrapper.introductoryPrice.numberOfPeriods, 1);
      expect(wrapper.introductoryPrice.paymentMode, 1);
      expect(wrapper.introductoryPrice.subscriptionPeriod.unit, 1);
      expect(wrapper.introductoryPrice.subscriptionPeriod.numberOfUnits, 0);
      expect(wrapper.subscriptionPeriod.unit, 1);
      expect(wrapper.subscriptionPeriod.numberOfUnits, 0);
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
      fakePlatformViewsController.addCall(
        name: 'getProductList',
        value: <Map<String, dynamic>>[productMap],
      );
      final List<SKProductWrapper> productList =
          await SKProductRequestWrapper.getSKProductList(
        <String>['identifier1'],
          );
          print(productList);
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
