// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/// Represents the data that is used to verify purchases.
///
/// The property [source] helps you to determine the method to verify purchases.
/// Different source of purchase has different methods of verifying purchases.
///
/// Both platforms have 2 ways to verify purchase data. You can either choose to
/// verify the data locally using [localVerificationData] or verify the data
/// using your own server with [serverVerificationData]. It is preferable to
/// verify purchases using a server with [serverVerificationData].
///
/// You should never use any purchase data until verified.
class PurchaseVerificationData {
  /// Creates a [PurchaseVerificationData] object with the provided information.
  PurchaseVerificationData({
    required this.localVerificationData,
    required this.serverVerificationData,
    required this.source,
  });

  /// The data used for local verification.
  ///
  /// The data is formatted according to the specifications of the respective
  /// store. You can use the [source] field to determine the store from which
  /// the data originated and proces the data accordingly.
  final String localVerificationData;

  /// The data used for server verification.
  final String serverVerificationData;

  /// Indicates the source of the purchase.
  final String source;
}
