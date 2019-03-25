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
///
/// Both platforms have 2 ways to verify purchase data. You can either choose to verify the data locally using [localVerificationData]
/// or verify the data using your own server with [serverVerificationData].
///
/// For details on how to verify your purchase on iOS,
/// you can refer to Apple's document about [`About Receipt Validation`](https://developer.apple.com/library/archive/releasenotes/General/ValidateAppStoreReceipt/Introduction.html#//apple_ref/doc/uid/TP40010573-CH105-SW1).
///
/// on Android, all purchase information should also be verified manually, with your
/// server if at all possible. See [`Verify a purchase`](https://developer.android.com/google/play/billing/billing_library_overview#Verify).
class PurchaseVerificationData {
  /// The data used for local verification.
  ///
  /// If the [source] is [PurchaseSource.AppStore], this data is a based64 encoded string. The structure of the payload is defined using ASN.1.
  /// If the [source] is [PurchaseSource.GooglePlay], this data is a JSON String.
  ///
  /// If the platform is iOS, it is possible the data can be null or your validation of this data turns out invalid. When these happen,
  /// Call [InAppPurchaseConnection.refreshPurchaseVerificationData] to get a new [PurchaseVerificationData] object. And then you can
  /// validate th receipt data again using one of the methods mentioned in [`Receipt Validation`](https://developer.apple.com/library/archive/releasenotes/General/ValidateAppStoreReceipt/Introduction.html#//apple_ref/doc/uid/TP40010573-CH105-SW1).
  final String localVerificationData;

  /// The data used for server verification.
  ///
  /// If the platform is iOS, this data is identical to [localVerificationData].
  final String serverVerificationData;

  /// Indicates the source of the purchase.
  final PurchaseSource source;

  PurchaseVerificationData(
      {@required this.localVerificationData,
      @required this.serverVerificationData,
      @required this.source});
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

/// The response object for fetching the past purchases.
///
/// An instance of this class is returned in [InAppPurchaseConnection.queryPastPurchases].
class QueryPastPurchaseResponse {
  QueryPastPurchaseResponse({@required this.pastPurchases, this.error});

  /// A list of successfully fetched past purchases.
  ///
  /// If there are no past purchases, or there is an [error] fetching past purchases,
  /// this variable is an empty List.
  final List<PurchaseDetails> pastPurchases;

  /// The error when fetching past purchases.
  ///
  /// If fetch is successful, the value is null.
  /// This map contains 'errorCode' and 'message'.
  final Map<String, String> error;
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
  Future<QueryPastPurchaseResponse> queryPastPurchases(
      {String applicationUserName});

  /// Get a refreshed purchase verification data.
  Future<PurchaseVerificationData> refreshPurchaseVerificationData(
      PurchaseDetails purchase);

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
