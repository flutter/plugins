// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:in_app_purchase_platform_interface/in_app_purchase_platform_interface.dart';

import '../../store_kit_wrappers.dart';

/// Apple AppStore specific parameter object for generating a purchase.
class AppStorePurchaseParam extends PurchaseParam {
  /// Creates a new [AppStorePurchaseParam] object with the given data.
  AppStorePurchaseParam({
    required ProductDetails productDetails,
    String? applicationUserName,
    this.simulatesAskToBuyInSandbox = false,
  }) : super(
          productDetails: productDetails,
          applicationUserName: applicationUserName,
        );

  /// Set it to `true` to produce an "ask to buy" flow for this payment in the
  /// sandbox.
  ///
  /// If you want to test [simulatesAskToBuyInSandbox], you should ensure that
  /// you create an instance of the [AppStorePurchaseParam] class and set its
  /// [simulateAskToBuyInSandbox] field to `true` and use it with the
  /// `buyNonConsumable` or `buyConsumable` methods.
  ///
  /// See also [SKPaymentWrapper.simulatesAskToBuyInSandbox].
  final bool simulatesAskToBuyInSandbox;
}
