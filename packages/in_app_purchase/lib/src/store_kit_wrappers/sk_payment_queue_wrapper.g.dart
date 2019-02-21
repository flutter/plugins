// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sk_payment_queue_wrapper.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SKPaymentTransactionWrapper _$SKPaymentTransactionWrapperFromJson(Map json) {
  return SKPaymentTransactionWrapper(
      payment: SKPaymentWrapper.fromJson(json['payment'] as Map),
      transactionState: _$enumDecode(
          _$SKPaymentTransactionStateWrapperEnumMap, json['transactionState']),
      originalTransaction: SKPaymentTransactionWrapper.fromJson(
          json['originalTransaction'] as Map),
      transactionTimeStamp: (json['transactionTimeStamp'] as num).toDouble(),
      transactionIdentifier: json['transactionIdentifier'] as String,
      downloads: (json['downloads'] as List)
          .map((e) => SKDownloadWrapper.fromJson(e as Map))
          .toList(),
      error: SKError.fromJson(json['error'] as Map));
}

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

const _$SKPaymentTransactionStateWrapperEnumMap =
    <SKPaymentTransactionStateWrapper, dynamic>{
  SKPaymentTransactionStateWrapper.purchasing: 0,
  SKPaymentTransactionStateWrapper.purchased: 1,
  SKPaymentTransactionStateWrapper.failed: 2,
  SKPaymentTransactionStateWrapper.restored: 3,
  SKPaymentTransactionStateWrapper.deferred: 4
};

SKDownloadWrapper _$SKDownloadWrapperFromJson(Map json) {
  return SKDownloadWrapper(
      contentIdentifier: json['contentIdentifier'] as String,
      state: _$enumDecode(_$SKDownloadStateEnumMap, json['state']),
      contentLength: json['contentLength'] as int,
      contentURL: json['contentURL'] as String,
      contentVersion: json['contentVersion'] as String,
      transactionID: json['transactionID'] as String,
      progress: (json['progress'] as num).toDouble(),
      timeRemaining: (json['timeRemaining'] as num).toDouble(),
      downloadTimeUnknown: json['downloadTimeUnknown'] as bool,
      error: SKError.fromJson(json['error'] as Map));
}

const _$SKDownloadStateEnumMap = <SKDownloadState, dynamic>{
  SKDownloadState.waiting: 0,
  SKDownloadState.active: 1,
  SKDownloadState.pause: 2,
  SKDownloadState.finished: 3,
  SKDownloadState.failed: 4,
  SKDownloadState.cancelled: 5
};

SKError _$SKErrorFromJson(Map json) {
  return SKError(
      code: json['code'] as int,
      domain: json['domain'] as String,
      userInfo: Map<String, dynamic>.from(json['userInfo'] as Map));
}

SKPaymentWrapper _$SKPaymentWrapperFromJson(Map json) {
  return SKPaymentWrapper(
      productIdentifier: json['productIdentifier'] as String,
      applicationUsername: json['applicationUsername'] as String,
      requestData: json['requestData'] as String,
      quantity: json['quantity'] as int,
      simulatesAskToBuyInSandbox: json['simulatesAskToBuyInSandbox'] as bool);
}
