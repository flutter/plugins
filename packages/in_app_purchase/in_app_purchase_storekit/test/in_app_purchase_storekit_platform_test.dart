// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:in_app_purchase_storekit/in_app_purchase_storekit.dart';
import 'package:in_app_purchase_storekit/src/store_kit_wrappers/enum_converters.dart';
import 'package:in_app_purchase_storekit/store_kit_wrappers.dart';
import 'package:in_app_purchase_platform_interface/in_app_purchase_platform_interface.dart';

import 'fakes/fake_storekit_platform.dart';
import 'store_kit_wrappers/sk_test_stub_objects.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final FakeStoreKitPlatform fakeStoreKitPlatform = FakeStoreKitPlatform();
  late InAppPurchaseStoreKitPlatform iapStoreKitPlatform;

  setUpAll(() {
    SystemChannels.platform
        .setMockMethodCallHandler(fakeStoreKitPlatform.onMethodCall);
  });

  setUp(() {
    InAppPurchaseStoreKitPlatform.registerPlatform();
    iapStoreKitPlatform =
        InAppPurchasePlatform.instance as InAppPurchaseStoreKitPlatform;
    fakeStoreKitPlatform.reset();
  });

  tearDown(() => fakeStoreKitPlatform.reset());

  group('isAvailable', () {
    test('true', () async {
      expect(await iapStoreKitPlatform.isAvailable(), isTrue);
    });
  });

  group('query product list', () {
    test('should get product list and correct invalid identifiers', () async {
      final InAppPurchaseStoreKitPlatform connection =
          InAppPurchaseStoreKitPlatform();
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
      fakeStoreKitPlatform.queryProductException = PlatformException(
          code: 'error_code',
          message: 'error_message',
          details: {'info': 'error_info'});
      final InAppPurchaseStoreKitPlatform connection =
          InAppPurchaseStoreKitPlatform();
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
      fakeStoreKitPlatform.transactions.insert(
          0, fakeStoreKitPlatform.createRestoredTransaction('foo', 'RT1'));
      fakeStoreKitPlatform.transactions.insert(
          1, fakeStoreKitPlatform.createRestoredTransaction('foo', 'RT2'));
      Completer completer = Completer();
      Stream<List<PurchaseDetails>> stream = iapStoreKitPlatform.purchaseStream;

      late StreamSubscription subscription;
      subscription = stream.listen((purchaseDetailsList) {
        if (purchaseDetailsList.first.status == PurchaseStatus.restored) {
          subscription.cancel();
          completer.complete(purchaseDetailsList);
        }
      });

      await iapStoreKitPlatform.restorePurchases();
      List<PurchaseDetails> details = await completer.future;

      expect(details.length, 2);
      for (int i = 0; i < fakeStoreKitPlatform.transactions.length; i++) {
        SKPaymentTransactionWrapper expected =
            fakeStoreKitPlatform.transactions[i];
        PurchaseDetails actual = details[i];

        expect(actual.purchaseID, expected.transactionIdentifier);
        expect(actual.verificationData, isNotNull);
        expect(actual.status, PurchaseStatus.restored);
        expect(actual.verificationData.localVerificationData,
            fakeStoreKitPlatform.receiptData);
        expect(actual.verificationData.serverVerificationData,
            fakeStoreKitPlatform.receiptData);
        expect(actual.pendingCompletePurchase, true);
      }
    });

    test(
        'should emit empty transaction list on purchase stream when there is nothing to restore',
        () async {
      fakeStoreKitPlatform.testRestoredTransactionsNull = true;
      Completer completer = Completer();
      Stream<List<PurchaseDetails>> stream = iapStoreKitPlatform.purchaseStream;

      late StreamSubscription subscription;
      subscription = stream.listen((purchaseDetailsList) {
        expect(purchaseDetailsList.isEmpty, true);
        subscription.cancel();
        completer.complete();
      });

      await iapStoreKitPlatform.restorePurchases();
      await completer.future;
    });

    test('should not block transaction updates', () async {
      fakeStoreKitPlatform.transactions.insert(
          0, fakeStoreKitPlatform.createRestoredTransaction('foo', 'RT1'));
      fakeStoreKitPlatform.transactions.insert(
          1, fakeStoreKitPlatform.createPurchasedTransaction('foo', 'bar'));
      fakeStoreKitPlatform.transactions.insert(
          2, fakeStoreKitPlatform.createRestoredTransaction('foo', 'RT2'));
      Completer completer = Completer();
      Stream<List<PurchaseDetails>> stream = iapStoreKitPlatform.purchaseStream;

      late StreamSubscription subscription;
      subscription = stream.listen((purchaseDetailsList) {
        if (purchaseDetailsList[1].status == PurchaseStatus.purchased) {
          completer.complete(purchaseDetailsList);
          subscription.cancel();
        }
      });
      await iapStoreKitPlatform.restorePurchases();
      List<PurchaseDetails> details = await completer.future;
      expect(details.length, 3);
      for (int i = 0; i < fakeStoreKitPlatform.transactions.length; i++) {
        SKPaymentTransactionWrapper expected =
            fakeStoreKitPlatform.transactions[i];
        PurchaseDetails actual = details[i];

        expect(actual.purchaseID, expected.transactionIdentifier);
        expect(actual.verificationData, isNotNull);
        expect(
          actual.status,
          SKTransactionStatusConverter()
              .toPurchaseStatus(expected.transactionState, expected.error),
        );
        expect(actual.verificationData.localVerificationData,
            fakeStoreKitPlatform.receiptData);
        expect(actual.verificationData.serverVerificationData,
            fakeStoreKitPlatform.receiptData);
        expect(actual.pendingCompletePurchase, true);
      }
    });

    test(
        'should emit empty transaction if transactions array does not contain a transaction with PurchaseStatus.restored status.',
        () async {
      fakeStoreKitPlatform.transactions.insert(
          0, fakeStoreKitPlatform.createPurchasedTransaction('foo', 'bar'));
      Completer completer = Completer();
      Stream<List<PurchaseDetails>> stream = iapStoreKitPlatform.purchaseStream;
      List<List<PurchaseDetails>> purchaseDetails = [];

      late StreamSubscription subscription;
      subscription = stream.listen((purchaseDetailsList) {
        purchaseDetails.add(purchaseDetailsList);

        if (purchaseDetails.length == 2) {
          completer.complete(purchaseDetails);
          subscription.cancel();
        }
      });
      await iapStoreKitPlatform.restorePurchases();
      final details = await completer.future;
      expect(details.length, 2);
      expect(details[0], []);
      for (int i = 0; i < fakeStoreKitPlatform.transactions.length; i++) {
        SKPaymentTransactionWrapper expected =
            fakeStoreKitPlatform.transactions[i];
        PurchaseDetails actual = details[1][i];

        expect(actual.purchaseID, expected.transactionIdentifier);
        expect(actual.verificationData, isNotNull);
        expect(
          actual.status,
          SKTransactionStatusConverter()
              .toPurchaseStatus(expected.transactionState, expected.error),
        );
        expect(actual.verificationData.localVerificationData,
            fakeStoreKitPlatform.receiptData);
        expect(actual.verificationData.serverVerificationData,
            fakeStoreKitPlatform.receiptData);
        expect(actual.pendingCompletePurchase, true);
      }
    });

    test('receipt error should populate null to verificationData.data',
        () async {
      fakeStoreKitPlatform.transactions.insert(
          0, fakeStoreKitPlatform.createRestoredTransaction('foo', 'RT1'));
      fakeStoreKitPlatform.transactions.insert(
          1, fakeStoreKitPlatform.createRestoredTransaction('foo', 'RT2'));
      fakeStoreKitPlatform.receiptData = null;
      Completer completer = Completer();
      Stream<List<PurchaseDetails>> stream = iapStoreKitPlatform.purchaseStream;

      late StreamSubscription subscription;
      subscription = stream.listen((purchaseDetailsList) {
        if (purchaseDetailsList.first.status == PurchaseStatus.restored) {
          completer.complete(purchaseDetailsList);
          subscription.cancel();
        }
      });

      await iapStoreKitPlatform.restorePurchases();
      List<PurchaseDetails> details = await completer.future;

      for (PurchaseDetails purchase in details) {
        expect(purchase.verificationData.localVerificationData, isEmpty);
        expect(purchase.verificationData.serverVerificationData, isEmpty);
      }
    });

    test('test restore error', () {
      fakeStoreKitPlatform.testRestoredError = SKError(
          code: 123,
          domain: 'error_test',
          userInfo: {'message': 'errorMessage'});

      expect(
          () => iapStoreKitPlatform.restorePurchases(),
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
      Stream<List<PurchaseDetails>> stream = iapStoreKitPlatform.purchaseStream;

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
      await iapStoreKitPlatform.buyNonConsumable(purchaseParam: purchaseParam);

      List<PurchaseDetails> result = await completer.future;
      expect(result.length, 2);
      expect(result.first.productID, dummyProductWrapper.productIdentifier);
    });

    test(
        'buying consumable, should get purchase objects in the purchase update callback',
        () async {
      List<PurchaseDetails> details = [];
      Completer completer = Completer();
      Stream<List<PurchaseDetails>> stream = iapStoreKitPlatform.purchaseStream;

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
      await iapStoreKitPlatform.buyConsumable(purchaseParam: purchaseParam);

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
          () => iapStoreKitPlatform.buyConsumable(
              purchaseParam: purchaseParam, autoConsume: false),
          throwsA(isInstanceOf<AssertionError>()));
    });

    test('should get failed purchase status', () async {
      fakeStoreKitPlatform.testTransactionFail = true;
      List<PurchaseDetails> details = [];
      Completer completer = Completer();
      late IAPError error;

      Stream<List<PurchaseDetails>> stream = iapStoreKitPlatform.purchaseStream;
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
      await iapStoreKitPlatform.buyNonConsumable(purchaseParam: purchaseParam);

      IAPError completerError = await completer.future;
      expect(completerError.code, 'purchase_error');
      expect(completerError.source, kIAPSource);
      expect(completerError.message, 'ios_domain');
      expect(completerError.details, {'message': 'an error message'});
    });

    test(
        'should get canceled purchase status when error code is SKErrorPaymentCancelled',
        () async {
      fakeStoreKitPlatform.testTransactionCancel = 2;
      List<PurchaseDetails> details = [];
      Completer completer = Completer();

      Stream<List<PurchaseDetails>> stream = iapStoreKitPlatform.purchaseStream;
      late StreamSubscription subscription;
      subscription = stream.listen((purchaseDetailsList) {
        details.addAll(purchaseDetailsList);
        purchaseDetailsList.forEach((purchaseDetails) {
          if (purchaseDetails.status == PurchaseStatus.canceled) {
            completer.complete(purchaseDetails.status);
            subscription.cancel();
          }
        });
      });
      final AppStorePurchaseParam purchaseParam = AppStorePurchaseParam(
          productDetails:
              AppStoreProductDetails.fromSKProduct(dummyProductWrapper),
          applicationUserName: 'appName');
      await iapStoreKitPlatform.buyNonConsumable(purchaseParam: purchaseParam);

      PurchaseStatus purchaseStatus = await completer.future;
      expect(purchaseStatus, PurchaseStatus.canceled);
    });

    test(
        'should get canceled purchase status when error code is SKErrorOverlayCancelled',
        () async {
      fakeStoreKitPlatform.testTransactionCancel = 15;
      List<PurchaseDetails> details = [];
      Completer completer = Completer();

      Stream<List<PurchaseDetails>> stream = iapStoreKitPlatform.purchaseStream;
      late StreamSubscription subscription;
      subscription = stream.listen((purchaseDetailsList) {
        details.addAll(purchaseDetailsList);
        purchaseDetailsList.forEach((purchaseDetails) {
          if (purchaseDetails.status == PurchaseStatus.canceled) {
            completer.complete(purchaseDetails.status);
            subscription.cancel();
          }
        });
      });
      final AppStorePurchaseParam purchaseParam = AppStorePurchaseParam(
          productDetails:
              AppStoreProductDetails.fromSKProduct(dummyProductWrapper),
          applicationUserName: 'appName');
      await iapStoreKitPlatform.buyNonConsumable(purchaseParam: purchaseParam);

      PurchaseStatus purchaseStatus = await completer.future;
      expect(purchaseStatus, PurchaseStatus.canceled);
    });
  });

  group('complete purchase', () {
    test('should complete purchase', () async {
      List<PurchaseDetails> details = [];
      Completer completer = Completer();
      Stream<List<PurchaseDetails>> stream = iapStoreKitPlatform.purchaseStream;
      late StreamSubscription subscription;
      subscription = stream.listen((purchaseDetailsList) {
        details.addAll(purchaseDetailsList);
        purchaseDetailsList.forEach((purchaseDetails) {
          if (purchaseDetails.pendingCompletePurchase) {
            iapStoreKitPlatform.completePurchase(purchaseDetails);
            completer.complete(details);
            subscription.cancel();
          }
        });
      });
      final AppStorePurchaseParam purchaseParam = AppStorePurchaseParam(
          productDetails:
              AppStoreProductDetails.fromSKProduct(dummyProductWrapper),
          applicationUserName: 'appName');
      await iapStoreKitPlatform.buyNonConsumable(purchaseParam: purchaseParam);
      List<PurchaseDetails> result = await completer.future;
      expect(result.length, 2);
      expect(result.first.productID, dummyProductWrapper.productIdentifier);
      expect(fakeStoreKitPlatform.finishedTransactions.length, 1);
    });
  });

  group('purchase stream', () {
    test('Should only have active queue when purchaseStream has listeners', () {
      Stream<List<PurchaseDetails>> stream = iapStoreKitPlatform.purchaseStream;
      expect(fakeStoreKitPlatform.queueIsActive, false);
      StreamSubscription subscription1 = stream.listen((event) {});
      expect(fakeStoreKitPlatform.queueIsActive, true);
      StreamSubscription subscription2 = stream.listen((event) {});
      expect(fakeStoreKitPlatform.queueIsActive, true);
      subscription1.cancel();
      expect(fakeStoreKitPlatform.queueIsActive, true);
      subscription2.cancel();
      expect(fakeStoreKitPlatform.queueIsActive, false);
    });
  });
}
