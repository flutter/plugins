// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:io';
import 'app_store_connection.dart';
import 'google_play_connection.dart';
import 'product_details.dart';
import 'package:flutter/foundation.dart';

/// Represents the data that is used to verify purchases.
///
/// The property [source] helps you to determine the method to verify purchases.
/// Different source of purchase has different methods of verifying purchases.
/// For details on how to verify your purchase on iOS,
/// you can refer to Apple's document about [`About Receipt Validation`](https://developer.apple.com/library/archive/releasenotes/General/ValidateAppStoreReceipt/Introduction.html#//apple_ref/doc/uid/TP40010573-CH105-SW1).
class PurchaseVerificationData {
  /// The data used for verification.
  ///
  /// If the [source] is [PurchaseSource.AppStore], data will be based64 encoded. The structure of the payload is defined using ASN.1.
  /// If the platform is iOS, it is possible the data can be null or your validation of this data turns out invalid. When these happen,
  /// Call [SKRequestMaker.startRefreshReceiptRequest] and then call [SKReceiptManager.retrieveReceiptData] to retrieve a new receipt. Finally,
  /// validate th receipt data again using one of the methods mentioned in [`Receipt Validation`](https://developer.apple.com/library/archive/releasenotes/General/ValidateAppStoreReceipt/Introduction.html#//apple_ref/doc/uid/TP40010573-CH105-SW1).
  ///
  /// You can use the receipt data retrieved by this method to validate users' purchases.
  final String data;

  /// Indicates the source of the purchase.
  final PurchaseSource source;

  PurchaseVerificationData({@required this.data, @required this.source});
}

enum PurchaseSource { GooglePlay, AppStore }

enum PurchaseStatus { pending, purchased, error }

/// Represents the transaction details of a purchase.
class PurchaseDetails {
  /// A unique identifier of the purchase.
  final String purchaseID;

  /// The product identifier of the purchase.
  final String productId;

  /// The verification data of the purchase.
  ///
  /// Use this to verify the purchase.
  ///
  /// For details on how to verify your purchase on iOS,
  /// you can refer to Apple's document about [`Receipt Validation`](https://developer.apple.com/library/archive/releasenotes/General/ValidateAppStoreReceipt/Introduction.html#//apple_ref/doc/uid/TP40010573-CH105-SW1).
  ///
  /// on Android, all purchase information should also be verified manually, with your
  /// server if at all possible. See [`Verify a purchase`](https://developer.android.com/google/play/billing/billing_library_overview#Verify).
  final PurchaseVerificationData verificationData;

  /// The timestamp of the transaction.
  ///
  /// Milliseconds since epoch.
  final String transactionDate;

  /// The original purchase data of this purchase.
  ///
  /// It is only available when this purchase is a restored purchase in iOS.
  /// See [InAppPurchaseConnection.queryPastPurchases] for details on restoring purchases.
  /// The value of this property is null if the purchase is not a restored purchases.
  final PurchaseDetails originalPurchase;

  PurchaseDetails(
      {@required this.purchaseID,
      @required this.productId,
      @required this.verificationData,
      @required this.transactionDate,
      this.originalPurchase});
}

/// Basic generic API for making in app purchases across multiple platforms.
abstract class InAppPurchaseConnection {
  /// Returns true if the payment platform is ready and available.
  Future<bool> isAvailable();

  /// Query product details list that match the given set of identifiers.
  Future<ProductDetailsResponse> queryProductDetails(Set<String> identifiers);

  /// Query all the past purchases.
  ///
  /// The `applicationUserName` is used for iOS only and it is optional. It does not have any effects on Android.
  /// It is the `applicationUsername` you used to create payments.
  /// If you did not use a `applicationUserName` when creating payments, you can ignore this parameter.
  Future<List<PurchaseDetails>> queryPastPurchases(
      {String applicationUserName});

  /// The [InAppPurchaseConnection] implemented for this platform.
  ///
  /// Throws an [UnsupportedError] when accessed on a platform other than
  /// Android or iOS.
  static InAppPurchaseConnection get instance => _getOrCreateInstance();
  static InAppPurchaseConnection _instance;

  static InAppPurchaseConnection _getOrCreateInstance() {
    if (_instance != null) {
      return _instance;
    }

    if (Platform.isAndroid) {
      _instance = GooglePlayConnection.instance;
    } else if (Platform.isIOS) {
      _instance = AppStoreConnection.instance;
    } else {
      throw UnsupportedError(
          'InAppPurchase plugin only works on Android and iOS.');
    }

    return _instance;
  }
}
