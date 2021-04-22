// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/// The class represents the information of a product.
class ProductDetails {
  /// Creates a new product details object with the provided details.
  ProductDetails({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
  });

  /// The identifier of the product.
  ///
  /// For example, on iOS it is specified in App Store Connect; on Android, it is specified in Google Play Console.
  final String id;

  /// The title of the product.
  ///
  /// For example, on iOS it is specified in App Store Connect; on Android, it is specified in Google Play Console.
  final String title;

  /// The description of the product.
  ///
  /// For example, on iOS it is specified in App Store Connect; on Android, it is specified in Google Play Console.
  final String description;

  /// The price of the product, formatted with currency symbol ("$0.99").
  ///
  /// For example, on iOS it is specified in App Store Connect; on Android, it is specified in Google Play Console.
  final String price;
}
