// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'package:in_app_purchase/src/channel.dart';

import '../../store_kit_wrappers.dart';
import './product.dart';
import 'in_app_purchase_connection.dart';

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

  @override
  Future<List<Product>> getProductList(List<String> identifiers) =>
      throw UnimplementedError();

  /// Get product list.
  ///
  /// [identifiers] is the product identifiers specified in Itunes Connect for the products that need to be retrived.
  ///
  /// Returns a future containing a list of [SKProductWrapper] which then can be queried to get desired information.
  Future<List<SKProductWrapper>> getSKProductList(
      List<String> identifiers) async {
    final List<Map<dynamic, dynamic>> productListSerilized =
        await channel.invokeListMethod<Map<dynamic, dynamic>>(
      'getProductList',
      <String, Object>{
        'identifiers': identifiers,
      },
    );

    final List<SKProductWrapper> productList = <SKProductWrapper>[];
    for (Map<dynamic, dynamic> productMap in productListSerilized) {
      productList.add(SKProductWrapper.fromMap(
        productMap.cast<String, dynamic>(),
      ));
    }
    return productList;
  }
}
