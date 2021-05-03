// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';
import 'package:in_app_purchase_android/src/types/in_app_purchase_exception.dart';
import 'package:in_app_purchase_platform_interface/in_app_purchase_platform_interface.dart';

import '../billing_client_wrappers.dart';

/// [IAPError.code] code for failed purchases.
const String kPurchaseErrorCode = 'purchase_error';

/// [IAPError.code] code used when a consuming a purchased item fails.
const String kConsumptionFailedErrorCode = 'consume_purchase_failed';

/// [IAPError.code] code used when a query for previouys transaction has failed.
const String kRestoredPurchaseErrorCode = 'restore_transactions_failed';

/// Indicates store front is Google Play
const String kIAPSource = 'google_play';

/// An [InAppPurchasePlatform] that wraps Android BillingClient.
///
/// This translates various `BillingClient` calls and responses into the
/// generic plugin API.
class InAppPurchaseAndroidPlatform extends InAppPurchasePlatform
    with WidgetsBindingObserver {
  InAppPurchaseAndroidPlatform._()
      : billingClient =
            BillingClient((PurchasesResultWrapper resultWrapper) async {
          _purchaseUpdatedController
              .add(await _getPurchaseDetailsFromResult(resultWrapper));
        }) {
    if (InAppPurchaseAndroidPlatform.enablePendingPurchase) {
      billingClient.enablePendingPurchases();
    }

    _readyFuture = _connect();
    WidgetsBinding.instance!.addObserver(this);
    _purchaseUpdatedController = StreamController.broadcast();
    ;
  }

  /// Returns the singleton instance of the [InAppPurchaseAndroidPlatform].
  static InAppPurchaseAndroidPlatform get instance => _getOrCreateInstance();
  static InAppPurchaseAndroidPlatform? _instance;

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

  Stream<List<PurchaseDetails>> get purchaseStream =>
      _purchaseUpdatedController.stream;
  static late StreamController<List<PurchaseDetails>>
      _purchaseUpdatedController;

  /// The [BillingClient] that's abstracted by [GooglePlayConnection].
  ///
  /// This field should not be used out of test code.
  @visibleForTesting
  late final BillingClient billingClient;

  late Future<void> _readyFuture;
  static Set<String> _productIdsToConsume = Set<String>();

  @override
  Future<bool> isAvailable() async {
    await _readyFuture;
    return billingClient.isReady();
  }

  @override
  Future<bool> buyNonConsumable({required PurchaseParam purchaseParam}) async {
    if (!(purchaseParam is GooglePlayPurchaseParam)) {
      throw ArgumentError(
        'On Android, the `purchaseParam` should always be of type `GooglePlayPurchaseParam`.',
      );
    }

    BillingResultWrapper billingResultWrapper =
        await billingClient.launchBillingFlow(
            sku: purchaseParam.productDetails.id,
            accountId: purchaseParam.applicationUserName,
            oldSku: purchaseParam
                .changeSubscriptionParam?.oldPurchaseDetails.productID,
            purchaseToken: purchaseParam.changeSubscriptionParam
                ?.oldPurchaseDetails.verificationData.serverVerificationData,
            prorationMode:
                purchaseParam.changeSubscriptionParam?.prorationMode);
    return billingResultWrapper.responseCode == BillingResponse.ok;
  }

  @override
  Future<bool> buyConsumable(
      {required PurchaseParam purchaseParam, bool autoConsume = true}) {
    if (autoConsume) {
      _productIdsToConsume.add(purchaseParam.productDetails.id);
    }
    return buyNonConsumable(purchaseParam: purchaseParam);
  }

  @override
  Future<BillingResultWrapper> completePurchase(
      PurchaseDetails purchase) async {
    assert(
      purchase is GooglePlayPurchaseDetails,
      'On Android, the `purchase` should always be of type `GooglePlayPurchaseDetails`.',
    );

    GooglePlayPurchaseDetails googlePurchase =
        purchase as GooglePlayPurchaseDetails;

    if (googlePurchase.billingClientPurchase.isAcknowledged) {
      return BillingResultWrapper(responseCode: BillingResponse.ok);
    }

    if (googlePurchase.verificationData == null) {
      throw ArgumentError(
          'completePurchase unsuccessful. The `purchase.verificationData` is not valid');
    }

    return await billingClient
        .acknowledgePurchase(purchase.verificationData.serverVerificationData);
  }

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
    return billingClient
        .consumeAsync(purchase.verificationData.serverVerificationData);
  }

  @override
  Future<void> restorePurchases({
    String? applicationUserName,
  }) async {
    List<PurchasesResultWrapper> responses;

    responses = await Future.wait([
      billingClient.queryPurchases(SkuType.inapp),
      billingClient.queryPurchases(SkuType.subs)
    ]);

    Set errorCodeSet = responses
        .where((PurchasesResultWrapper response) =>
            response.responseCode != BillingResponse.ok)
        .map((PurchasesResultWrapper response) =>
            response.responseCode.toString())
        .toSet();

    String errorMessage =
        errorCodeSet.isNotEmpty ? errorCodeSet.join(', ') : '';

    List<PurchaseDetails> pastPurchases =
        responses.expand((PurchasesResultWrapper response) {
      return response.purchasesList;
    }).map((PurchaseWrapper purchaseWrapper) {
      return GooglePlayPurchaseDetails.fromPurchase(purchaseWrapper);
    }).toList();

    if (errorMessage.isNotEmpty) {
      throw InAppPurchaseException(
        source: kIAPSource,
        code: kRestoredPurchaseErrorCode,
        message: errorMessage,
      );
    }

    _purchaseUpdatedController.add(pastPurchases);
  }

  /// Resets the connection instance.
  ///
  /// The next call to [instance] will create a new instance. Should only be
  /// used in tests.
  @visibleForTesting
  static void reset() => _instance = null;

  static InAppPurchaseAndroidPlatform _getOrCreateInstance() {
    if (_instance != null) {
      return _instance!;
    }

    _instance = InAppPurchaseAndroidPlatform._();
    return _instance!;
  }

  Future<void> _connect() =>
      billingClient.startConnection(onBillingServiceDisconnected: () {});

  /// Query the product detail list.
  ///
  /// This method only returns [ProductDetailsResponse].
  /// To get detailed Google Play sku list, use [BillingClient.querySkuDetails]
  /// to get the [SkuDetailsResponseWrapper].
  Future<ProductDetailsResponse> queryProductDetails(
      Set<String> identifiers) async {
    List<SkuDetailsResponseWrapper> responses;
    PlatformException? exception;
    try {
      responses = await Future.wait([
        billingClient.querySkuDetails(
            skuType: SkuType.inapp, skusList: identifiers.toList()),
        billingClient.querySkuDetails(
            skuType: SkuType.subs, skusList: identifiers.toList())
      ]);
    } on PlatformException catch (e) {
      exception = e;
      responses = [
        // ignore: invalid_use_of_visible_for_testing_member
        SkuDetailsResponseWrapper(
            billingResult: BillingResultWrapper(
                responseCode: BillingResponse.error, debugMessage: e.code),
            skuDetailsList: []),
        // ignore: invalid_use_of_visible_for_testing_member
        SkuDetailsResponseWrapper(
            billingResult: BillingResultWrapper(
                responseCode: BillingResponse.error, debugMessage: e.code),
            skuDetailsList: [])
      ];
    }
    List<ProductDetails> productDetailsList =
        responses.expand((SkuDetailsResponseWrapper response) {
      return response.skuDetailsList;
    }).map((SkuDetailsWrapper skuDetailWrapper) {
      return GooglePlayProductDetails.fromSkuDetails(skuDetailWrapper);
    }).toList();

    Set<String> successIDS = productDetailsList
        .map((ProductDetails productDetails) => productDetails.id)
        .toSet();
    List<String> notFoundIDS = identifiers.difference(successIDS).toList();
    return ProductDetailsResponse(
        productDetails: productDetailsList,
        notFoundIDs: notFoundIDS,
        error: exception == null
            ? null
            : IAPError(
                source: kIAPSource,
                code: exception.code,
                message: exception.message ?? '',
                details: exception.details));
  }

  static Future<List<PurchaseDetails>> _getPurchaseDetailsFromResult(
      PurchasesResultWrapper resultWrapper) async {
    IAPError? error;
    if (resultWrapper.responseCode != BillingResponse.ok) {
      error = IAPError(
        source: kIAPSource,
        code: kPurchaseErrorCode,
        message: resultWrapper.responseCode.toString(),
        details: resultWrapper.billingResult.debugMessage,
      );
    }
    final List<Future<PurchaseDetails>> purchases =
        resultWrapper.purchasesList.map((PurchaseWrapper purchase) {
      return _maybeAutoConsumePurchase(
          GooglePlayPurchaseDetails.fromPurchase(purchase)..error = error);
    }).toList();
    if (purchases.isNotEmpty) {
      return Future.wait(purchases);
    } else {
      return [
        PurchaseDetails(
            purchaseID: '',
            productID: '',
            status: PurchaseStatus.error,
            transactionDate: null,
            verificationData: PurchaseVerificationData(
                localVerificationData: '',
                serverVerificationData: '',
                source: kIAPSource))
          ..error = error
      ];
    }
  }

  static Future<PurchaseDetails> _maybeAutoConsumePurchase(
      PurchaseDetails purchaseDetails) async {
    if (!(purchaseDetails.status == PurchaseStatus.purchased &&
        _productIdsToConsume.contains(purchaseDetails.productID))) {
      return purchaseDetails;
    }

    final BillingResultWrapper billingResult =
        await instance.consumePurchase(purchaseDetails);
    final BillingResponse consumedResponse = billingResult.responseCode;
    if (consumedResponse != BillingResponse.ok) {
      purchaseDetails.status = PurchaseStatus.error;
      purchaseDetails.error = IAPError(
        source: kIAPSource,
        code: kConsumptionFailedErrorCode,
        message: consumedResponse.toString(),
        details: billingResult.debugMessage,
      );
    }
    _productIdsToConsume.remove(purchaseDetails.productID);

    return purchaseDetails;
  }
}
