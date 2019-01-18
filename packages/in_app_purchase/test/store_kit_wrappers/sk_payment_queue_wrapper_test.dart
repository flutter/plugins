// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:test/test.dart';

import 'package:in_app_purchase/store_kit_wrappers.dart';
import 'package:in_app_purchase/src/channel.dart';
import '../stub_in_app_purchase_platform.dart';

void main() {
  final StubInAppPurchasePlatform stubPlatform = StubInAppPurchasePlatform();

  setUpAll(() =>
      channel.setMockMethodCallHandler(stubPlatform.fakeMethodCallHandler));

  group('canMakePayments', () {
    test('YES', () async {
      stubPlatform.addResponse(
          name: '-[SKPaymentQueue canMakePayments:]', value: true);
      expect(await SKPaymentQueueWrapper.canMakePayments(), isTrue);
    });

    test('NO', () async {
      stubPlatform.addResponse(
          name: '-[SKPaymentQueue canMakePayments:]', value: false);
      expect(await SKPaymentQueueWrapper.canMakePayments(), isFalse);
    });
  });
}
