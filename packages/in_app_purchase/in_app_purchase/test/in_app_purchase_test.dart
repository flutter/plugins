// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_platform_interface/in_app_purchase_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

void main() {
  group('InAppPurchase', () {
    final ProductDetails productDetails = ProductDetails(
      id: 'id',
      title: 'title',
      description: 'description',
      price: 'price',
      rawPrice: 0.0,
      currencyCode: 'currencyCode',
    );

    final PurchaseDetails purchaseDetails = PurchaseDetails(
      productID: 'productID',
      verificationData: PurchaseVerificationData(
        localVerificationData: 'localVerificationData',
        serverVerificationData: 'serverVerificationData',
        source: 'source',
      ),
      transactionDate: 'transactionDate',
      status: PurchaseStatus.purchased,
    );

    late InAppPurchase inAppPurchase;
    late MockInAppPurchasePlatform fakePlatform;

    setUp(() {
      debugDefaultTargetPlatformOverride = TargetPlatform.fuchsia;

      fakePlatform = MockInAppPurchasePlatform();
      InAppPurchasePlatform.instance = fakePlatform;
      inAppPurchase = InAppPurchase.instance;
    });

    tearDown(() {
      // Restore the default target platform
      debugDefaultTargetPlatformOverride = null;
    });

    test('isAvailable', () async {
      final bool isAvailable = await inAppPurchase.isAvailable();
      expect(isAvailable, true);
      expect(fakePlatform.log, <Matcher>[
        isMethodCall('isAvailable', arguments: null),
      ]);
    });

    test('purchaseStream', () async {
      final bool isEmptyStream = await inAppPurchase.purchaseStream.isEmpty;
      expect(isEmptyStream, true);
      expect(fakePlatform.log, <Matcher>[
        isMethodCall('purchaseStream', arguments: null),
      ]);
    });

    test('queryProductDetails', () async {
      final ProductDetailsResponse response =
          await inAppPurchase.queryProductDetails(Set<String>());
      expect(response.notFoundIDs.isEmpty, true);
      expect(response.productDetails.isEmpty, true);
      expect(fakePlatform.log, <Matcher>[
        isMethodCall('queryProductDetails', arguments: null),
      ]);
    });

    test('buyNonConsumable', () async {
      final bool result = await inAppPurchase.buyNonConsumable(
        purchaseParam: PurchaseParam(
          productDetails: productDetails,
        ),
      );

      expect(result, true);
      expect(fakePlatform.log, <Matcher>[
        isMethodCall('buyNonConsumable', arguments: null),
      ]);
    });

    test('buyConsumable', () async {
      final purchaseParam = PurchaseParam(productDetails: productDetails);
      final bool result = await inAppPurchase.buyConsumable(
        purchaseParam: purchaseParam,
      );

      expect(result, true);
      expect(fakePlatform.log, <Matcher>[
        isMethodCall('buyConsumable', arguments: {
          "purchaseParam": purchaseParam,
          "autoConsume": true,
        }),
      ]);
    });

    test('buyConsumable with autoConsume=false', () async {
      final purchaseParam = PurchaseParam(productDetails: productDetails);
      final bool result = await inAppPurchase.buyConsumable(
        purchaseParam: purchaseParam,
        autoConsume: false,
      );

      expect(result, true);
      expect(fakePlatform.log, <Matcher>[
        isMethodCall('buyConsumable', arguments: {
          "purchaseParam": purchaseParam,
          "autoConsume": false,
        }),
      ]);
    });

    test('completePurchase', () async {
      await inAppPurchase.completePurchase(purchaseDetails);

      expect(fakePlatform.log, <Matcher>[
        isMethodCall('completePurchase', arguments: null),
      ]);
    });

    test('restorePurchases', () async {
      await inAppPurchase.restorePurchases();

      expect(fakePlatform.log, <Matcher>[
        isMethodCall('restorePurchases', arguments: null),
      ]);
    });
  });
}

class MockInAppPurchasePlatform extends Fake
    with MockPlatformInterfaceMixin
    implements InAppPurchasePlatform {
  final List<MethodCall> log = [];

  @override
  Future<bool> isAvailable() {
    log.add(MethodCall('isAvailable'));
    return Future.value(true);
  }

  @override
  Stream<List<PurchaseDetails>> get purchaseStream {
    log.add(MethodCall('purchaseStream'));
    return Stream.empty();
  }

  @override
  Future<ProductDetailsResponse> queryProductDetails(Set<String> identifiers) {
    log.add(MethodCall('queryProductDetails'));
    return Future.value(
        ProductDetailsResponse(productDetails: [], notFoundIDs: []));
  }

  @override
  Future<bool> buyNonConsumable({required PurchaseParam purchaseParam}) {
    log.add(MethodCall('buyNonConsumable'));
    return Future.value(true);
  }

  @override
  Future<bool> buyConsumable({
    required PurchaseParam purchaseParam,
    bool autoConsume = true,
  }) {
    log.add(MethodCall('buyConsumable', {
      "purchaseParam": purchaseParam,
      "autoConsume": autoConsume,
    }));
    return Future.value(true);
  }

  @override
  Future<void> completePurchase(PurchaseDetails purchase) {
    log.add(MethodCall('completePurchase'));
    return Future.value(null);
  }

  @override
  Future<void> restorePurchases({String? applicationUserName}) {
    log.add(MethodCall('restorePurchases'));
    return Future.value(null);
  }
}
