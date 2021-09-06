// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:in_app_purchase_ios/in_app_purchase_ios.dart';
import 'package:in_app_purchase_platform_interface/in_app_purchase_platform_interface.dart';

import 'fakes/fake_ios_platform.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final FakeIOSPlatform fakeIOSPlatform = FakeIOSPlatform();

  setUpAll(() {
    SystemChannels.platform
        .setMockMethodCallHandler(fakeIOSPlatform.onMethodCall);
  });

  group('present code redemption sheet', () {
    test('null', () async {
      expect(
          await InAppPurchaseIosPlatformAddition().presentCodeRedemptionSheet(),
          null);
    });
  });

  group('refresh receipt data', () {
    test('should refresh receipt data', () async {
      PurchaseVerificationData? receiptData =
          await InAppPurchaseIosPlatformAddition()
              .refreshPurchaseVerificationData();
      expect(receiptData, isNotNull);
      expect(receiptData!.source, kIAPSource);
      expect(receiptData.localVerificationData, 'refreshed receipt data');
      expect(receiptData.serverVerificationData, 'refreshed receipt data');
    });
  });
}
