// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'in_app_purchase_connection.dart';
import 'product.dart';
import 'package:in_app_purchase/store_kit_wrappers.dart';

/// An [InAppPurchaseConnection] that wraps StoreKit.
///
/// This translates various `StoreKit` calls and responses into the
/// generic plugin API.
class AppStoreConnection implements InAppPurchaseConnection {
  static AppStoreConnection get instance => _getOrCreateInstance();
  static AppStoreConnection _instance;

  @override
  Future<bool> isAvailable() => SKPaymentQueueWrapper.canMakePayments();

  static AppStoreConnection _getOrCreateInstance() {
    if (_instance != null) {
      return _instance;
    }

    _instance = AppStoreConnection();
    return _instance;
  }

  /// query the product detail list using [SkProductResponseWrapper.startProductRequest]
  ///
  /// This method only returns a simple product list that works for both platforms.
  /// To get detailed Store Kit product list, use [SkProductResponseWrapper.startProductRequest]
  /// to get the [SKProductResponseWrapper].
  Future<List<Product>> queryProductDetails(List<String> identifiers) async {
    final SKRequestMaker requestMaker = SKRequestMaker();
    SkProductResponseWrapper response =
        await requestMaker.startProductRequest(identifiers);
    return response.products
        .map((SKProductWrapper productWrapper) => productWrapper.toProduct())
        .toList();
  }
}
