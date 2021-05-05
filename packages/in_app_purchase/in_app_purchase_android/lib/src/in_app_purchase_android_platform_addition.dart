// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:in_app_purchase_platform_interface/in_app_purchase_platform_interface.dart';

import '../billing_client_wrappers.dart';

/// Contains InApp Purchase features that are only available on PlayStore.
class InAppPurchaseAndroidPlatformAddition
    extends InAppPurchasePlatformAddition {
  /// Creates a [InAppPurchaseAndroidPlatformAddition] which uses the supplied
  /// `BillingClient` to provide Android specific features.
  InAppPurchaseAndroidPlatformAddition(this._billingClient) {
    assert(
      _enablePendingPurchase,
      'enablePendingPurchases() must be called when initializing the application and before you access the [InAppPurchase.instance].',
    );

    _billingClient.enablePendingPurchases();
  }

  /// Whether pending purchase is enabled.
  ///
  /// See also [enablePendingPurchases] for more on pending purchases.
  static bool get enablePendingPurchase => _enablePendingPurchase;
  static bool _enablePendingPurchase = false;

  /// Enable the [InAppPurchaseConnection] to handle pending purchases.
  ///
  /// This method is required to be called when initialize the application.
  /// It is to acknowledge your application has been updated to support pending purchases.
  /// See [Support pending transactions](https://developer.android.com/google/play/billing/billing_library_overview#pending)
  /// for more details.
  /// Failure to call this method before access [instance] will throw an exception.
  static void enablePendingPurchases() {
    _enablePendingPurchase = true;
  }

  final BillingClient _billingClient;

  /// Mark that the user has consumed a product.
  ///
  /// You are responsible for consuming all consumable purchases once they are
  /// delivered. The user won't be able to buy the same product again until the
  /// purchase of the product is consumed.
  Future<BillingResultWrapper> consumePurchase(PurchaseDetails purchase) {
    if (purchase.verificationData == null) {
      throw ArgumentError(
          'consumePurchase unsuccessful. The `purchase.verificationData` is not valid');
    }
    return _billingClient
        .consumeAsync(purchase.verificationData.serverVerificationData);
  }
}
