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
      responseCode: const BillingResponseConverter()
          .fromJson(json['responseCode'] as int),
      purchasesList: (json['purchasesList'] as List)
          .map((e) => PurchaseWrapper.fromJson(e as Map))
          .toList());
}

Map<String, dynamic> _$PurchasesResultWrapperToJson(
        PurchasesResultWrapper instance) =>
    <String, dynamic>{
      'responseCode':
          const BillingResponseConverter().toJson(instance.responseCode),
      'purchasesList': instance.purchasesList
    };
