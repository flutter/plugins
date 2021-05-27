// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:in_app_purchase_platform_interface/in_app_purchase_platform_interface.dart';

import 'types.dart';

/// The response object for fetching the past purchases.
///
/// An instance of this class is returned in [InAppPurchaseConnection.queryPastPurchases].
class QueryPurchaseDetailsResponse {
  /// Creates a new [QueryPurchaseDetailsResponse] object with the provider information.
  QueryPurchaseDetailsResponse({required this.pastPurchases, this.error});

  /// A list of successfully fetched past purchases.
  ///
  /// If there are no past purchases, or there is an [error] fetching past purchases,
  /// this variable is an empty List.
  /// You should verify the purchase data using [PurchaseDetails.verificationData] before using the [PurchaseDetails] object.
  final List<GooglePlayPurchaseDetails> pastPurchases;

  /// The error when fetching past purchases.
  ///
  /// If the fetch is successful, the value is `null`.
  final IAPError? error;
}
