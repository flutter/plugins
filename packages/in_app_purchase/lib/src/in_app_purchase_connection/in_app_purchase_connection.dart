// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:io';
import 'app_store_connection.dart';
import 'google_play_connection.dart';
import 'product_details.dart';
import 'package:flutter/foundation.dart';

final String kPurchaseErrorCode = 'purchase_error';
final String kRestoredPurchaseErrorCode = 'restore_transactions_failed';

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
/// On Android, all purchase information should also be verified manually. See [`Verify a purchase`](https://developer.android.com/google/play/billing/billing_library_overview#Verify).
///
/// It is preferable to verify purchases using a server with [serverVerificationData].
///
/// If the platform is iOS, it is possible the data can be null or your validation of this data turns out invalid. When this happens,
/// Call [InAppPurchaseConnection.refreshPurchaseVerificationData] to get a new [PurchaseVerificationData] object. And then you can
/// validate the receipt data again using one of the methods mentioned in [`Receipt Validation`](https://developer.apple.com/library/archive/releasenotes/General/ValidateAppStoreReceipt/Introduction.html#//apple_ref/doc/uid/TP40010573-CH105-SW1).
///
/// You should never use any purchase data until verified.
class PurchaseVerificationData {
  /// The data used for local verification.
  ///
  /// If the [source] is [PurchaseSource.AppStore], this data is a based64 encoded string. The structure of the payload is defined using ASN.1.
  /// If the [source] is [PurchaseSource.GooglePlay], this data is a JSON String.
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

/// Which platform the purchase is on.
enum PurchaseSource { GooglePlay, AppStore }

enum PurchaseStatus {
  /// The purchase process is pending.
  ///
  /// You can update UI to let your users know the purchase is pending.
  pending,

  /// The purchase is finished and successful.
  ///
  /// Update your UI to indicate the purchase is finished and deliver the product.
  /// On Android, the google play store is handling the purchase, so we set the status to
  /// `purchased` as long as we can successfully launch play store purchase flow.
  purchased,

  /// Some error occurred in the purchase. The purchasing process if aborted.
  error
}

/// Error of a purchase process.
///
/// The error can happen during the purchase, or restoring a purchase.
/// Errors from restoring a purchase are not indicative of any errors during the original purchase.
class PurchaseError {
  PurchaseError(
      {@required this.source, @required this.code, @required this.message});

  /// Which source is the error on.
  final PurchaseSource source;

  /// The error code.
  final String code;

  /// A map containing the detailed error message.
  final Map<String, dynamic> message;
}

/// Represents the transaction details of a purchase.
class PurchaseDetails {
  /// A unique identifier of the purchase.
  final String purchaseID;

  /// The product identifier of the purchase.
  final String productId;

  /// The verification data of the purchase.
  ///
  /// Use this to verify the purchase. See [PurchaseVerificationData] for details on how to verify purchase use this data.
  /// You should never use any purchase data until verified.
  final PurchaseVerificationData verificationData;

  /// The timestamp of the transaction.
  ///
  /// Milliseconds since epoch.
  final String transactionDate;

  /// The status that this [PurchaseDetails] is currently on.
  PurchaseStatus status;

  /// The error is only available when [status] is [PurchaseStatus.error].
  PurchaseError error;

  PurchaseDetails({
    @required this.purchaseID,
    @required this.productId,
    @required this.verificationData,
    @required this.transactionDate,
  });
}

/// The response object for fetching the past purchases.
///
/// An instance of this class is returned in [InAppPurchaseConnection.queryPastPurchases].
class QueryPurchaseDetailsResponse {
  QueryPurchaseDetailsResponse({@required this.pastPurchases, this.error});

  /// A list of successfully fetched past purchases.
  ///
  /// If there are no past purchases, or there is an [error] fetching past purchases,
  /// this variable is an empty List.
  /// You should verify the purchase data using [PurchaseDetails.verificationData] before using the [PurchaseDetails] object.
  final List<PurchaseDetails> pastPurchases;

  /// The error when fetching past purchases.
  ///
  /// If the fetch is successful, the value is null.
  final PurchaseError error;
}

/// Basic generic API for making in app purchases across multiple platforms.
abstract class InAppPurchaseConnection {

  /// Listen to this stream to get real time update for purchases.
  ///
  /// Purchase updates can happen in several situations:
  /// * When a purchase is triggered by user in the APP.
  /// * When a purchase is triggered by user from App Store or Google Play.
  /// * If a purchase is not completed([completePurchase] is not called on the purchase object) from the last APP session. Purchase updates will happen when a new APP session starts.
  ///
  /// IMPORTANT! To Avoid losing information on purchase updates, You should listen to this stream as soon as your APP launches, preferably before returning your main App Widget in main().
  Stream<List<PurchaseDetails>> get purchaseUpdated => _getStream();

  Stream<List<PurchaseDetails>> _purchaseUpdated;

  Stream<List<PurchaseDetails>> _getStream() {
    if (_purchaseUpdated != null) {
      return _purchaseUpdated;
    }

    if (Platform.isAndroid) {
      _purchaseUpdated = GooglePlayConnection.instance.purchaseUpdated;
    } else if (Platform.isIOS) {
      _purchaseUpdated = AppStoreConnection.instance.purchaseUpdated;
    } else {
      throw UnsupportedError(
          'InAppPurchase plugin only works on Android and iOS.');
    }
    return _purchaseUpdated;
  }

  /// Returns true if the payment platform is ready and available.
  Future<bool> isAvailable();

  /// Query product details list that match the given set of identifiers.
  Future<ProductDetailsResponse> queryProductDetails(Set<String> identifiers);

  /// Make a payment
  ///
  /// This method does not return anything. Instead, after triggering this method, purchase updates will be sent to [purchaseUpdated].
  /// You should [Stream.listen] to [purchaseUpdated] to get [PurchaseDetails] objects in different [PurchaseDetails.status] and
  /// update your UI accordingly. When the [PurchaseDetails.status] is [PurchaseStatus.purchased] or [PurchaseStatus.error], you should deliver the content or handle the error, then call
  /// [completePurchase] to finish the purchasing process.
  ///
  ///
  /// The `productID` is the product ID to create payment for.
  /// The `applicationUserName`
  /// The 'sandboxTesting' is only necessary to set to `true` for testing on iOS. The default value is `false`.
  /// You can find more details on testing payments on iOS [here](https://developer.apple.com/library/archive/documentation/NetworkingInternet/Conceptual/StoreKitGuide/Chapters/ShowUI.html#//apple_ref/doc/uid/TP40008267-CH3-SW11).
  /// You can find more details on testing payments on Android [here](https://developer.android.com/google/play/billing/billing_testing).
  void makePayment(
      {@required String productID,
      String applicationUserName,
      bool sandboxTesting = false});

  /// Completes a purchase either after delivering the content or the purchase is failed. (iOS only).
  ///
  /// Developer is responsible to complete every [PurchaseDetails] whose [PurchaseDetails.status] is [PurchaseStatus.purchased] or [[PurchaseStatus.error].
  /// Completing a [PurchaseStatus.pending] purchase will cause exception.
  ///
  /// This is a non-op on Android.
  Future<void> completePurchase(PurchaseDetails purchase);

  /// Consume a product that is purchased with `purchase` so user can buy it again.
  ///
  /// Developer is responsible to consume purchases for consumable items after delivery the product.
  /// The user cannot buy the same product again until the purchase of the product is consumed.
  ///
  /// This is a non-op on Android.
  Future<void> consumePurchase(PurchaseDetails purchase);

  /// Query all the past purchases.
  ///
  /// The `applicationUserName` is required if you also passed this in when making a purchase.
  /// If you did not use a `applicationUserName` when creating payments, you can ignore this parameter.
  Future<QueryPurchaseDetailsResponse> queryPastPurchases(
      {String applicationUserName});

  /// A utility method in case there is an issue with getting the verification data originally.
  ///
  /// On Android, it is a non-op. We directly return the verification data in the `purchase` that is passed in.
  /// See [PurchaseVerificationData] for more details on when to use this.
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
