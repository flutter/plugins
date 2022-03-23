// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'enum_converters.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SerializedEnums _$SerializedEnumsFromJson(Map json) => _SerializedEnums()
  ..response =
      $enumDecode(_$SKPaymentTransactionStateWrapperEnumMap, json['response'])
  ..unit = $enumDecode(_$SKSubscriptionPeriodUnitEnumMap, json['unit'])
  ..discountPaymentMode = $enumDecode(
      _$SKProductDiscountPaymentModeEnumMap, json['discountPaymentMode']);

const _$SKPaymentTransactionStateWrapperEnumMap = {
  SKPaymentTransactionStateWrapper.purchasing: 0,
  SKPaymentTransactionStateWrapper.purchased: 1,
  SKPaymentTransactionStateWrapper.failed: 2,
  SKPaymentTransactionStateWrapper.restored: 3,
  SKPaymentTransactionStateWrapper.deferred: 4,
  SKPaymentTransactionStateWrapper.unspecified: -1,
};

const _$SKSubscriptionPeriodUnitEnumMap = {
  SKSubscriptionPeriodUnit.day: 0,
  SKSubscriptionPeriodUnit.week: 1,
  SKSubscriptionPeriodUnit.month: 2,
  SKSubscriptionPeriodUnit.year: 3,
};

const _$SKProductDiscountPaymentModeEnumMap = {
  SKProductDiscountPaymentMode.payAsYouGo: 0,
  SKProductDiscountPaymentMode.payUpFront: 1,
  SKProductDiscountPaymentMode.freeTrail: 2,
  SKProductDiscountPaymentMode.unspecified: -1,
};

const _$SKProductDiscountTypeEnumMap = {
  SKProductDiscountType.introductory: 0,
  SKProductDiscountType.subscription: 1,
};
