// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:ui' show hashValues;

import 'package:flutter/foundation.dart';
import 'package:in_app_purchase_platform_interface/in_app_purchase_platform_interface.dart';
import 'package:json_annotation/json_annotation.dart';

import 'billing_client_wrapper.dart';
import 'sku_details_wrapper.dart';

// WARNING: Changes to `@JsonSerializable` classes need to be reflected in the
// below generated file. Run `flutter packages pub run build_runner watch` to
// rebuild and watch for further changes.
part 'purchase_wrapper.g.dart';

/// Data structure representing a successful purchase.
///
/// All purchase information should also be verified manually, with your
/// server if at all possible. See ["Verify a
/// purchase"](https://developer.android.com/google/play/billing/billing_library_overview#Verify).
///
/// This wraps [`com.android.billlingclient.api.Purchase`](https://developer.android.com/reference/com/android/billingclient/api/Purchase)
@JsonSerializable()
@PurchaseStateConverter()
@immutable
class PurchaseWrapper {
  /// Creates a purchase wrapper with the given purchase details.
  @visibleForTesting
  const PurchaseWrapper({
    required this.orderId,
    required this.packageName,
    required this.purchaseTime,
    required this.purchaseToken,
    required this.signature,
    required this.sku,
    required this.isAutoRenewing,
    required this.originalJson,
    this.developerPayload,
    required this.isAcknowledged,
    required this.purchaseState,
    this.obfuscatedAccountId,
    this.obfuscatedProfileId,
  });

  /// Factory for creating a [PurchaseWrapper] from a [Map] with the purchase details.
  factory PurchaseWrapper.fromJson(Map<String, dynamic> map) =>
      _$PurchaseWrapperFromJson(map);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) {
      return true;
    }
    if (other.runtimeType != runtimeType) {
      return false;
    }
    return other is PurchaseWrapper &&
        other.orderId == orderId &&
        other.packageName == packageName &&
        other.purchaseTime == purchaseTime &&
        other.purchaseToken == purchaseToken &&
        other.signature == signature &&
        other.sku == sku &&
        other.isAutoRenewing == isAutoRenewing &&
        other.originalJson == originalJson &&
        other.isAcknowledged == isAcknowledged &&
        other.purchaseState == purchaseState;
  }

  @override
  int get hashCode => hashValues(
      orderId,
      packageName,
      purchaseTime,
      purchaseToken,
      signature,
      sku,
      isAutoRenewing,
      originalJson,
      isAcknowledged,
      purchaseState);

  /// The unique ID for this purchase. Corresponds to the Google Payments order
  /// ID.
  @JsonKey(defaultValue: '')
  final String orderId;

  /// The package name the purchase was made from.
  @JsonKey(defaultValue: '')
  final String packageName;

  /// When the purchase was made, as an epoch timestamp.
  @JsonKey(defaultValue: 0)
  final int purchaseTime;

  /// A unique ID for a given [SkuDetailsWrapper], user, and purchase.
  @JsonKey(defaultValue: '')
  final String purchaseToken;

  /// Signature of purchase data, signed with the developer's private key. Uses
  /// RSASSA-PKCS1-v1_5.
  @JsonKey(defaultValue: '')
  final String signature;

  /// The product ID of this purchase.
  @JsonKey(defaultValue: '')
  final String sku;

  /// True for subscriptions that renew automatically. Does not apply to
  /// [SkuType.inapp] products.
  ///
  /// For [SkuType.subs] this means that the subscription is canceled when it is
  /// false.
  ///
  /// The value is `false` for [SkuType.inapp] products.
  final bool isAutoRenewing;

  /// Details about this purchase, in JSON.
  ///
  /// This can be used verify a purchase. See ["Verify a purchase on a
  /// device"](https://developer.android.com/google/play/billing/billing_library_overview#Verify-purchase-device).
  /// Note though that verifying a purchase locally is inherently insecure (see
  /// the article for more details).
  @JsonKey(defaultValue: '')
  final String originalJson;

  /// The payload specified by the developer when the purchase was acknowledged or consumed.
  ///
  /// The value is `null` if it wasn't specified when the purchase was acknowledged or consumed.
  /// The `developerPayload` is removed from [BillingClientWrapper.acknowledgePurchase], [BillingClientWrapper.consumeAsync], [InAppPurchaseConnection.completePurchase], [InAppPurchaseConnection.consumePurchase]
  /// after plugin version `0.5.0`. As a result, this will be `null` for new purchases that happen after updating to `0.5.0`.
  final String? developerPayload;

  /// Whether the purchase has been acknowledged.
  ///
  /// A successful purchase has to be acknowledged within 3 days after the purchase via [BillingClient.acknowledgePurchase].
  /// * See also [BillingClient.acknowledgePurchase] for more details on acknowledging purchases.
  @JsonKey(defaultValue: false)
  final bool isAcknowledged;

  /// Determines the current state of the purchase.
  ///
  /// [BillingClient.acknowledgePurchase] should only be called when the `purchaseState` is [PurchaseStateWrapper.purchased].
  /// * See also [BillingClient.acknowledgePurchase] for more details on acknowledging purchases.
  final PurchaseStateWrapper purchaseState;

  /// The obfuscatedAccountId specified when making a purchase.
  ///
  /// The [obfuscatedAccountId] can either be set in
  /// [PurchaseParam.applicationUserName] when using the [InAppPurchasePlatform]
  /// or by setting the [accountId] in [BillingClient.launchBillingFlow].
  final String? obfuscatedAccountId;

  /// The obfuscatedProfileId can be used when there are multiple profiles
  /// withing one account. The obfuscatedProfileId should be specified when
  /// making a purchase. This property can only be set on a purchase by
  /// directly calling [BillingClient.launchBillingFlow] and is not available
  /// on the generic [InAppPurchasePlatform].
  final String? obfuscatedProfileId;
}

/// Data structure representing a purchase history record.
///
/// This class includes a subset of fields in [PurchaseWrapper].
///
/// This wraps [`com.android.billlingclient.api.PurchaseHistoryRecord`](https://developer.android.com/reference/com/android/billingclient/api/PurchaseHistoryRecord)
///
/// * See also: [BillingClient.queryPurchaseHistory] for obtaining a [PurchaseHistoryRecordWrapper].
// We can optionally make [PurchaseWrapper] extend or implement [PurchaseHistoryRecordWrapper].
// For now, we keep them separated classes to be consistent with Android's BillingClient implementation.
@JsonSerializable()
@immutable
class PurchaseHistoryRecordWrapper {
  /// Creates a [PurchaseHistoryRecordWrapper] with the given record details.
  @visibleForTesting
  const PurchaseHistoryRecordWrapper({
    required this.purchaseTime,
    required this.purchaseToken,
    required this.signature,
    required this.sku,
    required this.originalJson,
    required this.developerPayload,
  });

  /// Factory for creating a [PurchaseHistoryRecordWrapper] from a [Map] with the record details.
  factory PurchaseHistoryRecordWrapper.fromJson(Map<String, dynamic> map) =>
      _$PurchaseHistoryRecordWrapperFromJson(map);

  /// When the purchase was made, as an epoch timestamp.
  @JsonKey(defaultValue: 0)
  final int purchaseTime;

  /// A unique ID for a given [SkuDetailsWrapper], user, and purchase.
  @JsonKey(defaultValue: '')
  final String purchaseToken;

  /// Signature of purchase data, signed with the developer's private key. Uses
  /// RSASSA-PKCS1-v1_5.
  @JsonKey(defaultValue: '')
  final String signature;

  /// The product ID of this purchase.
  @JsonKey(defaultValue: '')
  final String sku;

  /// Details about this purchase, in JSON.
  ///
  /// This can be used verify a purchase. See ["Verify a purchase on a
  /// device"](https://developer.android.com/google/play/billing/billing_library_overview#Verify-purchase-device).
  /// Note though that verifying a purchase locally is inherently insecure (see
  /// the article for more details).
  @JsonKey(defaultValue: '')
  final String originalJson;

  /// The payload specified by the developer when the purchase was acknowledged or consumed.
  ///
  /// The value is `null` if it wasn't specified when the purchase was acknowledged or consumed.
  final String? developerPayload;

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) {
      return true;
    }
    if (other.runtimeType != runtimeType) {
      return false;
    }
    return other is PurchaseHistoryRecordWrapper &&
        other.purchaseTime == purchaseTime &&
        other.purchaseToken == purchaseToken &&
        other.signature == signature &&
        other.sku == sku &&
        other.originalJson == originalJson &&
        other.developerPayload == developerPayload;
  }

  @override
  int get hashCode => hashValues(purchaseTime, purchaseToken, signature, sku,
      originalJson, developerPayload);
}

/// A data struct representing the result of a transaction.
///
/// Contains a potentially empty list of [PurchaseWrapper]s, a [BillingResultWrapper]
/// that contains a detailed description of the status and a
/// [BillingResponse] to signify the overall state of the transaction.
///
/// Wraps [`com.android.billingclient.api.Purchase.PurchasesResult`](https://developer.android.com/reference/com/android/billingclient/api/Purchase.PurchasesResult).
@JsonSerializable()
@BillingResponseConverter()
@immutable
class PurchasesResultWrapper {
  /// Creates a [PurchasesResultWrapper] with the given purchase result details.
  const PurchasesResultWrapper(
      {required this.responseCode,
      required this.billingResult,
      required this.purchasesList});

  /// Factory for creating a [PurchaseResultWrapper] from a [Map] with the result details.
  factory PurchasesResultWrapper.fromJson(Map<String, dynamic> map) =>
      _$PurchasesResultWrapperFromJson(map);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) {
      return true;
    }
    if (other.runtimeType != runtimeType) {
      return false;
    }
    return other is PurchasesResultWrapper &&
        other.responseCode == responseCode &&
        other.purchasesList == purchasesList &&
        other.billingResult == billingResult;
  }

  @override
  int get hashCode => hashValues(billingResult, responseCode, purchasesList);

  /// The detailed description of the status of the operation.
  final BillingResultWrapper billingResult;

  /// The status of the operation.
  ///
  /// This can represent either the status of the "query purchase history" half
  /// of the operation and the "user made purchases" transaction itself.
  final BillingResponse responseCode;

  /// The list of successful purchases made in this transaction.
  ///
  /// May be empty, especially if [responseCode] is not [BillingResponse.ok].
  @JsonKey(defaultValue: <PurchaseWrapper>[])
  final List<PurchaseWrapper> purchasesList;
}

/// A data struct representing the result of a purchase history.
///
/// Contains a potentially empty list of [PurchaseHistoryRecordWrapper]s and a [BillingResultWrapper]
/// that contains a detailed description of the status.
@JsonSerializable()
@BillingResponseConverter()
@immutable
class PurchasesHistoryResult {
  /// Creates a [PurchasesHistoryResult] with the provided history.
  const PurchasesHistoryResult(
      {required this.billingResult, required this.purchaseHistoryRecordList});

  /// Factory for creating a [PurchasesHistoryResult] from a [Map] with the history result details.
  factory PurchasesHistoryResult.fromJson(Map<String, dynamic> map) =>
      _$PurchasesHistoryResultFromJson(map);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) {
      return true;
    }
    if (other.runtimeType != runtimeType) {
      return false;
    }
    return other is PurchasesHistoryResult &&
        other.purchaseHistoryRecordList == purchaseHistoryRecordList &&
        other.billingResult == billingResult;
  }

  @override
  int get hashCode => hashValues(billingResult, purchaseHistoryRecordList);

  /// The detailed description of the status of the [BillingClient.queryPurchaseHistory].
  final BillingResultWrapper billingResult;

  /// The list of queried purchase history records.
  ///
  /// May be empty, especially if [billingResult.responseCode] is not [BillingResponse.ok].
  @JsonKey(defaultValue: <PurchaseHistoryRecordWrapper>[])
  final List<PurchaseHistoryRecordWrapper> purchaseHistoryRecordList;
}

/// Possible state of a [PurchaseWrapper].
///
/// Wraps
/// [`BillingClient.api.Purchase.PurchaseState`](https://developer.android.com/reference/com/android/billingclient/api/Purchase.PurchaseState.html).
/// * See also: [PurchaseWrapper].
@JsonEnum(alwaysCreate: true)
enum PurchaseStateWrapper {
  /// The state is unspecified.
  ///
  /// No actions on the [PurchaseWrapper] should be performed on this state.
  /// This is a catch-all. It should never be returned by the Play Billing Library.
  @JsonValue(0)
  unspecified_state,

  /// The user has completed the purchase process.
  ///
  /// The production should be delivered and then the purchase should be acknowledged.
  /// * See also [BillingClient.acknowledgePurchase] for more details on acknowledging purchases.
  @JsonValue(1)
  purchased,

  /// The user has started the purchase process.
  ///
  /// The user should follow the instructions that were given to them by the Play
  /// Billing Library to complete the purchase.
  ///
  /// You can also choose to remind the user to complete the purchase if you detected a
  /// [PurchaseWrapper] is still in the `pending` state in the future while calling [BillingClient.queryPurchases].
  @JsonValue(2)
  pending,
}

/// Serializer for [PurchaseStateWrapper].
///
/// Use these in `@JsonSerializable()` classes by annotating them with
/// `@PurchaseStateConverter()`.
class PurchaseStateConverter
    implements JsonConverter<PurchaseStateWrapper, int?> {
  /// Default const constructor.
  const PurchaseStateConverter();

  @override
  PurchaseStateWrapper fromJson(int? json) {
    if (json == null) {
      return PurchaseStateWrapper.unspecified_state;
    }
    return $enumDecode(_$PurchaseStateWrapperEnumMap, json);
  }

  @override
  int toJson(PurchaseStateWrapper object) =>
      _$PurchaseStateWrapperEnumMap[object]!;

  /// Converts the purchase state stored in `object` to a [PurchaseStatus].
  ///
  /// [PurchaseStateWrapper.unspecified_state] is mapped to [PurchaseStatus.error].
  PurchaseStatus toPurchaseStatus(PurchaseStateWrapper object) {
    switch (object) {
      case PurchaseStateWrapper.pending:
        return PurchaseStatus.pending;
      case PurchaseStateWrapper.purchased:
        return PurchaseStatus.purchased;
      case PurchaseStateWrapper.unspecified_state:
        return PurchaseStatus.error;
    }
  }
}
