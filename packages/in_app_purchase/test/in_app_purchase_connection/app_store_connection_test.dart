// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:test/test.dart';

import 'package:in_app_purchase/src/channel.dart';
import 'package:in_app_purchase/src/in_app_purchase_connection/app_store_connection.dart';
import 'package:in_app_purchase/src/in_app_purchase_connection/product_details.dart';
import 'package:in_app_purchase/src/in_app_purchase_connection/in_app_purchase_connection.dart';
import 'package:in_app_purchase/store_kit_wrappers.dart';
import '../store_kit_wrappers/sk_test_stub_objects.dart';

void main() {
  final FakeIOSPlatform fakeIOSPlatform = FakeIOSPlatform();

  setUpAll(() {
    AppStoreConnection.configure(purchaseUpdateListener: (
        {PurchaseDetails purchaseDetails,
        PurchaseStatus status,
        PurchaseError error}) {
      return;
    }, storePaymentDecisionMaker: (
        {ProductDetails productDetails, String applicationUserName}) {
      return true;
    });
    SystemChannels.platform
        .setMockMethodCallHandler(fakeIOSPlatform.onMethodCall);
  });

  group('isAvailable', () {
    test('true', () async {
      expect(await AppStoreConnection.instance.isAvailable(), isTrue);
    });
  });

  group('query product list', () {
    test('should get product list and correct invalid identifiers', () async {
      final AppStoreConnection connection = AppStoreConnection();
      final ProductDetailsResponse response = await connection
          .queryProductDetails(<String>['123', '456', '789'].toSet());
      List<ProductDetails> products = response.productDetails;
      expect(
        products.first.id,
        '123',
      );
      expect(
        products[1].id,
        '456',
      );
      expect(
        response.notFoundIDs,
        ['789'],
      );
    });
  });

  group('query purchases list', () {
    test('should get purchase list', () async {
      QueryPastPurchaseResponse response =
          await AppStoreConnection.instance.queryPastPurchases();
      expect(response.pastPurchases.length, 2);
      expect(response.pastPurchases.first.purchaseID,
          fakeIOSPlatform.transactions.first.transactionIdentifier);
      expect(response.pastPurchases.last.purchaseID,
          fakeIOSPlatform.transactions.last.transactionIdentifier);
      expect(
          response.pastPurchases.first.verificationData.localVerificationData,
          'dummy base64data');
      expect(
          response.pastPurchases.first.verificationData.serverVerificationData,
          'dummy base64data');
      expect(response.error, isNull);
    });

    test('should get empty result if there is no restored transactions',
        () async {
      fakeIOSPlatform.testRestoredTransactionsNull = true;
      QueryPastPurchaseResponse response =
          await AppStoreConnection.instance.queryPastPurchases();
      expect(response.pastPurchases, isEmpty);
      fakeIOSPlatform.testRestoredTransactionsNull = false;
    });

    test('test restore error', () async {
      fakeIOSPlatform.testRestoredError = {'message': 'errorMessage'};
      QueryPastPurchaseResponse response =
          await AppStoreConnection.instance.queryPastPurchases();
      expect(response.pastPurchases, isEmpty);
      expect(response.error.source, PurchaseSource.AppStore);
      expect(response.error.message['message'], 'errorMessage');
      fakeIOSPlatform.testRestoredError = null;
    });

    test('receipt error should populate null to verificationData.data',
        () async {
      fakeIOSPlatform.receiptData = null;
      QueryPastPurchaseResponse response =
          await AppStoreConnection.instance.queryPastPurchases();
      expect(
          response.pastPurchases.first.verificationData.localVerificationData,
          null);
      expect(
          response.pastPurchases.first.verificationData.serverVerificationData,
          null);
      fakeIOSPlatform.receiptData = 'dummy base64data';
    });
  });

  group('refresh receipt data', () {
    test('should refresh receipt data', () async {
      PurchaseVerificationData receiptData = await AppStoreConnection.instance
          .refreshPurchaseVerificationData(null);
      expect(receiptData.source, PurchaseSource.AppStore);
      expect(receiptData.localVerificationData, 'refreshed receipt data');
      expect(receiptData.serverVerificationData, 'refreshed receipt data');
      fakeIOSPlatform.receiptData = 'dummy base64data';
    });
  });

  group('make payment', () {
    test('should get purchase objects in the purchase update callback',
        () async {
      List<PurchaseDetails> details = [];
      Completer completer = Completer();
      PurchaseUpdateListener listener = (
          {PurchaseDetails purchaseDetails,
          PurchaseStatus status,
          PurchaseError error}) {
        details.add(purchaseDetails);
        if (status == PurchaseStatus.purchased) {
          completer.complete(details);
        }
      };

      StorePaymentDecisionMaker decisionMaker =
          ({ProductDetails productDetails, String applicationUserName}) => true;

      AppStoreConnection.configure(
          purchaseUpdateListener: listener,
          storePaymentDecisionMaker: decisionMaker);
      AppStoreConnection.instance
          .makePayment(productID: 'productID', applicationUserName: 'appName');
      List<PurchaseDetails> result = await completer.future;
      expect(result.length, 2);
      expect(result.first.productId, 'productID');
    });
  });

  test('should get failed purchase status', () async {
    fakeIOSPlatform.testTransactionFail = true;
    List<PurchaseDetails> details = [];
    Completer completer = Completer();
    PurchaseUpdateListener listener = (
        {PurchaseDetails purchaseDetails,
        PurchaseStatus status,
        PurchaseError error}) {
      details.add(purchaseDetails);
      if (status == PurchaseStatus.error) {
        completer.complete(error);
      }
    };

    StorePaymentDecisionMaker decisionMaker =
        ({ProductDetails productDetails, String applicationUserName}) => true;

    AppStoreConnection.configure(
        purchaseUpdateListener: listener,
        storePaymentDecisionMaker: decisionMaker);
    AppStoreConnection.instance
        .makePayment(productID: 'productID', applicationUserName: 'appName');
    PurchaseError error = await completer.future;

    expect(error.code, kPurchaseErrorCode);
    expect(error.source, PurchaseSource.AppStore);
    expect(error.message, {'message': 'an error message'});
    fakeIOSPlatform.testTransactionFail = false;
  });
}

class FakeIOSPlatform {
  FakeIOSPlatform() {
    channel.setMockMethodCallHandler(onMethodCall);
    preConfigure();
  }

  // pre-configured store informations
  String receiptData = 'dummy base64data';
  Set<String> validProductIDs = ['123', '456'].toSet();
  Map<String, SKProductWrapper> validProducts = Map();
  List<SKPaymentTransactionWrapper> transactions = [];
  bool testRestoredTransactionsNull = false;
  bool testTransactionFail = false;
  Map<String, String> testRestoredError = null;

  void preConfigure() {
    for (String validID in validProductIDs) {
      Map productWrapperMap = buildProductMap(dummyProductWrapper);
      productWrapperMap['productIdentifier'] = validID;
      validProducts[validID] = SKProductWrapper.fromJson(productWrapperMap);
    }

    SKPaymentTransactionWrapper tran1 = SKPaymentTransactionWrapper(
      transactionIdentifier: '123',
      payment: dummyPayment,
      originalTransaction: dummyTransaction,
      transactionTimeStamp: 123123123.022,
      transactionState: SKPaymentTransactionStateWrapper.restored,
      downloads: null,
      error: null,
    );
    SKPaymentTransactionWrapper tran2 = SKPaymentTransactionWrapper(
      transactionIdentifier: '1234',
      payment: dummyPayment,
      originalTransaction: dummyTransaction,
      transactionTimeStamp: 123123123.022,
      transactionState: SKPaymentTransactionStateWrapper.restored,
      downloads: null,
      error: null,
    );

    transactions.addAll([tran1, tran2]);
  }

  SKPaymentTransactionWrapper createPendingTransactionWithProductID(String id) {
    return SKPaymentTransactionWrapper(
        payment: SKPaymentWrapper(productIdentifier: id),
        transactionState: SKPaymentTransactionStateWrapper.purchasing,
        transactionTimeStamp: 123123.121,
        transactionIdentifier: id,
        error: null,
        downloads: null,
        originalTransaction: null);
  }

  SKPaymentTransactionWrapper createPurchasedTransactionWithProductID(
      String id) {
    return SKPaymentTransactionWrapper(
        payment: SKPaymentWrapper(productIdentifier: id),
        transactionState: SKPaymentTransactionStateWrapper.purchased,
        transactionTimeStamp: 123123.121,
        transactionIdentifier: id,
        error: null,
        downloads: null,
        originalTransaction: null);
  }

  SKPaymentTransactionWrapper createFailedTransactionWithProductID(String id) {
    return SKPaymentTransactionWrapper(
        payment: SKPaymentWrapper(productIdentifier: id),
        transactionState: SKPaymentTransactionStateWrapper.failed,
        transactionTimeStamp: 123123.121,
        transactionIdentifier: id,
        error: SKError(
            code: 0,
            domain: 'ios_domain',
            userInfo: {'message': 'an error message'}),
        downloads: null,
        originalTransaction: null);
  }

  Future<dynamic> onMethodCall(MethodCall call) {
    switch (call.method) {
      case '-[SKPaymentQueue canMakePayments:]':
        return Future<bool>.value(true);
      case '-[InAppPurchasePlugin startProductRequest:result:]':
        List<String> productIDS =
            List.castFrom<dynamic, String>(call.arguments);
        assert(productIDS is List<String>, 'invalid argument type');
        List<String> invalidFound = [];
        List<SKProductWrapper> products = [];
        for (String productID in productIDS) {
          if (!validProductIDs.contains(productID)) {
            invalidFound.add(productID);
          } else {
            products.add(validProducts[productID]);
          }
        }
        SkProductResponseWrapper response = SkProductResponseWrapper(
            products: products, invalidProductIdentifiers: invalidFound);
        return Future<Map<String, dynamic>>.value(
            buildProductResponseMap(response));
      case '-[InAppPurchasePlugin restoreTransactions:result:]':
        if (testRestoredError != null) {
          AppStoreConnection.observer
              .restoreCompletedTransactionsFailed(error: testRestoredError);
          return Future<void>.sync(() {});
        }
        if (!testRestoredTransactionsNull) {
          AppStoreConnection.observer
              .updatedTransactions(transactions: transactions);
        }
        AppStoreConnection.observer
            .paymentQueueRestoreCompletedTransactionsFinished();
        return Future<void>.sync(() {});
      case '-[InAppPurchasePlugin retrieveReceiptData:result:]':
        if (receiptData != null) {
          return Future<void>.value(receiptData);
        } else {
          throw PlatformException(code: 'no_receipt_data');
        }
        break;
      case '-[InAppPurchasePlugin refreshReceipt:result:]':
        receiptData = 'refreshed receipt data';
        return Future<void>.sync(() {});
      case '-[InAppPurchasePlugin addPayment:result:]':
        String id = call.arguments['productIdentifier'];
        SKPaymentTransactionWrapper transaction =
            createPendingTransactionWithProductID(id);
        AppStoreConnection.observer
            .updatedTransactions(transactions: [transaction]);
        sleep(const Duration(milliseconds: 30));
        if (testTransactionFail) {
          SKPaymentTransactionWrapper transaction_failed =
              createFailedTransactionWithProductID(id);
          AppStoreConnection.observer
              .updatedTransactions(transactions: [transaction_failed]);
        } else {
          SKPaymentTransactionWrapper transaction_finished =
              createPurchasedTransactionWithProductID(id);
          AppStoreConnection.observer
              .updatedTransactions(transactions: [transaction_finished]);
        }
        break;
    }
    return Future<void>.sync(() {});
  }
}
