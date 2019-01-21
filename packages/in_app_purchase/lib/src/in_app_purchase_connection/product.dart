// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/// A consolidated product class represents the common fields in StoreKit product and BillingClient product.
///
/// This product class is returned from the [getProductList] method of a [InAppPurchaseConnection] instance. Use this class
/// if you only need to have genenric and basic implementation. If prefer a detailed platform specific impelmentation,
/// use the platform specific class [SKProductWrapper] or [SkuDetailsWrapper] that is inside this class.
class Product {
  // TODO(cyanglaz): implemention required https://github.com/flutter/flutter/issues/26325
}
