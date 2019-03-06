// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:test/test.dart';
import 'package:in_app_purchase/src/store_kit_wrappers/sk_receipt_manager.dart';
import 'package:in_app_purchase/src/channel.dart';

import '../stub_in_app_purchase_platform.dart';

void main() {
  final StubInAppPurchasePlatform stubPlatform = StubInAppPurchasePlatform();

  setUpAll(() =>
      channel.setMockMethodCallHandler(stubPlatform.fakeMethodCallHandler));

  group('retrieveReceiptData', () {
    test('Should get result', () async {
      stubPlatform.addResponse(
          name: '-[InAppPurchasePlugin retrieveReceiptData:result:]',
          value: 'dummy data');
      final String result = await SKReceiptManager().retrieveReceiptData();
      expect(result, 'dummy data');
    });
  });
}
