// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'package:in_app_purchase/src/channel.dart';

///This class contains static methods to handle StoreKit receipts.
class ReceiptHandler {
  /// Retrieve the receipt data from your application's main bundle.
  ///
  /// If `serialized` is `false`, the receipt data will be contained in a base64 string inside a map: {"base64data":<base54 encoded string that represents the receipt>}
  /// If `serialized` is `true`, the receipt data will be represented as a Map object.
  /// The default value of `serialized` is `false`.
  /// You can use the receipt data retrieved by this method to validate users' purchases.
  /// There are 2 ways to do so. Either validate locally or validate with App Store.
  /// To validate the receipt locally, you will need the detailed receipt information that being represented in a Map. Thus you need to pass `serialized` as true.
  /// For more details on how to validate the receipt data, you can refer to Apple's document about [`About Receipt Validation`](https://developer.apple.com/library/archive/releasenotes/General/ValidateAppStoreReceipt/Introduction.html#//apple_ref/doc/uid/TP40010573-CH105-SW1).
  static Future<Map<String, dynamic>> retrieveReceiptData(
      {bool serialized = false}) async {
    return await Map.castFrom<dynamic, dynamic, String, dynamic>(
        await channel.invokeMethod(
            '-[InAppPurchasePlugin retrieveReceiptData:result:]', serialized));
  }
}
