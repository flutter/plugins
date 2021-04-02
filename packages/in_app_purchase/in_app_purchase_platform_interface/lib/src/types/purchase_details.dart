// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'in_app_purchase_error.dart';
import 'purchase_status.dart';
import 'purchase_verification_data.dart';

/// Represents the transaction details of a purchase.
///
/// This class unifies the BillingClient's [PurchaseWrapper] and StoreKit's [SKPaymentTransactionWrapper]. You can use the common attributes in
/// This class for simple operations. If you would like to see the detailed representation of the product, instead,  use [PurchaseWrapper] on Android and [SKPaymentTransactionWrapper] on iOS.
class PurchaseDetails {
  /// Creates a new PurchaseDetails object with the provided data.
  PurchaseDetails({
    this.purchaseID,
    required this.productID,
    required this.verificationData,
    required this.transactionDate,
  });

  /// A unique identifier of the purchase.
  ///
  /// The `value` is null on iOS if it is not a successful purchase.
  final String? purchaseID;

  /// The product identifier of the purchase.
  final String productID;

  /// The verification data of the purchase.
  ///
  /// Use this to verify the purchase. See [PurchaseVerificationData] for
  /// details on how to verify purchase use this data. You should never use any
  /// purchase data until verified.
  ///
  /// On iOS, [InAppPurchaseConnection.refreshPurchaseVerificationData] can be used to get a new
  /// [PurchaseVerificationData] object for further validation.
  final PurchaseVerificationData verificationData;

  /// The timestamp of the transaction.
  ///
  /// Milliseconds since epoch.
  ///
  /// The value is `null` if [status] is not [PurchaseStatus.purchased].
  final String? transactionDate;

  /// The status that this [PurchaseDetails] is currently on.
  PurchaseStatus? status;

  /// The error details when the [status] is [PurchaseStatus.error].
  ///
  /// The value is `null` if [status] is not [PurchaseStatus.error].
  IAPError? error;

  /// The developer has to call [InAppPurchaseConnection.completePurchase] if the value is `true`
  /// and the product has been delivered to the user.
  ///
  /// The initial value is `false`.
  /// * See also [InAppPurchaseConnection.completePurchase] for more details on completing purchases.
  bool pendingCompletePurchase = false;
}
