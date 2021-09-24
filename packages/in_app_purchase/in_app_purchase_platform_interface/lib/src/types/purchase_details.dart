// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import '../errors/in_app_purchase_error.dart';
import 'purchase_status.dart';
import 'purchase_verification_data.dart';

/// Represents the transaction details of a purchase.
class PurchaseDetails {
  /// Creates a new PurchaseDetails object with the provided data.
  PurchaseDetails({
    this.purchaseID,
    required this.productID,
    required this.verificationData,
    required this.transactionDate,
    required this.status,
  });

  /// A unique identifier of the purchase.
  final String? purchaseID;

  /// The product identifier of the purchase.
  final String productID;

  /// The verification data of the purchase.
  ///
  /// Use this to verify the purchase. See [PurchaseVerificationData] for
  /// details on how to verify purchase use this data. You should never use any
  /// purchase data until verified.
  final PurchaseVerificationData verificationData;

  /// The timestamp of the transaction.
  ///
  /// Milliseconds since epoch.
  ///
  /// The value is `null` if [status] is not [PurchaseStatus.purchased].
  final String? transactionDate;

  /// The status that this [PurchaseDetails] is currently on.
  PurchaseStatus status;

  /// The error details when the [status] is [PurchaseStatus.error].
  ///
  /// The value is `null` if [status] is not [PurchaseStatus.error].
  IAPError? error;

  /// The developer has to call [InAppPurchasePlatform.completePurchase] if the value is `true`
  /// and the product has been delivered to the user.
  ///
  /// The initial value is `false`.
  /// * See also [InAppPurchasePlatform.completePurchase] for more details on completing purchases.
  bool pendingCompletePurchase = false;
}
