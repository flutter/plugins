// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:json_annotation/json_annotation.dart';
import '../channel.dart';
import 'sku_details_wrapper.dart';
import 'enum_converters.dart';

/// This class can be used directly instead of [InAppPurchaseConnection] to call
/// Play-specific billing APIs.
///
/// Wraps a
/// [`com.android.billingclient.api.BillingClient`](https://developer.android.com/reference/com/android/billingclient/api/BillingClient)
/// instance.
///
///
/// In general this API conforms to the Java
/// `com.android.billingclient.api.BillingClient` API as much as possible, with
/// some minor changes to account for language differences. Callbacks have been
/// converted to futures where appropriate.
class BillingClient {
  BillingClient() {
    channel.setMethodCallHandler(_callHandler);
  }

  // Occasionally methods in the native layer require a Dart callback to be
  // triggered in response to a Java callback. For example,
  // [startConnection] registers an [OnBillingServiceDisconnected] callback.
  // This list of names to callbacks is used to trigger Dart callbacks in
  // response to those Java callbacks. Dart sends the Java layer a handle to the
  // matching callback here to remember, and then once its twin is triggered it
  // sends the handle back over the platform channel. We then access that handle
  // in this array and call it in Dart code. See also [_callHandler].
  List<Map<String, Function>> _callbacks = <Map<String, Function>>[];

  /// Calls
  /// [`BillingClient#isReady()`](https://developer.android.com/reference/com/android/billingclient/api/BillingClient.html#isReady())
  /// to get the ready status of the BillingClient instance.
  Future<bool> isReady() async =>
      await channel.invokeMethod('BillingClient#isReady()');

  /// Calls
  /// [`BillingClient#startConnection(BillingClientStateListener)`](https://developer.android.com/reference/com/android/billingclient/api/BillingClient.html#startconnection)
  /// to create and connect a `BillingClient` instance.
  ///
  /// [onBillingServiceConnected] has been converted from a callback parameter
  /// to the Future result returned by this function. This returns the
  /// `BillingClient.BillingResponse` `responseCode` of the connection result.
  ///
  /// This triggers the creation of a new `BillingClient` instance in Java if
  /// one doesn't already exist.
  Future<BillingResponse> startConnection(
      {@required
          OnBillingServiceDisconnected onBillingServiceDisconnected}) async {
    final Map<String, Function> callbacks = <String, Function>{
      'OnBillingServiceDisconnected': onBillingServiceDisconnected,
    };
    _callbacks.add(callbacks);
    return BillingResponseConverter().fromJson(await channel.invokeMethod(
        "BillingClient#startConnection(BillingClientStateListener)",
        <String, dynamic>{'handle': _callbacks.length - 1}));
  }

  /// Calls
  /// [`BillingClient#endConnection(BillingClientStateListener)`](https://developer.android.com/reference/com/android/billingclient/api/BillingClient.html#endconnect
  /// to disconnect a `BillingClient` instance.
  ///
  /// Will trigger the [OnBillingServiceDisconnected] callback passed to [startConnection].
  ///
  /// This triggers the destruction of the `BillingClient` instance in Java.
  Future<void> endConnection() async {
    return channel.invokeMethod("BillingClient#endConnection()", null);
  }

  /// Returns a list of [SkuDetailsWrapper]s that have [SkuDetailsWrapper.sku]
  /// in `skusList`, and [SkuDetailsWrapper.type] matching `skuType`.
  ///
  /// Calls through to [`BillingClient#querySkuDetailsAsync(SkuDetailsParams,
  /// SkuDetailsResponseListener)`](https://developer.android.com/reference/com/android/billingclient/api/BillingClient#querySkuDetailsAsync(com.android.billingclient.api.SkuDetailsParams,%20com.android.billingclient.api.SkuDetailsResponseListener))
  /// Instead of taking a callback parameter, it returns a Future
  /// [SkuDetailsResponseWrapper]. It also takes the values of
  /// `SkuDetailsParams` as direct arguments instead of requiring it constructed
  /// and passed in as a class.
  Future<SkuDetailsResponseWrapper> querySkuDetails(
      {@required SkuType skuType, @required List<String> skusList}) async {
    final Map<String, dynamic> arguments = <String, dynamic>{
      'skuType': SkuTypeConverter().toJson(skuType),
      'skusList': skusList
    };
    return SkuDetailsResponseWrapper.fromJson(await channel.invokeMapMethod<
            String, dynamic>(
        'BillingClient#querySkuDetailsAsync(SkuDetailsParams, SkuDetailsResponseListener)',
        arguments));
  }

  /// Attempt to launch the Play Billing Flow for a given [skuDetails].
  ///
  /// The [skuDetails] needs to have already been fetched in a [querySkuDetails]
  /// call. The [accountId] is an optional hashed string associated with the user
  /// that's unique to your app. It's used by Google to detect unusual behavior.
  /// Do not pass in a cleartext [accountId], use your developer ID, or use the
  /// user's Google ID for this field.
  ///
  /// Calling this attemps to show the Google Play purchase UI. The user is free
  /// to complete the transaction there.
  ///
  /// This method returns a [BillingResponse] representing the initial attempt
  /// to show the Google Play purchase screen.
  /// TODO(mklim, flutter/flutter#26326): Expose onPurchasesUpdated() result.
  ///
  /// This method calls through to
  /// [`BillingClient#launchBillingFlow`](https://developer.android.com/reference/com/android/billingclient/api/BillingClient#launchbillingflow).
  /// It constructs a
  /// [`BillingFlowParams`](https://developer.android.com/reference/com/android/billingclient/api/BillingFlowParams)
  /// instance by [setting the given
  /// skuDetails](https://developer.android.com/reference/com/android/billingclient/api/BillingFlowParams.Builder.html#setskudetails)
  /// and [the given
  /// accountId](https://developer.android.com/reference/com/android/billingclient/api/BillingFlowParams.Builder.html#setAccountId(java.lang.String)).
  Future<BillingResponse> launchBillingFlow(
      {@required SkuDetailsWrapper skuDetails, String accountId}) async {
    assert(skuDetails != null);
    final Map<String, dynamic> arguments = <String, dynamic>{
      'sku': skuDetails.sku,
      'accountId': accountId,
    };
    return BillingResponseConverter().fromJson(await channel.invokeMethod(
        'BillingClient#launchBillingFlow(Activity, BillingFlowParams)',
        arguments));
  }

  Future<void> _callHandler(MethodCall call) async {
    switch (call.method) {
      case 'BillingClientStateListener#onBillingServiceDisconnected()':
        final int handle = call.arguments['handle'];
        await _callbacks[handle]['OnBillingServiceDisconnected']();
        _callbacks.removeAt(handle);
        break;
    }
  }
}

/// Callback triggered when the [BillingClientWrapper] is disconnected.
///
/// Wraps
/// [`com.android.billingclient.api.BillingClientStateListener.onServiceDisconnected()`](https://developer.android.com/reference/com/android/billingclient/api/BillingClientStateListener.html#onBillingServiceDisconnected())
/// to call back on `BillingClient` disconnect.
typedef void OnBillingServiceDisconnected();

/// Possible `BillingClient` response statuses.
///
/// Wraps
/// [`BillingClient.BillingResponse`](https://developer.android.com/reference/com/android/billingclient/api/BillingClient.BillingResponse).
/// See the `BillingResponse` docs for more explanation of the different
/// constants.
enum BillingResponse {
  // WARNING: Changes to this class need to be reflected in our generated code.
  // Run `flutter packages pub run build_runner watch` to rebuild and watch for
  // further changes.
  @JsonValue(-2)
  featureNotSupported,

  @JsonValue(0)
  ok,

  @JsonValue(1)
  userCanceled,

  @JsonValue(2)
  serviceUnavailable,

  @JsonValue(3)
  billingUnavailable,

  @JsonValue(4)
  itemUnavailable,

  @JsonValue(5)
  developerError,

  @JsonValue(6)
  error,

  @JsonValue(7)
  itemAlreadyOwned,

  @JsonValue(8)
  itemNotOwned,
}

/// Enum representing potential [SkuDetailsWrapper.type]s.
///
/// Wraps
/// [`BillingClient.SkuType`](https://developer.android.com/reference/com/android/billingclient/api/BillingClient.SkuType)
/// See the linked documentation for an explanation of the different constants.
enum SkuType {
  // WARNING: Changes to this class need to be reflected in our generated code.
  // Run `flutter packages pub run build_runner watch` to rebuild and watch for
  // further changes.

  /// A one time product. Acquired in a single transaction.
  @JsonValue('inapp')
  inapp,

  /// A product requiring a recurring charge over time.
  @JsonValue('subs')
  subs,
}
