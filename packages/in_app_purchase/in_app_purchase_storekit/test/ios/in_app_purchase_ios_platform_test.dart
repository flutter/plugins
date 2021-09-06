// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:in_app_purchase_ios/in_app_purchase_ios.dart';
import 'package:in_app_purchase_ios/src/store_kit_wrappers/enum_converters.dart';
import 'package:in_app_purchase_ios/store_kit_wrappers.dart';
import 'package:in_app_purchase_platform_interface/in_app_purchase_platform_interface.dart';

import 'fakes/fake_ios_platform.dart';
import 'store_kit_wrappers/sk_test_stub_objects.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final FakeIOSPlatform fakeIOSPlatform = FakeIOSPlatform();
  late InAppPurchaseIosPlatform iapIosPlatform;

  setUpAll(() {
    SystemChannels.platform
        .setMockMethodCallHandler(fakeIOSPlatform.onMethodCall);
  });

  setUp(() {
    InAppPurchaseIosPlatform.registerPlatform();
    iapIosPlatform = InAppPurchasePlatform.instance as InAppPurchaseIosPlatform;
    fakeIOSPlatform.reset();
  });

  tearDown(() => fakeIOSPlatform.reset());

  group('isAvailable', () {
    test('true', () async {
      expect(await iapIosPlatform.isAvailable(), isTrue);
    });
  });

  group('query product list', () {
    test('should get product list and correct invalid identifiers', () async {
      final InAppPurchaseIosPlatform connection = InAppPurchaseIosPlatform();
      final ProductDetailsResponse response = await connection
          .queryProductDetails(<String>['123', '456', '789'].toSet());
      List<ProductDetails> products = response.productDetails;
      expect(products.first.id, '123');
      expect(products[1].id, '456');
      expect(response.notFoundIDs, ['789']);
      expect(response.error, isNull);
      expect(response.productDetails.first.currencySymbol, r'$');
      expect(response.productDetails[1].currencySymbol, 'EUR');
    });

    test(
        'if query products throws error, should get error object in the response',
        () async {
      fakeIOSPlatform.queryProductException = PlatformException(
          code: 'error_code',
          message: 'error_message',
          details: {'info': 'error_info'});
      final InAppPurchaseIosPlatform connection = InAppPurchaseIosPlatform();
      final ProductDetailsResponse response = await connection
          .queryProductDetails(<String>['123', '456', '789'].toSet());
      expect(response.productDetails, []);
      expect(response.notFoundIDs, ['123', '456', '789']);
      expect(response.error, isNotNull);
      expect(response.error!.source, kIAPSource);
      expect(response.error!.code, 'error_code');
      expect(response.error!.message, 'error_message');
      expect(response.error!.details, {'info': 'error_info'});
    });
  });

  group('restore purchases', () {
    test('should emit restored transactions on purchase stream', () async {
      Completer completer = Completer();
      Stream<List<PurchaseDetails>> stream = iapIosPlatform.purchaseStream;

      late StreamSubscription subscription;
      subscription = stream.listen((purchaseDetailsList) {
        if (purchaseDetailsList.first.status == PurchaseStatus.restored) {
          completer.complete(purchaseDetailsList);
          subscription.cancel();
        }
      });

      await iapIosPlatform.restorePurchases();
      List<PurchaseDetails> details = await completer.future;

      expect(details.length, 2);
      for (int i = 0; i < fakeIOSPlatform.transactions.length; i++) {
        SKPaymentTransactionWrapper expected = fakeIOSPlatform.transactions[i];
        PurchaseDetails actual = details[i];

        expect(actual.purchaseID, expected.transactionIdentifier);
        expect(actual.verificationData, isNotNull);
        expect(actual.status, PurchaseStatus.restored);
        expect(actual.verificationData.localVerificationData,
            fakeIOSPlatform.receiptData);
        expect(actual.verificationData.serverVerificationData,
            fakeIOSPlatform.receiptData);
        expect(actual.pendingCompletePurchase, true);
      }
    });

    test('should not block transaction updates', () async {
      fakeIOSPlatform.transactions
          .insert(0, fakeIOSPlatform.createPurchasedTransaction('foo', 'bar'));
      Completer completer = Completer();
      Stream<List<PurchaseDetails>> stream = iapIosPlatform.purchaseStream;

      late StreamSubscription subscription;
      subscription = stream.listen((purchaseDetailsList) {
        if (purchaseDetailsList.first.status == PurchaseStatus.purchased) {
          completer.complete(purchaseDetailsList);
          subscription.cancel();
        }
      });
      await iapIosPlatform.restorePurchases();
      List<PurchaseDetails> details = await completer.future;
      expect(details.length, 3);
      for (int i = 0; i < fakeIOSPlatform.transactions.length; i++) {
        SKPaymentTransactionWrapper expected = fakeIOSPlatform.transactions[i];
        PurchaseDetails actual = details[i];

        expect(actual.purchaseID, expected.transactionIdentifier);
        expect(actual.verificationData, isNotNull);
        expect(
          actual.status,
          SKTransactionStatusConverter()
              .toPurchaseStatus(expected.transactionState),
        );
        expect(actual.verificationData.localVerificationData,
            fakeIOSPlatform.receiptData);
        expect(actual.verificationData.serverVerificationData,
            fakeIOSPlatform.receiptData);
        expect(actual.pendingCompletePurchase, true);
      }
    });

    test('receipt error should populate null to verificationData.data',
        () async {
      fakeIOSPlatform.receiptData = null;
      Completer completer = Completer();
      Stream<List<PurchaseDetails>> stream = iapIosPlatform.purchaseStream;

      late StreamSubscription subscription;
      subscription = stream.listen((purchaseDetailsList) {
        if (purchaseDetailsList.first.status == PurchaseStatus.restored) {
          completer.complete(purchaseDetailsList);
          subscription.cancel();
        }
      });

      await iapIosPlatform.restorePurchases();
      List<PurchaseDetails> details = await completer.future;

      for (PurchaseDetails purchase in details) {
        expect(purchase.verificationData.localVerificationData, isEmpty);
        expect(purchase.verificationData.serverVerificationData, isEmpty);
      }
    });

    test('test restore error', () {
      fakeIOSPlatform.testRestoredError = SKError(
          code: 123,
          domain: 'error_test',
          userInfo: {'message': 'errorMessage'});

      expect(
          () => iapIosPlatform.restorePurchases(),
          throwsA(
            isA<SKError>()
                .having((error) => error.code, 'code', 123)
                .having((error) => error.domain, 'domain', 'error_test')
                .having((error) => error.userInfo, 'userInfo',
                    {'message': 'errorMessage'}),
          ));
    });
  });

  group('make payment', () {
    test(
        'buying non consumable, should get purchase objects in the purchase update callback',
        () async {
      List<PurchaseDetails> details = [];
      Completer completer = Completer();
      Stream<List<PurchaseDetails>> stream = iapIosPlatform.purchaseStream;

      late StreamSubscription subscription;
      subscription = stream.listen((purchaseDetailsList) {
        details.addAll(purchaseDetailsList);
        if (purchaseDetailsList.first.status == PurchaseStatus.purchased) {
          completer.complete(details);
          subscription.cancel();
        }
      });
      final AppStorePurchaseParam purchaseParam = AppStorePurchaseParam(
          productDetails:
              AppStoreProductDetails.fromSKProduct(dummyProductWrapper),
          applicationUserName: 'appName');
      await iapIosPlatform.buyNonConsumable(purchaseParam: purchaseParam);

      List<PurchaseDetails> result = await completer.future;
      expect(result.length, 2);
      expect(result.first.productID, dummyProductWrapper.productIdentifier);
    });

    test(
        'buying consumable, should get purchase objects in the purchase update callback',
        () async {
      List<PurchaseDetails> details = [];
      Completer completer = Completer();
      Stream<List<PurchaseDetails>> stream = iapIosPlatform.purchaseStream;

      late StreamSubscription subscription;
      subscription = stream.listen((purchaseDetailsList) {
        details.addAll(purchaseDetailsList);
        if (purchaseDetailsList.first.status == PurchaseStatus.purchased) {
          completer.complete(details);
          subscription.cancel();
        }
      });
      final AppStorePurchaseParam purchaseParam = AppStorePurchaseParam(
          productDetails:
              AppStoreProductDetails.fromSKProduct(dummyProductWrapper),
          applicationUserName: 'appName');
      await iapIosPlatform.buyConsumable(purchaseParam: purchaseParam);

      List<PurchaseDetails> result = await completer.future;
      expect(result.length, 2);
      expect(result.first.productID, dummyProductWrapper.productIdentifier);
    });

    test('buying consumable, should throw when autoConsume is false', () async {
      final AppStorePurchaseParam purchaseParam = AppStorePurchaseParam(
          productDetails:
              AppStoreProductDetails.fromSKProduct(dummyProductWrapper),
          applicationUserName: 'appName');
      expect(
          () => iapIosPlatform.buyConsumable(
              purchaseParam: purchaseParam, autoConsume: false),
          throwsA(isInstanceOf<AssertionError>()));
    });

    test('should get failed purchase status', () async {
      fakeIOSPlatform.testTransactionFail = true;
      List<PurchaseDetails> details = [];
      Completer completer = Completer();
      late IAPError error;

      Stream<List<PurchaseDetails>> stream = iapIosPlatform.purchaseStream;
      late StreamSubscription subscription;
      subscription = stream.listen((purchaseDetailsList) {
        details.addAll(purchaseDetailsList);
        purchaseDetailsList.forEach((purchaseDetails) {
          if (purchaseDetails.status == PurchaseStatus.error) {
            error = purchaseDetails.error!;
            completer.complete(error);
            subscription.cancel();
          }
        });
      });
      final AppStorePurchaseParam purchaseParam = AppStorePurchaseParam(
          productDetails:
              AppStoreProductDetails.fromSKProduct(dummyProductWrapper),
          applicationUserName: 'appName');
      await iapIosPlatform.buyNonConsumable(purchaseParam: purchaseParam);

      IAPError completerError = await completer.future;
      expect(completerError.code, 'purchase_error');
      expect(completerError.source, kIAPSource);
      expect(completerError.message, 'ios_domain');
      expect(completerError.details, {'message': 'an error message'});
    });
  });

  group('complete purchase', () {
    test('should complete purchase', () async {
      List<PurchaseDetails> details = [];
      Completer completer = Completer();
      Stream<List<PurchaseDetails>> stream = iapIosPlatform.purchaseStream;
      late StreamSubscription subscription;
      subscription = stream.listen((purchaseDetailsList) {
        details.addAll(purchaseDetailsList);
        purchaseDetailsList.forEach((purchaseDetails) {
          if (purchaseDetails.pendingCompletePurchase) {
            iapIosPlatform.completePurchase(purchaseDetails);
            completer.complete(details);
            subscription.cancel();
          }
        });
      });
      final AppStorePurchaseParam purchaseParam = AppStorePurchaseParam(
          productDetails:
              AppStoreProductDetails.fromSKProduct(dummyProductWrapper),
          applicationUserName: 'appName');
      await iapIosPlatform.buyNonConsumable(purchaseParam: purchaseParam);
      List<PurchaseDetails> result = await completer.future;
      expect(result.length, 2);
      expect(result.first.productID, dummyProductWrapper.productIdentifier);
      expect(fakeIOSPlatform.finishedTransactions.length, 1);
    });
  });

  group('purchase stream', () {
    test('Should only have active queue when purchaseStream has listeners', () {
      Stream<List<PurchaseDetails>> stream = iapIosPlatform.purchaseStream;
      expect(fakeIOSPlatform.queueIsActive, false);
      StreamSubscription subscription1 = stream.listen((event) {});
      expect(fakeIOSPlatform.queueIsActive, true);
      StreamSubscription subscription2 = stream.listen((event) {});
      expect(fakeIOSPlatform.queueIsActive, true);
      subscription1.cancel();
      expect(fakeIOSPlatform.queueIsActive, true);
      subscription2.cancel();
      expect(fakeIOSPlatform.queueIsActive, false);
    });
  });
}
