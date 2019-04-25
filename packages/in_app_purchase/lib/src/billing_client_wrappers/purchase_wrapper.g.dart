// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'purchase_wrapper.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PurchaseWrapper _$PurchaseWrapperFromJson(Map json) {
  return PurchaseWrapper(
      orderId: json['orderId'] as String,
      packageName: json['packageName'] as String,
      purchaseTime: json['purchaseTime'] as int,
      purchaseToken: json['purchaseToken'] as String,
      signature: json['signature'] as String,
      sku: json['sku'] as String,
      isAutoRenewing: json['isAutoRenewing'] as bool,
      originalJson: json['originalJson'] as String);
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
      'originalJson': instance.originalJson
    };

PurchasesResultWrapper _$PurchasesResultWrapperFromJson(Map json) {
  return PurchasesResultWrapper(
      responseCode:
          _$enumDecode(_$BillingResponseEnumMap, json['responseCode']),
      purchasesList: (json['purchasesList'] as List)
          .map((e) => PurchaseWrapper.fromJson(e as Map))
          .toList());
}

Map<String, dynamic> _$PurchasesResultWrapperToJson(
        PurchasesResultWrapper instance) =>
    <String, dynamic>{
      'responseCode': _$BillingResponseEnumMap[instance.responseCode],
      'purchasesList': instance.purchasesList
    };

T _$enumDecode<T>(Map<T, dynamic> enumValues, dynamic source) {
  if (source == null) {
    throw ArgumentError('A value must be provided. Supported values: '
        '${enumValues.values.join(', ')}');
  }
  return enumValues.entries
      .singleWhere((e) => e.value == source,
          orElse: () => throw ArgumentError(
              '`$source` is not one of the supported values: '
              '${enumValues.values.join(', ')}'))
      .key;
}

const _$BillingResponseEnumMap = <BillingResponse, dynamic>{
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
  BillingResponse.itemNotOwned: 8
};
