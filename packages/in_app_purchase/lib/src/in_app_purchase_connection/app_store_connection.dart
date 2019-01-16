// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import '../../store_kit_wrappers.dart';
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
}
