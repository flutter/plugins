// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter/foundation.dart';

import 'in_app_purchase_connection.dart';
import 'product_details.dart';
import 'package:in_app_purchase/store_kit_wrappers.dart';

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
  Future<QueryPurchaseDetailsResponse> queryPastPurchases(
      {String applicationUserName}) async {
    PurchaseError error;
    List<PurchaseDetails> pastPurchases = [];

    try {
      String receiptData;
      try {
        receiptData = await SKReceiptManager.retrieveReceiptData();
      } catch (e) {
        receiptData = null;
      }
      final List<SKPaymentTransactionWrapper> restoredTransactions =
          await _observer.getRestoredTransactions(
              queue: _skPaymentQueueWrapper,
              applicationUserName: applicationUserName);
      _observer.cleanUpRestoredTransactions();
      if (restoredTransactions != null) {
        pastPurchases = restoredTransactions
            .map((SKPaymentTransactionWrapper wrapper) =>
                wrapper.toPurchaseDetails(receiptData))
            .toList();
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

  Future<List<SKPaymentTransactionWrapper>> getRestoredTransactions(
      {@required SKPaymentQueueWrapper queue, String applicationUserName}) {
    assert(queue != null);
    _restoreCompleter = Completer();
    queue.restoreTransactions(applicationUserName: applicationUserName);
    return _restoreCompleter.future;
  }

  void cleanUpRestoredTransactions() {
    _restoredTransactions = null;
    _restoreCompleter = null;
  }

  /// Triggered when any transactions are updated.
  void updatedTransactions({List<SKPaymentTransactionWrapper> transactions}) {
    if (_restoreCompleter != null) {
      if (_restoredTransactions == null) {
        _restoredTransactions = [];
      }
      _restoredTransactions.addAll(transactions
          .where((SKPaymentTransactionWrapper wrapper) {
        return wrapper.transactionState ==
            SKPaymentTransactionStateWrapper.restored;
      }).map((SKPaymentTransactionWrapper wrapper) =>
              wrapper.originalTransaction));
    }
  }

  /// Triggered when any transactions are removed from the payment queue.
  void removedTransactions({List<SKPaymentTransactionWrapper> transactions}) {}

  /// Triggered when there is an error while restoring transactions.
  void restoreCompletedTransactionsFailed({SKError error}) {
    _restoreCompleter.completeError(error);
  }

  /// Triggered when payment queue has finished sending restored transactions.
  void paymentQueueRestoreCompletedTransactionsFinished() {
    _restoreCompleter.complete(_restoredTransactions);
  }

  /// Triggered when any download objects are updated.
  void updatedDownloads({List<SKDownloadWrapper> downloads}) {}

  /// Triggered when a user initiated an in-app purchase from App Store.
  ///
  /// Return `true` to continue the transaction in your app. If you have multiple [SKTransactionObserverWrapper]s, the transaction
  /// will continue if one [SKTransactionObserverWrapper] has [shouldAddStorePayment] returning `true`.
  /// Return `false` to defer or cancel the transaction. For example, you may need to defer a transaction if the user is in the middle of onboarding.
  /// You can also continue the transaction later by calling
  /// [addPayment] with the [SKPaymentWrapper] object you get from this method.
  bool shouldAddStorePayment(
      {SKPaymentWrapper payment, SKProductWrapper product}) {
    return true;
  }
}
