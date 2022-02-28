// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:in_app_purchase_android/billing_client_wrappers.dart';
import 'package:in_app_purchase_platform_interface/in_app_purchase_platform_interface.dart';

/// The class represents the information of a product as registered in at
/// Google Play store front.
class GooglePlayProductDetails extends ProductDetails {
  /// Creates a new Google Play specific product details object with the
  /// provided details.
  GooglePlayProductDetails({
    required String id,
    required String title,
    required String description,
    required String price,
    required double rawPrice,
    required String currencyCode,
    required this.skuDetails,
    required String currencySymbol,
  }) : super(
          id: id,
          title: title,
          description: description,
          price: price,
          rawPrice: rawPrice,
          currencyCode: currencyCode,
          currencySymbol: currencySymbol,
        );

  /// Generate a [GooglePlayProductDetails] object based on an Android
  /// [SkuDetailsWrapper] object.
  factory GooglePlayProductDetails.fromSkuDetails(
    SkuDetailsWrapper skuDetails,
  ) {
    return GooglePlayProductDetails(
      id: skuDetails.sku,
      title: skuDetails.title,
      description: skuDetails.description,
      price: skuDetails.price,
      rawPrice: ((skuDetails.priceAmountMicros) / 1000000.0).toDouble(),
      currencyCode: skuDetails.priceCurrencyCode,
      currencySymbol: skuDetails.priceCurrencySymbol,
      skuDetails: skuDetails,
    );
  }

  /// Points back to the [SkuDetailsWrapper] object that was used to generate
  /// this [GooglePlayProductDetails] object.
  final SkuDetailsWrapper skuDetails;
}
