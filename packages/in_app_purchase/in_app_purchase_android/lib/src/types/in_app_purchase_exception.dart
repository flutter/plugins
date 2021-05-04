// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/// Thrown to indicate that an action failed while interacting with the
/// in_app_purchase plugin.
class InAppPurchaseException implements Exception {
  /// Creates a [InAppPurchaseException] with the specified source and error
  /// [code] and optional [message].
  InAppPurchaseException({
    required this.source,
    required this.code,
    this.message,
  }) : assert(code != null);

  /// An error code.
  final String code;

  /// A human-readable error message, possibly null.
  final String? message;

  /// Which source is the error on.
  final String source;

  @override
  String toString() => 'InAppPurchaseException($code, $message, $source)';
}
