import 'package:test/test.dart';
import 'package:flutter/services.dart';

import 'package:in_app_purchase/billing_client_wrappers.dart';
import 'package:in_app_purchase/src/channel.dart';
import '../fake_platform_views_controller.dart';

void main() {
  final FakePlatformViewsController fakePlatformViewsController =
      FakePlatformViewsController();
  BillingClient billingClient;

  setUpAll(() {
    Channel.override = SystemChannels.platform_views;
    SystemChannels.platform_views.setMockMethodCallHandler(
        fakePlatformViewsController.fakePlatformViewsMethodHandler);
  });

  setUp(() {
    billingClient = BillingClient();
    fakePlatformViewsController.reset();
  });

  group('isReady', () {
    test('true', () async {
      fakePlatformViewsController.addCall(
          name: 'BillingClient#isReady()', value: true);
      expect(await billingClient.isReady(), isTrue);
    });

    test('false', () async {
      fakePlatformViewsController.addCall(
          name: 'BillingClient#isReady()', value: false);
      expect(await billingClient.isReady(), isFalse);
    });
  });

  group('startConnection', () {
    test('returns BillingResponse', () async {
      fakePlatformViewsController.addCall(
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
      fakePlatformViewsController.addCall(
          name: methodName, value: int.parse(BillingResponse.OK.toString()));
      await billingClient.startConnection(onBillingServiceDisconnected: () {});
      final MethodCall call =
          fakePlatformViewsController.previousCallMatching(methodName);
      expect(call.arguments, equals(<dynamic, dynamic>{'handle': 0}));
    });
  });

  test('endConnection', () async {
    final String endConnectionName = 'BillingClient#endConnection()';
    expect(fakePlatformViewsController.countPreviousCalls(endConnectionName),
        equals(0));
    fakePlatformViewsController.addCall(name: endConnectionName, value: null);
    await billingClient.endConnection();
    expect(fakePlatformViewsController.countPreviousCalls(endConnectionName),
        equals(1));
  });
}
