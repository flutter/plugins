// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/foundation.dart';

/// The class represents the product object, it combined the common fields in the [SkuDetailsWrapper] and [SKProductWrapper].
///
/// You can use this object for simple IAP operations. For more detailed and platform specific IAP operations,
/// see [SkuDetailsWrapper] and [SKProductWrapper] instead.
/// The programmer should not need to instantiate this object; rather use after returned by [InAppPurchaseConnection.getProductList].
class Product {
  Product({
    @required this.productIdentifier,
    @required this.title,
    @required this.description,
    @required this.price,
  });

  /// The ProductIdentifier in App Store Connect or Sku in Google Play console.
  final String productIdentifier;

  /// The title of the product, specified in the App Store Connect or Sku in Google Play console based on the platform.
  final String title;

  /// The description of the product, specified in the App Store Connect or Sku in Google Play console based on the platform.
  final String description;

  /// The price of the product, specified in the App Store Connect or Sku in Google Play console based on the platform.
  /// Formatted with currency symbol ("$0.99").
  final String price;
}
