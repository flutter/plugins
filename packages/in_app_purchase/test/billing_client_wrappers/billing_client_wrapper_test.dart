import 'package:test/test.dart';
import 'package:flutter/services.dart';

import 'package:in_app_purchase/billing_client_wrappers.dart';
import 'package:in_app_purchase/src/channel.dart';
import '../fake_in_app_purchase_platform.dart';

void main() {
  final FakeInAppPurchasePlatform fakePlatform = FakeInAppPurchasePlatform();
  BillingClient billingClient;

  setUpAll(() =>
      channel.setMockMethodCallHandler(fakePlatform.fakeMethodCallHandler));

  setUp(() {
    billingClient = BillingClient();
    fakePlatform.reset();
  });

  group('isReady', () {
    test('true', () async {
      fakePlatform.addResponse(name: 'BillingClient#isReady()', value: true);
      expect(await billingClient.isReady(), isTrue);
    });

    test('false', () async {
      fakePlatform.addResponse(name: 'BillingClient#isReady()', value: false);
      expect(await billingClient.isReady(), isFalse);
    });
  });

  group('startConnection', () {
    test('returns BillingResponse', () async {
      fakePlatform.addResponse(
          name: 'BillingClient#startConnection(BillingClientStateListener)',
          value: int.parse(BillingResponse.OK.toString()));
      expect(
          await billingClient.startConnection(
              onBillingServiceDisconnected: () {}),
          equals(BillingResponse.OK));
    });

    test('passes handle to onBillingServiceDisconnected', () async {
      final String methodName =
          'BillingClient#startConnection(BillingClientStateListener)';
      fakePlatform.addResponse(
          name: methodName, value: int.parse(BillingResponse.OK.toString()));
      await billingClient.startConnection(onBillingServiceDisconnected: () {});
      final MethodCall call = fakePlatform.previousCallMatching(methodName);
      expect(call.arguments, equals(<dynamic, dynamic>{'handle': 0}));
    });
  });

  test('endConnection', () async {
    final String endConnectionName = 'BillingClient#endConnection()';
    expect(fakePlatform.countPreviousCalls(endConnectionName), equals(0));
    fakePlatform.addResponse(name: endConnectionName, value: null);
    await billingClient.endConnection();
    expect(fakePlatform.countPreviousCalls(endConnectionName), equals(1));
  });
}
