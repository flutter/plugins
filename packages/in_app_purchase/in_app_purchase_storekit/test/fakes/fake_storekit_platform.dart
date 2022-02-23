// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
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
        error: const SKError(
            code: 0,
            domain: 'ios_domain',
            userInfo: <String, Object>{'message': 'an error message'}),
        originalTransaction: null);
  }

  SKPaymentTransactionWrapper createCanceledTransaction(
      String productId, int errorCode) {
    return SKPaymentTransactionWrapper(
        transactionIdentifier: '',
        payment: SKPaymentWrapper(productIdentifier: productId),
        transactionState: SKPaymentTransactionStateWrapper.failed,
        transactionTimeStamp: 123123.121,
        error: SKError(
            code: errorCode,
            domain: 'ios_domain',
            userInfo: const <String, Object>{'message': 'an error message'}),
        originalTransaction: null);
  }

  SKPaymentTransactionWrapper createRestoredTransaction(
      String productId, String transactionId) {
    return SKPaymentTransactionWrapper(
        payment: SKPaymentWrapper(productIdentifier: productId),
        transactionState: SKPaymentTransactionStateWrapper.restored,
        transactionTimeStamp: 123123.121,
        transactionIdentifier: transactionId,
        error: null,
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
        final SKPaymentTransactionWrapper transaction =
            createPendingTransaction(id);
        InAppPurchaseStoreKitPlatform.observer.updatedTransactions(
            transactions: <SKPaymentTransactionWrapper>[transaction]);
        sleep(const Duration(milliseconds: 30));
        if (testTransactionFail) {
          final SKPaymentTransactionWrapper transactionFailed =
              createFailedTransaction(id);
          InAppPurchaseStoreKitPlatform.observer.updatedTransactions(
              transactions: <SKPaymentTransactionWrapper>[transactionFailed]);
        } else if (testTransactionCancel > 0) {
          final SKPaymentTransactionWrapper transactionCanceled =
              createCanceledTransaction(id, testTransactionCancel);
          InAppPurchaseStoreKitPlatform.observer.updatedTransactions(
              transactions: <SKPaymentTransactionWrapper>[transactionCanceled]);
        } else {
          final SKPaymentTransactionWrapper transactionFinished =
              createPurchasedTransaction(
                  id, transaction.transactionIdentifier ?? '');
          InAppPurchaseStoreKitPlatform.observer.updatedTransactions(
              transactions: <SKPaymentTransactionWrapper>[transactionFinished]);
        }
        break;
      case '-[InAppPurchasePlugin finishTransaction:result:]':
        finishedTransactions.add(createPurchasedTransaction(
            call.arguments['productIdentifier'] as String,
            call.arguments['transactionIdentifier'] as String));
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
