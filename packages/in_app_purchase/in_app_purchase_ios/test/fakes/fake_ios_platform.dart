// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:in_app_purchase_ios/in_app_purchase_ios.dart';
import 'package:in_app_purchase_ios/src/channel.dart';
import 'package:in_app_purchase_ios/store_kit_wrappers.dart';

import '../store_kit_wrappers/sk_test_stub_objects.dart';

class FakeIOSPlatform {
  FakeIOSPlatform() {
    channel.setMockMethodCallHandler(onMethodCall);
  }

  // pre-configured store informations
  String? receiptData;
  late Set<String> validProductIDs;
  late Map<String, SKProductWrapper> validProducts;
  late List<SKPaymentTransactionWrapper> transactions;
  late List<SKPaymentTransactionWrapper> finishedTransactions;
  late bool testRestoredTransactionsNull;
  late bool testTransactionFail;
  PlatformException? queryProductException;
  PlatformException? restoreException;
  SKError? testRestoredError;
  bool queueIsActive = false;

  void reset() {
    transactions = [];
    receiptData = 'dummy base64data';
    validProductIDs = ['123', '456'].toSet();
    validProducts = Map();
    for (String validID in validProductIDs) {
      Map<String, dynamic> productWrapperMap =
          buildProductMap(dummyProductWrapper);
      productWrapperMap['productIdentifier'] = validID;
      if (validID == '456') {
        productWrapperMap['priceLocale'] = buildLocaleMap(noSymbolLocale);
      }
      validProducts[validID] = SKProductWrapper.fromJson(productWrapperMap);
    }

    SKPaymentTransactionWrapper tran1 = SKPaymentTransactionWrapper(
      transactionIdentifier: '123',
      payment: dummyPayment,
      originalTransaction: dummyTransaction,
      transactionTimeStamp: 123123123.022,
      transactionState: SKPaymentTransactionStateWrapper.restored,
      error: null,
    );
    SKPaymentTransactionWrapper tran2 = SKPaymentTransactionWrapper(
      transactionIdentifier: '1234',
      payment: dummyPayment,
      originalTransaction: dummyTransaction,
      transactionTimeStamp: 123123123.022,
      transactionState: SKPaymentTransactionStateWrapper.restored,
      error: null,
    );

    transactions.addAll([tran1, tran2]);
    finishedTransactions = [];
    testRestoredTransactionsNull = false;
    testTransactionFail = false;
    queryProductException = null;
    restoreException = null;
    testRestoredError = null;
    queueIsActive = false;
  }

  SKPaymentTransactionWrapper createPendingTransaction(String id) {
    return SKPaymentTransactionWrapper(
        transactionIdentifier: '',
        payment: SKPaymentWrapper(productIdentifier: id),
        transactionState: SKPaymentTransactionStateWrapper.purchasing,
        transactionTimeStamp: 123123.121,
        error: null,
        originalTransaction: null);
  }

  SKPaymentTransactionWrapper createPurchasedTransaction(
      String productId, String transactionId) {
    return SKPaymentTransactionWrapper(
        payment: SKPaymentWrapper(productIdentifier: productId),
        transactionState: SKPaymentTransactionStateWrapper.purchased,
        transactionTimeStamp: 123123.121,
        transactionIdentifier: transactionId,
        error: null,
        originalTransaction: null);
  }

  SKPaymentTransactionWrapper createFailedTransaction(String productId) {
    return SKPaymentTransactionWrapper(
        transactionIdentifier: '',
        payment: SKPaymentWrapper(productIdentifier: productId),
        transactionState: SKPaymentTransactionStateWrapper.failed,
        transactionTimeStamp: 123123.121,
        error: SKError(
            code: 0,
            domain: 'ios_domain',
            userInfo: {'message': 'an error message'}),
        originalTransaction: null);
  }

  Future<dynamic> onMethodCall(MethodCall call) {
    switch (call.method) {
      case '-[SKPaymentQueue canMakePayments:]':
        return Future<bool>.value(true);
      case '-[InAppPurchasePlugin startProductRequest:result:]':
        if (queryProductException != null) {
          throw queryProductException!;
        }
        List<String> productIDS =
            List.castFrom<dynamic, String>(call.arguments);
        List<String> invalidFound = [];
        List<SKProductWrapper> products = [];
        for (String productID in productIDS) {
          if (!validProductIDs.contains(productID)) {
            invalidFound.add(productID);
          } else {
            products.add(validProducts[productID]!);
          }
        }
        SkProductResponseWrapper response = SkProductResponseWrapper(
            products: products, invalidProductIdentifiers: invalidFound);
        return Future<Map<String, dynamic>>.value(
            buildProductResponseMap(response));
      case '-[InAppPurchasePlugin restoreTransactions:result:]':
        if (restoreException != null) {
          throw restoreException!;
        }
        if (testRestoredError != null) {
          InAppPurchaseIosPlatform.observer
              .restoreCompletedTransactionsFailed(error: testRestoredError!);
          return Future<void>.sync(() {});
        }
        if (!testRestoredTransactionsNull) {
          InAppPurchaseIosPlatform.observer
              .updatedTransactions(transactions: transactions);
        }
        InAppPurchaseIosPlatform.observer
            .paymentQueueRestoreCompletedTransactionsFinished();

        return Future<void>.sync(() {});
      case '-[InAppPurchasePlugin retrieveReceiptData:result:]':
        if (receiptData != null) {
          return Future<void>.value(receiptData);
        } else {
          throw PlatformException(code: 'no_receipt_data');
        }
      case '-[InAppPurchasePlugin refreshReceipt:result:]':
        receiptData = 'refreshed receipt data';
        return Future<void>.sync(() {});
      case '-[InAppPurchasePlugin addPayment:result:]':
        String id = call.arguments['productIdentifier'];
        SKPaymentTransactionWrapper transaction = createPendingTransaction(id);
        InAppPurchaseIosPlatform.observer
            .updatedTransactions(transactions: [transaction]);
        sleep(const Duration(milliseconds: 30));
        if (testTransactionFail) {
          SKPaymentTransactionWrapper transaction_failed =
              createFailedTransaction(id);
          InAppPurchaseIosPlatform.observer
              .updatedTransactions(transactions: [transaction_failed]);
        } else {
          SKPaymentTransactionWrapper transaction_finished =
              createPurchasedTransaction(
                  id, transaction.transactionIdentifier ?? '');
          InAppPurchaseIosPlatform.observer
              .updatedTransactions(transactions: [transaction_finished]);
        }
        break;
      case '-[InAppPurchasePlugin finishTransaction:result:]':
        finishedTransactions.add(createPurchasedTransaction(
            call.arguments["productIdentifier"],
            call.arguments["transactionIdentifier"]));
        break;
      case '-[SKPaymentQueue startObservingTransactionQueue]':
        queueIsActive = true;
        break;
      case '-[SKPaymentQueue stopObservingTransactionQueue]':
        queueIsActive = false;
        break;
    }
    return Future<void>.sync(() {});
  }
}
