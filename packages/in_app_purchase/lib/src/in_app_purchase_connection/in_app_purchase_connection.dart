// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:io';
import 'app_store_connection.dart';
import 'google_play_connection.dart';
import 'product_details.dart';
import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/store_kit_wrappers.dart';
import 'package:in_app_purchase/billing_client_wrappers.dart';

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
///
/// This class unifies the BillingClient's [PurchaseWrapper] and StoreKit's [SKPaymentTransactionWrapper]. You can use the common attributes in
/// This class for simple operations. If you would like to see the detailed representation of the product, instead,  use [PurchaseWrapper] on Android and [SKPaymentTransactionWrapper] on iOS.
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

  /// Points back to the `StoreKits`'s [SKPaymentTransactionWrapper] object that generated this [PurchaseDetails] object.
  ///
  /// This is null on Android.
  final SKPaymentTransactionWrapper skPaymentTransaction;

  /// Points back to the `BillingClient`'s [PurchaseWrapper] object that generated this [PurchaseDetails] object.
  ///
  /// This is null on Android.
  final PurchaseWrapper billingClientPurchase;

  PurchaseDetails({
    @required this.purchaseID,
    @required this.productId,
    @required this.verificationData,
    @required this.transactionDate,
    this.skPaymentTransaction = null,
    this.billingClientPurchase = null,
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
  /// Listen to this broadcast stream to get real time update for purchases.
  ///
  /// This stream would never close when the APP is active.
  ///
  /// Purchase updates can happen in several situations:
  /// * When a purchase is triggered by user in the APP.
  /// * When a purchase is triggered by user from App Store or Google Play.
  /// * If a purchase is not completed([completePurchase] is not called on the purchase object) from the last APP session. Purchase updates will happen when a new APP session starts.
  ///
  /// IMPORTANT! To Avoid losing information on purchase updates, You should listen to this stream as soon as your APP launches, preferably before returning your main App Widget in main().
  /// We recommend to have a single subscription listening to the stream at a given time. If you choose to have multiple subscription at the same time, you should be careful at the fact that each subscription will receive all the events after they start to listen.
  Stream<List<PurchaseDetails>> get purchaseUpdatedStream => _getStream();

  Stream<List<PurchaseDetails>> _purchaseUpdatedStream;

  Stream<List<PurchaseDetails>> _getStream() {
    if (_purchaseUpdatedStream != null) {
      return _purchaseUpdatedStream;
    }

    if (Platform.isAndroid) {
      _purchaseUpdatedStream =
          GooglePlayConnection.instance.purchaseUpdatedStream;
    } else if (Platform.isIOS) {
      _purchaseUpdatedStream =
          AppStoreConnection.instance.purchaseUpdatedStream;
    } else {
      throw UnsupportedError(
          'InAppPurchase plugin only works on Android and iOS.');
    }
    return _purchaseUpdatedStream;
  }

  /// Returns true if the payment platform is ready and available.
  Future<bool> isAvailable();

  /// Query product details list that match the given set of identifiers.
  Future<ProductDetailsResponse> queryProductDetails(Set<String> identifiers);

  /// Make a payment
  ///
  /// This method does not return anything. Instead, after triggering this method, purchase updates will be sent to [purchaseUpdatedStream].
  /// You should [Stream.listen] to [purchaseUpdatedStream] to get [PurchaseDetails] objects in different [PurchaseDetails.status] and
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
  /// Developer is responsible to consume purchases for consumable product after delivery the product.
  /// The user cannot buy the same product again until the purchase of the product is consumed.
  ///
  /// This is a non-op on iOS. In App Store Connect, the product specified as `consumable` category automatically allow
  /// users to buy multiple times.
  Future<void> consumePurchase(PurchaseDetails purchase);

  /// Query all the past purchases.
  ///
  /// The `applicationUserName` is required if you also passed this in when making a purchase.
  /// If you did not use a `applicationUserName` when creating payments, you can ignore this parameter.
  ///
  /// A major difference between Android and iOS here is that iOS does not return consumable products when querying past purchases.
  /// You would need to have your own server to store those information if you need those, although it is not necessary to store those information at all.
  /// For example, when a user installs your APP on a different phone, you want to restore the past purchases and deliver the products that they previously purchased.
  /// It is mandatory to restore non-consumable and subscription for them; however, for consumable product, it is up to you to decide if you should restore those.
  /// If you want to restore the consumable product as well, you need to persist consumable product information for your user on your own server and deliver it to them.
  Future<QueryPurchaseDetailsResponse> queryPastPurchases(
      {String applicationUserName});

  /// A utility method in case there is an issue with getting the verification data originally on iOS.
  ///
  /// Throws an [Exception] on Android.
  Future<PurchaseVerificationData> refreshPurchaseVerificationData();

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
