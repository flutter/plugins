// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'noop_in_app_purchase.dart';
import 'types/types.dart';

/// The interface that implementations of in_app_purchase must implement.
///
/// Platform implementations should extend this class rather than implement it as `in_app_purchase`
/// does not consider newly added methods to be breaking changes. Extending this class
/// (using `extends`) ensures that the subclass will get the default implementation, while
/// platform implementations that `implements` this interface will be broken by newly added
/// [InAppPurchasePlatform] methods.
abstract class InAppPurchasePlatform extends PlatformInterface {
  /// Constructs a UrlLauncherPlatform.
  InAppPurchasePlatform() : super(token: _token);

  static final Object _token = Object();

  static InAppPurchasePlatform _instance = NoopInAppPurchase();

  /// The default instance of [InAppPurchasePlatform] to use.
  static InAppPurchasePlatform get instance => _instance;

  /// Platform-specific plugins should set this with their own platform-specific
  /// class that extends [InAppPurchasePlatform] when they register themselves.
  // TODO(amirh): Extract common platform interface logic.
  // https://github.com/flutter/flutter/issues/43368
  static set instance(InAppPurchasePlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  /// Listen to this broadcast stream to get real time update for purchases.
  ///
  /// This stream will never close as long as the app is active.
  ///
  /// Purchase updates can happen in several situations:
  /// * When a purchase is triggered by user in the app.
  /// * When a purchase is triggered by user from App Store or Google Play.
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
  Stream<List<PurchaseDetails>> get purchaseUpdatedStream =>
      throw UnimplementedError(
          'purchaseUpdatedStream has not been implemented.');

  /// Returns true if the payment platform is ready and available.
  Future<bool> isAvailable() =>
      throw UnimplementedError('isAvailable() has not been implemented.');

  /// Query product details for the given set of IDs.
  ///
  /// The [identifiers] need to exactly match existing configured product
  /// identifiers in the underlying payment platform, whether that's [App Store
  /// Connect](https://appstoreconnect.apple.com/) or [Google Play
  /// Console](https://play.google.com/).
  ///
  /// See the [example readme](../../../../example/README.md) for steps on how
  /// to initialize products on both payment platforms.
  Future<ProductDetailsResponse> queryProductDetails(Set<String> identifiers) =>
      throw UnimplementedError(
          'queryProductDetails() had not been implemented.');

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
  /// [purchaseUpdatedStream]. You should [Stream.listen] to
  /// [purchaseUpdatedStream] to get [PurchaseDetails] objects in different
  /// [PurchaseDetails.status] and update your UI accordingly. When the
  /// [PurchaseDetails.status] is [PurchaseStatus.purchased] or
  /// [PurchaseStatus.error], you should deliver the content or handle the
  /// error, then call [completePurchase] to finish the purchasing process.
  ///
  /// This method does return whether or not the purchase request was initially
  /// sent successfully.
  ///
  /// Consumable items are defined differently by the different underlying
  /// payment platforms, and there's no way to query for whether or not the
  /// [ProductDetail] is a consumable at runtime. On iOS, products are defined
  /// as non consumable items in the [App Store
  /// Connect](https://appstoreconnect.apple.com/). [Google Play
  /// Console](https://play.google.com/) products are considered consumable if
  /// and when they are actively consumed manually.
  ///
  /// You can find more details on testing payments on iOS
  /// [here](https://developer.apple.com/library/archive/documentation/NetworkingInternet/Conceptual/StoreKitGuide/Chapters/ShowUI.html#//apple_ref/doc/uid/TP40008267-CH3-SW11).
  /// You can find more details on testing payments on Android
  /// [here](https://developer.android.com/google/play/billing/billing_testing).
  ///
  /// See also:
  ///
  ///  * [buyConsumable], for buying a consumable product.
  ///  * [queryPastPurchases], for restoring non consumable products.
  ///
  /// Calling this method for consumable items will cause unwanted behaviors!
  Future<bool> buyNonConsumable({required PurchaseParam purchaseParam}) =>
      throw UnimplementedError('buyNonConsumable() has not been implemented.');

  /// Buy a consumable product.
  ///
  /// Consumable items can be "consumed" to mark that they've been used and then
  /// bought additional times. For example, a health potion.
  ///
  /// To restore consumable purchases across devices, you should keep track of
  /// those purchase on your own server and restore the purchase for your users.
  /// Consumed products are no longer considered to be "owned" by payment
  /// platforms and will not be delivered by calling [queryPastPurchases].
  ///
  /// Consumable items are defined differently by the different underlying
  /// payment platforms, and there's no way to query for whether or not the
  /// [ProductDetail] is a consumable at runtime. On iOS, products are defined
  /// as consumable items in the [App Store
  /// Connect](https://appstoreconnect.apple.com/). [Google Play
  /// Console](https://play.google.com/) products are considered consumable if
  /// and when they are actively consumed manually.
  ///
  /// `autoConsume` is provided as a utility for Android only. It's meaningless
  /// on iOS because the App Store automatically considers all potentially
  /// consumable purchases "consumed" once the initial transaction is complete.
  /// `autoConsume` is `true` by default, and we will call [consumePurchase]
  /// after a successful purchase for you so that Google Play considers a
  /// purchase consumed after the initial transaction, like iOS. If you'd like
  /// to manually consume purchases in Play, you should set it to `false` and
  /// manually call [consumePurchase] instead. Failing to consume a purchase
  /// will cause user never be able to buy the same item again. Manually setting
  /// this to `false` on iOS will throw an `Exception`.
  ///
  /// This method does not return the result of the purchase. Instead, after
  /// triggering this method, purchase updates will be sent to
  /// [purchaseUpdatedStream]. You should [Stream.listen] to
  /// [purchaseUpdatedStream] to get [PurchaseDetails] objects in different
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
  ///  * [queryPastPurchases], for restoring non consumable products.
  ///  * [consumePurchase], for manually consuming products on Android.
  ///
  /// Calling this method for non consumable items will cause unwanted
  /// behaviors!
  Future<bool> buyConsumable({
    required PurchaseParam purchaseParam,
    bool autoConsume = true,
  }) =>
      throw UnimplementedError('buyConsumable() has not been implemented.');

  // TODO(mvanbeusekom): Add definition for the `completePurchase` method. The
  // current definition uses the Android specific `BillingResultWrapper` class
  // which is not really platform generic and needs a solution.

  /// Query all previous purchases.
  ///
  /// The `applicationUserName` should match whatever was sent in the initial
  /// `PurchaseParam`, if anything. If no `applicationUserName` was specified in the initial
  /// `PurchaseParam`, use `null`.
  ///
  /// This does not return consumed products. If you want to restore unused
  /// consumable products, you need to persist consumable product information
  /// for your user on your own server.
  ///
  /// See also:
  ///
  ///  * [refreshPurchaseVerificationData], for reloading failed
  ///    [PurchaseDetails.verificationData].
  Future<QueryPurchaseDetailsResponse> queryPastPurchases(
          {String? applicationUserName}) =>
      throw UnimplementedError('queryPastPurchase() has not been implemented.');
}
