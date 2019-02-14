// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:test/test.dart';

import 'package:flutter/widgets.dart';
import 'package:in_app_purchase/billing_client_wrappers.dart';
import 'package:in_app_purchase/src/billing_client_wrappers/enum_converters.dart';
import 'package:in_app_purchase/src/in_app_purchase_connection/google_play_connection.dart';
import 'package:in_app_purchase/src/channel.dart';
import '../stub_in_app_purchase_platform.dart';
import 'package:in_app_purchase/src/in_app_purchase_connection/product_details.dart';
import '../billing_client_wrappers/sku_details_wrapper_test.dart';

void main() {
  final StubInAppPurchasePlatform stubPlatform = StubInAppPurchasePlatform();
  GooglePlayConnection connection;
  const String startConnectionCall =
      'BillingClient#startConnection(BillingClientStateListener)';
  const String endConnectionCall = 'BillingClient#endConnection()';

  setUpAll(() =>
      channel.setMockMethodCallHandler(stubPlatform.fakeMethodCallHandler));

  setUp(() {
    WidgetsFlutterBinding.ensureInitialized();
    stubPlatform.addResponse(
        name: startConnectionCall,
        value: BillingResponseConverter().toJson(BillingResponse.ok));
    stubPlatform.addResponse(name: endConnectionCall, value: null);
    connection = GooglePlayConnection.instance;
  });

  tearDown(() {
    stubPlatform.reset();
    GooglePlayConnection.reset();
  });

  group('connection management', () {
    test('connects on initialization', () {
      expect(stubPlatform.countPreviousCalls(startConnectionCall), equals(1));
    });

    test('disconnects on app pause', () {
      expect(stubPlatform.countPreviousCalls(endConnectionCall), equals(0));
      connection.didChangeAppLifecycleState(AppLifecycleState.paused);
      expect(stubPlatform.countPreviousCalls(endConnectionCall), equals(1));
    });

    test('reconnects on app resume', () {
      expect(stubPlatform.countPreviousCalls(startConnectionCall), equals(1));
      connection.didChangeAppLifecycleState(AppLifecycleState.resumed);
      expect(stubPlatform.countPreviousCalls(startConnectionCall), equals(2));
    });
  });

  group('isAvailable', () {
    test('true', () async {
      stubPlatform.addResponse(name: 'BillingClient#isReady()', value: true);
      expect(await connection.isAvailable(), isTrue);
    });

    test('false', () async {
      stubPlatform.addResponse(name: 'BillingClient#isReady()', value: false);
      expect(await connection.isAvailable(), isFalse);
    });
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

      final ProductDetailsResponse response =
          await connection.queryProductDetails(<String>[''].toSet());
      expect(response.productDetails, isEmpty);
    });

    test('should get correct product details', () async {
      final BillingResponse responseCode = BillingResponse.ok;
      stubPlatform.addResponse(name: queryMethodName, value: <String, dynamic>{
        'responseCode': BillingResponseConverter().toJson(responseCode),
        'skuDetailsList': <Map<String, dynamic>>[buildSkuMap(dummyWrapper)]
      });
      // Since queryProductDetails makes 2 platform method calls (one for each SkuType), the result will contain 2 dummyWrapper instead
      // of 1.
      final ProductDetailsResponse response =
          await connection.queryProductDetails(<String>['valid'].toSet());
      expect(response.productDetails.first.title, dummyWrapper.title);
      expect(
          response.productDetails.first.description, dummyWrapper.description);
      expect(response.productDetails.first.price, dummyWrapper.price);
    });

    test('should get the correct notFoundIDs', () async {
      final BillingResponse responseCode = BillingResponse.ok;
      stubPlatform.addResponse(name: queryMethodName, value: <String, dynamic>{
        'responseCode': BillingResponseConverter().toJson(responseCode),
        'skuDetailsList': <Map<String, dynamic>>[buildSkuMap(dummyWrapper)]
      });
      // Since queryProductDetails makes 2 platform method calls (one for each SkuType), the result will contain 2 dummyWrapper instead
      // of 1.
      final ProductDetailsResponse response =
          await connection.queryProductDetails(<String>['invalid'].toSet());
      expect(response.notFoundIDs.first, 'invalid');
    });
  });
}
