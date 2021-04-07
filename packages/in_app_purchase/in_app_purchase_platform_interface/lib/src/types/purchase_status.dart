// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/// Status for a [PurchaseDetails].
///
/// This is the type for [PurchaseDetails.status].
enum PurchaseStatus {
  /// The purchase process is pending.
  ///
  /// You can update UI to let your users know the purchase is pending.
  pending,

  /// The purchase is finished and successful.
  ///
  /// Update your UI to indicate the purchase is finished and deliver the product.
  /// On Android, the google play store is handling the purchase, so we set the status to
  /// `purchased` as long as we can successfully launch play store purchase flow.
  purchased,

  /// Some error occurred in the purchase. The purchasing process if aborted.
  error,

  /// The purchase has been restored to the device.
  ///
  /// You should validate the receipt and if valid deliver the content. Once the
  /// content has been delivered or if the receipt is invalid you should finish
  /// the purchase by calling the `finishPurchase` method.
  restored,
}
