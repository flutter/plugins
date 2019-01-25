// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:test/test.dart';
import 'package:in_app_purchase/src/store_kit_wrappers/sk_product_wrapper.dart';
import 'package:in_app_purchase/src/channel.dart';
import 'package:in_app_purchase/src/store_kit_wrappers/sk_request_maker.dart';
import '../stub_in_app_purchase_platform.dart';

void main() {
  final StubInAppPurchasePlatform stubPlatform = StubInAppPurchasePlatform();

  final Map<String, dynamic> subMap = <String, dynamic>{
    'numberOfUnits': 1,
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

  final Map<String, List<dynamic>> productResponseMap = <String, List<dynamic>>{
    'products': <Map<String, dynamic>>[productMap],
    'invalidProductIdentifiers': <String>['123'],
  };

  setUpAll(() =>
      channel.setMockMethodCallHandler(stubPlatform.fakeMethodCallHandler));

  group('startProductRequest api', () {
    test('platform call should get result', () async {
      stubPlatform.addResponse(
          name: '-[InAppPurchasePlugin startProductRequest:result:]',
          value: productResponseMap.cast<String, dynamic>());
      final SKRequestMaker request = SKRequestMaker();
      final SkProductResponseWrapper response =
          await request.startProductRequest(<String>['123']);
      expect(
        response.products,
        isNotEmpty,
      );
      expect(
        response.products.first.currencyCode,
        'USD',
      );
      expect(
        response.products.first.currencyCode,
        isNot('USDA'),
      );
      expect(
        response.invalidProductIdentifiers,
        isNotEmpty,
      );
    });

    test('result is null should throw', () async {
      stubPlatform.addResponse(
          name: '-[InAppPurchasePlugin startProductRequest:result:]',
          value: null);
      final SKRequestMaker request = SKRequestMaker();
      expect(
        request.startProductRequest(<String>['123']),
        throwsException,
      );
    });
  });
}
