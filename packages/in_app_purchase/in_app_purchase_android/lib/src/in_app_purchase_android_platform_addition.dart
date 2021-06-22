// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/services.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';
import 'package:in_app_purchase_platform_interface/in_app_purchase_platform_interface.dart';

import '../billing_client_wrappers.dart';
import 'types/types.dart';

/// Contains InApp Purchase features that are only available on PlayStore.
class InAppPurchaseAndroidPlatformAddition
    extends InAppPurchasePlatformAddition {
  /// Creates a [InAppPurchaseAndroidPlatformAddition] which uses the supplied
  /// `BillingClient` to provide Android specific features.
  InAppPurchaseAndroidPlatformAddition(this._billingClient) {
    assert(
      _enablePendingPurchase,
      'enablePendingPurchases() must be called when initializing the application and before you access the [InAppPurchase.instance].',
    );

    _billingClient.enablePendingPurchases();
  }

  /// Whether pending purchase is enabled.
  ///
  /// See also [enablePendingPurchases] for more on pending purchases.
  static bool get enablePendingPurchase => _enablePendingPurchase;
  static bool _enablePendingPurchase = false;

  /// Enable the [InAppPurchaseConnection] to handle pending purchases.
  ///
  /// This method is required to be called when initialize the application.
  /// It is to acknowledge your application has been updated to support pending purchases.
  /// See [Support pending transactions](https://developer.android.com/google/play/billing/billing_library_overview#pending)
  /// for more details.
  /// Failure to call this method before access [instance] will throw an exception.
  static void enablePendingPurchases() {
    _enablePendingPurchase = true;
  }

  final BillingClient _billingClient;

  /// Mark that the user has consumed a product.
  ///
  /// You are responsible for consuming all consumable purchases once they are
  /// delivered. The user won't be able to buy the same product again until the
  /// purchase of the product is consumed.
  Future<BillingResultWrapper> consumePurchase(PurchaseDetails purchase) {
    if (purchase.verificationData == null) {
      throw ArgumentError(
          'consumePurchase unsuccessful. The `purchase.verificationData` is not valid');
    }
    return _billingClient
        .consumeAsync(purchase.verificationData.serverVerificationData);
  }

  /// Query all previous purchases.
  ///
  /// The `applicationUserName` should match whatever was sent in the initial
  /// `PurchaseParam`, if anything. If no `applicationUserName` was specified in
  /// the initial `PurchaseParam`, use `null`.
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
      {String? applicationUserName}) async {
    List<PurchasesResultWrapper> responses;
    PlatformException? exception;
    try {
      responses = await Future.wait([
        _billingClient.queryPurchases(SkuType.inapp),
        _billingClient.queryPurchases(SkuType.subs)
      ]);
    } on PlatformException catch (e) {
      exception = e;
      responses = [
        PurchasesResultWrapper(
          responseCode: BillingResponse.error,
          purchasesList: [],
          billingResult: BillingResultWrapper(
            responseCode: BillingResponse.error,
            debugMessage: e.details.toString(),
          ),
        ),
        PurchasesResultWrapper(
          responseCode: BillingResponse.error,
          purchasesList: [],
          billingResult: BillingResultWrapper(
            responseCode: BillingResponse.error,
            debugMessage: e.details.toString(),
          ),
        )
      ];
    }

    Set errorCodeSet = responses
        .where((PurchasesResultWrapper response) =>
            response.responseCode != BillingResponse.ok)
        .map((PurchasesResultWrapper response) =>
            response.responseCode.toString())
        .toSet();

    String errorMessage =
        errorCodeSet.isNotEmpty ? errorCodeSet.join(', ') : '';

    List<GooglePlayPurchaseDetails> pastPurchases =
        responses.expand((PurchasesResultWrapper response) {
      return response.purchasesList;
    }).map((PurchaseWrapper purchaseWrapper) {
      return GooglePlayPurchaseDetails.fromPurchase(purchaseWrapper);
    }).toList();

    IAPError? error;
    if (exception != null) {
      error = IAPError(
          source: kIAPSource,
          code: exception.code,
          message: exception.message ?? '',
          details: exception.details);
    } else if (errorMessage.isNotEmpty) {
      error = IAPError(
          source: kIAPSource,
          code: kRestoredPurchaseErrorCode,
          message: errorMessage);
    }

    return QueryPurchaseDetailsResponse(
        pastPurchases: pastPurchases, error: error);
  }

  /// Checks if the specified feature or capability is supported by the Play Store.
  /// Call this to check if a [BillingClientFeature] is supported by the device.
  Future<bool> isFeatureSupported(BillingClientFeature feature) async {
    return _billingClient.isFeatureSupported(feature);
  }

  /// Initiates a flow to confirm the change of price for an item subscribed by the user.
  ///
  /// When the price of a user subscribed item has changed, launch this flow to take users to
  /// a screen with price change information. User can confirm the new price or cancel the flow.
  ///
  /// The skuDetails needs to have already been fetched in a
  /// [InAppPurchaseAndroidPlatform.queryProductDetails] call.
  Future<BillingResultWrapper> launchPriceChangeConfirmationFlow(
      {required String sku}) {
    return _billingClient.launchPriceChangeConfirmationFlow(sku: sku);
  }
}
