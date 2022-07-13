// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:in_app_purchase_storekit/src/channel.dart';
import 'package:in_app_purchase_storekit/store_kit_wrappers.dart';
import 'sk_test_stub_objects.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final FakeStoreKitPlatform fakeStoreKitPlatform = FakeStoreKitPlatform();

  setUpAll(() {
    SystemChannels.platform
        .setMockMethodCallHandler(fakeStoreKitPlatform.onMethodCall);
  });

  setUp(() {});

  tearDown(() {
    fakeStoreKitPlatform.testReturnNull = false;
    fakeStoreKitPlatform.queueIsActive = null;
    fakeStoreKitPlatform.getReceiptFailTest = false;
  });

  group('sk_request_maker', () {
    test('get products method channel', () async {
      final SkProductResponseWrapper productResponseWrapper =
          await SKRequestMaker().startProductRequest(<String>['xxx']);
      expect(
        productResponseWrapper.products,
        isNotEmpty,
      );
      expect(
        productResponseWrapper.products.first.priceLocale.currencySymbol,
        r'$',
      );

      expect(
        productResponseWrapper.products.first.priceLocale.currencySymbol,
        isNot('A'),
      );
      expect(
        productResponseWrapper.products.first.priceLocale.currencyCode,
        'USD',
      );
      expect(
        productResponseWrapper.products.first.priceLocale.countryCode,
        'US',
      );
      expect(
        productResponseWrapper.invalidProductIdentifiers,
        isNotEmpty,
      );

      expect(
        fakeStoreKitPlatform.startProductRequestParam,
        <String>['xxx'],
      );
    });

    test('get products method channel should throw exception', () async {
      fakeStoreKitPlatform.getProductRequestFailTest = true;
      expect(
        SKRequestMaker().startProductRequest(<String>['xxx']),
        throwsException,
      );
      fakeStoreKitPlatform.getProductRequestFailTest = false;
    });

    test('refreshed receipt', () async {
      final int receiptCountBefore = fakeStoreKitPlatform.refreshReceipt;
      await SKRequestMaker().startRefreshReceiptRequest(
          receiptProperties: <String, dynamic>{'isExpired': true});
      expect(fakeStoreKitPlatform.refreshReceipt, receiptCountBefore + 1);
      expect(fakeStoreKitPlatform.refreshReceiptParam,
          <String, dynamic>{'isExpired': true});
    });

    test('should get null receipt if any exceptions are raised', () async {
      fakeStoreKitPlatform.getReceiptFailTest = true;
      expect(() async => SKReceiptManager.retrieveReceiptData(),
          throwsA(const TypeMatcher<PlatformException>()));
    });
  });

  group('sk_receipt_manager', () {
    test('should get receipt (faking it by returning a `receipt data` string)',
        () async {
      final String receiptData = await SKReceiptManager.retrieveReceiptData();
      expect(receiptData, 'receipt data');
    });
  });

  group('sk_payment_queue', () {
    test('canMakePayment should return true', () async {
      expect(await SKPaymentQueueWrapper.canMakePayments(), true);
    });

    test('canMakePayment returns false if method channel returns null',
        () async {
      fakeStoreKitPlatform.testReturnNull = true;
      expect(await SKPaymentQueueWrapper.canMakePayments(), false);
    });

    test('transactions should return a valid list of transactions', () async {
      expect(await SKPaymentQueueWrapper().transactions(), isNotEmpty);
    });

    test(
        'throws if observer is not set for payment queue before adding payment',
        () async {
      expect(SKPaymentQueueWrapper().addPayment(dummyPayment),
          throwsAssertionError);
    });

    test('should add payment to the payment queue', () async {
      final SKPaymentQueueWrapper queue = SKPaymentQueueWrapper();
      final TestPaymentTransactionObserver observer =
          TestPaymentTransactionObserver();
      queue.setTransactionObserver(observer);
      await queue.addPayment(dummyPayment);
      expect(fakeStoreKitPlatform.payments.first, equals(dummyPayment));
    });

    test('should finish transaction', () async {
      final SKPaymentQueueWrapper queue = SKPaymentQueueWrapper();
      final TestPaymentTransactionObserver observer =
          TestPaymentTransactionObserver();
      queue.setTransactionObserver(observer);
      await queue.finishTransaction(dummyTransaction);
      expect(fakeStoreKitPlatform.transactionsFinished.first,
          equals(dummyTransaction.toFinishMap()));
    });

    test('should restore transaction', () async {
      final SKPaymentQueueWrapper queue = SKPaymentQueueWrapper();
      final TestPaymentTransactionObserver observer =
          TestPaymentTransactionObserver();
      queue.setTransactionObserver(observer);
      await queue.restoreTransactions(applicationUserName: 'aUserID');
      expect(fakeStoreKitPlatform.applicationNameHasTransactionRestored,
          'aUserID');
    });

    test('startObservingTransactionQueue should call methodChannel', () async {
      expect(fakeStoreKitPlatform.queueIsActive, isNot(true));
      await SKPaymentQueueWrapper().startObservingTransactionQueue();
      expect(fakeStoreKitPlatform.queueIsActive, true);
    });

    test('stopObservingTransactionQueue should call methodChannel', () async {
      expect(fakeStoreKitPlatform.queueIsActive, isNot(false));
      await SKPaymentQueueWrapper().stopObservingTransactionQueue();
      expect(fakeStoreKitPlatform.queueIsActive, false);
    });

    test('setDelegate should call methodChannel', () async {
      expect(fakeStoreKitPlatform.isPaymentQueueDelegateRegistered, false);
      await SKPaymentQueueWrapper().setDelegate(TestPaymentQueueDelegate());
      expect(fakeStoreKitPlatform.isPaymentQueueDelegateRegistered, true);
      await SKPaymentQueueWrapper().setDelegate(null);
      expect(fakeStoreKitPlatform.isPaymentQueueDelegateRegistered, false);
    });

    test('showPriceConsentIfNeeded should call methodChannel', () async {
      expect(fakeStoreKitPlatform.showPriceConsentIfNeeded, false);
      await SKPaymentQueueWrapper().showPriceConsentIfNeeded();
      expect(fakeStoreKitPlatform.showPriceConsentIfNeeded, true);
    });
  });

  group('Code Redemption Sheet', () {
    test('presentCodeRedemptionSheet should not throw', () async {
      expect(fakeStoreKitPlatform.presentCodeRedemption, false);
      await SKPaymentQueueWrapper().presentCodeRedemptionSheet();
      expect(fakeStoreKitPlatform.presentCodeRedemption, true);
      fakeStoreKitPlatform.presentCodeRedemption = false;
    });
  });
}

class FakeStoreKitPlatform {
  FakeStoreKitPlatform() {
    channel.setMockMethodCallHandler(onMethodCall);
  }
  // get product request
  List<dynamic> startProductRequestParam = <dynamic>[];
  bool getProductRequestFailTest = false;
  bool testReturnNull = false;

  // get receipt request
  bool getReceiptFailTest = false;

  // refresh receipt request
  int refreshReceipt = 0;
  late Map<String, dynamic> refreshReceiptParam;

  // payment queue
  List<SKPaymentWrapper> payments = <SKPaymentWrapper>[];
  List<Map<String, String>> transactionsFinished = <Map<String, String>>[];
  String applicationNameHasTransactionRestored = '';

  // present Code Redemption
  bool presentCodeRedemption = false;

  // show price consent sheet
  bool showPriceConsentIfNeeded = false;

  // indicate if the payment queue delegate is registered
  bool isPaymentQueueDelegateRegistered = false;

  // Listen to purchase updates
  bool? queueIsActive;

  Future<dynamic> onMethodCall(MethodCall call) {
    switch (call.method) {
      // request makers
      case '-[InAppPurchasePlugin startProductRequest:result:]':
        startProductRequestParam = call.arguments as List<dynamic>;
        if (getProductRequestFailTest) {
          return Future<dynamic>.value(null);
        }
        return Future<Map<String, dynamic>>.value(
            buildProductResponseMap(dummyProductResponseWrapper));
      case '-[InAppPurchasePlugin refreshReceipt:result:]':
        refreshReceipt++;
        refreshReceiptParam = Map.castFrom<dynamic, dynamic, String, dynamic>(
            call.arguments as Map<dynamic, dynamic>);
        return Future<void>.sync(() {});
      // receipt manager
      case '-[InAppPurchasePlugin retrieveReceiptData:result:]':
        if (getReceiptFailTest) {
          throw 'some arbitrary error';
        }
        return Future<String>.value('receipt data');
      // payment queue
      case '-[SKPaymentQueue canMakePayments:]':
        if (testReturnNull) {
          return Future<dynamic>.value(null);
        }
        return Future<bool>.value(true);
      case '-[SKPaymentQueue transactions]':
        return Future<List<dynamic>>.value(
            <dynamic>[buildTransactionMap(dummyTransaction)]);
      case '-[InAppPurchasePlugin addPayment:result:]':
        payments.add(SKPaymentWrapper.fromJson(Map<String, dynamic>.from(
            call.arguments as Map<dynamic, dynamic>)));
        return Future<void>.sync(() {});
      case '-[InAppPurchasePlugin finishTransaction:result:]':
        transactionsFinished.add(
            Map<String, String>.from(call.arguments as Map<dynamic, dynamic>));
        return Future<void>.sync(() {});
      case '-[InAppPurchasePlugin restoreTransactions:result:]':
        applicationNameHasTransactionRestored = call.arguments as String;
        return Future<void>.sync(() {});
      case '-[InAppPurchasePlugin presentCodeRedemptionSheet:result:]':
        presentCodeRedemption = true;
        return Future<void>.sync(() {});
      case '-[SKPaymentQueue startObservingTransactionQueue]':
        queueIsActive = true;
        return Future<void>.sync(() {});
      case '-[SKPaymentQueue stopObservingTransactionQueue]':
        queueIsActive = false;
        return Future<void>.sync(() {});
      case '-[SKPaymentQueue registerDelegate]':
        isPaymentQueueDelegateRegistered = true;
        return Future<void>.sync(() {});
      case '-[SKPaymentQueue removeDelegate]':
        isPaymentQueueDelegateRegistered = false;
        return Future<void>.sync(() {});
      case '-[SKPaymentQueue showPriceConsentIfNeeded]':
        showPriceConsentIfNeeded = true;
        return Future<void>.sync(() {});
    }
    return Future<dynamic>.error('method not mocked');
  }
}

class TestPaymentQueueDelegate extends SKPaymentQueueDelegateWrapper {}

class TestPaymentTransactionObserver extends SKTransactionObserverWrapper {
  @override
  void updatedTransactions(
      {required List<SKPaymentTransactionWrapper> transactions}) {}

  @override
  void removedTransactions(
      {required List<SKPaymentTransactionWrapper> transactions}) {}

  @override
  void restoreCompletedTransactionsFailed({required SKError error}) {}

  @override
  void paymentQueueRestoreCompletedTransactionsFinished() {}

  @override
  bool shouldAddStorePayment(
      {required SKPaymentWrapper payment, required SKProductWrapper product}) {
    return true;
  }
}
