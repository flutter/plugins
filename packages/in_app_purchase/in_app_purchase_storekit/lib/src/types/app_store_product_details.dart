// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:in_app_purchase_platform_interface/in_app_purchase_platform_interface.dart';

import '../../store_kit_wrappers.dart';

/// The class represents the information of a product as registered in the Apple
/// AppStore.
class AppStoreProductDetails extends ProductDetails {
  /// Creates a new AppStore specific product details object with the provided
  /// details.
  AppStoreProductDetails({
    required super.id,
    required super.title,
    required super.description,
    required super.price,
    required super.rawPrice,
    required super.currencyCode,
    required this.skProduct,
    required super.currencySymbol,
  });

  /// Generate a [AppStoreProductDetails] object based on an iOS [SKProductWrapper] object.
  factory AppStoreProductDetails.fromSKProduct(SKProductWrapper product) {
    return AppStoreProductDetails(
      id: product.productIdentifier,
      title: product.localizedTitle,
      description: product.localizedDescription,
      price: product.priceLocale.currencySymbol + product.price,
      rawPrice: double.parse(product.price),
      currencyCode: product.priceLocale.currencyCode,
      currencySymbol: product.priceLocale.currencySymbol.isNotEmpty
          ? product.priceLocale.currencySymbol
          : product.priceLocale.currencyCode,
      skProduct: product,
    );
  }

  /// Points back to the [SKProductWrapper] object that was used to generate
  /// this [AppStoreProductDetails] object.
  final SKProductWrapper skProduct;
}
