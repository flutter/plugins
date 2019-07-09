import 'package:in_app_purchase/billing_client_wrappers.dart';
import 'package:json_annotation/json_annotation.dart';

part 'enum_converters.g.dart';

/// Serializer for [BillingResponse].
///
/// Use these in `@JsonSerializable()` classes by annotating them with
/// `@BillingResponseConverter()`.
class BillingResponseConverter implements JsonConverter<BillingResponse, int> {
  const BillingResponseConverter();

  @override
  BillingResponse fromJson(int json) => _$enumDecode<BillingResponse>(
      _$BillingResponseEnumMap.cast<BillingResponse, dynamic>(), json);

  @override
  int toJson(BillingResponse object) => _$BillingResponseEnumMap[object];
}

/// Serializer for [SkuType].
///
/// Use these in `@JsonSerializable()` classes by annotating them with
/// `@SkuTypeConverter()`.
class SkuTypeConverter implements JsonConverter<SkuType, String> {
  const SkuTypeConverter();

  @override
  SkuType fromJson(String json) =>
      _$enumDecode<SkuType>(_$SkuTypeEnumMap.cast<SkuType, dynamic>(), json);

  @override
  String toJson(SkuType object) => _$SkuTypeEnumMap[object];
}

// Define a class so we generate serializer helper methods for the enums
@JsonSerializable()
class _SerializedEnums {
  BillingResponse response;
  SkuType type;
}
