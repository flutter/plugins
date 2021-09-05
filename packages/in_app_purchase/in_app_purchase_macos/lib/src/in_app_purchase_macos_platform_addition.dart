// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:in_app_purchase_macos/in_app_purchase_macos.dart';
import 'package:in_app_purchase_platform_interface/in_app_purchase_platform_interface.dart';

import '../store_kit_wrappers.dart';

/// Contains InApp Purchase features that are only available on macOS.
class InAppPurchaseMacOSPlatformAddition extends InAppPurchasePlatformAddition {
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
}
