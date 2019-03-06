// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:test/test.dart';
import 'package:in_app_purchase/src/store_kit_wrappers/sk_product_wrapper.dart';
import 'package:in_app_purchase/src/channel.dart';
import 'package:in_app_purchase/src/store_kit_wrappers/sk_request_maker.dart';
import '../stub_in_app_purchase_platform.dart';
import 'sk_test_stub_objects.dart';

void main() {
  final StubInAppPurchasePlatform stubPlatform = StubInAppPurchasePlatform();

  setUpAll(() =>
      channel.setMockMethodCallHandler(stubPlatform.fakeMethodCallHandler));

  group('startProductRequest api', () {
    test('platform call should get result', () async {
      stubPlatform.addResponse(
          name: '-[InAppPurchasePlugin startProductRequest:result:]',
          value: buildProductResponseMap(dummyProductResponseWrapper));
      final SKRequestMaker request = SKRequestMaker();
      final SkProductResponseWrapper response =
          await request.startProductRequest(<String>['123']);
      expect(
        response.products,
        isNotEmpty,
      );
      expect(
        response.products.first.priceLocale.currencySymbol,
        '\$',
      );
      expect(
        response.products.first.priceLocale.currencySymbol,
        isNot('A'),
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
