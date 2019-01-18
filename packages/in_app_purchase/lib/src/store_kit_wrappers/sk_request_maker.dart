// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'package:flutter/services.dart';
import 'package:in_app_purchase/src/channel.dart';
import 'sk_product_wrapper.dart';

/// Handles all the SKRequest subclasses.
///
/// [SKRequest](https://developer.apple.com/documentation/storekit/skrequest?language=objc)
class SKRequestMaker {
  /// A product request.
  ///
  /// Returns the [SkProductsResponseWrapper] object.
  Future<SkProductResponseWrapper> startProductRequest(
      List<String> productIdentifiers) async {
    final Map<dynamic, dynamic> productResponseMap = await channel.invokeMethod(
      '-[InAppPurchasePlugin startProductRequest:result:]',
      productIdentifiers,
    );
    if (productResponseMap == null) {
      throw PlatformException(
        code: 'storekit_no_response',
        message: 'StoreKit: Failed to get response from platform.',
      );
    }
    return SkProductResponseWrapper.fromMap(
        productResponseMap.cast<String, List<dynamic>>());
  }
}
