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

  final Map<String, dynamic> subJson = <String, dynamic>{
    'numberOfUnits': 0,
    'unit': 1
  };
  final Map<String, dynamic> discountJson = <String, dynamic>{
    'price': 1.0,
    'numberOfPeriods': 1,
    'paymentMode': 1,
    'subscriptionPeriod': subJson,
  };
  final Map<String, dynamic> productJson = <String, dynamic>{
    'productIdentifier': 'id',
    'localizedTitle': 'title',
    'localizedDescription': 'description',
    'currencyCode': 'USD',
    'downloadContentVersion': 'version',
    'subscriptionGroupIdentifier': 'com.group',
    'price': 1.0,
    'downloadable': true,
    'downloadContentLengths': <int>[1, 2],
    'subscriptionPeriod': subJson,
    'introductoryPrice': discountJson,
  };

  setUpAll(() {
    Channel.override = SystemChannels.platform_views;
    SystemChannels.platform_views.setMockMethodCallHandler(
        fakePlatformViewsController.fakePlatformViewsMethodHandler);
  });

  group('canMakePayments', () {
    test(
        'SKProductSubscriptionPeriodWrapper should have property values consistent with json',
        () {
      final SKProductSubscriptionPeriodWrapper wrapper =
          SKProductSubscriptionPeriodWrapper.fromJson(subJson);
      expect(wrapper.numberOfUnits, 0);
      expect(wrapper.unit, 1);
    });

    test(
        'SKProductSubscriptionPeriodWrapper should have properties to be null if json is empty',
        () {
      final SKProductSubscriptionPeriodWrapper wrapper =
          SKProductSubscriptionPeriodWrapper.fromJson(<String, dynamic>{});
      expect(wrapper.numberOfUnits, null);
      expect(wrapper.unit, null);
    });

    test(
        'SKProductDiscountWrapper should have property values consistent with json',
        () {
      final SKProductDiscountWrapper wrapper =
          SKProductDiscountWrapper.fromJson(discountJson);
      expect(wrapper.price, 1.0);
      expect(wrapper.numberOfPeriods, 1);
      expect(wrapper.paymentMode, 1);
      expect(wrapper.subscriptionPeriod.unit, 1);
      expect(wrapper.subscriptionPeriod.numberOfUnits, 0);
    });

    test(
        'SKProductDiscountWrapper should have properties to be null if json is empty',
        () {
      final SKProductDiscountWrapper wrapper =
          SKProductDiscountWrapper.fromJson(<String, dynamic>{});
      expect(wrapper.price, null);
      expect(wrapper.numberOfPeriods, null);
      expect(wrapper.paymentMode, null);
      expect(wrapper.subscriptionPeriod, null);
    });

    test('SKProductWrapper should have property values consistent with json',
        () {
      final SKProductWrapper wrapper = SKProductWrapper.fromJson(productJson);
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
        'SKProductDiscountWrapper should have properties to be null if json is empty',
        () {
      final SKProductWrapper wrapper =
          SKProductWrapper.fromJson(<String, dynamic>{});
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
        value: <Map<String, dynamic>>[productJson],
      );
      final List<Product> productList =
          await SKProductRequestWrapper.getProductList(
        <String>['identifier1'],
          );
          print(productList);
      expect(
        productList,
        isNotEmpty,
      );
      expect(
        productList.first.skProduct.currencyCode,
        'USD',
      );
      expect(
        productList.first.skProduct.currencyCode,
        isNot('USDA'),
      );
    });
  });
}
