// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/widgets.dart' as widgets;
import 'package:flutter_test/flutter_test.dart';
import 'package:in_app_purchase_android/billing_client_wrappers.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';
import 'package:in_app_purchase_android/src/channel.dart';
import 'package:in_app_purchase_android/src/in_app_purchase_android_platform_addition.dart';

import 'billing_client_wrappers/purchase_wrapper_test.dart';
import 'stub_in_app_purchase_platform.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final StubInAppPurchasePlatform stubPlatform = StubInAppPurchasePlatform();
  late InAppPurchaseAndroidPlatformAddition iapAndroidPlatformAddition;
  const String startConnectionCall =
      'BillingClient#startConnection(BillingClientStateListener)';
  const String endConnectionCall = 'BillingClient#endConnection()';

  setUpAll(() {
    channel.setMockMethodCallHandler(stubPlatform.fakeMethodCallHandler);
  });

  setUp(() {
    widgets.WidgetsFlutterBinding.ensureInitialized();

    InAppPurchaseAndroidPlatformAddition.enablePendingPurchases();

    const String debugMessage = 'dummy message';
    final BillingResponse responseCode = BillingResponse.ok;
    final BillingResultWrapper expectedBillingResult = BillingResultWrapper(
        responseCode: responseCode, debugMessage: debugMessage);
    stubPlatform.addResponse(
        name: startConnectionCall,
        value: buildBillingResultMap(expectedBillingResult));
    stubPlatform.addResponse(name: endConnectionCall, value: null);
    iapAndroidPlatformAddition =
        InAppPurchaseAndroidPlatformAddition(BillingClient((_) {}));
  });

  group('consume purchases', () {
    const String consumeMethodName =
        'BillingClient#consumeAsync(String, ConsumeResponseListener)';
    test('consume purchase async success', () async {
      final BillingResponse expectedCode = BillingResponse.ok;
      const String debugMessage = 'dummy message';
      final BillingResultWrapper expectedBillingResult = BillingResultWrapper(
          responseCode: expectedCode, debugMessage: debugMessage);
      stubPlatform.addResponse(
        name: consumeMethodName,
        value: buildBillingResultMap(expectedBillingResult),
      );
      final BillingResultWrapper billingResultWrapper =
          await iapAndroidPlatformAddition.consumePurchase(
              GooglePlayPurchaseDetails.fromPurchase(dummyPurchase));

      expect(billingResultWrapper, equals(expectedBillingResult));
    });
  });
}
