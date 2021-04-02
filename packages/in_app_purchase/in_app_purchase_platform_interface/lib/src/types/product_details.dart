// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/// The class represents the information of a product.
///
/// This class unifies the BillingClient's [SkuDetailsWrapper] and StoreKit's [SKProductWrapper]. You can use the common attributes in
/// This class for simple operations. If you would like to see the detailed representation of the product, instead,  use [skuDetails] on Android and [skProduct] on iOS.
class ProductDetails {
  /// Creates a new product details object with the provided details.
  ProductDetails({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
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
