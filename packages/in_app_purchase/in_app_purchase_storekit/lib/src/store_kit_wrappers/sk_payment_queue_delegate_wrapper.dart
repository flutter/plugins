// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:in_app_purchase_storekit/store_kit_wrappers.dart';

/// A wrapper around
/// [`SKPaymentQueueDelegate`](https://developer.apple.com/documentation/storekit/skpaymentqueuedelegate?language=objc).
///
/// The payment queue delegate can be implementated to provide information
/// needed to complete transactions.
///
/// The [SKPaymentQueueDelegateWrapper] is only available on iOS 13 and higher.
/// Using the delegate on older iOS version will be ignored.
abstract class SKPaymentQueueDelegateWrapper {
  /// Called by the system to check whether the transaction should continue if
  /// the device's App Store storefront has changed during a transaction.
  ///
  /// - Return `true` if the transaction should continue within the updated
  /// storefront (default behaviour).
  /// - Return `false` if the transaction should be cancelled. In this case the
  /// transaction will fail with the error [SKErrorStoreProductNotAvailable](https://developer.apple.com/documentation/storekit/skerrorcode/skerrorstoreproductnotavailable?language=objc).
  ///
  /// See the documentation in StoreKit's [`[-SKPaymentQueueDelegate shouldContinueTransaction]`](https://developer.apple.com/documentation/storekit/skpaymentqueuedelegate/3242935-paymentqueue?language=objc).
  bool shouldContinueTransaction(
    SKPaymentTransactionWrapper transaction,
    SKStorefrontWrapper storefront,
  ) =>
      true;

  /// Called by the system to check whether to immediately show the price
  /// consent form.
  ///
  /// The default return value is `true`. This will inform the system to display
  /// the price consent sheet when the subscription price has been changed in
  /// App Store Connect and the subscriber has not yet taken action. See the
  /// documentation in StoreKit's [`[-SKPaymentQueueDelegate shouldShowPriceConsent:]`](https://developer.apple.com/documentation/storekit/skpaymentqueuedelegate/3521328-paymentqueueshouldshowpriceconse?language=objc).
  bool shouldShowPriceConsent() => true;
}
