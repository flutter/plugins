// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sk_payment_queue_wrapper.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

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
