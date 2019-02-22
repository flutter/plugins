// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'package:flutter/services.dart';
import 'package:in_app_purchase/src/channel.dart';
import 'sk_product_wrapper.dart';

/// A request maker that handles all the requests made by SKRequest subclasses.
///
/// There are multiple [SKRequest](https://developer.apple.com/documentation/storekit/skrequest?language=objc) subclasses handling different requests in the `StoreKit` with multiple delegate methods,
/// we consolidated all the `SKRequest` subclasses into this class to make requests in a more straightforward way.
/// The request maker will create a SKRequest object, immediately starting it, and completing the future successfully or throw an exception depending on what happened to the request.
class SKRequestMaker {
  /// Fetches product information for a list of given product identifiers.
  ///
  /// The `productIdentifiers` should contain legit product identifiers that you declared for the products in the Itunes Connect. invalid identifiers
  /// Will be stored and returned in [SkProductResponseWrapper.invalidProductIdentifiers]. Duplicate values in `productIdentifiers` will be omitted.
  /// If `productIdentifiers` is null, an `storekit_invalid_argument` error will be returned. If `productIdentifiers` is empty, a [SkProductResponseWrapper]
  /// will still be returned with [SkProductResponseWrapper.products] being null.
  ///
  /// [SkProductResponseWrapper] is returned if there is no error during the request.
  /// A [PlatformException] is thrown if the platform code making the request fails.
  Future<SkProductResponseWrapper> startProductRequest(
      List<String> productIdentifiers) async {
    final Map productResponseMap = await channel.invokeMethod(
      '-[InAppPurchasePlugin startProductRequest:result:]',
      productIdentifiers,
    );
    if (productResponseMap == null) {
      throw PlatformException(
        code: 'storekit_no_response',
        message: 'StoreKit: Failed to get response from platform.',
      );
    }
    return SkProductResponseWrapper.fromJson(productResponseMap);
  }
}
