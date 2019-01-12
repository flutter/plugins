// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:test/test.dart';
import 'package:in_app_purchase/src/store_kit_wrappers/sk_product_request_wrapper.dart';

void main() {
  setUpAll(() {});

  setUp(() {});

  test(
      'SKProductSubscriptionPeriodWrapper should have property values consistent with json',
      () {
    final Map<dynamic, dynamic> json = <dynamic, dynamic>{
      'numberOfUnits': 0,
      'unit': 1
    };
    final SKProductSubscriptionPeriodWrapper wrapper =
        SKProductSubscriptionPeriodWrapper.fromJson(json);
    expect(wrapper.numberOfUnits, 0);
    expect(wrapper.unit, 1);
  });

  test(
      'SKProductSubscriptionPeriodWrapper should have properties to be null if json is empty',
      () {
    final SKProductSubscriptionPeriodWrapper wrapper =
        SKProductSubscriptionPeriodWrapper.fromJson(<dynamic, dynamic>{});
    expect(wrapper.numberOfUnits, null);
    expect(wrapper.unit, null);
  });

  test(
      'SKProductDiscountWrapper should have property values consistent with json',
      () {
    final Map<dynamic, dynamic> subJson = <dynamic, dynamic>{
      'numberOfUnits': 0,
      'unit': 1
    };
    final Map<dynamic, dynamic> json = <dynamic, dynamic>{
      'price': 1.0,
      'numberOfPeriods': 1,
      'paymentMode': 1,
      'subscriptionPeriod': subJson,
    };
    final SKProductDiscountWrapper wrapper =
        SKProductDiscountWrapper.fromJson(json);
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
        SKProductDiscountWrapper.fromJson(<dynamic, dynamic>{});
    expect(wrapper.price, null);
    expect(wrapper.numberOfPeriods, null);
    expect(wrapper.paymentMode, null);
    expect(wrapper.subscriptionPeriod, null);
  });

  test('SKProductWrapper should have property values consistent with json', () {
    final Map<dynamic, dynamic> subJson = <dynamic, dynamic>{
      'numberOfUnits': 0,
      'unit': 1
    };
    final Map<dynamic, dynamic> discountJson = <dynamic, dynamic>{
      'price': 1.0,
      'numberOfPeriods': 1,
      'paymentMode': 1,
      'subscriptionPeriod': subJson,
    };
    final Map<dynamic, dynamic> json = <dynamic, dynamic>{
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

    final SKProductWrapper wrapper = SKProductWrapper.fromJson(json);
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
        SKProductWrapper.fromJson(<dynamic, dynamic>{});
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
}
