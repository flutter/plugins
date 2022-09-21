// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'purchase_wrapper.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PurchaseWrapper _$PurchaseWrapperFromJson(Map json) => PurchaseWrapper(
      orderId: json['orderId'] as String? ?? '',
      packageName: json['packageName'] as String? ?? '',
      purchaseTime: json['purchaseTime'] as int? ?? 0,
      purchaseToken: json['purchaseToken'] as String? ?? '',
      signature: json['signature'] as String? ?? '',
      skus:
          (json['skus'] as List<dynamic>?)?.map((e) => e as String).toList() ??
              [],
      isAutoRenewing: json['isAutoRenewing'] as bool,
      originalJson: json['originalJson'] as String? ?? '',
      developerPayload: json['developerPayload'] as String?,
      isAcknowledged: json['isAcknowledged'] as bool? ?? false,
      purchaseState: const PurchaseStateConverter()
          .fromJson(json['purchaseState'] as int?),
      obfuscatedAccountId: json['obfuscatedAccountId'] as String?,
      obfuscatedProfileId: json['obfuscatedProfileId'] as String?,
    );

PurchaseHistoryRecordWrapper _$PurchaseHistoryRecordWrapperFromJson(Map json) =>
    PurchaseHistoryRecordWrapper(
      purchaseTime: json['purchaseTime'] as int? ?? 0,
      purchaseToken: json['purchaseToken'] as String? ?? '',
      signature: json['signature'] as String? ?? '',
      skus:
          (json['skus'] as List<dynamic>?)?.map((e) => e as String).toList() ??
              [],
      originalJson: json['originalJson'] as String? ?? '',
      developerPayload: json['developerPayload'] as String?,
    );

PurchasesResultWrapper _$PurchasesResultWrapperFromJson(Map json) =>
    PurchasesResultWrapper(
      responseCode: const BillingResponseConverter()
          .fromJson(json['responseCode'] as int?),
      billingResult:
          BillingResultWrapper.fromJson((json['billingResult'] as Map?)?.map(
        (k, e) => MapEntry(k as String, e),
      )),
      purchasesList: (json['purchasesList'] as List<dynamic>?)
              ?.map((e) =>
                  PurchaseWrapper.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList() ??
          [],
    );

PurchasesHistoryResult _$PurchasesHistoryResultFromJson(Map json) =>
    PurchasesHistoryResult(
      billingResult:
          BillingResultWrapper.fromJson((json['billingResult'] as Map?)?.map(
        (k, e) => MapEntry(k as String, e),
      )),
      purchaseHistoryRecordList:
          (json['purchaseHistoryRecordList'] as List<dynamic>?)
                  ?.map((e) => PurchaseHistoryRecordWrapper.fromJson(
                      Map<String, dynamic>.from(e as Map)))
                  .toList() ??
              [],
    );

const _$PurchaseStateWrapperEnumMap = {
  PurchaseStateWrapper.unspecified_state: 0,
  PurchaseStateWrapper.purchased: 1,
  PurchaseStateWrapper.pending: 2,
};
