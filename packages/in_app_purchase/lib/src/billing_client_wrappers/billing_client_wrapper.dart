// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import '../channel.dart';

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
    return BillingResponse._(await channel.invokeMethod(
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

/// Wraps
/// [`com.android.billingclient.api.BillingClientStateListener.onServiceDisconnected()`](https://developer.android.com/reference/com/android/billingclient/api/BillingClientStateListener.html#onBillingServiceDisconnected())
/// to call back on `BillingClient` disconnect.
typedef void OnBillingServiceDisconnected();

/// Wraps
/// [`BillingClient.BillingResponse`](https://developer.android.com/reference/com/android/billingclient/api/BillingClient.BillingResponse),
/// possible status codes.
///
/// See the `BillingResponse` docs for an explanation of the different constants.
class BillingResponse {
  const BillingResponse._(this._code);
  final int _code;
  @override
  String toString() => _code.toString();
  @override
  int get hashCode => _code;
  @override
  bool operator ==(dynamic other) =>
      other is BillingResponse && other._code == _code;

  static const BillingResponse FEATURE_NOT_SUPPORTED = BillingResponse._(-2);
  static const BillingResponse OK = BillingResponse._(0);
  static const BillingResponse USER_CANCELED = BillingResponse._(1);
  static const BillingResponse SERVICE_UNAVAILABLE = BillingResponse._(2);
  static const BillingResponse BILLING_UNAVAILABLE = BillingResponse._(3);
  static const BillingResponse ITEM_UNAVAILABLE = BillingResponse._(4);
  static const BillingResponse DEVELOPER_ERROR = BillingResponse._(5);
  static const BillingResponse ERROR = BillingResponse._(6);
  static const BillingResponse ITEM_ALREADY_OWNED = BillingResponse._(7);
  static const BillingResponse ITEM_NOT_OWNED = BillingResponse._(8);
}
