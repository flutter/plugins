// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'product_details.dart';

/// The parameter object for generating a purchase.
class PurchaseParam {
  /// Creates a new purchase parameter object with the given data.
  PurchaseParam({
    required this.productDetails,
    this.applicationUserName,
  });

  /// The product to create payment for.
  ///
  /// It has to match one of the valid [ProductDetails] objects that you get from [ProductDetailsResponse] after calling [InAppPurchasePlatform.queryProductDetails].
  final ProductDetails productDetails;

  /// An opaque id for the user's account that's unique to your app. (Optional)
  ///
  /// Used to help the store detect irregular activity.
  /// Do not pass in a clear text, your developer ID, the user’s Apple ID, or the
  /// user's Google ID for this field.
  /// For example, you can use a one-way hash of the user’s account name on your server.
  final String? applicationUserName;
}
