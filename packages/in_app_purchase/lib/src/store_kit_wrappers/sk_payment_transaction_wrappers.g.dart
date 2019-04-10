// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sk_payment_transaction_wrappers.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SKPaymentTransactionWrapper _$SKPaymentTransactionWrapperFromJson(Map json) {
  return SKPaymentTransactionWrapper(
      payment: json['payment'] == null
          ? null
          : SKPaymentWrapper.fromJson(json['payment'] as Map),
      transactionState: _$enumDecodeNullable(
          _$SKPaymentTransactionStateWrapperEnumMap, json['transactionState']),
      originalTransaction: json['originalTransaction'] == null
          ? null
          : SKPaymentTransactionWrapper.fromJson(
              json['originalTransaction'] as Map),
      transactionTimeStamp: (json['transactionTimeStamp'] as num)?.toDouble(),
      transactionIdentifier: json['transactionIdentifier'] as String,
      error: json['error'] == null
          ? null
          : SKError.fromJson(json['error'] as Map));
}

Map<String, dynamic> _$SKPaymentTransactionWrapperToJson(
        SKPaymentTransactionWrapper instance) =>
    <String, dynamic>{
      'transactionState':
          _$SKPaymentTransactionStateWrapperEnumMap[instance.transactionState],
      'payment': instance.payment,
      'originalTransaction': instance.originalTransaction,
      'transactionTimeStamp': instance.transactionTimeStamp,
      'transactionIdentifier': instance.transactionIdentifier,
      'error': instance.error
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

T _$enumDecodeNullable<T>(Map<T, dynamic> enumValues, dynamic source) {
  if (source == null) {
    return null;
  }
  return _$enumDecode<T>(enumValues, source);
}

const _$SKPaymentTransactionStateWrapperEnumMap =
    <SKPaymentTransactionStateWrapper, dynamic>{
  SKPaymentTransactionStateWrapper.purchasing: 0,
  SKPaymentTransactionStateWrapper.purchased: 1,
  SKPaymentTransactionStateWrapper.failed: 2,
  SKPaymentTransactionStateWrapper.restored: 3,
  SKPaymentTransactionStateWrapper.deferred: 4
};
