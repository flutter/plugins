// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:io';
import 'app_store_connection.dart';
import 'google_play_connection.dart';
import 'product_details.dart';
import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/billing_client_wrappers.dart';
import './purchase_details.dart';

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

  /// Buy a non consumable product or subscription.
  ///
  /// Non consumable items are the items that user can only buy once, for example, a purchase that unlocks a special content in your APP.
  /// Subscriptions are also non consumable products.
  ///
  /// You need to restore all the non consumable products for user when they switch their phones.
  ///
  /// On iOS, you can define your product as a non consumable items in the [App Store Connect](https://appstoreconnect.apple.com/login).
  /// Unfortunately, [Google Play Console](https://play.google.com/) defaults all the products as non consumable. You have to consume the consumable items manually calling [consumePurchase].
  ///
  /// This method does not return anything. Instead, after triggering this method, purchase updates will be sent to [purchaseUpdatedStream].
  /// You should [Stream.listen] to [purchaseUpdatedStream] to get [PurchaseDetails] objects in different [PurchaseDetails.status] and
  /// update your UI accordingly. When the [PurchaseDetails.status] is [PurchaseStatus.purchased] or [PurchaseStatus.error], you should deliver the content or handle the error, then call
  /// [completePurchase] to finish the purchasing process.
  ///
  /// You can find more details on testing payments on iOS [here](https://developer.apple.com/library/archive/documentation/NetworkingInternet/Conceptual/StoreKitGuide/Chapters/ShowUI.html#//apple_ref/doc/uid/TP40008267-CH3-SW11).
  /// You can find more details on testing payments on Android [here](https://developer.android.com/google/play/billing/billing_testing).
  ///
  /// See also:
  ///
  ///  * [buyConsumable], for buying a consumable product.
  ///  * [queryPastPurchases], for restoring non consumable products.
  ///
  /// Calling this method for consumable items will cause unwanted behaviors!
  void buyNonConsumable({@required PurchaseParam purchaseParam});

  /// Buy a consumable product.
  ///
  /// Non consumable items are the items that user can buy multiple times, for example, a health potion.
  ///
  /// It is not mandatory to restore non consumable products for user when they switch their phones. If you'd like to restore non consumable purchases, you should keep track of those purchase on your own server
  /// and restore the purchase for your users.
  ///
  /// On iOS, you can define your product as a consumable items in the [App Store Connect](https://appstoreconnect.apple.com/login).
  /// Unfortunately, [Google Play Console](https://play.google.com/) defaults all the products as non consumable. You have to consume the consumable items manually calling [consumePurchase].
  ///
  /// The `autoConsume` is for Android only since iOS will automatically consume your purchase if the product is categorized as `consumable` on `App Store Connect`.
  /// The `autoConsume` if `true` by default, and we will call [consumePurchase] after a successful purchase for you. If you'd like to have an advance purchase flow management. You should set it to `false` and
  /// consume the purchase when you see fit. Fail to consume a purchase will cause user never be able to buy the same item again. Setting this to `false` on iOS will throw an `Exception`.
  ///
  /// This method does not return anything. Instead, after triggering this method, purchase updates will be sent to [purchaseUpdatedStream].
  /// You should [Stream.listen] to [purchaseUpdatedStream] to get [PurchaseDetails] objects in different [PurchaseDetails.status] and
  /// update your UI accordingly. When the [PurchaseDetails.status] is [PurchaseStatus.purchased] or [PurchaseStatus.error], you should deliver the content or handle the error, then call
  /// [completePurchase] to finish the purchasing process.
  ///
  /// You can find more details on testing payments on iOS [here](https://developer.apple.com/library/archive/documentation/NetworkingInternet/Conceptual/StoreKitGuide/Chapters/ShowUI.html#//apple_ref/doc/uid/TP40008267-CH3-SW11).
  /// You can find more details on testing payments on Android [here](https://developer.android.com/google/play/billing/billing_testing).
  ///
  /// See also:
  ///
  ///  * [buyNonConsumable], for buying a non consumable product or subscription.
  ///  * [queryPastPurchases], for restoring non consumable products.
  ///  * [consumePurchase], for consume consumable products on Android.
  ///
  /// Calling this method for non consumable items will cause unwanted behaviors!
  void buyConsumable(
      {@required PurchaseParam purchaseParam, bool autoConsume = true});

  /// Completes a purchase either after delivering the content or the purchase is failed. (iOS only).
  ///
  /// You are responsible to complete every [PurchaseDetails] whose [PurchaseDetails.status] is [PurchaseStatus.purchased] or [[PurchaseStatus.error].
  /// Completing a [PurchaseStatus.pending] purchase will cause exception.
  ///
  /// It throws an [UnsupportedError] on Android.
  Future<void> completePurchase(PurchaseDetails purchase);

  /// Consume a product that is purchased with `purchase` so user can buy it again. (Android only).
  ///
  /// You are responsible to consume purchases for consumable product after delivery the product.
  /// The user cannot buy the same product again until the purchase of the product is consumed.
  ///
  /// It throws an [UnsupportedError] on iOS.
  Future<BillingResponse> consumePurchase(PurchaseDetails purchase);

  /// Query all the past purchases.
  ///
  /// The `applicationUserName` is required if you also passed this in when making a purchase.
  /// If you did not use a `applicationUserName` when creating payments, you can ignore this parameter.
  ///
  /// For example, when a user installs your APP on a different phone, you want to restore the past purchases and deliver the products that they previously purchased.
  /// It is mandatory to restore non-consumable and subscription for them; however, for consumable product, it is up to you to decide if you should restore those.
  /// If you want to restore the consumable product as well, you need to persist consumable product information for your user on your own server and deliver it to them.
  Future<QueryPurchaseDetailsResponse> queryPastPurchases(
      {String applicationUserName});

  /// A utility method in case there is an issue with getting the verification data originally on iOS.
  ///
  /// Throws an [UnsupportedError] on Android.
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
