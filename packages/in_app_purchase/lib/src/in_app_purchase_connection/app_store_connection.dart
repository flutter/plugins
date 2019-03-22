// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

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
  Future<List<PurchaseDetails>> queryPastPurchases() async {
    _skPaymentQueueWrapper.restoreTransactions();
    try {
      final List<SKPaymentTransactionWrapper> restoredTransactions =
          await _observer.restoredTransactionsStream.toList();
      final String receiptData = await SKReceiptManager.retrieveReceiptData();
      print(restoredTransactions);
      return restoredTransactions
          .where((SKPaymentTransactionWrapper wrapper) =>
              wrapper.transactionState ==
              SKPaymentTransactionStateWrapper.restored)
          .map((SKPaymentTransactionWrapper wrapper) =>
              wrapper.toPurchaseDetails(receiptData))
          .toList();
    } catch (e) {
      print('failed to query past purchases $e');
      return <PurchaseDetails>[];
    }
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
  StreamController<SKPaymentTransactionWrapper> _restoredTransactions =
      StreamController.broadcast();
  Stream<SKPaymentTransactionWrapper> get restoredTransactionsStream =>
      _restoredTransactions.stream;

  /// Triggered when any transactions are updated.
  void updatedTransactions({List<SKPaymentTransactionWrapper> transactions}) {
    transactions.forEach((SKPaymentTransactionWrapper wrapper) {
      if (wrapper.transactionState ==
          SKPaymentTransactionStateWrapper.restored) {
        _restoredTransactions.add(wrapper);
        print('added');
      }
    });
  }

  /// Triggered when any transactions are removed from the payment queue.
  void removedTransactions({List<SKPaymentTransactionWrapper> transactions}) {}

  /// Triggered when there is an error while restoring transactions.
  ///
  /// The error is represented in a Map. The map contains `errorCode` and `message`
  void restoreCompletedTransactions({Map<String, String> error}) {
    _restoredTransactions.addError(error);
  }

  /// Triggered when payment queue has finished sending restored transactions.
  void paymentQueueRestoreCompletedTransactionsFinished() {
    _restoredTransactions.close();
    print('closed');
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
