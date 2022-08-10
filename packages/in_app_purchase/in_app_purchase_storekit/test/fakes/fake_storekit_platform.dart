// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:in_app_purchase_storekit/in_app_purchase_storekit.dart';
import 'package:in_app_purchase_storekit/src/channel.dart';
import 'package:in_app_purchase_storekit/store_kit_wrappers.dart';

import '../store_kit_wrappers/sk_test_stub_objects.dart';

class FakeStoreKitPlatform {
  FakeStoreKitPlatform() {
    channel.setMockMethodCallHandler(onMethodCall);
  }

  // pre-configured store information
  String? receiptData;
  late Set<String> validProductIDs;
  late Map<String, SKProductWrapper> validProducts;
  late List<SKPaymentTransactionWrapper> transactions;
  late List<SKPaymentTransactionWrapper> finishedTransactions;
  late bool testRestoredTransactionsNull;
  late bool testTransactionFail;
  late int testTransactionCancel;
  PlatformException? queryProductException;
  PlatformException? restoreException;
  SKError? testRestoredError;
  bool queueIsActive = false;

  void reset() {
    transactions = <SKPaymentTransactionWrapper>[];
    receiptData = 'dummy base64data';
    validProductIDs = <String>{'123', '456'};
    validProducts = <String, SKProductWrapper>{};
    for (final String validID in validProductIDs) {
      final Map<String, dynamic> productWrapperMap =
          buildProductMap(dummyProductWrapper);
      productWrapperMap['productIdentifier'] = validID;
      if (validID == '456') {
        productWrapperMap['priceLocale'] = buildLocaleMap(noSymbolLocale);
      }
      validProducts[validID] = SKProductWrapper.fromJson(productWrapperMap);
    }

    finishedTransactions = <SKPaymentTransactionWrapper>[];
    testRestoredTransactionsNull = false;
    testTransactionFail = false;
    testTransactionCancel = -1;
    queryProductException = null;
    restoreException = null;
    testRestoredError = null;
    queueIsActive = false;
  }

  SKPaymentTransactionWrapper createPendingTransaction(String id,
      {int quantity = 1}) {
    return SKPaymentTransactionWrapper(
      transactionIdentifier: '',
      payment: SKPaymentWrapper(productIdentifier: id, quantity: quantity),
      transactionState: SKPaymentTransactionStateWrapper.purchasing,
      transactionTimeStamp: 123123.121,
    );
  }

  SKPaymentTransactionWrapper createPurchasedTransaction(
      String productId, String transactionId,
      {int quantity = 1}) {
    return SKPaymentTransactionWrapper(
        payment:
            SKPaymentWrapper(productIdentifier: productId, quantity: quantity),
        transactionState: SKPaymentTransactionStateWrapper.purchased,
        transactionTimeStamp: 123123.121,
        transactionIdentifier: transactionId);
  }

  SKPaymentTransactionWrapper createFailedTransaction(String productId,
      {int quantity = 1}) {
    return SKPaymentTransactionWrapper(
        transactionIdentifier: '',
        payment:
            SKPaymentWrapper(productIdentifier: productId, quantity: quantity),
        transactionState: SKPaymentTransactionStateWrapper.failed,
        transactionTimeStamp: 123123.121,
        error: const SKError(
            code: 0,
            domain: 'ios_domain',
            userInfo: <String, Object>{'message': 'an error message'}));
  }

  SKPaymentTransactionWrapper createCanceledTransaction(
      String productId, int errorCode,
      {int quantity = 1}) {
    return SKPaymentTransactionWrapper(
        transactionIdentifier: '',
        payment:
            SKPaymentWrapper(productIdentifier: productId, quantity: quantity),
        transactionState: SKPaymentTransactionStateWrapper.failed,
        transactionTimeStamp: 123123.121,
        error: SKError(
            code: errorCode,
            domain: 'ios_domain',
            userInfo: const <String, Object>{'message': 'an error message'}));
  }

  SKPaymentTransactionWrapper createRestoredTransaction(
      String productId, String transactionId,
      {int quantity = 1}) {
    return SKPaymentTransactionWrapper(
        payment:
            SKPaymentWrapper(productIdentifier: productId, quantity: quantity),
        transactionState: SKPaymentTransactionStateWrapper.restored,
        transactionTimeStamp: 123123.121,
        transactionIdentifier: transactionId);
  }

  Future<dynamic> onMethodCall(MethodCall call) {
    switch (call.method) {
      case '-[SKPaymentQueue canMakePayments:]':
        return Future<bool>.value(true);
      case '-[InAppPurchasePlugin startProductRequest:result:]':
        if (queryProductException != null) {
          throw queryProductException!;
        }
        final List<String> productIDS =
            List.castFrom<dynamic, String>(call.arguments as List<dynamic>);
        final List<String> invalidFound = <String>[];
        final List<SKProductWrapper> products = <SKProductWrapper>[];
        for (final String productID in productIDS) {
          if (!validProductIDs.contains(productID)) {
            invalidFound.add(productID);
          } else {
            products.add(validProducts[productID]!);
          }
        }
        final SkProductResponseWrapper response = SkProductResponseWrapper(
            products: products, invalidProductIdentifiers: invalidFound);
        return Future<Map<String, dynamic>>.value(
            buildProductResponseMap(response));
      case '-[InAppPurchasePlugin restoreTransactions:result:]':
        if (restoreException != null) {
          throw restoreException!;
        }
        if (testRestoredError != null) {
          InAppPurchaseStoreKitPlatform.observer
              .restoreCompletedTransactionsFailed(error: testRestoredError!);
          return Future<void>.sync(() {});
        }
        if (!testRestoredTransactionsNull) {
          InAppPurchaseStoreKitPlatform.observer
              .updatedTransactions(transactions: transactions);
        }
        InAppPurchaseStoreKitPlatform.observer
            .paymentQueueRestoreCompletedTransactionsFinished();

        return Future<void>.sync(() {});
      case '-[InAppPurchasePlugin retrieveReceiptData:result:]':
        if (receiptData != null) {
          return Future<String>.value(receiptData);
        } else {
          throw PlatformException(code: 'no_receipt_data');
        }
      case '-[InAppPurchasePlugin refreshReceipt:result:]':
        receiptData = 'refreshed receipt data';
        return Future<void>.sync(() {});
      case '-[InAppPurchasePlugin addPayment:result:]':
        final String id = call.arguments['productIdentifier'] as String;
        final int quantity = call.arguments['quantity'] as int;
        final SKPaymentTransactionWrapper transaction =
            createPendingTransaction(id, quantity: quantity);
        transactions.add(transaction);
        InAppPurchaseStoreKitPlatform.observer.updatedTransactions(
            transactions: <SKPaymentTransactionWrapper>[transaction]);
        sleep(const Duration(milliseconds: 30));
        if (testTransactionFail) {
          final SKPaymentTransactionWrapper transactionFailed =
              createFailedTransaction(id, quantity: quantity);
          InAppPurchaseStoreKitPlatform.observer.updatedTransactions(
              transactions: <SKPaymentTransactionWrapper>[transactionFailed]);
        } else if (testTransactionCancel > 0) {
          final SKPaymentTransactionWrapper transactionCanceled =
              createCanceledTransaction(id, testTransactionCancel,
                  quantity: quantity);
          InAppPurchaseStoreKitPlatform.observer.updatedTransactions(
              transactions: <SKPaymentTransactionWrapper>[transactionCanceled]);
        } else {
          final SKPaymentTransactionWrapper transactionFinished =
              createPurchasedTransaction(
                  id, transaction.transactionIdentifier ?? '',
                  quantity: quantity);
          InAppPurchaseStoreKitPlatform.observer.updatedTransactions(
              transactions: <SKPaymentTransactionWrapper>[transactionFinished]);
        }
        break;
      case '-[InAppPurchasePlugin finishTransaction:result:]':
        finishedTransactions.add(createPurchasedTransaction(
            call.arguments['productIdentifier'] as String,
            call.arguments['transactionIdentifier'] as String,
            quantity: transactions.first.payment.quantity));
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
