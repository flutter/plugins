// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/foundation.dart';

/// The class represents the information of a product.
///
/// A list of [ProductDetails] can be obtained from the [QueryProductDetailsResponse].
class ProductDetails {
  ProductDetails({
    @required this.id,
    @required this.title,
    @required this.description,
    @required this.price,
  });

  /// The identifier of the product, specified in App Store Connect or Sku in Google Play console.
  final String id;

  /// The title of the product, specified in the App Store Connect or Sku in Google Play console based on the platform.
  final String title;

  /// The description of the product, specified in the App Store Connect or Sku in Google Play console based on the platform.
  final String description;

  /// The price of the product, specified in the App Store Connect or Sku in Google Play console based on the platform.
  /// Formatted with currency symbol ("$0.99").
  final String price;
}

/// The response returned by [InAppPurchaseConnection.queryProductDetails]
class QueryProductDetailsResponse {
  QueryProductDetailsResponse(
      {@required this.productDetails, @required this.notFoundIDs});

  ///Each [ProductDetails] uniquely matches one valid identifier in [identifiers] of [InAppPurchaseConnection.queryProductDetails].
  final List<ProductDetails> productDetails;

  ///The list of identifiers that are in the `identifiers` of [InAppPurchaseConnection.queryProductDetails] but failed to be fetched.
  ///
  ///These are the identifiers not matching the `productIdentifer` or `sku` in any product on the App Store Connect or Google Play Console.
  final List<String> notFoundIDs;
}
