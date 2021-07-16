// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/// Captures an error from the underlying purchase platform.
///
/// The error can happen during the purchase, restoring a purchase, or querying product.
/// Errors from restoring a purchase are not indicative of any errors during the original purchase.
/// See also:
/// * [ProductDetailsResponse] for error when querying product details.
/// * [PurchaseDetails] for error happened in purchase.
class IAPError {
  /// Creates a new IAP error object with the given error details.
  IAPError(
      {required this.source,
      required this.code,
      required this.message,
      this.details});

  /// Which source is the error on.
  final String source;

  /// The error code.
  final String code;

  /// A human-readable error message.
  final String message;

  /// Error details, possibly null.
  final dynamic details;

  @override
  String toString() {
    return 'IAPError(code: $code, source: $source, message: $message, details: $details)';
  }
}
