// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter/widgets.dart';
import '../../billing_client_wrappers.dart';
import 'in_app_purchase_connection.dart';
import 'product_details.dart';

/// An [InAppPurchaseConnection] that wraps Google Play Billing.
///
/// This translates various [BillingClient] calls and responses into the
/// common plugin API.
class GooglePlayConnection
    with WidgetsBindingObserver
    implements InAppPurchaseConnection {
  GooglePlayConnection._()
      : billingClient = BillingClient((PurchasesResultWrapper resultWrapper) {
          resultWrapper.purchasesList.forEach((purchase) {
            PurchaseError error = null;
            if (resultWrapper.responseCode != BillingResponse.ok) {
              error = PurchaseError(
                source: PurchaseSource.GooglePlay,
                code: kRestoredPurchaseErrorCode,
                message: {'message': resultWrapper.responseCode.toString()},
              );
            }
            PurchaseDetails purchaseDetails = purchase.toPurchaseDetails()
              ..status = resultWrapper.responseCode == BillingResponse.ok
                  ? PurchaseStatus.purchased
                  : PurchaseStatus.error
              ..error = error;
            if(_purchaseStreamControllers[purchase.sku] != null);
            _purchaseStreamControllers[purchase.sku].add(purchaseDetails);
            if (resultWrapper.responseCode == BillingResponse.ok) {
              _purchaseStreamControllers[purchase.sku].close();
              _purchaseStreamControllers.remove(purchase.sku);
            }
          });
        }) {
    _readyFuture = _connect();
    WidgetsBinding.instance.addObserver(this);
    _purchaseStreamControllers = Map();
  }
  static GooglePlayConnection get instance => _getOrCreateInstance();
  static GooglePlayConnection _instance;

  @visibleForTesting
  final BillingClient billingClient;

  Future<void> _readyFuture;
  static Map<String, StreamController<PurchaseDetails>>
      _purchaseStreamControllers;

  @override
  Future<bool> isAvailable() async {
    await _readyFuture;
    return billingClient.isReady();
  }

  /// Query the product detail list.
  ///
  /// This method only returns [ProductDetailsResponse].
  /// To get detailed Google Play sku list, use [BillingClient.querySkuDetails]
  /// to get the [SkuDetailsResponseWrapper].
  Future<ProductDetailsResponse> queryProductDetails(
      Set<String> identifiers) async {
    List<SkuDetailsResponseWrapper> responses = await Future.wait([
      billingClient.querySkuDetails(
          skuType: SkuType.inapp, skusList: identifiers.toList()),
      billingClient.querySkuDetails(
          skuType: SkuType.subs, skusList: identifiers.toList())
    ]);
    List<ProductDetails> productDetails =
        responses.expand((SkuDetailsResponseWrapper response) {
      return response.skuDetailsList;
    }).map((SkuDetailsWrapper skuDetailWrapper) {
      return skuDetailWrapper.toProductDetails();
    }).toList();
    Set<String> successIDS = productDetails
        .map((ProductDetails productDetails) => productDetails.id)
        .toSet();
    List<String> notFoundIDS = identifiers.difference(successIDS).toList();
    return ProductDetailsResponse(
        productDetails: productDetails, notFoundIDs: notFoundIDS);
  }

  @override
  Stream<PurchaseDetails> makePayment(
      {@required String productID,
      String applicationUserName,
      bool sandboxTesting = false}) {
    if (_purchaseStreamControllers == null) {
      _purchaseStreamControllers = Map();
    }
    _purchaseStreamControllers[productID] = StreamController();
    Stream stream = _purchaseStreamControllers[productID].stream;
    billingClient.launchBillingFlow(sku:productID, accountId: applicationUserName);
    return stream;
  }

  @override
  Future<void> completePurchase(PurchaseDetails purchase) {
    return Future<void>.sync(() {});
  }

  @override
    Future<void> consumePurchase(PurchaseDetails purchase) {
      return billingClient.consumeAsync(purchase.verificationData.serverVerificationData);
    }

  @override
  Future<QueryPurchaseDetailsResponse> queryPastPurchases(
      {String applicationUserName}) async {
    final List<PurchasesResultWrapper> responses = await Future.wait([
      billingClient.queryPurchaseHistory(SkuType.inapp),
      billingClient.queryPurchaseHistory(SkuType.subs)
    ]);

    Set errorCodeSet = responses
        .where((PurchasesResultWrapper response) =>
            response.responseCode != BillingResponse.ok)
        .map((PurchasesResultWrapper response) =>
            response.responseCode.toString())
        .toSet();

    String errorMessage =
        errorCodeSet.isNotEmpty ? errorCodeSet.join(', ') : null;

    List<PurchaseDetails> pastPurchases =
        responses.expand((PurchasesResultWrapper response) {
      return response.purchasesList;
    }).map((PurchaseWrapper purchaseWrapper) {
      return purchaseWrapper.toPurchaseDetails();
    }).toList();

    return QueryPurchaseDetailsResponse(
      pastPurchases: pastPurchases,
      error: errorMessage != null
          ? PurchaseError(
              source: PurchaseSource.GooglePlay,
              code: kRestoredPurchaseErrorCode,
              message: {'message': errorMessage})
          : null,
    );
  }

  /// This is a non-op.
  ///
  /// There is no refreshing verification data on Google Play.
  @override
  Future<PurchaseVerificationData> refreshPurchaseVerificationData(
      PurchaseDetails purchase) async {
    return purchase.verificationData;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.paused:
        _disconnect();
        break;
      case AppLifecycleState.resumed:
        _readyFuture = _connect();
        break;
      default:
    }
  }

  @visibleForTesting
  static void reset() => _instance = null;

  static GooglePlayConnection _getOrCreateInstance() {
    if (_instance != null) {
      return _instance;
    }

    _instance = GooglePlayConnection._();
    return _instance;
  }

  Future<void> _connect() =>
      billingClient.startConnection(onBillingServiceDisconnected: () {});

  Future<void> _disconnect() => billingClient.endConnection();
}
