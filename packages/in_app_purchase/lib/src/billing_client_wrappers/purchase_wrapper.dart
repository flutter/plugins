// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.

import 'dart:ui' show hashValues;
import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/src/in_app_purchase_connection/purchase_details.dart';
import 'package:json_annotation/json_annotation.dart';
import 'enum_converters.dart';
import 'billing_client_wrapper.dart';

// WARNING: Changes to `@JsonSerializable` classes need to be reflected in the
// below generated file. Run `flutter packages pub run build_runner watch` to
// rebuild and watch for further changes.
part 'purchase_wrapper.g.dart';

/// Data structure reprenting a succesful purchase.
///
/// All purchase information should also be verified manually, with your
/// server if at all possible. See ["Verify a
/// purchase"](https://developer.android.com/google/play/billing/billing_library_overview#Verify).
///
/// This wraps [`com.android.billlingclient.api.Purchase`](https://developer.android.com/reference/com/android/billingclient/api/Purchase)
@JsonSerializable()
class PurchaseWrapper {
  @visibleForTesting
  PurchaseWrapper({
    @required this.orderId,
    @required this.packageName,
    @required this.purchaseTime,
    @required this.purchaseToken,
    @required this.signature,
    @required this.sku,
    @required this.isAutoRenewing,
    @required this.originalJson,
  });

  factory PurchaseWrapper.fromJson(Map map) => _$PurchaseWrapperFromJson(map);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    if (other.runtimeType != runtimeType) return false;
    final PurchaseWrapper typedOther = other;
    return typedOther.orderId == orderId &&
        typedOther.packageName == packageName &&
        typedOther.purchaseTime == purchaseTime &&
        typedOther.purchaseToken == purchaseToken &&
        typedOther.signature == signature &&
        typedOther.sku == sku &&
        typedOther.isAutoRenewing == isAutoRenewing &&
        typedOther.originalJson == originalJson;
  }

  @override
  int get hashCode => hashValues(orderId, packageName, purchaseTime,
      purchaseToken, signature, sku, isAutoRenewing, originalJson);

  /// The unique ID for this purchase. Corresponds to the Google Payments order
  /// ID.
  final String orderId;

  /// The package name the purchase was made from.
  final String packageName;

  /// When the purchase was made, as an epoch timestamp.
  final int purchaseTime;

  /// A unique ID for a given [SkuDetailsWrapper], user, and purchase.
  final String purchaseToken;

  /// Signature of purchase data, signed with the developer's private key. Uses
  /// RSASSA-PKCS1-v1_5.
  final String signature;

  /// The product ID of this purchase.
  final String sku;

  /// True for subscriptions that renew automatically. Does not apply to
  /// [SkuType.inapp] products.
  ///
  /// For [SkuType.subs] this means that the subscription is canceled when it is
  /// false.
  final bool isAutoRenewing;

  /// Details about this purchase, in JSON.
  ///
  /// This can be used verify a purchase. See ["Verify a purchase on a
  /// device"](https://developer.android.com/google/play/billing/billing_library_overview#Verify-purchase-device).
  /// Note though that verifying a purchase locally is inherently insecure (see
  /// the article for more details).
  final String originalJson;

  /// Generate a [PurchaseDetails] object based on the transaction.
  ///
  /// [PurchaseDetails] is used to represent a purchase for the unified payment APIs.
  PurchaseDetails toPurchaseDetails() {
    return PurchaseDetails(
      purchaseID: orderId,
      productID: sku,
      verificationData: PurchaseVerificationData(
          localVerificationData: originalJson,
          serverVerificationData: purchaseToken,
          source: PurchaseSource.GooglePlay),
      transactionDate: purchaseTime.toString(),
      billingClientPurchase: this,
    );
  }
}

/// A data struct representing the result of a transaction.
///
/// Contains a potentially empty list of [PurchaseWrapper]s and a
/// [BillingResponse] to signify the overall state of the transaction.
///
/// Wraps [`com.android.billingclient.api.Purchase.PurchasesResult`](https://developer.android.com/reference/com/android/billingclient/api/Purchase.PurchasesResult).
@JsonSerializable()
@BillingResponseConverter()
class PurchasesResultWrapper {
  PurchasesResultWrapper(
      {@required BillingResponse this.responseCode,
      @required List<PurchaseWrapper> this.purchasesList});

  factory PurchasesResultWrapper.fromJson(Map map) =>
      _$PurchasesResultWrapperFromJson(map);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    if (other.runtimeType != runtimeType) return false;
    final PurchasesResultWrapper typedOther = other;
    return typedOther.responseCode == responseCode &&
        typedOther.purchasesList == purchasesList;
  }

  @override
  int get hashCode => hashValues(responseCode, purchasesList);

  /// The status of the operation.
  ///
  /// This can represent either the status of the "query purchase history" half
  /// of the operation and the "user made purchases" transaction itself.
  final BillingResponse responseCode;

  /// The list of succesful purchases made in this transaction.
  ///
  /// May be empty, especially if [responseCode] is not [BillingResponse.ok].
  final List<PurchaseWrapper> purchasesList;
}
