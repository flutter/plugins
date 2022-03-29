// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:in_app_purchase_platform_interface/in_app_purchase_platform_interface.dart';

import '../../in_app_purchase_storekit.dart';
import '../../store_kit_wrappers.dart';
import '../store_kit_wrappers/enum_converters.dart';

/// The class represents the information of a purchase made with the Apple
/// AppStore.
class AppStorePurchaseDetails extends PurchaseDetails {
  /// Creates a new AppStore specific purchase details object with the provided
  /// details.
  AppStorePurchaseDetails(
      {String? purchaseID,
      required String productID,
      required PurchaseVerificationData verificationData,
      required String? transactionDate,
      required this.skPaymentTransaction,
      required PurchaseStatus status})
      : super(
            productID: productID,
            purchaseID: purchaseID,
            transactionDate: transactionDate,
            verificationData: verificationData,
            status: status) {
    this.status = status;
  }

  /// Generate a [AppStorePurchaseDetails] object based on an iOS
  /// [SKPaymentTransactionWrapper] object.
  factory AppStorePurchaseDetails.fromSKTransaction(
    SKPaymentTransactionWrapper transaction,
    String base64EncodedReceipt,
  ) {
    final AppStorePurchaseDetails purchaseDetails = AppStorePurchaseDetails(
      productID: transaction.payment.productIdentifier,
      purchaseID: transaction.transactionIdentifier,
      skPaymentTransaction: transaction,
      status: const SKTransactionStatusConverter()
          .toPurchaseStatus(transaction.transactionState, transaction.error),
      transactionDate: transaction.transactionTimeStamp != null
          ? (transaction.transactionTimeStamp! * 1000).toInt().toString()
          : null,
      verificationData: PurchaseVerificationData(
          localVerificationData: base64EncodedReceipt,
          serverVerificationData: base64EncodedReceipt,
          source: kIAPSource),
    );

    if (purchaseDetails.status == PurchaseStatus.error ||
        purchaseDetails.status == PurchaseStatus.canceled) {
      purchaseDetails.error = IAPError(
        source: kIAPSource,
        code: kPurchaseErrorCode,
        message: transaction.error?.domain ?? '',
        details: transaction.error?.userInfo,
      );
    }

    return purchaseDetails;
  }

  /// Points back to the [SKPaymentTransactionWrapper] which was used to
  /// generate this [AppStorePurchaseDetails] object.
  final SKPaymentTransactionWrapper skPaymentTransaction;

  late PurchaseStatus _status;

  /// The status that this [PurchaseDetails] is currently on.
  @override
  PurchaseStatus get status => _status;
  @override
  set status(PurchaseStatus status) {
    _pendingCompletePurchase = status != PurchaseStatus.pending;
    _status = status;
  }

  bool _pendingCompletePurchase = false;
  @override
  bool get pendingCompletePurchase => _pendingCompletePurchase;
}
