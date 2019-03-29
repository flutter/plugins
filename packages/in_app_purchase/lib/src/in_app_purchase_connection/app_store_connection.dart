// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter/foundation.dart';

import 'in_app_purchase_connection.dart';
import 'product_details.dart';
import 'package:in_app_purchase/store_kit_wrappers.dart';
import 'package:in_app_purchase/src/store_kit_wrappers/enum_converters.dart';

/// An [InAppPurchaseConnection] that wraps StoreKit.
///
/// This translates various `StoreKit` calls and responses into the
/// generic plugin API.
class AppStoreConnection implements InAppPurchaseConnection {
  static AppStoreConnection get instance => _getOrCreateInstance();
  static AppStoreConnection _instance;
  static SKPaymentQueueWrapper _skPaymentQueueWrapper;
  static _TransactionObserver _observer;

  static SKTransactionObserverWrapper get observer => _observer;

  static AppStoreConnection _getOrCreateInstance() {
    if (_instance != null) {
      return _instance;
    }

    _instance = AppStoreConnection();
    _skPaymentQueueWrapper = SKPaymentQueueWrapper();
    _observer = _TransactionObserver();
    _skPaymentQueueWrapper.setTransactionObserver(observer);
    return _instance;
  }
  @override
  Future<bool> isAvailable() => SKPaymentQueueWrapper.canMakePayments();

  @override
  Stream<PurchaseDetails> makePayment(
      {String productID,
      String applicationUserName,
      bool sandboxTesting = false}) {
    return _observer.getPurchaseStream(
        queue: _skPaymentQueueWrapper,
        productID: productID,
        applicationUserName: applicationUserName,
        sandboxTesting: sandboxTesting);
  }

  @override
  Future<void> completePurchase(PurchaseDetails purchase) {
    return _skPaymentQueueWrapper.finishTransaction(purchase.purchaseID);
  }

  @override
  Future<void> consumePurchase(PurchaseDetails purchase) {
    return Future<void>.sync(() {});
  }

  @override
  Future<QueryPurchaseDetailsResponse> queryPastPurchases(
      {String applicationUserName}) async {
    PurchaseError error;
    List<PurchaseDetails> pastPurchases = [];

    try {
      String receiptData = await _observer.getReceiptData();
      final List<SKPaymentTransactionWrapper> restoredTransactions =
          await _observer.getRestoredTransactions(
              queue: _skPaymentQueueWrapper,
              applicationUserName: applicationUserName);
      _observer.cleanUpRestoredTransactions();
      if (restoredTransactions != null) {
        pastPurchases = restoredTransactions.map((transaction) {
          return transaction.toPurchaseDetails(receiptData)
            ..status = SKTransactionStatusConverter()
                .toPurchaseStatus(transaction.transactionState)
            ..error = transaction.error != null
                ? PurchaseError(
                    source: PurchaseSource.AppStore,
                    code: kPurchaseErrorCode,
                    message: transaction.error.userInfo,
                  )
                : null;
        }).toList();
      }
    } catch (e) {
      error = PurchaseError(
          source: PurchaseSource.AppStore, code: e.domain, message: e.userInfo);
    }
    return QueryPurchaseDetailsResponse(
        pastPurchases: pastPurchases, error: error);
  }

  @override
  Future<PurchaseVerificationData> refreshPurchaseVerificationData(
      PurchaseDetails purchase) async {
    await SKRequestMaker().startRefreshReceiptRequest();
    String receipt = await SKReceiptManager.retrieveReceiptData();
    return PurchaseVerificationData(
        localVerificationData: receipt,
        serverVerificationData: receipt,
        source: PurchaseSource.AppStore);
  }

  /// Query the product detail list.
  ///
  /// This method only returns [ProductDetailsResponse].
  /// To get detailed Store Kit product list, use [SkProductResponseWrapper.startProductRequest]
  /// to get the [SKProductResponseWrapper].
  @override
  Future<ProductDetailsResponse> queryProductDetails(
      Set<String> identifiers) async {
    final SKRequestMaker requestMaker = SKRequestMaker();
    SkProductResponseWrapper response =
        await requestMaker.startProductRequest(identifiers.toList());
    List<ProductDetails> productDetails = response.products
        .map((SKProductWrapper productWrapper) =>
            productWrapper.toProductDetails())
        .toList();
    ProductDetailsResponse productDetailsResponse = ProductDetailsResponse(
      productDetails: productDetails,
      notFoundIDs: response.invalidProductIdentifiers,
    );
    return productDetailsResponse;
  }
}

class _TransactionObserver implements SKTransactionObserverWrapper {

  Completer<List<SKPaymentTransactionWrapper>> _restoreCompleter;
  List<SKPaymentTransactionWrapper> _restoredTransactions;
  Map<String, StreamController<PurchaseDetails>> _purchaseStreamControllers;
  String _receiptData;

  _TransactionObserver();

  Future<List<SKPaymentTransactionWrapper>> getRestoredTransactions(
      {@required SKPaymentQueueWrapper queue, String applicationUserName}) {
    assert(queue != null);
    _restoreCompleter = Completer();
    queue.restoreTransactions(applicationUserName: applicationUserName);
    return _restoreCompleter.future;
  }

  Stream<PurchaseDetails> getPurchaseStream(
      {@required SKPaymentQueueWrapper queue,
      @required String productID,
      String applicationUserName,
      bool sandboxTesting = false}) {
    if (_purchaseStreamControllers == null) {
      _purchaseStreamControllers = Map();
    }
    _purchaseStreamControllers[productID] = StreamController();

    SKPaymentWrapper payment = SKPaymentWrapper(
        productIdentifier: productID,
        quantity: 1,
        applicationUsername: applicationUserName,
        simulatesAskToBuyInSandbox: sandboxTesting,
        requestData: null);
    Stream stream = _purchaseStreamControllers[productID].stream;
    SKPaymentQueueWrapper().addPayment(payment);
    return stream;
  }

  void cleanUpRestoredTransactions() {
    _restoredTransactions = null;
    _restoreCompleter = null;
  }

  void updatedTransactions(
      {List<SKPaymentTransactionWrapper> transactions}) async {
    if (_restoreCompleter != null) {
      if (_restoredTransactions == null) {
        _restoredTransactions = [];
      }
      _restoredTransactions
          .addAll(transactions.where((SKPaymentTransactionWrapper wrapper) {
        return wrapper.transactionState ==
            SKPaymentTransactionStateWrapper.restored;
      }).map((SKPaymentTransactionWrapper wrapper) => wrapper));
    }

    String receiptData = await getReceiptData();
    transactions.where((transaction) {
      // restored case is already handled in the `if (_restoreCompleter != null)` clause.
      return transaction.transactionState !=
          SKPaymentTransactionStateWrapper.restored;
    }).forEach((transaction) {
      if (_purchaseStreamControllers != null &&
          _purchaseStreamControllers[transaction.payment.productIdentifier] !=
              null) {
        PurchaseDetails purchaseDetails = transaction
            .toPurchaseDetails(receiptData)
              ..status = SKTransactionStatusConverter()
                  .toPurchaseStatus(transaction.transactionState)
              ..error = transaction.error != null
                  ? PurchaseError(
                      source: PurchaseSource.AppStore,
                      code: kPurchaseErrorCode,
                      message: transaction.error.userInfo,
                    )
                  : null;
        StreamController controller =
            _purchaseStreamControllers[transaction.payment.productIdentifier];
        controller.add(purchaseDetails);
        if (transaction.transactionState ==
                SKPaymentTransactionStateWrapper.purchased ||
            transaction.transactionState ==
                SKPaymentTransactionStateWrapper.failed) {
          controller.close();
          _purchaseStreamControllers
              .remove(transaction.payment.productIdentifier);
        }
      }
    });
  }

  void removedTransactions({List<SKPaymentTransactionWrapper> transactions}) {}

  /// Triggered when there is an error while restoring transactions.
  void restoreCompletedTransactionsFailed({SKError error}) {
    _restoreCompleter.completeError(error);
  }

  void paymentQueueRestoreCompletedTransactionsFinished() {
    _restoreCompleter.complete(_restoredTransactions);
  }

  void updatedDownloads({List<SKDownloadWrapper> downloads}) {}

  bool shouldAddStorePayment(
      {SKPaymentWrapper payment, SKProductWrapper product}) {
    // In this unified API, we always return true to keep it consistent with the behavior on Google Play.
    return true;
  }

  Future<String> getReceiptData() async {
    try {
      _receiptData = await SKReceiptManager.retrieveReceiptData();
    } catch (e) {
      print('Error getting receipt data: $e');
      _receiptData = null;
    }
    return _receiptData;
  }
}
