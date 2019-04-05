import 'package:in_app_purchase/store_kit_wrappers.dart';
import 'package:json_annotation/json_annotation.dart';

part 'enum_converters.g.dart';

/// Serializer for [SKPaymentTransactionStateWrapper].
///
/// Use these in `@JsonSerializable()` classes by annotating them with
/// `@SKTransactionStatusConverter()`.
class SKTransactionStatusConverter
    implements JsonConverter<SKPaymentTransactionStateWrapper, int> {
  const SKTransactionStatusConverter();

  @override
  SKPaymentTransactionStateWrapper fromJson(int json) =>
      _$enumDecode<SKPaymentTransactionStateWrapper>(
          _$SKPaymentTransactionStateWrapperEnumMap
              .cast<SKPaymentTransactionStateWrapper, dynamic>(),
          json);

  @override
  int toJson(SKPaymentTransactionStateWrapper object) =>
      _$SKPaymentTransactionStateWrapperEnumMap[object];
}

// Define a class so we generate serializer helper methods for the enums
@JsonSerializable()
class _SerializedEnums {
  SKPaymentTransactionStateWrapper response;
}
