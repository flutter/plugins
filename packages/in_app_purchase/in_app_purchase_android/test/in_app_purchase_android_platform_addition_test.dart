// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/services.dart';
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

    const String debugMessage = 'dummy message';
    const BillingResponse responseCode = BillingResponse.ok;
    const BillingResultWrapper expectedBillingResult = BillingResultWrapper(
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
      const BillingResponse expectedCode = BillingResponse.ok;
      const String debugMessage = 'dummy message';
      const BillingResultWrapper expectedBillingResult = BillingResultWrapper(
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

  group('queryPastPurchase', () {
    group('queryPurchaseDetails', () {
      const String queryMethodName = 'BillingClient#queryPurchases(String)';
      test('handles error', () async {
        const String debugMessage = 'dummy message';
        const BillingResponse responseCode = BillingResponse.developerError;
        const BillingResultWrapper expectedBillingResult = BillingResultWrapper(
            responseCode: responseCode, debugMessage: debugMessage);

        stubPlatform
            .addResponse(name: queryMethodName, value: <dynamic, dynamic>{
          'billingResult': buildBillingResultMap(expectedBillingResult),
          'responseCode': const BillingResponseConverter().toJson(responseCode),
          'purchasesList': <Map<String, dynamic>>[]
        });
        final QueryPurchaseDetailsResponse response =
            await iapAndroidPlatformAddition.queryPastPurchases();
        expect(response.pastPurchases, isEmpty);
        expect(response.error, isNotNull);
        expect(
            response.error!.message, BillingResponse.developerError.toString());
        expect(response.error!.source, kIAPSource);
      });

      test('returns SkuDetailsResponseWrapper', () async {
        const String debugMessage = 'dummy message';
        const BillingResponse responseCode = BillingResponse.ok;
        const BillingResultWrapper expectedBillingResult = BillingResultWrapper(
            responseCode: responseCode, debugMessage: debugMessage);

        stubPlatform
            .addResponse(name: queryMethodName, value: <String, dynamic>{
          'billingResult': buildBillingResultMap(expectedBillingResult),
          'responseCode': const BillingResponseConverter().toJson(responseCode),
          'purchasesList': <Map<String, dynamic>>[
            buildPurchaseMap(dummyPurchase),
          ]
        });

        // Since queryPastPurchases makes 2 platform method calls (one for each SkuType), the result will contain 2 dummyWrapper instead
        // of 1.
        final QueryPurchaseDetailsResponse response =
            await iapAndroidPlatformAddition.queryPastPurchases();
        expect(response.error, isNull);
        expect(response.pastPurchases.first.purchaseID, dummyPurchase.orderId);
      });

      test('should store platform exception in the response', () async {
        const String debugMessage = 'dummy message';

        const BillingResponse responseCode = BillingResponse.developerError;
        const BillingResultWrapper expectedBillingResult = BillingResultWrapper(
            responseCode: responseCode, debugMessage: debugMessage);
        stubPlatform.addResponse(
            name: queryMethodName,
            value: <dynamic, dynamic>{
              'responseCode':
                  const BillingResponseConverter().toJson(responseCode),
              'billingResult': buildBillingResultMap(expectedBillingResult),
              'purchasesList': <Map<String, dynamic>>[]
            },
            additionalStepBeforeReturn: (dynamic _) {
              throw PlatformException(
                code: 'error_code',
                message: 'error_message',
                details: <dynamic, dynamic>{'info': 'error_info'},
              );
            });
        final QueryPurchaseDetailsResponse response =
            await iapAndroidPlatformAddition.queryPastPurchases();
        expect(response.pastPurchases, isEmpty);
        expect(response.error, isNotNull);
        expect(response.error!.code, 'error_code');
        expect(response.error!.message, 'error_message');
        expect(
            response.error!.details, <String, dynamic>{'info': 'error_info'});
      });
    });
  });

  group('isFeatureSupported', () {
    const String isFeatureSupportedMethodName =
        'BillingClient#isFeatureSupported(String)';
    test('isFeatureSupported returns false', () async {
      late Map<Object?, Object?> arguments;
      stubPlatform.addResponse(
        name: isFeatureSupportedMethodName,
        value: false,
        additionalStepBeforeReturn: (dynamic value) =>
            arguments = value as Map<dynamic, dynamic>,
      );
      final bool isSupported = await iapAndroidPlatformAddition
          .isFeatureSupported(BillingClientFeature.subscriptions);
      expect(isSupported, isFalse);
      expect(arguments['feature'], equals('subscriptions'));
    });

    test('isFeatureSupported returns true', () async {
      late Map<Object?, Object?> arguments;
      stubPlatform.addResponse(
        name: isFeatureSupportedMethodName,
        value: true,
        additionalStepBeforeReturn: (dynamic value) =>
            arguments = value as Map<dynamic, dynamic>,
      );
      final bool isSupported = await iapAndroidPlatformAddition
          .isFeatureSupported(BillingClientFeature.subscriptions);
      expect(isSupported, isTrue);
      expect(arguments['feature'], equals('subscriptions'));
    });
  });

  group('launchPriceChangeConfirmationFlow', () {
    const String launchPriceChangeConfirmationFlowMethodName =
        'BillingClient#launchPriceChangeConfirmationFlow (Activity, PriceChangeFlowParams, PriceChangeConfirmationListener)';
    const String dummySku = 'sku';

    const BillingResultWrapper expectedBillingResultPriceChangeConfirmation =
        BillingResultWrapper(
      responseCode: BillingResponse.ok,
      debugMessage: 'dummy message',
    );

    test('serializes and deserializes data', () async {
      stubPlatform.addResponse(
        name: launchPriceChangeConfirmationFlowMethodName,
        value:
            buildBillingResultMap(expectedBillingResultPriceChangeConfirmation),
      );

      expect(
        await iapAndroidPlatformAddition.launchPriceChangeConfirmationFlow(
          sku: dummySku,
        ),
        equals(expectedBillingResultPriceChangeConfirmation),
      );
    });

    test('passes sku to launchPriceChangeConfirmationFlow', () async {
      stubPlatform.addResponse(
        name: launchPriceChangeConfirmationFlowMethodName,
        value:
            buildBillingResultMap(expectedBillingResultPriceChangeConfirmation),
      );
      await iapAndroidPlatformAddition.launchPriceChangeConfirmationFlow(
        sku: dummySku,
      );
      final MethodCall call = stubPlatform
          .previousCallMatching(launchPriceChangeConfirmationFlowMethodName);
      expect(call.arguments, equals(<dynamic, dynamic>{'sku': dummySku}));
    });
  });
}
