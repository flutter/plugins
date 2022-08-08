// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/foundation.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';
import 'package:in_app_purchase_platform_interface/in_app_purchase_platform_interface.dart';
import 'package:in_app_purchase_storekit/in_app_purchase_storekit.dart';

export 'package:in_app_purchase_platform_interface/in_app_purchase_platform_interface.dart'
    show
        IAPError,
        InAppPurchaseException,
        ProductDetails,
        ProductDetailsResponse,
        PurchaseDetails,
        PurchaseParam,
        PurchaseVerificationData,
        PurchaseStatus;

/// Basic API for making in app purchases across multiple platforms.
class InAppPurchase implements InAppPurchasePlatformAdditionProvider {
  InAppPurchase._();

  static InAppPurchase? _instance;

  /// The instance of the [InAppPurchase] to use.
  static InAppPurchase get instance => _getOrCreateInstance();

  static InAppPurchase _getOrCreateInstance() {
    if (_instance != null) {
      return _instance!;
    }

    if (defaultTargetPlatform == TargetPlatform.android) {
      InAppPurchaseAndroidPlatform.registerPlatform();
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      InAppPurchaseStoreKitPlatform.registerPlatform();
    }

    _instance = InAppPurchase._();
    return _instance!;
  }

  @override
  T getPlatformAddition<T extends InAppPurchasePlatformAddition?>() {
    return InAppPurchasePlatformAddition.instance as T;
  }

  /// Listen to this broadcast stream to get real time update for purchases.
  ///
  /// This stream will never close as long as the app is active.
  ///
  /// Purchase updates can happen in several situations:
  /// * When a purchase is triggered by user in the app.
  /// * When a purchase is triggered by user from the platform-specific store front.
  /// * When a purchase is restored on the device by the user in the app.
  /// * If a purchase is not completed ([completePurchase] is not called on the
  ///   purchase object) from the last app session. Purchase updates will happen
  ///   when a new app session starts instead.
  ///
  /// IMPORTANT! You must subscribe to this stream as soon as your app launches,
  /// preferably before returning your main App Widget in main(). Otherwise you
  /// will miss purchase updated made before this stream is subscribed to.
  ///
  /// We also recommend listening to the stream with one subscription at a given
  /// time. If you choose to have multiple subscription at the same time, you
  /// should be careful at the fact that each subscription will receive all the
  /// events after they start to listen.
  Stream<List<PurchaseDetails>> get purchaseStream =>
      InAppPurchasePlatform.instance.purchaseStream;

  /// Returns `true` if the payment platform is ready and available.
  Future<bool> isAvailable() => InAppPurchasePlatform.instance.isAvailable();

  /// Query product details for the given set of IDs.
  ///
  /// Identifiers in the underlying payment platform, for example, [App Store
  /// Connect](https://appstoreconnect.apple.com/) for iOS and [Google Play
  /// Console](https://play.google.com/) for Android.
  Future<ProductDetailsResponse> queryProductDetails(Set<String> identifiers) =>
      InAppPurchasePlatform.instance.queryProductDetails(identifiers);

  /// Buy a non consumable product or subscription.
  ///
  /// Non consumable items can only be bought once. For example, a purchase that
  /// unlocks a special content in your app. Subscriptions are also non
  /// consumable products.
  ///
  /// You always need to restore all the non consumable products for user when
  /// they switch their phones.
  ///
  /// This method does not return the result of the purchase. Instead, after
  /// triggering this method, purchase updates will be sent to
  /// [purchaseStream]. You should [Stream.listen] to [purchaseStream] to get
  /// [PurchaseDetails] objects in different [PurchaseDetails.status] and update
  ///  your UI accordingly. When the [PurchaseDetails.status] is
  /// [PurchaseStatus.purchased], [PurchaseStatus.restored] or
  /// [PurchaseStatus.error] you should deliver the content or handle the error,
  /// then call [completePurchase] to finish the purchasing process.
  ///
  /// This method does return whether or not the purchase request was initially
  /// sent successfully.
  ///
  /// Consumable items are defined differently by the different underlying
  /// payment platforms, and there's no way to query for whether or not the
  /// [ProductDetail] is a consumable at runtime.
  ///
  /// See also:
  ///
  ///  * [buyConsumable], for buying a consumable product.
  ///  * [restorePurchases], for restoring non consumable products.
  ///
  /// Calling this method for consumable items will cause unwanted behaviors!
  Future<bool> buyNonConsumable({required PurchaseParam purchaseParam}) =>
      InAppPurchasePlatform.instance.buyNonConsumable(
        purchaseParam: purchaseParam,
      );

  /// Buy a consumable product.
  ///
  /// Consumable items can be "consumed" to mark that they've been used and then
  /// bought additional times. For example, a health potion.
  ///
  /// To restore consumable purchases across devices, you should keep track of
  /// those purchase on your own server and restore the purchase for your users.
  /// Consumed products are no longer considered to be "owned" by payment
  /// platforms and will not be delivered by calling [restorePurchases].
  ///
  /// Consumable items are defined differently by the different underlying
  /// payment platforms, and there's no way to query for whether or not the
  /// [ProductDetail] is a consumable at runtime.
  ///
  /// `autoConsume` is provided as a utility and will instruct the plugin to
  /// automatically consume the product after a succesful purchase.
  /// `autoConsume` is `true` by default.
  ///
  /// This method does not return the result of the purchase. Instead, after
  /// triggering this method, purchase updates will be sent to
  /// [purchaseStream]. You should [Stream.listen] to
  /// [purchaseStream] to get [PurchaseDetails] objects in different
  /// [PurchaseDetails.status] and update your UI accordingly. When the
  /// [PurchaseDetails.status] is [PurchaseStatus.purchased] or
  /// [PurchaseStatus.error], you should deliver the content or handle the
  /// error, then call [completePurchase] to finish the purchasing process.
  ///
  /// This method does return whether or not the purchase request was initially
  /// sent succesfully.
  ///
  /// See also:
  ///
  ///  * [buyNonConsumable], for buying a non consumable product or
  ///    subscription.
  ///  * [restorePurchases], for restoring non consumable products.
  ///
  /// Calling this method for non consumable items will cause unwanted
  /// behaviors!
  Future<bool> buyConsumable({
    required PurchaseParam purchaseParam,
    bool autoConsume = true,
  }) =>
      InAppPurchasePlatform.instance.buyConsumable(
        purchaseParam: purchaseParam,
        autoConsume: autoConsume,
      );

  /// Mark that purchased content has been delivered to the user.
  ///
  /// You are responsible for completing every [PurchaseDetails] whose
  /// [PurchaseDetails.status] is [PurchaseStatus.purchased] or
  /// [PurchaseStatus.restored].
  /// Completing a [PurchaseStatus.pending] purchase will cause an exception.
  /// For convenience, [PurchaseDetails.pendingCompletePurchase] indicates if a
  /// purchase is pending for completion.
  ///
  /// The method will throw a [PurchaseException] when the purchase could not be
  /// finished. Depending on the [PurchaseException.errorCode] the developer
  /// should try to complete the purchase via this method again, or retry the
  /// [completePurchase] method at a later time. If the
  /// [PurchaseException.errorCode] indicates you should not retry there might
  /// be some issue with the app's code or the configuration of the app in the
  /// respective store. The developer is responsible to fix this issue. The
  /// [PurchaseException.message] field might provide more information on what
  /// went wrong.
  Future<void> completePurchase(PurchaseDetails purchase) =>
      InAppPurchasePlatform.instance.completePurchase(purchase);

  /// Restore all previous purchases.
  ///
  /// The `applicationUserName` should match whatever was sent in the initial
  /// `PurchaseParam`, if anything. If no `applicationUserName` was specified in the initial
  /// `PurchaseParam`, use `null`.
  ///
  /// Restored purchases are delivered through the [purchaseStream] with a
  /// status of [PurchaseStatus.restored]. You should listen for these purchases,
  /// validate their receipts, deliver the content and mark the purchase complete
  /// by calling the [finishPurchase] method for each purchase.
  ///
  /// This does not return consumed products. If you want to restore unused
  /// consumable products, you need to persist consumable product information
  /// for your user on your own server.
  ///
  /// See also:
  ///
  ///  * [refreshPurchaseVerificationData], for reloading failed
  ///    [PurchaseDetails.verificationData].
  Future<void> restorePurchases({String? applicationUserName}) =>
      InAppPurchasePlatform.instance.restorePurchases(
        applicationUserName: applicationUserName,
      );
}
