import 'package:flutter/services.dart';

/// Thrown to indicate that a purchase could not be finished successfully.
/// 
/// The exception should be implemented per platform. Each platform implementation
/// should override the [shouldRetry] property and return the correct value 
/// according to the platform specific error codes.
abstract class PurchaseException implements Exception {
  /// Creates a [PurchaseException] with the specified error [code] and optional
  /// [message].
  PurchaseException({
    required this.code,
    this.message,
  });

  /// The error code indicating 
  final String code;

  /// An human readible error message, possibly null.
  final String? message;

  /// Indicates if the action should be retried or not.
  /// 
  /// Implementing classes should override this property and make sure the 
  /// correct value is returned based on the [code] value.
  bool get shouldRetry;
}
