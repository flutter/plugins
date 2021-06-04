// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'enum_converters.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SerializedEnums _$_SerializedEnumsFromJson(Map json) {
  return _SerializedEnums()
    ..response = _$enumDecode(
        _$SKPaymentTransactionStateWrapperEnumMap, json['response'])
    ..unit = _$enumDecode(_$SKSubscriptionPeriodUnitEnumMap, json['unit'])
    ..discountPaymentMode = _$enumDecode(
        _$SKProductDiscountPaymentModeEnumMap, json['discountPaymentMode']);
}

Map<String, dynamic> _$_SerializedEnumsToJson(_SerializedEnums instance) =>
    <String, dynamic>{
      'response': _$SKPaymentTransactionStateWrapperEnumMap[instance.response],
      'unit': _$SKSubscriptionPeriodUnitEnumMap[instance.unit],
      'discountPaymentMode':
          _$SKProductDiscountPaymentModeEnumMap[instance.discountPaymentMode],
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
