// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:in_app_purchase/src/channel.dart';
import 'package:in_app_purchase/store_kit_wrappers.dart';
import 'sk_test_stub_objects.dart';

void main() {
  final FakeIOSPlatform fakeIOSPlatform = FakeIOSPlatform();

  setUpAll(() {
    SystemChannels.platform
        .setMockMethodCallHandler(fakeIOSPlatform.onMethodCall);
  });

  setUp(() {});

  group('sk_request_maker', () {
    test('get products method channel', () async {
      SkProductResponseWrapper productResponseWrapper =
          await SKRequestMaker().startProductRequest(['xxx']);
      expect(
        productResponseWrapper.products,
        isNotEmpty,
      );
      expect(
        productResponseWrapper.products.first.priceLocale.currencySymbol,
        '\$',
      );
      expect(
        productResponseWrapper.products.first.priceLocale.currencySymbol,
        isNot('A'),
      );
      expect(
        productResponseWrapper.invalidProductIdentifiers,
        isNotEmpty,
      );

      expect(fakeIOSPlatform.startProductRequestParam, ['xxx'],);
    });

    test('refreshed receipt', () async {
      int receiptCountBefore = fakeIOSPlatform.refreshReceipt;
      await SKRequestMaker().startRefreshReceiptRequest(receiptProperties:{"isExpired":true});
      expect(fakeIOSPlatform.refreshReceipt, receiptCountBefore + 1);
      expect(fakeIOSPlatform.refreshReceiptParam, {"isExpired":true});
    });
  });
}

class FakeIOSPlatform {
  FakeIOSPlatform() {
    channel.setMockMethodCallHandler(onMethodCall);
  }
  // get product request
  List startProductRequestParam;
  bool getProductRequestFailTest;

  // refresh receipt request
  int refreshReceipt = 0;
  Map refreshReceiptParam;

  Future<dynamic> onMethodCall(MethodCall call) {
    switch (call.method) {
      case '-[InAppPurchasePlugin startProductRequest:result:]':
        List<String> productIDS =
            List.castFrom<dynamic, String>(call.arguments);
        assert(productIDS is List<String>, 'invalid argument type');
        startProductRequestParam = call.arguments;
        if (getProductRequestFailTest) {
          return Future<Map<String, dynamic>>.value(null);
        }
        return Future<Map<String, dynamic>>.value(productResponseMap);
        break;
      case '-[InAppPurchasePlugin refreshReceipt:result:]':
        refreshReceipt++;
        refreshReceiptParam = call.arguments;
        return Future<void>.sync(() {});
    }
    return Future<void>.sync(() {});
  }
}
