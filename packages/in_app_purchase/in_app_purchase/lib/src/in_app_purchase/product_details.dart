// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:in_app_purchase/store_kit_wrappers.dart';
import 'package:in_app_purchase/billing_client_wrappers.dart';
import 'in_app_purchase_connection.dart';

/// The class represents the information of a product.
///
/// This class unifies the BillingClient's [SkuDetailsWrapper] and StoreKit's [SKProductWrapper]. You can use the common attributes in
/// This class for simple operations. If you would like to see the detailed representation of the product, instead,  use [skuDetails] on Android and [skProduct] on iOS.
class ProductDetails {
  /// Creates a new product details object with the provided details.
  ProductDetails(
      {required this.id,
      required this.title,
      required this.description,
      required this.price,
      required this.rawPrice,
      required this.currencyCode,
      this.skProduct,
      this.skuDetail});

  /// The identifier of the product, specified in App Store Connect or Sku in Google Play console.
  final String id;

  /// The title of the product, specified in the App Store Connect or Sku in Google Play console based on the platform.
  final String title;

  /// The description of the product, specified in the App Store Connect or Sku in Google Play console based on the platform.
  final String description;

  /// The price of the product, specified in the App Store Connect or Sku in Google Play console based on the platform.
  /// Formatted with currency symbol ("$0.99").
  final String price;

  /// The unformatted price of the product, specified in the App Store Connect or Sku in Google Play console based on the platform.
  /// The currency unit for this value can be found in the [currencyCode] property.
  /// The value always describes full units of the currency. (e.g. 2.45 in the case of $2.45)
  final double rawPrice;

  /// The currency code for the price of the product.
  /// Based on the price specified in the App Store Connect or Sku in Google Play console based on the platform.
  final String currencyCode;

  /// Points back to the `StoreKits`'s [SKProductWrapper] object that generated this [ProductDetails] object.
  ///
  /// This is `null` on Android.
  final SKProductWrapper? skProduct;

  /// Points back to the `BillingClient1`'s [SkuDetailsWrapper] object that generated this [ProductDetails] object.
  ///
  /// This is `null` on iOS.
  final SkuDetailsWrapper? skuDetail;

  /// Generate a [ProductDetails] object based on an iOS [SKProductWrapper] object.
  ProductDetails.fromSKProduct(SKProductWrapper product)
      : this.id = product.productIdentifier,
        this.title = product.localizedTitle,
        this.description = product.localizedDescription,
        this.price = product.priceLocale.currencySymbol + product.price,
        this.rawPrice = double.parse(product.price),
        this.currencyCode = product.priceLocale.currencyCode,
        this.skProduct = product,
        this.skuDetail = null;

  /// Generate a [ProductDetails] object based on an Android [SkuDetailsWrapper] object.
  ProductDetails.fromSkuDetails(SkuDetailsWrapper skuDetails)
      : this.id = skuDetails.sku,
        this.title = skuDetails.title,
        this.description = skuDetails.description,
        this.price = skuDetails.price,
        this.rawPrice = ((skuDetails.priceAmountMicros) / 1000000.0).toDouble(),
        this.currencyCode = skuDetails.priceCurrencyCode,
        this.skProduct = null,
        this.skuDetail = skuDetails;
}

/// The response returned by [InAppPurchaseConnection.queryProductDetails].
///
/// A list of [ProductDetails] can be obtained from the this response.
class ProductDetailsResponse {
  /// Creates a new [ProductDetailsResponse] with the provided response details.
  ProductDetailsResponse(
      {required this.productDetails, required this.notFoundIDs, this.error});

  /// Each [ProductDetails] uniquely matches one valid identifier in [identifiers] of [InAppPurchaseConnection.queryProductDetails].
  final List<ProductDetails> productDetails;

  /// The list of identifiers that are in the `identifiers` of [InAppPurchaseConnection.queryProductDetails] but failed to be fetched.
  ///
  /// There's multiple platform-specific reasons that product information could fail to be fetched,
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
