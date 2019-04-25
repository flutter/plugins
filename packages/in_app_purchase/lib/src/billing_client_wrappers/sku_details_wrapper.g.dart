// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sku_details_wrapper.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SkuDetailsWrapper _$SkuDetailsWrapperFromJson(Map json) {
  return SkuDetailsWrapper(
      description: json['description'] as String,
      freeTrialPeriod: json['freeTrialPeriod'] as String,
      introductoryPrice: json['introductoryPrice'] as String,
      introductoryPriceMicros: json['introductoryPriceMicros'] as String,
      introductoryPriceCycles: json['introductoryPriceCycles'] as String,
      introductoryPricePeriod: json['introductoryPricePeriod'] as String,
      price: json['price'] as String,
      priceAmountMicros: json['priceAmountMicros'] as int,
      priceCurrencyCode: json['priceCurrencyCode'] as String,
      sku: json['sku'] as String,
      subscriptionPeriod: json['subscriptionPeriod'] as String,
      title: json['title'] as String,
      type: _$enumDecode(_$SkuTypeEnumMap, json['type']),
      isRewarded: json['isRewarded'] as bool);
}

Map<String, dynamic> _$SkuDetailsWrapperToJson(SkuDetailsWrapper instance) =>
    <String, dynamic>{
      'description': instance.description,
      'freeTrialPeriod': instance.freeTrialPeriod,
      'introductoryPrice': instance.introductoryPrice,
      'introductoryPriceMicros': instance.introductoryPriceMicros,
      'introductoryPriceCycles': instance.introductoryPriceCycles,
      'introductoryPricePeriod': instance.introductoryPricePeriod,
      'price': instance.price,
      'priceAmountMicros': instance.priceAmountMicros,
      'priceCurrencyCode': instance.priceCurrencyCode,
      'sku': instance.sku,
      'subscriptionPeriod': instance.subscriptionPeriod,
      'title': instance.title,
      'type': _$SkuTypeEnumMap[instance.type],
      'isRewarded': instance.isRewarded
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

const _$SkuTypeEnumMap = <SkuType, dynamic>{
  SkuType.inapp: 'inapp',
  SkuType.subs: 'subs'
};

SkuDetailsResponseWrapper _$SkuDetailsResponseWrapperFromJson(Map json) {
  return SkuDetailsResponseWrapper(
      responseCode:
          _$enumDecode(_$BillingResponseEnumMap, json['responseCode']),
      skuDetailsList: (json['skuDetailsList'] as List)
          .map((e) => SkuDetailsWrapper.fromJson(e as Map))
          .toList());
}

Map<String, dynamic> _$SkuDetailsResponseWrapperToJson(
        SkuDetailsResponseWrapper instance) =>
    <String, dynamic>{
      'responseCode': _$BillingResponseEnumMap[instance.responseCode],
      'skuDetailsList': instance.skuDetailsList
    };

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
