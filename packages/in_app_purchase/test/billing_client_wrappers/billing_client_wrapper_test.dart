// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:test/test.dart';
import 'package:flutter/services.dart';

import 'package:in_app_purchase/billing_client_wrappers.dart';
import 'package:in_app_purchase/src/channel.dart';
import '../stub_in_app_purchase_platform.dart';
import 'sku_details_wrapper_test.dart';

void main() {
  final StubInAppPurchasePlatform stubPlatform = StubInAppPurchasePlatform();
  BillingClient billingClient;
  setUpAll(() =>
      channel.setMockMethodCallHandler(stubPlatform.fakeMethodCallHandler));

  setUp(() {
    billingClient = BillingClient();
    stubPlatform.reset();
  });

  group('isReady', () {
    test('true', () async {
      stubPlatform.addResponse(name: 'BillingClient#isReady()', value: true);
      expect(await billingClient.isReady(), isTrue);
    });

    test('false', () async {
      stubPlatform.addResponse(name: 'BillingClient#isReady()', value: false);
      expect(await billingClient.isReady(), isFalse);
    });
  });

  group('startConnection', () {
    test('returns BillingResponse', () async {
      stubPlatform.addResponse(
          name: 'BillingClient#startConnection(BillingClientStateListener)',
          value: int.parse(BillingResponse.OK.toString()));
      expect(
          await billingClient.startConnection(
              onBillingServiceDisconnected: () {}),
          equals(BillingResponse.OK));
    });

    test('passes handle to onBillingServiceDisconnected', () async {
      final String methodName =
          'BillingClient#startConnection(BillingClientStateListener)';
      stubPlatform.addResponse(
          name: methodName, value: int.parse(BillingResponse.OK.toString()));
      await billingClient.startConnection(onBillingServiceDisconnected: () {});
      final MethodCall call = stubPlatform.previousCallMatching(methodName);
      expect(call.arguments, equals(<dynamic, dynamic>{'handle': 0}));
    });
  });

  test('endConnection', () async {
    final String endConnectionName = 'BillingClient#endConnection()';
    expect(stubPlatform.countPreviousCalls(endConnectionName), equals(0));
    stubPlatform.addResponse(name: endConnectionName, value: null);
    await billingClient.endConnection();
    expect(stubPlatform.countPreviousCalls(endConnectionName), equals(1));
  });

  group('querySkuDetails', () {
    final String queryMethodName =
        'BillingClient#querySkuDetailsAsync(SkuDetailsParams, SkuDetailsResponseListener)';

    test('handles empty skuDetails', () async {
      final BillingResponse responseCode = BillingResponse.DEVELOPER_ERROR;
      stubPlatform.addResponse(name: queryMethodName, value: <dynamic, dynamic>{
        'responseCode': int.parse(responseCode.toString()),
        'skuDetailsList': <Map<String, dynamic>>[]
      });

      final SkuDetailsResponseWrapper response = await billingClient
          .querySkuDetails(
              skuType: SkuType.INAPP, skusList: <String>['invalid']);

      expect(response.responseCode, equals(responseCode));
      expect(response.skuDetailsList, isEmpty);
    });

    test('returns SkuDetailsResponseWrapper', () async {
      final BillingResponse responseCode = BillingResponse.OK;
      stubPlatform.addResponse(name: queryMethodName, value: <String, dynamic>{
        'responseCode': int.parse(responseCode.toString()),
        'skuDetailsList': <Map<String, dynamic>>[buildSkuMap(dummyWrapper)]
      });

      final SkuDetailsResponseWrapper response = await billingClient
          .querySkuDetails(
              skuType: SkuType.INAPP, skusList: <String>['invalid']);

      expect(response.responseCode, equals(responseCode));
      expect(response.skuDetailsList, contains(dummyWrapper));
    });
  });
}
