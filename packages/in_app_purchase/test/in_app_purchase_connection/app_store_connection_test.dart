// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:test/test.dart';

import 'package:in_app_purchase/src/channel.dart';
import 'package:in_app_purchase/src/in_app_purchase_connection/app_store_connection.dart';
import '../stub_in_app_purchase_platform.dart';
import 'package:in_app_purchase/src/in_app_purchase_connection/product_details.dart';
import '../store_kit_wrappers/sk_test_stub_objects.dart';

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

  group('query product list', () {
    test('should get product list', () async {
      stubPlatform.addResponse(
          name: '-[InAppPurchasePlugin startProductRequest:result:]',
          value: buildProductResponseMap(dummyProductResponseWrapper));
      final AppStoreConnection connection = AppStoreConnection();
      final ProductDetailsResponse response =
          await connection.queryProductDetails(<String>['id'].toSet());
      List<ProductDetails> products = response.productDetails;
      expect(
        products,
        isNotEmpty,
      );
      expect(
        products.first.title,
        'title',
      );
      expect(
        products.first.title,
        isNot('splash coins'),
      );
    });

    test('should get correct not found identifiers', () async {
      stubPlatform.addResponse(
          name: '-[InAppPurchasePlugin startProductRequest:result:]',
          value: buildProductResponseMap(dummyProductResponseWrapper));
      final AppStoreConnection connection = AppStoreConnection();
      final ProductDetailsResponse response =
          await connection.queryProductDetails(<String>['123'].toSet());
      expect(
        response.notFoundIDs,
        <String>['123'],
      );
    });
  });
}
