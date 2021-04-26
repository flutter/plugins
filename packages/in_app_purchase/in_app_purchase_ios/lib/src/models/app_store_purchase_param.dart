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
  /// See also [SKPaymentWrapper.simulatesAskToBuyInSandbox].
  final bool simulatesAskToBuyInSandbox;
}
