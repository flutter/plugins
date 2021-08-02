// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:in_app_purchase_ios/in_app_purchase_ios.dart';
import 'package:in_app_purchase_platform_interface/in_app_purchase_platform_interface.dart';

import '../store_kit_wrappers.dart';

/// Contains InApp Purchase features that are only available on iOS.
class InAppPurchaseIosPlatformAddition extends InAppPurchasePlatformAddition {
  /// Present Code Redemption Sheet.
  ///
  /// Available on devices running iOS 14 and iPadOS 14 and later.
  Future presentCodeRedemptionSheet() {
    return SKPaymentQueueWrapper().presentCodeRedemptionSheet();
  }

  /// Retry loading purchase data after an initial failure.
  ///
  /// If no results, a `null` value is returned.
  Future<PurchaseVerificationData?> refreshPurchaseVerificationData() async {
    await SKRequestMaker().startRefreshReceiptRequest();
    try {
      String receipt = await SKReceiptManager.retrieveReceiptData();
      return PurchaseVerificationData(
          localVerificationData: receipt,
          serverVerificationData: receipt,
          source: kIAPSource);
    } catch (e) {
      print(
          'Something is wrong while fetching the receipt, this normally happens when the app is '
          'running on a simulator: $e');
      return null;
    }
  }

  /// Sets an implementation of the [SKPaymentQueueDelegateWrapper].
  ///
  /// The [SKPaymentQueueDelegateWrapper] can be used to inform iOS how to
  /// finish transactions when the storefront changes or if the price consent
  /// sheet should be displayed when the price of a subscription has changed. If
  /// no delegate is registered iOS will fallback to it's default configuration.
  /// See the documentation on StoreKite's [`-[SKPaymentQueue delegate:]`](https://developer.apple.com/documentation/storekit/skpaymentqueue/3182429-delegate?language=objc).
  ///
  /// When set to `null` the payment queue delegate will be removed and the
  /// default behaviour will apply (see [documentation](https://developer.apple.com/documentation/storekit/skpaymentqueue/3182429-delegate?language=objc)).
  Future setDelegate(SKPaymentQueueDelegateWrapper? delegate) =>
      SKPaymentQueueWrapper().setDelegate(delegate);

  /// Shows the price consent sheet if the user has not yet responded to a
  /// subscription price change.
  ///
  /// Use this function when you have registered a [SKPaymentQueueDelegateWrapper]
  /// (using the [setDelegate] method) and returned `false` when the
  /// `SKPaymentQueueDelegateWrapper.shouldShowPriceConsent()` method was called.
  ///
  /// See documentation of StoreKit's [`-[SKPaymentQueue showPriceConsentIfNeeded]`](https://developer.apple.com/documentation/storekit/skpaymentqueue/3521327-showpriceconsentifneeded?language=objc).
  Future showPriceConsentIfNeeded() =>
      SKPaymentQueueWrapper().showPriceConsentIfNeeded();
}
