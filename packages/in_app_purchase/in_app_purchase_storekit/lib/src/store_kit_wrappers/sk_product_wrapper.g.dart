// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sk_product_wrapper.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SkProductResponseWrapper _$SkProductResponseWrapperFromJson(Map json) =>
    SkProductResponseWrapper(
      products: (json['products'] as List<dynamic>?)
              ?.map((e) => SKProductWrapper.fromJson(
                  Map<String, dynamic>.from(e as Map)))
              .toList() ??
          [],
      invalidProductIdentifiers:
          (json['invalidProductIdentifiers'] as List<dynamic>?)
                  ?.map((e) => e as String)
                  .toList() ??
              [],
    );

SKProductSubscriptionPeriodWrapper _$SKProductSubscriptionPeriodWrapperFromJson(
        Map json) =>
    SKProductSubscriptionPeriodWrapper(
      numberOfUnits: json['numberOfUnits'] as int? ?? 0,
      unit: const SKSubscriptionPeriodUnitConverter()
          .fromJson(json['unit'] as int?),
    );

SKProductDiscountWrapper _$SKProductDiscountWrapperFromJson(Map json) =>
    SKProductDiscountWrapper(
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
      identifier: json['identifier'] as String? ?? null,
      type:
          const SKProductDiscountTypeConverter().fromJson(json['type'] as int?),
    );

SKProductWrapper _$SKProductWrapperFromJson(Map json) => SKProductWrapper(
      productIdentifier: json['productIdentifier'] as String? ?? '',
      localizedTitle: json['localizedTitle'] as String? ?? '',
      localizedDescription: json['localizedDescription'] as String? ?? '',
      priceLocale:
          SKPriceLocaleWrapper.fromJson((json['priceLocale'] as Map?)?.map(
        (k, e) => MapEntry(k as String, e),
      )),
      subscriptionGroupIdentifier:
          json['subscriptionGroupIdentifier'] as String?,
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
      discounts: (json['discounts'] as List<dynamic>?)
              ?.map((e) => SKProductDiscountWrapper.fromJson(
                  Map<String, dynamic>.from(e as Map)))
              .toList() ??
          [],
    );

SKPriceLocaleWrapper _$SKPriceLocaleWrapperFromJson(Map json) =>
    SKPriceLocaleWrapper(
      currencySymbol: json['currencySymbol'] as String? ?? '',
      currencyCode: json['currencyCode'] as String? ?? '',
      countryCode: json['countryCode'] as String? ?? '',
    );
