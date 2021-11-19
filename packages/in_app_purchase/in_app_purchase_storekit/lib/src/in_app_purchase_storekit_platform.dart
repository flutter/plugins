// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:in_app_purchase_storekit/src/in_app_purchase_storekit_platform_addition.dart';
import 'package:in_app_purchase_platform_interface/in_app_purchase_platform_interface.dart';

import '../in_app_purchase_storekit.dart';
import '../store_kit_wrappers.dart';

/// [IAPError.code] code for failed purchases.
const String kPurchaseErrorCode = 'purchase_error';

/// Indicates store front is Apple AppStore.
const String kIAPSource = 'app_store';

/// An [InAppPurchasePlatform] that wraps StoreKit.
///
/// This translates various `StoreKit` calls and responses into the
/// generic plugin API.
class InAppPurchaseStoreKitPlatform extends InAppPurchasePlatform {
  static late SKPaymentQueueWrapper _skPaymentQueueWrapper;
  static late _TransactionObserver _observer;

  /// Creates an [InAppPurchaseStoreKitPlatform] object.
  ///
  /// This constructor should only be used for testing, for any other purpose
  /// get the connection from the [instance] getter.
  @visibleForTesting
  InAppPurchaseStoreKitPlatform();

  Stream<List<PurchaseDetails>> get purchaseStream =>
      _observer.purchaseUpdatedController.stream;

  /// Callback handler for transaction status changes.
  @visibleForTesting
  static SKTransactionObserverWrapper get observer => _observer;

  /// Registers this class as the default instance of [InAppPurchasePlatform].
  static void registerPlatform() {
    // Register the [InAppPurchaseStoreKitPlatformAddition] containing
    // StoreKit-specific functionality.
    InAppPurchasePlatformAddition.instance =
        InAppPurchaseStoreKitPlatformAddition();

    // Register the platform-specific implementation of the idiomatic
    // InAppPurchase API.
    InAppPurchasePlatform.instance = InAppPurchaseStoreKitPlatform();

    _skPaymentQueueWrapper = SKPaymentQueueWrapper();

    // Create a purchaseUpdatedController and notify the native side when to
    // start of stop sending updates.
    StreamController<List<PurchaseDetails>> updateController =
        StreamController.broadcast(
      onListen: () => _skPaymentQueueWrapper.startObservingTransactionQueue(),
      onCancel: () => _skPaymentQueueWrapper.stopObservingTransactionQueue(),
    );
    _observer = _TransactionObserver(updateController);
    _skPaymentQueueWrapper.setTransactionObserver(observer);
  }

  @override
  Future<bool> isAvailable() => SKPaymentQueueWrapper.canMakePayments();

  @override
  Future<bool> buyNonConsumable({required PurchaseParam purchaseParam}) async {
    await _skPaymentQueueWrapper.addPayment(SKPaymentWrapper(
        productIdentifier: purchaseParam.productDetails.id,
        quantity: 1,
        applicationUsername: purchaseParam.applicationUserName,
        simulatesAskToBuyInSandbox: (purchaseParam is AppStorePurchaseParam)
            ? purchaseParam.simulatesAskToBuyInSandbox
            : false,
        requestData: null));

    return true; // There's no error feedback from iOS here to return.
  }

  @override
  Future<bool> buyConsumable(
      {required PurchaseParam purchaseParam, bool autoConsume = true}) {
    assert(autoConsume == true, 'On iOS, we should always auto consume');
    return buyNonConsumable(purchaseParam: purchaseParam);
  }

  @override
  Future<void> completePurchase(PurchaseDetails purchase) {
    assert(
      purchase is AppStorePurchaseDetails,
      'On iOS, the `purchase` should always be of type `AppStorePurchaseDetails`.',
    );

    return _skPaymentQueueWrapper.finishTransaction(
      (purchase as AppStorePurchaseDetails).skPaymentTransaction,
    );
  }

  @override
  Future<void> restorePurchases({String? applicationUserName}) async {
    return _observer
        .restoreTransactions(
            queue: _skPaymentQueueWrapper,
            applicationUserName: applicationUserName)
        .whenComplete(() => _observer.cleanUpRestoredTransactions());
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
    SkProductResponseWrapper response;
    PlatformException? exception;
    try {
      response = await requestMaker.startProductRequest(identifiers.toList());
    } on PlatformException catch (e) {
      exception = e;
      response = SkProductResponseWrapper(
          products: [], invalidProductIdentifiers: identifiers.toList());
    }
    List<AppStoreProductDetails> productDetails = [];
    if (response.products != null) {
      productDetails = response.products
          .map((SKProductWrapper productWrapper) =>
              AppStoreProductDetails.fromSKProduct(productWrapper))
          .toList();
    }
    List<String> invalidIdentifiers = response.invalidProductIdentifiers;
    if (productDetails.isEmpty) {
      invalidIdentifiers = identifiers.toList();
    }
    ProductDetailsResponse productDetailsResponse = ProductDetailsResponse(
      productDetails: productDetails,
      notFoundIDs: invalidIdentifiers,
      error: exception == null
          ? null
          : IAPError(
              source: kIAPSource,
              code: exception.code,
              message: exception.message ?? '',
              details: exception.details),
    );
    return productDetailsResponse;
  }
}

enum _TransactionRestoreState {
  notRunning,
  waitingForTransactions,
  receivedTransaction,
}

class _TransactionObserver implements SKTransactionObserverWrapper {
  final StreamController<List<PurchaseDetails>> purchaseUpdatedController;

  Completer? _restoreCompleter;
  late String _receiptData;
  _TransactionRestoreState _transactionRestoreState =
      _TransactionRestoreState.notRunning;

  _TransactionObserver(this.purchaseUpdatedController);

  Future<void> restoreTransactions({
    required SKPaymentQueueWrapper queue,
    String? applicationUserName,
  }) {
    _transactionRestoreState = _TransactionRestoreState.waitingForTransactions;
    _restoreCompleter = Completer();
    queue.restoreTransactions(applicationUserName: applicationUserName);
    return _restoreCompleter!.future;
  }

  void cleanUpRestoredTransactions() {
    _restoreCompleter = null;
  }

  void updatedTransactions(
      {required List<SKPaymentTransactionWrapper> transactions}) async {
    if (_transactionRestoreState ==
            _TransactionRestoreState.waitingForTransactions &&
        transactions.any((transaction) =>
            transaction.transactionState ==
            SKPaymentTransactionStateWrapper.restored)) {
      _transactionRestoreState = _TransactionRestoreState.receivedTransaction;
    }

    String receiptData = await getReceiptData();
    List<PurchaseDetails> purchases = transactions
        .map((SKPaymentTransactionWrapper transaction) =>
            AppStorePurchaseDetails.fromSKTransaction(transaction, receiptData))
        .toList();

    purchaseUpdatedController.add(purchases);
  }

  void removedTransactions(
      {required List<SKPaymentTransactionWrapper> transactions}) {}

  /// Triggered when there is an error while restoring transactions.
  void restoreCompletedTransactionsFailed({required SKError error}) {
    _restoreCompleter!.completeError(error);
    _transactionRestoreState = _TransactionRestoreState.notRunning;
  }

  void paymentQueueRestoreCompletedTransactionsFinished() {
    _restoreCompleter!.complete();

    // If no restored transactions were received during the restore session
    // emit an empty list of purchase details to inform listeners that the
    // restore session finished without any results.
    if (_transactionRestoreState ==
        _TransactionRestoreState.waitingForTransactions) {
      purchaseUpdatedController.add(<PurchaseDetails>[]);
    }

    _transactionRestoreState = _TransactionRestoreState.notRunning;
  }

  bool shouldAddStorePayment(
      {required SKPaymentWrapper payment, required SKProductWrapper product}) {
    // In this unified API, we always return true to keep it consistent with the behavior on Google Play.
    return true;
  }

  Future<String> getReceiptData() async {
    try {
      _receiptData = await SKReceiptManager.retrieveReceiptData();
    } catch (e) {
      _receiptData = '';
    }
    return _receiptData;
  }
}
