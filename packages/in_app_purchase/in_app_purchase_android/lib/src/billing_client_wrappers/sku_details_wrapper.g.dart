// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sku_details_wrapper.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SkuDetailsWrapper _$SkuDetailsWrapperFromJson(Map json) => SkuDetailsWrapper(
      description: json['description'] as String? ?? '',
      freeTrialPeriod: json['freeTrialPeriod'] as String? ?? '',
      introductoryPrice: json['introductoryPrice'] as String? ?? '',
      introductoryPriceAmountMicros:
          json['introductoryPriceAmountMicros'] as int? ?? 0,
      introductoryPriceCycles: json['introductoryPriceCycles'] as int? ?? 0,
      introductoryPricePeriod: json['introductoryPricePeriod'] as String? ?? '',
      price: json['price'] as String? ?? '',
      priceAmountMicros: json['priceAmountMicros'] as int? ?? 0,
      priceCurrencyCode: json['priceCurrencyCode'] as String? ?? '',
      priceCurrencySymbol: json['priceCurrencySymbol'] as String? ?? '',
      sku: json['sku'] as String? ?? '',
      subscriptionPeriod: json['subscriptionPeriod'] as String? ?? '',
      title: json['title'] as String? ?? '',
      type: const SkuTypeConverter().fromJson(json['type'] as String?),
      originalPrice: json['originalPrice'] as String? ?? '',
      originalPriceAmountMicros: json['originalPriceAmountMicros'] as int? ?? 0,
    );

SkuDetailsResponseWrapper _$SkuDetailsResponseWrapperFromJson(Map json) =>
    SkuDetailsResponseWrapper(
      billingResult:
          BillingResultWrapper.fromJson((json['billingResult'] as Map?)?.map(
        (k, e) => MapEntry(k as String, e),
      )),
      skuDetailsList: (json['skuDetailsList'] as List<dynamic>?)
              ?.map((e) => SkuDetailsWrapper.fromJson(
                  Map<String, dynamic>.from(e as Map)))
              .toList() ??
          [],
    );

BillingResultWrapper _$BillingResultWrapperFromJson(Map json) =>
    BillingResultWrapper(
      responseCode: const BillingResponseConverter()
          .fromJson(json['responseCode'] as int?),
      debugMessage: json['debugMessage'] as String?,
    );
