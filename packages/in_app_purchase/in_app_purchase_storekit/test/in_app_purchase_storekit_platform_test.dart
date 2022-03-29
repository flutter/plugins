// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:in_app_purchase_platform_interface/in_app_purchase_platform_interface.dart';
import 'package:in_app_purchase_storekit/in_app_purchase_storekit.dart';
import 'package:in_app_purchase_storekit/src/store_kit_wrappers/enum_converters.dart';
import 'package:in_app_purchase_storekit/store_kit_wrappers.dart';

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
      final ProductDetailsResponse response =
          await connection.queryProductDetails(<String>{'123', '456', '789'});
      final List<ProductDetails> products = response.productDetails;
      expect(products.first.id, '123');
      expect(products[1].id, '456');
      expect(response.notFoundIDs, <String>['789']);
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
          details: <Object, Object>{'info': 'error_info'});
      final InAppPurchaseStoreKitPlatform connection =
          InAppPurchaseStoreKitPlatform();
      final ProductDetailsResponse response =
          await connection.queryProductDetails(<String>{'123', '456', '789'});
      expect(response.productDetails, <ProductDetails>[]);
      expect(response.notFoundIDs, <String>['123', '456', '789']);
      expect(response.error, isNotNull);
      expect(response.error!.source, kIAPSource);
      expect(response.error!.code, 'error_code');
      expect(response.error!.message, 'error_message');
      expect(response.error!.details, <Object, Object>{'info': 'error_info'});
    });
  });

  group('restore purchases', () {
    test('should emit restored transactions on purchase stream', () async {
      fakeStoreKitPlatform.transactions.insert(
          0, fakeStoreKitPlatform.createRestoredTransaction('foo', 'RT1'));
      fakeStoreKitPlatform.transactions.insert(
          1, fakeStoreKitPlatform.createRestoredTransaction('foo', 'RT2'));
      final Completer<List<PurchaseDetails>> completer =
          Completer<List<PurchaseDetails>>();
      final Stream<List<PurchaseDetails>> stream =
          iapStoreKitPlatform.purchaseStream;

      late StreamSubscription<List<PurchaseDetails>> subscription;
      subscription = stream.listen((List<PurchaseDetails> purchaseDetailsList) {
        if (purchaseDetailsList.first.status == PurchaseStatus.restored) {
          subscription.cancel();
          completer.complete(purchaseDetailsList);
        }
      });

      await iapStoreKitPlatform.restorePurchases();
      final List<PurchaseDetails> details = await completer.future;

      expect(details.length, 2);
      for (int i = 0; i < fakeStoreKitPlatform.transactions.length; i++) {
        final SKPaymentTransactionWrapper expected =
            fakeStoreKitPlatform.transactions[i];
        final PurchaseDetails actual = details[i];

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
      final Completer<List<PurchaseDetails>?> completer =
          Completer<List<PurchaseDetails>?>();
      final Stream<List<PurchaseDetails>> stream =
          iapStoreKitPlatform.purchaseStream;

      late StreamSubscription<List<PurchaseDetails>> subscription;
      subscription = stream.listen((List<PurchaseDetails> purchaseDetailsList) {
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
      final Completer<List<PurchaseDetails>> completer =
          Completer<List<PurchaseDetails>>();
      final Stream<List<PurchaseDetails>> stream =
          iapStoreKitPlatform.purchaseStream;

      late StreamSubscription<List<PurchaseDetails>> subscription;
      subscription = stream.listen((List<PurchaseDetails> purchaseDetailsList) {
        if (purchaseDetailsList[1].status == PurchaseStatus.purchased) {
          completer.complete(purchaseDetailsList);
          subscription.cancel();
        }
      });
      await iapStoreKitPlatform.restorePurchases();
      final List<PurchaseDetails> details = await completer.future;
      expect(details.length, 3);
      for (int i = 0; i < fakeStoreKitPlatform.transactions.length; i++) {
        final SKPaymentTransactionWrapper expected =
            fakeStoreKitPlatform.transactions[i];
        final PurchaseDetails actual = details[i];

        expect(actual.purchaseID, expected.transactionIdentifier);
        expect(actual.verificationData, isNotNull);
        expect(
          actual.status,
          const SKTransactionStatusConverter()
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
      final Completer<List<List<PurchaseDetails>>> completer =
          Completer<List<List<PurchaseDetails>>>();
      final Stream<List<PurchaseDetails>> stream =
          iapStoreKitPlatform.purchaseStream;
      final List<List<PurchaseDetails>> purchaseDetails =
          <List<PurchaseDetails>>[];

      late StreamSubscription<List<PurchaseDetails>> subscription;
      subscription = stream.listen((List<PurchaseDetails> purchaseDetailsList) {
        purchaseDetails.add(purchaseDetailsList);

        if (purchaseDetails.length == 2) {
          completer.complete(purchaseDetails);
          subscription.cancel();
        }
      });
      await iapStoreKitPlatform.restorePurchases();
      final List<List<PurchaseDetails>> details = await completer.future;
      expect(details.length, 2);
      expect(details[0], <List<PurchaseDetails>>[]);
      for (int i = 0; i < fakeStoreKitPlatform.transactions.length; i++) {
        final SKPaymentTransactionWrapper expected =
            fakeStoreKitPlatform.transactions[i];
        final PurchaseDetails actual = details[1][i];

        expect(actual.purchaseID, expected.transactionIdentifier);
        expect(actual.verificationData, isNotNull);
        expect(
          actual.status,
          const SKTransactionStatusConverter()
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
      final Completer<List<PurchaseDetails>> completer =
          Completer<List<PurchaseDetails>>();
      final Stream<List<PurchaseDetails>> stream =
          iapStoreKitPlatform.purchaseStream;

      late StreamSubscription<List<PurchaseDetails>> subscription;
      subscription = stream.listen((List<PurchaseDetails> purchaseDetailsList) {
        if (purchaseDetailsList.first.status == PurchaseStatus.restored) {
          completer.complete(purchaseDetailsList);
          subscription.cancel();
        }
      });

      await iapStoreKitPlatform.restorePurchases();
      final List<PurchaseDetails> details = await completer.future;

      for (final PurchaseDetails purchase in details) {
        expect(purchase.verificationData.localVerificationData, isEmpty);
        expect(purchase.verificationData.serverVerificationData, isEmpty);
      }
    });

    test('test restore error', () {
      fakeStoreKitPlatform.testRestoredError = const SKError(
          code: 123,
          domain: 'error_test',
          userInfo: <String, dynamic>{'message': 'errorMessage'});

      expect(
          () => iapStoreKitPlatform.restorePurchases(),
          throwsA(
            isA<SKError>()
                .having((SKError error) => error.code, 'code', 123)
                .having((SKError error) => error.domain, 'domain', 'error_test')
                .having((SKError error) => error.userInfo, 'userInfo',
                    <String, dynamic>{'message': 'errorMessage'}),
          ));
    });
  });

  group('make payment', () {
    test(
        'buying non consumable, should get purchase objects in the purchase update callback',
        () async {
      final List<PurchaseDetails> details = <PurchaseDetails>[];
      final Completer<List<PurchaseDetails>> completer =
          Completer<List<PurchaseDetails>>();
      final Stream<List<PurchaseDetails>> stream =
          iapStoreKitPlatform.purchaseStream;

      late StreamSubscription<List<PurchaseDetails>> subscription;
      subscription = stream.listen((List<PurchaseDetails> purchaseDetailsList) {
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

      final List<PurchaseDetails> result = await completer.future;
      expect(result.length, 2);
      expect(result.first.productID, dummyProductWrapper.productIdentifier);
    });

    test(
        'buying consumable, should get purchase objects in the purchase update callback',
        () async {
      final List<PurchaseDetails> details = <PurchaseDetails>[];
      final Completer<List<PurchaseDetails>> completer =
          Completer<List<PurchaseDetails>>();
      final Stream<List<PurchaseDetails>> stream =
          iapStoreKitPlatform.purchaseStream;

      late StreamSubscription<List<PurchaseDetails>> subscription;
      subscription = stream.listen((List<PurchaseDetails> purchaseDetailsList) {
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

      final List<PurchaseDetails> result = await completer.future;
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
      final List<PurchaseDetails> details = <PurchaseDetails>[];
      final Completer<IAPError> completer = Completer<IAPError>();
      late IAPError error;

      final Stream<List<PurchaseDetails>> stream =
          iapStoreKitPlatform.purchaseStream;
      late StreamSubscription<List<PurchaseDetails>> subscription;
      subscription = stream.listen((List<PurchaseDetails> purchaseDetailsList) {
        details.addAll(purchaseDetailsList);
        for (final PurchaseDetails purchaseDetails in purchaseDetailsList) {
          if (purchaseDetails.status == PurchaseStatus.error) {
            error = purchaseDetails.error!;
            completer.complete(error);
            subscription.cancel();
          }
        }
      });
      final AppStorePurchaseParam purchaseParam = AppStorePurchaseParam(
          productDetails:
              AppStoreProductDetails.fromSKProduct(dummyProductWrapper),
          applicationUserName: 'appName');
      await iapStoreKitPlatform.buyNonConsumable(purchaseParam: purchaseParam);

      final IAPError completerError = await completer.future;
      expect(completerError.code, 'purchase_error');
      expect(completerError.source, kIAPSource);
      expect(completerError.message, 'ios_domain');
      expect(completerError.details,
          <Object, Object>{'message': 'an error message'});
    });

    test(
        'should get canceled purchase status when error code is SKErrorPaymentCancelled',
        () async {
      fakeStoreKitPlatform.testTransactionCancel = 2;
      final List<PurchaseDetails> details = <PurchaseDetails>[];
      final Completer<PurchaseStatus> completer = Completer<PurchaseStatus>();

      final Stream<List<PurchaseDetails>> stream =
          iapStoreKitPlatform.purchaseStream;
      late StreamSubscription<List<PurchaseDetails>> subscription;
      subscription = stream.listen((List<PurchaseDetails> purchaseDetailsList) {
        details.addAll(purchaseDetailsList);
        for (final PurchaseDetails purchaseDetails in purchaseDetailsList) {
          if (purchaseDetails.status == PurchaseStatus.canceled) {
            completer.complete(purchaseDetails.status);
            subscription.cancel();
          }
        }
      });
      final AppStorePurchaseParam purchaseParam = AppStorePurchaseParam(
          productDetails:
              AppStoreProductDetails.fromSKProduct(dummyProductWrapper),
          applicationUserName: 'appName');
      await iapStoreKitPlatform.buyNonConsumable(purchaseParam: purchaseParam);

      final PurchaseStatus purchaseStatus = await completer.future;
      expect(purchaseStatus, PurchaseStatus.canceled);
    });

    test(
        'should get canceled purchase status when error code is SKErrorOverlayCancelled',
        () async {
      fakeStoreKitPlatform.testTransactionCancel = 15;
      final List<PurchaseDetails> details = <PurchaseDetails>[];
      final Completer<PurchaseStatus> completer = Completer<PurchaseStatus>();

      final Stream<List<PurchaseDetails>> stream =
          iapStoreKitPlatform.purchaseStream;
      late StreamSubscription<List<PurchaseDetails>> subscription;
      subscription = stream.listen((List<PurchaseDetails> purchaseDetailsList) {
        details.addAll(purchaseDetailsList);
        for (final PurchaseDetails purchaseDetails in purchaseDetailsList) {
          if (purchaseDetails.status == PurchaseStatus.canceled) {
            completer.complete(purchaseDetails.status);
            subscription.cancel();
          }
        }
      });
      final AppStorePurchaseParam purchaseParam = AppStorePurchaseParam(
          productDetails:
              AppStoreProductDetails.fromSKProduct(dummyProductWrapper),
          applicationUserName: 'appName');
      await iapStoreKitPlatform.buyNonConsumable(purchaseParam: purchaseParam);

      final PurchaseStatus purchaseStatus = await completer.future;
      expect(purchaseStatus, PurchaseStatus.canceled);
    });
  });

  group('complete purchase', () {
    test('should complete purchase', () async {
      final List<PurchaseDetails> details = <PurchaseDetails>[];
      final Completer<List<PurchaseDetails>> completer =
          Completer<List<PurchaseDetails>>();
      final Stream<List<PurchaseDetails>> stream =
          iapStoreKitPlatform.purchaseStream;
      late StreamSubscription<List<PurchaseDetails>> subscription;
      subscription = stream.listen((List<PurchaseDetails> purchaseDetailsList) {
        details.addAll(purchaseDetailsList);
        for (final PurchaseDetails purchaseDetails in purchaseDetailsList) {
          if (purchaseDetails.pendingCompletePurchase) {
            iapStoreKitPlatform.completePurchase(purchaseDetails);
            completer.complete(details);
            subscription.cancel();
          }
        }
      });
      final AppStorePurchaseParam purchaseParam = AppStorePurchaseParam(
          productDetails:
              AppStoreProductDetails.fromSKProduct(dummyProductWrapper),
          applicationUserName: 'appName');
      await iapStoreKitPlatform.buyNonConsumable(purchaseParam: purchaseParam);
      final List<PurchaseDetails> result = await completer.future;
      expect(result.length, 2);
      expect(result.first.productID, dummyProductWrapper.productIdentifier);
      expect(fakeStoreKitPlatform.finishedTransactions.length, 1);
    });
  });

  group('purchase stream', () {
    test('Should only have active queue when purchaseStream has listeners', () {
      final Stream<List<PurchaseDetails>> stream =
          iapStoreKitPlatform.purchaseStream;
      expect(fakeStoreKitPlatform.queueIsActive, false);
      final StreamSubscription<List<PurchaseDetails>> subscription1 =
          stream.listen((List<PurchaseDetails> event) {});
      expect(fakeStoreKitPlatform.queueIsActive, true);
      final StreamSubscription<List<PurchaseDetails>> subscription2 =
          stream.listen((List<PurchaseDetails> event) {});
      expect(fakeStoreKitPlatform.queueIsActive, true);
      subscription1.cancel();
      expect(fakeStoreKitPlatform.queueIsActive, true);
      subscription2.cancel();
      expect(fakeStoreKitPlatform.queueIsActive, false);
    });
  });
}
