// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart' as widgets;
import 'package:flutter_test/flutter_test.dart';
import 'package:in_app_purchase_android/billing_client_wrappers.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';
import 'package:in_app_purchase_android/src/channel.dart';
import 'package:in_app_purchase_platform_interface/in_app_purchase_platform_interface.dart';

import 'billing_client_wrappers/purchase_wrapper_test.dart';
import 'billing_client_wrappers/sku_details_wrapper_test.dart';
import 'stub_in_app_purchase_platform.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final StubInAppPurchasePlatform stubPlatform = StubInAppPurchasePlatform();
  late InAppPurchaseAndroidPlatform iapAndroidPlatform;
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
    stubPlatform.addResponse(name: endConnectionCall);

    InAppPurchaseAndroidPlatform.registerPlatform();
    iapAndroidPlatform =
        InAppPurchasePlatform.instance as InAppPurchaseAndroidPlatform;
  });

  tearDown(() {
    stubPlatform.reset();
  });

  group('connection management', () {
    test('connects on initialization', () {
      //await iapAndroidPlatform.isAvailable();
      expect(stubPlatform.countPreviousCalls(startConnectionCall), equals(1));
    });
  });

  group('isAvailable', () {
    test('true', () async {
      stubPlatform.addResponse(name: 'BillingClient#isReady()', value: true);
      expect(await iapAndroidPlatform.isAvailable(), isTrue);
    });

    test('false', () async {
      stubPlatform.addResponse(name: 'BillingClient#isReady()', value: false);
      expect(await iapAndroidPlatform.isAvailable(), isFalse);
    });
  });

  group('querySkuDetails', () {
    const String queryMethodName =
        'BillingClient#querySkuDetailsAsync(SkuDetailsParams, SkuDetailsResponseListener)';

    test('handles empty skuDetails', () async {
      const String debugMessage = 'dummy message';
      const BillingResponse responseCode = BillingResponse.ok;
      const BillingResultWrapper expectedBillingResult = BillingResultWrapper(
          responseCode: responseCode, debugMessage: debugMessage);
      stubPlatform.addResponse(name: queryMethodName, value: <String, dynamic>{
        'billingResult': buildBillingResultMap(expectedBillingResult),
        'skuDetailsList': <Map<String, dynamic>>[],
      });

      final ProductDetailsResponse response =
          await iapAndroidPlatform.queryProductDetails(<String>{''});
      expect(response.productDetails, isEmpty);
    });

    test('should get correct product details', () async {
      const String debugMessage = 'dummy message';
      const BillingResponse responseCode = BillingResponse.ok;
      const BillingResultWrapper expectedBillingResult = BillingResultWrapper(
          responseCode: responseCode, debugMessage: debugMessage);
      stubPlatform.addResponse(name: queryMethodName, value: <String, dynamic>{
        'billingResult': buildBillingResultMap(expectedBillingResult),
        'skuDetailsList': <Map<String, dynamic>>[buildSkuMap(dummySkuDetails)]
      });
      // Since queryProductDetails makes 2 platform method calls (one for each SkuType), the result will contain 2 dummyWrapper instead
      // of 1.
      final ProductDetailsResponse response =
          await iapAndroidPlatform.queryProductDetails(<String>{'valid'});
      expect(response.productDetails.first.title, dummySkuDetails.title);
      expect(response.productDetails.first.description,
          dummySkuDetails.description);
      expect(response.productDetails.first.price, dummySkuDetails.price);
      expect(response.productDetails.first.currencySymbol, r'$');
    });

    test('should get the correct notFoundIDs', () async {
      const String debugMessage = 'dummy message';
      const BillingResponse responseCode = BillingResponse.ok;
      const BillingResultWrapper expectedBillingResult = BillingResultWrapper(
          responseCode: responseCode, debugMessage: debugMessage);
      stubPlatform.addResponse(name: queryMethodName, value: <String, dynamic>{
        'billingResult': buildBillingResultMap(expectedBillingResult),
        'skuDetailsList': <Map<String, dynamic>>[buildSkuMap(dummySkuDetails)]
      });
      // Since queryProductDetails makes 2 platform method calls (one for each SkuType), the result will contain 2 dummyWrapper instead
      // of 1.
      final ProductDetailsResponse response =
          await iapAndroidPlatform.queryProductDetails(<String>{'invalid'});
      expect(response.notFoundIDs.first, 'invalid');
    });

    test(
        'should have error stored in the response when platform exception is thrown',
        () async {
      const BillingResponse responseCode = BillingResponse.ok;
      stubPlatform.addResponse(
          name: queryMethodName,
          value: <String, dynamic>{
            'responseCode':
                const BillingResponseConverter().toJson(responseCode),
            'skuDetailsList': <Map<String, dynamic>>[
              buildSkuMap(dummySkuDetails)
            ]
          },
          additionalStepBeforeReturn: (dynamic _) {
            throw PlatformException(
              code: 'error_code',
              message: 'error_message',
              details: <dynamic, dynamic>{'info': 'error_info'},
            );
          });
      // Since queryProductDetails makes 2 platform method calls (one for each SkuType), the result will contain 2 dummyWrapper instead
      // of 1.
      final ProductDetailsResponse response =
          await iapAndroidPlatform.queryProductDetails(<String>{'invalid'});
      expect(response.notFoundIDs, <String>['invalid']);
      expect(response.productDetails, isEmpty);
      expect(response.error, isNotNull);
      expect(response.error!.source, kIAPSource);
      expect(response.error!.code, 'error_code');
      expect(response.error!.message, 'error_message');
      expect(response.error!.details, <String, dynamic>{'info': 'error_info'});
    });
  });

  group('restorePurchases', () {
    const String queryMethodName = 'BillingClient#queryPurchases(String)';
    test('handles error', () async {
      const String debugMessage = 'dummy message';
      const BillingResponse responseCode = BillingResponse.developerError;
      const BillingResultWrapper expectedBillingResult = BillingResultWrapper(
          responseCode: responseCode, debugMessage: debugMessage);

      stubPlatform.addResponse(name: queryMethodName, value: <dynamic, dynamic>{
        'billingResult': buildBillingResultMap(expectedBillingResult),
        'responseCode': const BillingResponseConverter().toJson(responseCode),
        'purchasesList': <Map<String, dynamic>>[]
      });

      expect(
        iapAndroidPlatform.restorePurchases(),
        throwsA(
          isA<InAppPurchaseException>()
              .having(
                  (InAppPurchaseException e) => e.source, 'source', kIAPSource)
              .having((InAppPurchaseException e) => e.code, 'code',
                  kRestoredPurchaseErrorCode)
              .having((InAppPurchaseException e) => e.message, 'message',
                  responseCode.toString()),
        ),
      );
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

      expect(
        iapAndroidPlatform.restorePurchases(),
        throwsA(
          isA<PlatformException>()
              .having((PlatformException e) => e.code, 'code', 'error_code')
              .having((PlatformException e) => e.message, 'message',
                  'error_message')
              .having((PlatformException e) => e.details, 'details',
                  <String, dynamic>{'info': 'error_info'}),
        ),
      );
    });

    test('returns SkuDetailsResponseWrapper', () async {
      final Completer<List<PurchaseDetails>> completer =
          Completer<List<PurchaseDetails>>();
      final Stream<List<PurchaseDetails>> stream =
          iapAndroidPlatform.purchaseStream;

      late StreamSubscription<List<PurchaseDetails>> subscription;
      subscription = stream.listen((List<PurchaseDetails> purchaseDetailsList) {
        if (purchaseDetailsList.first.status == PurchaseStatus.restored) {
          completer.complete(purchaseDetailsList);
          subscription.cancel();
        }
      });

      const String debugMessage = 'dummy message';
      const BillingResponse responseCode = BillingResponse.ok;
      const BillingResultWrapper expectedBillingResult = BillingResultWrapper(
          responseCode: responseCode, debugMessage: debugMessage);

      stubPlatform.addResponse(name: queryMethodName, value: <String, dynamic>{
        'billingResult': buildBillingResultMap(expectedBillingResult),
        'responseCode': const BillingResponseConverter().toJson(responseCode),
        'purchasesList': <Map<String, dynamic>>[
          buildPurchaseMap(dummyPurchase),
        ]
      });

      // Since queryPastPurchases makes 2 platform method calls (one for each
      // SkuType), the result will contain 2 dummyPurchase instances instead
      // of 1.
      await iapAndroidPlatform.restorePurchases();
      final List<PurchaseDetails> restoredPurchases = await completer.future;

      expect(restoredPurchases.length, 2);
      for (final PurchaseDetails element in restoredPurchases) {
        final GooglePlayPurchaseDetails purchase =
            element as GooglePlayPurchaseDetails;

        expect(purchase.productID, dummyPurchase.sku);
        expect(purchase.purchaseID, dummyPurchase.orderId);
        expect(purchase.verificationData.localVerificationData,
            dummyPurchase.originalJson);
        expect(purchase.verificationData.serverVerificationData,
            dummyPurchase.purchaseToken);
        expect(purchase.verificationData.source, kIAPSource);
        expect(purchase.transactionDate, dummyPurchase.purchaseTime.toString());
        expect(purchase.billingClientPurchase, dummyPurchase);
        expect(purchase.status, PurchaseStatus.restored);
      }
    });
  });

  group('make payment', () {
    const String launchMethodName =
        'BillingClient#launchBillingFlow(Activity, BillingFlowParams)';
    const String consumeMethodName =
        'BillingClient#consumeAsync(String, ConsumeResponseListener)';

    test('buy non consumable, serializes and deserializes data', () async {
      const SkuDetailsWrapper skuDetails = dummySkuDetails;
      const String accountId = 'hashedAccountId';
      const String debugMessage = 'dummy message';
      const BillingResponse sentCode = BillingResponse.ok;
      const BillingResultWrapper expectedBillingResult = BillingResultWrapper(
          responseCode: sentCode, debugMessage: debugMessage);

      stubPlatform.addResponse(
          name: launchMethodName,
          value: buildBillingResultMap(expectedBillingResult),
          additionalStepBeforeReturn: (dynamic _) {
            // Mock java update purchase callback.
            final MethodCall call =
                MethodCall(kOnPurchasesUpdated, <dynamic, dynamic>{
              'billingResult': buildBillingResultMap(expectedBillingResult),
              'responseCode': const BillingResponseConverter().toJson(sentCode),
              'purchasesList': <dynamic>[
                <dynamic, dynamic>{
                  'orderId': 'orderID1',
                  'skus': <String>[skuDetails.sku],
                  'isAutoRenewing': false,
                  'packageName': 'package',
                  'purchaseTime': 1231231231,
                  'purchaseToken': 'token',
                  'signature': 'sign',
                  'originalJson': 'json',
                  'developerPayload': 'dummy payload',
                  'isAcknowledged': true,
                  'purchaseState': 1,
                }
              ]
            });
            iapAndroidPlatform.billingClient.callHandler(call);
          });
      final Completer<PurchaseDetails> completer = Completer<PurchaseDetails>();
      PurchaseDetails purchaseDetails;
      final Stream<List<PurchaseDetails>> purchaseStream =
          iapAndroidPlatform.purchaseStream;
      late StreamSubscription<List<PurchaseDetails>> subscription;
      subscription = purchaseStream.listen((_) {
        purchaseDetails = _.first;
        completer.complete(purchaseDetails);
        subscription.cancel();
      }, onDone: () {});
      final GooglePlayPurchaseParam purchaseParam = GooglePlayPurchaseParam(
          productDetails: GooglePlayProductDetails.fromSkuDetails(skuDetails),
          applicationUserName: accountId);
      final bool launchResult = await iapAndroidPlatform.buyNonConsumable(
          purchaseParam: purchaseParam);

      final PurchaseDetails result = await completer.future;
      expect(launchResult, isTrue);
      expect(result.purchaseID, 'orderID1');
      expect(result.status, PurchaseStatus.purchased);
      expect(result.productID, dummySkuDetails.sku);
    });

    test('handles an error with an empty purchases list', () async {
      const SkuDetailsWrapper skuDetails = dummySkuDetails;
      const String accountId = 'hashedAccountId';
      const String debugMessage = 'dummy message';
      const BillingResponse sentCode = BillingResponse.error;
      const BillingResultWrapper expectedBillingResult = BillingResultWrapper(
          responseCode: sentCode, debugMessage: debugMessage);

      stubPlatform.addResponse(
          name: launchMethodName,
          value: buildBillingResultMap(expectedBillingResult),
          additionalStepBeforeReturn: (dynamic _) {
            // Mock java update purchase callback.
            final MethodCall call =
                MethodCall(kOnPurchasesUpdated, <dynamic, dynamic>{
              'billingResult': buildBillingResultMap(expectedBillingResult),
              'responseCode': const BillingResponseConverter().toJson(sentCode),
              'purchasesList': const <dynamic>[]
            });
            iapAndroidPlatform.billingClient.callHandler(call);
          });
      final Completer<PurchaseDetails> completer = Completer<PurchaseDetails>();
      PurchaseDetails purchaseDetails;
      final Stream<List<PurchaseDetails>> purchaseStream =
          iapAndroidPlatform.purchaseStream;
      late StreamSubscription<List<PurchaseDetails>> subscription;
      subscription = purchaseStream.listen((_) {
        purchaseDetails = _.first;
        completer.complete(purchaseDetails);
        subscription.cancel();
      }, onDone: () {});
      final GooglePlayPurchaseParam purchaseParam = GooglePlayPurchaseParam(
          productDetails: GooglePlayProductDetails.fromSkuDetails(skuDetails),
          applicationUserName: accountId);
      await iapAndroidPlatform.buyNonConsumable(purchaseParam: purchaseParam);
      final PurchaseDetails result = await completer.future;

      expect(result.error, isNotNull);
      expect(result.error!.source, kIAPSource);
      expect(result.status, PurchaseStatus.error);
      expect(result.purchaseID, isEmpty);
    });

    test('buy consumable with auto consume, serializes and deserializes data',
        () async {
      const SkuDetailsWrapper skuDetails = dummySkuDetails;
      const String accountId = 'hashedAccountId';
      const String debugMessage = 'dummy message';
      const BillingResponse sentCode = BillingResponse.ok;
      const BillingResultWrapper expectedBillingResult = BillingResultWrapper(
          responseCode: sentCode, debugMessage: debugMessage);

      stubPlatform.addResponse(
          name: launchMethodName,
          value: buildBillingResultMap(expectedBillingResult),
          additionalStepBeforeReturn: (dynamic _) {
            // Mock java update purchase callback.
            final MethodCall call =
                MethodCall(kOnPurchasesUpdated, <dynamic, dynamic>{
              'billingResult': buildBillingResultMap(expectedBillingResult),
              'responseCode': const BillingResponseConverter().toJson(sentCode),
              'purchasesList': <dynamic>[
                <dynamic, dynamic>{
                  'orderId': 'orderID1',
                  'skus': <String>[skuDetails.sku],
                  'isAutoRenewing': false,
                  'packageName': 'package',
                  'purchaseTime': 1231231231,
                  'purchaseToken': 'token',
                  'signature': 'sign',
                  'originalJson': 'json',
                  'developerPayload': 'dummy payload',
                  'isAcknowledged': true,
                  'purchaseState': 1,
                }
              ]
            });
            iapAndroidPlatform.billingClient.callHandler(call);
          });
      final Completer<String> consumeCompleter = Completer<String>();
      // adding call back for consume purchase
      const BillingResponse expectedCode = BillingResponse.ok;
      const BillingResultWrapper expectedBillingResultForConsume =
          BillingResultWrapper(
              responseCode: expectedCode, debugMessage: debugMessage);
      stubPlatform.addResponse(
          name: consumeMethodName,
          value: buildBillingResultMap(expectedBillingResultForConsume),
          additionalStepBeforeReturn: (dynamic args) {
            final String purchaseToken = args['purchaseToken'] as String;
            consumeCompleter.complete(purchaseToken);
          });

      final Completer<PurchaseDetails> completer = Completer<PurchaseDetails>();
      PurchaseDetails purchaseDetails;
      final Stream<List<PurchaseDetails>> purchaseStream =
          iapAndroidPlatform.purchaseStream;
      late StreamSubscription<List<PurchaseDetails>> subscription;
      subscription = purchaseStream.listen((_) {
        purchaseDetails = _.first;
        completer.complete(purchaseDetails);
        subscription.cancel();
      }, onDone: () {});
      final GooglePlayPurchaseParam purchaseParam = GooglePlayPurchaseParam(
          productDetails: GooglePlayProductDetails.fromSkuDetails(skuDetails),
          applicationUserName: accountId);
      final bool launchResult =
          await iapAndroidPlatform.buyConsumable(purchaseParam: purchaseParam);

      // Verify that the result has succeeded
      final GooglePlayPurchaseDetails result =
          await completer.future as GooglePlayPurchaseDetails;
      expect(launchResult, isTrue);
      expect(result.billingClientPurchase, isNotNull);
      expect(result.billingClientPurchase.purchaseToken,
          await consumeCompleter.future);
      expect(result.status, PurchaseStatus.purchased);
      expect(result.error, isNull);
    });

    test('buyNonConsumable propagates failures to launch the billing flow',
        () async {
      const String debugMessage = 'dummy message';
      const BillingResponse sentCode = BillingResponse.error;
      const BillingResultWrapper expectedBillingResult = BillingResultWrapper(
          responseCode: sentCode, debugMessage: debugMessage);
      stubPlatform.addResponse(
          name: launchMethodName,
          value: buildBillingResultMap(expectedBillingResult));

      final bool result = await iapAndroidPlatform.buyNonConsumable(
          purchaseParam: GooglePlayPurchaseParam(
              productDetails:
                  GooglePlayProductDetails.fromSkuDetails(dummySkuDetails)));

      // Verify that the failure has been converted and returned
      expect(result, isFalse);
    });

    test('buyConsumable propagates failures to launch the billing flow',
        () async {
      const String debugMessage = 'dummy message';
      const BillingResponse sentCode = BillingResponse.developerError;
      const BillingResultWrapper expectedBillingResult = BillingResultWrapper(
          responseCode: sentCode, debugMessage: debugMessage);
      stubPlatform.addResponse(
        name: launchMethodName,
        value: buildBillingResultMap(expectedBillingResult),
      );

      final bool result = await iapAndroidPlatform.buyConsumable(
          purchaseParam: GooglePlayPurchaseParam(
              productDetails:
                  GooglePlayProductDetails.fromSkuDetails(dummySkuDetails)));

      // Verify that the failure has been converted and returned
      expect(result, isFalse);
    });

    test('adds consumption failures to PurchaseDetails objects', () async {
      const SkuDetailsWrapper skuDetails = dummySkuDetails;
      const String accountId = 'hashedAccountId';
      const String debugMessage = 'dummy message';
      const BillingResponse sentCode = BillingResponse.ok;
      const BillingResultWrapper expectedBillingResult = BillingResultWrapper(
          responseCode: sentCode, debugMessage: debugMessage);
      stubPlatform.addResponse(
          name: launchMethodName,
          value: buildBillingResultMap(expectedBillingResult),
          additionalStepBeforeReturn: (dynamic _) {
            // Mock java update purchase callback.
            final MethodCall call =
                MethodCall(kOnPurchasesUpdated, <dynamic, dynamic>{
              'billingResult': buildBillingResultMap(expectedBillingResult),
              'responseCode': const BillingResponseConverter().toJson(sentCode),
              'purchasesList': <dynamic>[
                <dynamic, dynamic>{
                  'orderId': 'orderID1',
                  'skus': <String>[skuDetails.sku],
                  'isAutoRenewing': false,
                  'packageName': 'package',
                  'purchaseTime': 1231231231,
                  'purchaseToken': 'token',
                  'signature': 'sign',
                  'originalJson': 'json',
                  'developerPayload': 'dummy payload',
                  'isAcknowledged': true,
                  'purchaseState': 1,
                }
              ]
            });
            iapAndroidPlatform.billingClient.callHandler(call);
          });
      final Completer<String> consumeCompleter = Completer<String>();
      // adding call back for consume purchase
      const BillingResponse expectedCode = BillingResponse.error;
      const BillingResultWrapper expectedBillingResultForConsume =
          BillingResultWrapper(
              responseCode: expectedCode, debugMessage: debugMessage);
      stubPlatform.addResponse(
          name: consumeMethodName,
          value: buildBillingResultMap(expectedBillingResultForConsume),
          additionalStepBeforeReturn: (dynamic args) {
            final String purchaseToken = args['purchaseToken'] as String;
            consumeCompleter.complete(purchaseToken);
          });

      final Completer<PurchaseDetails> completer = Completer<PurchaseDetails>();
      PurchaseDetails purchaseDetails;
      final Stream<List<PurchaseDetails>> purchaseStream =
          iapAndroidPlatform.purchaseStream;
      late StreamSubscription<List<PurchaseDetails>> subscription;
      subscription = purchaseStream.listen((_) {
        purchaseDetails = _.first;
        completer.complete(purchaseDetails);
        subscription.cancel();
      }, onDone: () {});
      final GooglePlayPurchaseParam purchaseParam = GooglePlayPurchaseParam(
          productDetails: GooglePlayProductDetails.fromSkuDetails(skuDetails),
          applicationUserName: accountId);
      await iapAndroidPlatform.buyConsumable(purchaseParam: purchaseParam);

      // Verify that the result has an error for the failed consumption
      final GooglePlayPurchaseDetails result =
          await completer.future as GooglePlayPurchaseDetails;
      expect(result.billingClientPurchase, isNotNull);
      expect(result.billingClientPurchase.purchaseToken,
          await consumeCompleter.future);
      expect(result.status, PurchaseStatus.error);
      expect(result.error, isNotNull);
      expect(result.error!.code, kConsumptionFailedErrorCode);
    });

    test(
        'buy consumable without auto consume, consume api should not receive calls',
        () async {
      const SkuDetailsWrapper skuDetails = dummySkuDetails;
      const String accountId = 'hashedAccountId';
      const String debugMessage = 'dummy message';
      const BillingResponse sentCode = BillingResponse.developerError;
      const BillingResultWrapper expectedBillingResult = BillingResultWrapper(
          responseCode: sentCode, debugMessage: debugMessage);

      stubPlatform.addResponse(
          name: launchMethodName,
          value: buildBillingResultMap(expectedBillingResult),
          additionalStepBeforeReturn: (dynamic _) {
            // Mock java update purchase callback.
            final MethodCall call =
                MethodCall(kOnPurchasesUpdated, <dynamic, dynamic>{
              'billingResult': buildBillingResultMap(expectedBillingResult),
              'responseCode': const BillingResponseConverter().toJson(sentCode),
              'purchasesList': <dynamic>[
                <dynamic, dynamic>{
                  'orderId': 'orderID1',
                  'skus': <String>[skuDetails.sku],
                  'isAutoRenewing': false,
                  'packageName': 'package',
                  'purchaseTime': 1231231231,
                  'purchaseToken': 'token',
                  'signature': 'sign',
                  'originalJson': 'json',
                  'developerPayload': 'dummy payload',
                  'isAcknowledged': true,
                  'purchaseState': 1,
                }
              ]
            });
            iapAndroidPlatform.billingClient.callHandler(call);
          });
      final Completer<String?> consumeCompleter = Completer<String?>();
      // adding call back for consume purchase
      const BillingResponse expectedCode = BillingResponse.ok;
      const BillingResultWrapper expectedBillingResultForConsume =
          BillingResultWrapper(
              responseCode: expectedCode, debugMessage: debugMessage);
      stubPlatform.addResponse(
          name: consumeMethodName,
          value: buildBillingResultMap(expectedBillingResultForConsume),
          additionalStepBeforeReturn: (dynamic args) {
            final String purchaseToken = args['purchaseToken'] as String;
            consumeCompleter.complete(purchaseToken);
          });

      final Stream<List<PurchaseDetails>> purchaseStream =
          iapAndroidPlatform.purchaseStream;
      late StreamSubscription<List<PurchaseDetails>> subscription;
      subscription = purchaseStream.listen((_) {
        consumeCompleter.complete(null);
        subscription.cancel();
      }, onDone: () {});
      final GooglePlayPurchaseParam purchaseParam = GooglePlayPurchaseParam(
          productDetails: GooglePlayProductDetails.fromSkuDetails(skuDetails),
          applicationUserName: accountId);
      await iapAndroidPlatform.buyConsumable(
          purchaseParam: purchaseParam, autoConsume: false);
      expect(null, await consumeCompleter.future);
    });

    test(
        'should get canceled purchase status when response code is BillingResponse.userCanceled',
        () async {
      const SkuDetailsWrapper skuDetails = dummySkuDetails;
      const String accountId = 'hashedAccountId';
      const String debugMessage = 'dummy message';
      const BillingResponse sentCode = BillingResponse.userCanceled;
      const BillingResultWrapper expectedBillingResult = BillingResultWrapper(
          responseCode: sentCode, debugMessage: debugMessage);
      stubPlatform.addResponse(
          name: launchMethodName,
          value: buildBillingResultMap(expectedBillingResult),
          additionalStepBeforeReturn: (dynamic _) {
            // Mock java update purchase callback.
            final MethodCall call =
                MethodCall(kOnPurchasesUpdated, <dynamic, dynamic>{
              'billingResult': buildBillingResultMap(expectedBillingResult),
              'responseCode': const BillingResponseConverter().toJson(sentCode),
              'purchasesList': <dynamic>[
                <dynamic, dynamic>{
                  'orderId': 'orderID1',
                  'sku': skuDetails.sku,
                  'isAutoRenewing': false,
                  'packageName': 'package',
                  'purchaseTime': 1231231231,
                  'purchaseToken': 'token',
                  'signature': 'sign',
                  'originalJson': 'json',
                  'developerPayload': 'dummy payload',
                  'isAcknowledged': true,
                  'purchaseState': 1,
                }
              ]
            });
            iapAndroidPlatform.billingClient.callHandler(call);
          });
      final Completer<String> consumeCompleter = Completer<String>();
      // adding call back for consume purchase
      const BillingResponse expectedCode = BillingResponse.userCanceled;
      const BillingResultWrapper expectedBillingResultForConsume =
          BillingResultWrapper(
              responseCode: expectedCode, debugMessage: debugMessage);
      stubPlatform.addResponse(
          name: consumeMethodName,
          value: buildBillingResultMap(expectedBillingResultForConsume),
          additionalStepBeforeReturn: (dynamic args) {
            final String purchaseToken = args['purchaseToken'] as String;
            consumeCompleter.complete(purchaseToken);
          });

      final Completer<PurchaseDetails> completer = Completer<PurchaseDetails>();
      PurchaseDetails purchaseDetails;
      final Stream<List<PurchaseDetails>> purchaseStream =
          iapAndroidPlatform.purchaseStream;
      late StreamSubscription<List<PurchaseDetails>> subscription;
      subscription = purchaseStream.listen((_) {
        purchaseDetails = _.first;
        completer.complete(purchaseDetails);
        subscription.cancel();
      }, onDone: () {});
      final GooglePlayPurchaseParam purchaseParam = GooglePlayPurchaseParam(
          productDetails: GooglePlayProductDetails.fromSkuDetails(skuDetails),
          applicationUserName: accountId);
      await iapAndroidPlatform.buyConsumable(purchaseParam: purchaseParam);

      // Verify that the result has an error for the failed consumption
      final GooglePlayPurchaseDetails result =
          await completer.future as GooglePlayPurchaseDetails;
      expect(result.status, PurchaseStatus.canceled);
    });

    test(
        'should get purchased purchase status when upgrading subscription by deferred proration mode',
        () async {
      const SkuDetailsWrapper skuDetails = dummySkuDetails;
      const String accountId = 'hashedAccountId';
      const String debugMessage = 'dummy message';
      const BillingResponse sentCode = BillingResponse.ok;
      const BillingResultWrapper expectedBillingResult = BillingResultWrapper(
          responseCode: sentCode, debugMessage: debugMessage);
      stubPlatform.addResponse(
          name: launchMethodName,
          value: buildBillingResultMap(expectedBillingResult),
          additionalStepBeforeReturn: (dynamic _) {
            // Mock java update purchase callback.
            final MethodCall call =
                MethodCall(kOnPurchasesUpdated, <dynamic, dynamic>{
              'billingResult': buildBillingResultMap(expectedBillingResult),
              'responseCode': const BillingResponseConverter().toJson(sentCode),
              'purchasesList': const <dynamic>[]
            });
            iapAndroidPlatform.billingClient.callHandler(call);
          });

      final Completer<PurchaseDetails> completer = Completer<PurchaseDetails>();
      PurchaseDetails purchaseDetails;
      final Stream<List<PurchaseDetails>> purchaseStream =
          iapAndroidPlatform.purchaseStream;
      late StreamSubscription<List<PurchaseDetails>> subscription;
      subscription = purchaseStream.listen((_) {
        purchaseDetails = _.first;
        completer.complete(purchaseDetails);
        subscription.cancel();
      }, onDone: () {});
      final GooglePlayPurchaseParam purchaseParam = GooglePlayPurchaseParam(
          productDetails: GooglePlayProductDetails.fromSkuDetails(skuDetails),
          applicationUserName: accountId,
          changeSubscriptionParam: ChangeSubscriptionParam(
            oldPurchaseDetails: GooglePlayPurchaseDetails.fromPurchase(
                dummyUnacknowledgedPurchase),
            prorationMode: ProrationMode.deferred,
          ));
      await iapAndroidPlatform.buyNonConsumable(purchaseParam: purchaseParam);

      final PurchaseDetails result = await completer.future;
      expect(result.status, PurchaseStatus.purchased);
    });
  });

  group('complete purchase', () {
    const String completeMethodName =
        'BillingClient#(AcknowledgePurchaseParams params, (AcknowledgePurchaseParams, AcknowledgePurchaseResponseListener)';
    test('complete purchase success', () async {
      const BillingResponse expectedCode = BillingResponse.ok;
      const String debugMessage = 'dummy message';
      const BillingResultWrapper expectedBillingResult = BillingResultWrapper(
          responseCode: expectedCode, debugMessage: debugMessage);
      stubPlatform.addResponse(
        name: completeMethodName,
        value: buildBillingResultMap(expectedBillingResult),
      );
      final PurchaseDetails purchaseDetails =
          GooglePlayPurchaseDetails.fromPurchase(dummyUnacknowledgedPurchase);
      final Completer<BillingResultWrapper> completer =
          Completer<BillingResultWrapper>();
      purchaseDetails.status = PurchaseStatus.purchased;
      if (purchaseDetails.pendingCompletePurchase) {
        final BillingResultWrapper billingResultWrapper =
            await iapAndroidPlatform.completePurchase(purchaseDetails);
        expect(billingResultWrapper, equals(expectedBillingResult));
        completer.complete(billingResultWrapper);
      }
      expect(await completer.future, equals(expectedBillingResult));
    });
  });
}
