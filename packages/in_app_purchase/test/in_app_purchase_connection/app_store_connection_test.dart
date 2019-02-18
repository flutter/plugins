// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:test/test.dart';

import 'package:in_app_purchase/src/channel.dart';
import 'package:in_app_purchase/src/in_app_purchase_connection/app_store_connection.dart';
import '../stub_in_app_purchase_platform.dart';
import 'package:in_app_purchase/src/in_app_purchase_connection/product_details.dart';

void main() {
  final StubInAppPurchasePlatform stubPlatform = StubInAppPurchasePlatform();

  setUpAll(() =>
      channel.setMockMethodCallHandler(stubPlatform.fakeMethodCallHandler));

  group('isAvailable', () {
    test('true', () async {
      stubPlatform.addResponse(
          name: '-[SKPaymentQueue canMakePayments:]', value: true);
      expect(await AppStoreConnection.instance.isAvailable(), isTrue);
    });

    test('false', () async {
      stubPlatform.addResponse(
          name: '-[SKPaymentQueue canMakePayments:]', value: false);
      expect(await AppStoreConnection.instance.isAvailable(), isFalse);
    });
  });

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
    'localizedTitle': 'splash coin',
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
    'invalidProductIdentifiers': <String>['567'],
  };

  group('query product list', () {
    test('should get product list', () async {
      stubPlatform.addResponse(
          name: '-[InAppPurchasePlugin startProductRequest:result:]',
          value: productResponseMap);
      final AppStoreConnection connection = AppStoreConnection();
      final ProductDetailsResponse response =
          await connection.queryProductDetails(<String>['123'].toSet());
      List<ProductDetails> products = response.productDetails;
      expect(
        products,
        isNotEmpty,
      );
      expect(
        products.first.title,
        'splash coin',
      );
      expect(
        products.first.title,
        isNot('splash coins'),
      );
    });

    test('should get correct not found identifiers', () async {
      stubPlatform.addResponse(
          name: '-[InAppPurchasePlugin startProductRequest:result:]',
          value: productResponseMap);
      final AppStoreConnection connection = AppStoreConnection();
      final ProductDetailsResponse response =
          await connection.queryProductDetails(<String>['123'].toSet());
      expect(
        response.notFoundIDs,
        <String>['567'],
      );
    });
  });
}
