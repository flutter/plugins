// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sk_product_wrapper.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SkProductResponseWrapper _$SkProductResponseWrapperFromJson(Map json) {
  return SkProductResponseWrapper(
    products: (json['products'] as List<dynamic>?)
            ?.map((e) =>
                SKProductWrapper.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList() ??
        [],
    invalidProductIdentifiers:
        (json['invalidProductIdentifiers'] as List<dynamic>?)
                ?.map((e) => e as String)
                .toList() ??
            [],
  );
}

Map<String, dynamic> _$SkProductResponseWrapperToJson(
        SkProductResponseWrapper instance) =>
    <String, dynamic>{
      'products': instance.products,
      'invalidProductIdentifiers': instance.invalidProductIdentifiers,
    };

SKProductSubscriptionPeriodWrapper _$SKProductSubscriptionPeriodWrapperFromJson(
    Map json) {
  return SKProductSubscriptionPeriodWrapper(
    numberOfUnits: json['numberOfUnits'] as int? ?? 0,
    unit: const SKSubscriptionPeriodUnitConverter()
        .fromJson(json['unit'] as int?),
  );
}

Map<String, dynamic> _$SKProductSubscriptionPeriodWrapperToJson(
        SKProductSubscriptionPeriodWrapper instance) =>
    <String, dynamic>{
      'numberOfUnits': instance.numberOfUnits,
      'unit': const SKSubscriptionPeriodUnitConverter().toJson(instance.unit),
    };

SKProductDiscountWrapper _$SKProductDiscountWrapperFromJson(Map json) {
  return SKProductDiscountWrapper(
    price: json['price'] as String? ?? '',
    priceLocale:
        SKPriceLocaleWrapper.fromJson((json['priceLocale'] as Map?)?.map(
      (k, e) => MapEntry(k as String, e),
    )),
    numberOfPeriods: json['numberOfPeriods'] as int? ?? 0,
    paymentMode: const SKProductDiscountPaymentModeConverter()
        .fromJson(json['paymentMode'] as int?),
    subscriptionPeriod: SKProductSubscriptionPeriodWrapper.fromJson(
        (json['subscriptionPeriod'] as Map?)?.map(
      (k, e) => MapEntry(k as String, e),
    )),
  );
}

Map<String, dynamic> _$SKProductDiscountWrapperToJson(
        SKProductDiscountWrapper instance) =>
    <String, dynamic>{
      'price': instance.price,
      'priceLocale': instance.priceLocale,
      'numberOfPeriods': instance.numberOfPeriods,
      'paymentMode': const SKProductDiscountPaymentModeConverter()
          .toJson(instance.paymentMode),
      'subscriptionPeriod': instance.subscriptionPeriod,
    };

SKProductWrapper _$SKProductWrapperFromJson(Map json) {
  return SKProductWrapper(
    productIdentifier: json['productIdentifier'] as String? ?? '',
    localizedTitle: json['localizedTitle'] as String? ?? '',
    localizedDescription: json['localizedDescription'] as String? ?? '',
    priceLocale:
        SKPriceLocaleWrapper.fromJson((json['priceLocale'] as Map?)?.map(
      (k, e) => MapEntry(k as String, e),
    )),
    subscriptionGroupIdentifier: json['subscriptionGroupIdentifier'] as String?,
    price: json['price'] as String? ?? '',
    subscriptionPeriod: json['subscriptionPeriod'] == null
        ? null
        : SKProductSubscriptionPeriodWrapper.fromJson(
            (json['subscriptionPeriod'] as Map?)?.map(
            (k, e) => MapEntry(k as String, e),
          )),
    introductoryPrice: json['introductoryPrice'] == null
        ? null
        : SKProductDiscountWrapper.fromJson(
            Map<String, dynamic>.from(json['introductoryPrice'] as Map)),
  );
}

Map<String, dynamic> _$SKProductWrapperToJson(SKProductWrapper instance) =>
    <String, dynamic>{
      'productIdentifier': instance.productIdentifier,
      'localizedTitle': instance.localizedTitle,
      'localizedDescription': instance.localizedDescription,
      'priceLocale': instance.priceLocale,
      'subscriptionGroupIdentifier': instance.subscriptionGroupIdentifier,
      'price': instance.price,
      'subscriptionPeriod': instance.subscriptionPeriod,
      'introductoryPrice': instance.introductoryPrice,
    };

SKPriceLocaleWrapper _$SKPriceLocaleWrapperFromJson(Map json) {
  return SKPriceLocaleWrapper(
    localeIdentifier: json['localeIdentifier'] as String? ?? '',
    countryCode: json['countryCode'] as String? ?? '',
    languageCode: json['languageCode'] as String? ?? '',
    scriptCode: json['scriptCode'] as String? ?? '',
    variantCode: json['variantCode'] as String? ?? '',
    collationIdentifier: json['collationIdentifier'] as String? ?? '',
    collatorIdentifier: json['collatorIdentifier'] as String? ?? '',
    usesMetricSystem: json['usesMetricSystem'] as bool? ?? true,
    measurementSystem: json['measurementSystem'] as String? ?? '',
    decimalSeparator: json['decimalSeparator'] as String? ?? '',
    groupingSeparator: json['groupingSeparator'] as String? ?? '',
    currencySymbol: json['currencySymbol'] as String? ?? '',
    currencyCode: json['currencyCode'] as String? ?? '',
    endDelimiterKey: json['endDelimiterKey'] as String? ?? '',
    beginDelimiterKey: json['beginDelimiterKey'] as String? ?? '',
    alternateQuotationEndDelimiterKey:
        json['alternateQuotationEndDelimiterKey'] as String? ?? '',
    alternateQuotationBeginDelimiterKey:
        json['alternateQuotationBeginDelimiterKey'] as String? ?? '',
  );
}

Map<String, dynamic> _$SKPriceLocaleWrapperToJson(
        SKPriceLocaleWrapper instance) =>
    <String, dynamic>{
      'localeIdentifier': instance.localeIdentifier,
      'countryCode': instance.countryCode,
      'languageCode': instance.languageCode,
      'scriptCode': instance.scriptCode,
      'variantCode': instance.variantCode,
      'collationIdentifier': instance.collationIdentifier,
      'collatorIdentifier': instance.collatorIdentifier,
      'usesMetricSystem': instance.usesMetricSystem,
      'measurementSystem': instance.measurementSystem,
      'decimalSeparator': instance.decimalSeparator,
      'groupingSeparator': instance.groupingSeparator,
      'currencySymbol': instance.currencySymbol,
      'currencyCode': instance.currencyCode,
      'endDelimiterKey': instance.endDelimiterKey,
      'beginDelimiterKey': instance.beginDelimiterKey,
      'alternateQuotationEndDelimiterKey':
          instance.alternateQuotationEndDelimiterKey,
      'alternateQuotationBeginDelimiterKey':
          instance.alternateQuotationBeginDelimiterKey,
    };
