// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import '../errors/in_app_purchase_error.dart';
import 'product_details.dart';

/// The response returned by [InAppPurchasePlatform.queryProductDetails].
///
/// A list of [ProductDetails] can be obtained from the this response.
class ProductDetailsResponse {
  /// Creates a new [ProductDetailsResponse] with the provided response details.
  ProductDetailsResponse(
      {required this.productDetails, required this.notFoundIDs, this.error});

  /// Each [ProductDetails] uniquely matches one valid identifier in [identifiers] of [InAppPurchasePlatform.queryProductDetails].
  final List<ProductDetails> productDetails;

  /// The list of identifiers that are in the `identifiers` of [InAppPurchasePlatform.queryProductDetails] but failed to be fetched.
  ///
  /// There are multiple platform-specific reasons that product information could fail to be fetched,
  /// ranging from products not being correctly configured in the storefront to the queried IDs not existing.
  final List<String> notFoundIDs;

  /// A caught platform exception thrown while querying the purchases.
  ///
  /// The value is `null` if there is no error.
  ///
  /// It's possible for this to be null but for there still to be notFoundIds in cases where the request itself was a success but the
  /// requested IDs could not be found.
  final IAPError? error;
}
