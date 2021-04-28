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
    final String? receipt = await SKReceiptManager.retrieveReceiptData();
    if (receipt == null) {
      return null;
    }
    return PurchaseVerificationData(
        localVerificationData: receipt,
        serverVerificationData: receipt,
        source: kIAPSource);
  }
}
