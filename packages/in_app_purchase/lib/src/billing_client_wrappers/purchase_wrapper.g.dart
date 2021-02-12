// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'purchase_wrapper.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PurchaseWrapper _$PurchaseWrapperFromJson(Map json) {
  return PurchaseWrapper(
    orderId: json['orderId'] as String? ?? '',
    packageName: json['packageName'] as String? ?? '',
    purchaseTime: json['purchaseTime'] as int? ?? 0,
    purchaseToken: json['purchaseToken'] as String? ?? '',
    signature: json['signature'] as String? ?? '',
    sku: json['sku'] as String? ?? '',
    isAutoRenewing: json['isAutoRenewing'] as bool?,
    originalJson: json['originalJson'] as String? ?? '',
    developerPayload: json['developerPayload'] as String? ?? '',
    isAcknowledged: json['isAcknowledged'] as bool? ?? false,
    purchaseState:
        _$enumDecode(_$PurchaseStateWrapperEnumMap, json['purchaseState']),
  );
}

Map<String, dynamic> _$PurchaseWrapperToJson(PurchaseWrapper instance) =>
    <String, dynamic>{
      'orderId': instance.orderId,
      'packageName': instance.packageName,
      'purchaseTime': instance.purchaseTime,
      'purchaseToken': instance.purchaseToken,
      'signature': instance.signature,
      'sku': instance.sku,
      'isAutoRenewing': instance.isAutoRenewing,
      'originalJson': instance.originalJson,
      'developerPayload': instance.developerPayload,
      'isAcknowledged': instance.isAcknowledged,
      'purchaseState': _$PurchaseStateWrapperEnumMap[instance.purchaseState],
    };

K _$enumDecode<K, V>(
  Map<K, V> enumValues,
  Object? source, {
  K? unknownValue,
}) {
  if (source == null) {
    throw ArgumentError(
      'A value must be provided. Supported values: '
      '${enumValues.values.join(', ')}',
    );
  }

  return enumValues.entries.singleWhere(
    (e) => e.value == source,
    orElse: () {
      if (unknownValue == null) {
        throw ArgumentError(
          '`$source` is not one of the supported values: '
          '${enumValues.values.join(', ')}',
        );
      }
      return MapEntry(unknownValue, enumValues.values.first);
    },
  ).key;
}

const _$PurchaseStateWrapperEnumMap = {
  PurchaseStateWrapper.unspecified_state: 0,
  PurchaseStateWrapper.purchased: 1,
  PurchaseStateWrapper.pending: 2,
};

PurchaseHistoryRecordWrapper _$PurchaseHistoryRecordWrapperFromJson(Map json) {
  return PurchaseHistoryRecordWrapper(
    purchaseTime: json['purchaseTime'] as int? ?? 0,
    purchaseToken: json['purchaseToken'] as String? ?? '',
    signature: json['signature'] as String? ?? '',
    sku: json['sku'] as String? ?? '',
    originalJson: json['originalJson'] as String? ?? '',
    developerPayload: json['developerPayload'] as String? ?? '',
  );
}

Map<String, dynamic> _$PurchaseHistoryRecordWrapperToJson(
        PurchaseHistoryRecordWrapper instance) =>
    <String, dynamic>{
      'purchaseTime': instance.purchaseTime,
      'purchaseToken': instance.purchaseToken,
      'signature': instance.signature,
      'sku': instance.sku,
      'originalJson': instance.originalJson,
      'developerPayload': instance.developerPayload,
    };

PurchasesResultWrapper _$PurchasesResultWrapperFromJson(Map json) {
  return PurchasesResultWrapper(
    responseCode:
        _$enumDecodeNullable(_$BillingResponseEnumMap, json['responseCode']) ??
            BillingResponse.error,
    billingResult: BillingResultWrapper.fromJson(
        Map<String, dynamic>.from(json['billingResult'] as Map)),
    purchasesList: (json['purchasesList'] as List<dynamic>?)
            ?.map((e) =>
                PurchaseWrapper.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList() ??
        [],
  );
}

Map<String, dynamic> _$PurchasesResultWrapperToJson(
        PurchasesResultWrapper instance) =>
    <String, dynamic>{
      'billingResult': instance.billingResult,
      'responseCode': _$BillingResponseEnumMap[instance.responseCode],
      'purchasesList': instance.purchasesList,
    };

K? _$enumDecodeNullable<K, V>(
  Map<K, V> enumValues,
  dynamic source, {
  K? unknownValue,
}) {
  if (source == null) {
    return null;
  }
  return _$enumDecode<K, V>(enumValues, source, unknownValue: unknownValue);
}

const _$BillingResponseEnumMap = {
  BillingResponse.serviceTimeout: -3,
  BillingResponse.featureNotSupported: -2,
  BillingResponse.serviceDisconnected: -1,
  BillingResponse.ok: 0,
  BillingResponse.userCanceled: 1,
  BillingResponse.serviceUnavailable: 2,
  BillingResponse.billingUnavailable: 3,
  BillingResponse.itemUnavailable: 4,
  BillingResponse.developerError: 5,
  BillingResponse.error: 6,
  BillingResponse.itemAlreadyOwned: 7,
  BillingResponse.itemNotOwned: 8,
};

PurchasesHistoryResult _$PurchasesHistoryResultFromJson(Map json) {
  return PurchasesHistoryResult(
    billingResult: BillingResultWrapper.fromJson(
        Map<String, dynamic>.from(json['billingResult'] as Map)),
    purchaseHistoryRecordList:
        (json['purchaseHistoryRecordList'] as List<dynamic>?)
                ?.map((e) => PurchaseHistoryRecordWrapper.fromJson(
                    Map<String, dynamic>.from(e as Map)))
                .toList() ??
            [],
  );
}

Map<String, dynamic> _$PurchasesHistoryResultToJson(
        PurchasesHistoryResult instance) =>
    <String, dynamic>{
      'billingResult': instance.billingResult,
      'purchaseHistoryRecordList': instance.purchaseHistoryRecordList,
    };
