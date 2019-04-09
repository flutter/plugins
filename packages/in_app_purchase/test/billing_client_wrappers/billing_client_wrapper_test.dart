// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/services.dart';

import 'package:in_app_purchase/billing_client_wrappers.dart';
import 'package:in_app_purchase/src/billing_client_wrappers/enum_converters.dart';
import 'package:in_app_purchase/src/channel.dart';
import '../stub_in_app_purchase_platform.dart';
import 'sku_details_wrapper_test.dart';
import 'purchase_wrapper_test.dart';

void main() {
  final StubInAppPurchasePlatform stubPlatform = StubInAppPurchasePlatform();
  BillingClient billingClient;

  setUpAll(() =>
      channel.setMockMethodCallHandler(stubPlatform.fakeMethodCallHandler));

  setUp(() {
    billingClient = BillingClient((PurchasesResultWrapper _) {});
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
          value: BillingResponseConverter().toJson(BillingResponse.ok));
      expect(
          await billingClient.startConnection(
              onBillingServiceDisconnected: () {}),
          equals(BillingResponse.ok));
    });

    test('passes handle to onBillingServiceDisconnected', () async {
      final String methodName =
          'BillingClient#startConnection(BillingClientStateListener)';
      stubPlatform.addResponse(
          name: methodName,
          value: BillingResponseConverter().toJson(BillingResponse.ok));
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
      final BillingResponse responseCode = BillingResponse.developerError;
      stubPlatform.addResponse(name: queryMethodName, value: <dynamic, dynamic>{
        'responseCode': BillingResponseConverter().toJson(responseCode),
        'skuDetailsList': <Map<String, dynamic>>[]
      });

      final SkuDetailsResponseWrapper response = await billingClient
          .querySkuDetails(
              skuType: SkuType.inapp, skusList: <String>['invalid']);

      expect(response.responseCode, equals(responseCode));
      expect(response.skuDetailsList, isEmpty);
    });

    test('returns SkuDetailsResponseWrapper', () async {
      final BillingResponse responseCode = BillingResponse.ok;
      stubPlatform.addResponse(name: queryMethodName, value: <String, dynamic>{
        'responseCode': BillingResponseConverter().toJson(responseCode),
        'skuDetailsList': <Map<String, dynamic>>[buildSkuMap(dummySkuDetails)]
      });

      final SkuDetailsResponseWrapper response = await billingClient
          .querySkuDetails(
              skuType: SkuType.inapp, skusList: <String>['invalid']);

      expect(response.responseCode, equals(responseCode));
      expect(response.skuDetailsList, contains(dummySkuDetails));
    });
  });

  group('launchBillingFlow', () {
    final String launchMethodName =
        'BillingClient#launchBillingFlow(Activity, BillingFlowParams)';

    test('serializes and deserializes data', () async {
      final BillingResponse sentCode = BillingResponse.ok;
      stubPlatform.addResponse(
          name: launchMethodName,
          value: BillingResponseConverter().toJson(sentCode));
      final SkuDetailsWrapper skuDetails = dummySkuDetails;
      final String accountId = "hashedAccountId";

      final BillingResponse receivedCode = await billingClient
          .launchBillingFlow(sku: skuDetails.sku, accountId: accountId);

      expect(receivedCode, equals(sentCode));
      Map<dynamic, dynamic> arguments =
          stubPlatform.previousCallMatching(launchMethodName).arguments;
      expect(arguments['sku'], equals(skuDetails.sku));
      expect(arguments['accountId'], equals(accountId));
    });

    test('handles null accountId', () async {
      final BillingResponse sentCode = BillingResponse.ok;
      stubPlatform.addResponse(
          name: launchMethodName,
          value: BillingResponseConverter().toJson(sentCode));
      final SkuDetailsWrapper skuDetails = dummySkuDetails;

      final BillingResponse receivedCode =
          await billingClient.launchBillingFlow(sku: skuDetails.sku);

      expect(receivedCode, equals(sentCode));
      Map<dynamic, dynamic> arguments =
          stubPlatform.previousCallMatching(launchMethodName).arguments;
      expect(arguments['sku'], equals(skuDetails.sku));
      expect(arguments['accountId'], isNull);
    });
  });

  group('queryPurchases', () {
    const String queryPurchasesMethodName =
        'BillingClient#queryPurchases(String)';

    test('serializes and deserializes data', () async {
      final BillingResponse expectedCode = BillingResponse.ok;
      final List<PurchaseWrapper> expectedList = <PurchaseWrapper>[
        dummyPurchase
      ];
      stubPlatform
          .addResponse(name: queryPurchasesMethodName, value: <String, dynamic>{
        'responseCode': BillingResponseConverter().toJson(expectedCode),
        'purchasesList': expectedList
            .map((PurchaseWrapper purchase) => buildPurchaseMap(purchase))
            .toList(),
      });

      final PurchasesResultWrapper response =
          await billingClient.queryPurchases(SkuType.inapp);

      expect(response.responseCode, equals(expectedCode));
      expect(response.purchasesList, equals(expectedList));
    });

    test('checks for null params', () async {
      expect(() => billingClient.queryPurchases(null), throwsAssertionError);
    });

    test('handles empty purchases', () async {
      final BillingResponse expectedCode = BillingResponse.userCanceled;
      stubPlatform
          .addResponse(name: queryPurchasesMethodName, value: <String, dynamic>{
        'responseCode': BillingResponseConverter().toJson(expectedCode),
        'purchasesList': [],
      });

      final PurchasesResultWrapper response =
          await billingClient.queryPurchases(SkuType.inapp);

      expect(response.responseCode, equals(expectedCode));
      expect(response.purchasesList, isEmpty);
    });
  });

  group('queryPurchaseHistory', () {
    const String queryPurchaseHistoryMethodName =
        'BillingClient#queryPurchaseHistoryAsync(String, PurchaseHistoryResponseListener)';

    test('serializes and deserializes data', () async {
      final BillingResponse expectedCode = BillingResponse.ok;
      final List<PurchaseWrapper> expectedList = <PurchaseWrapper>[
        dummyPurchase
      ];
      stubPlatform.addResponse(
          name: queryPurchaseHistoryMethodName,
          value: <String, dynamic>{
            'responseCode': BillingResponseConverter().toJson(expectedCode),
            'purchasesList': expectedList
                .map((PurchaseWrapper purchase) => buildPurchaseMap(purchase))
                .toList(),
          });

      final PurchasesResultWrapper response =
          await billingClient.queryPurchaseHistory(SkuType.inapp);

      expect(response.responseCode, equals(expectedCode));
      expect(response.purchasesList, equals(expectedList));
    });

    test('checks for null params', () async {
      expect(
          () => billingClient.queryPurchaseHistory(null), throwsAssertionError);
    });

    test('handles empty purchases', () async {
      final BillingResponse expectedCode = BillingResponse.userCanceled;
      stubPlatform.addResponse(
          name: queryPurchaseHistoryMethodName,
          value: <String, dynamic>{
            'responseCode': BillingResponseConverter().toJson(expectedCode),
            'purchasesList': [],
          });

      final PurchasesResultWrapper response =
          await billingClient.queryPurchaseHistory(SkuType.inapp);

      expect(response.responseCode, equals(expectedCode));
      expect(response.purchasesList, isEmpty);
    });
  });

  group('consume purchases', () {
    const String consumeMethodName =
        'BillingClient#consumeAsync(String, ConsumeResponseListener)';
    test('consume purchase async success', () async {
      final BillingResponse expectedCode = BillingResponse.ok;
      stubPlatform.addResponse(
          name: consumeMethodName,
          value: BillingResponseConverter().toJson(expectedCode));

      final BillingResponse responseCode =
          await billingClient.consumeAsync('dummy token');

      expect(responseCode, equals(expectedCode));
    });
  });
}
