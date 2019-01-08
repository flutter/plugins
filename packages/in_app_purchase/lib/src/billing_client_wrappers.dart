import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';

/// Wraps a `com.android.billingclient.api.BillingClient` instance.
///
/// This class can be used directly instead of [InAppPurchaseConnection] to
/// call Play-specific billing APIs.
///
/// In general this API conforms to the Java
/// `com.android.billingclient.api.BillingClient` API as much as possible, with
/// some minor changes to account for language differences. Callbacks have been
/// converted to futures where appropriate.
class BillingClient {
  BillingClient() {
    _channel.setMethodCallHandler(_callHandler);
  }
  static const MethodChannel _channel =
      MethodChannel('plugins.flutter.io/in_app_purchase');
  List<Map<String, Function>> _callbacks = <Map<String, Function>>[];

  /// Wraps `BillingClient#isReady()`.
  Future<bool> get isReady async {
    return await _channel.invokeMethod('BillingClient#isReady()');
  }

  /// `BillingClient#startConnection(BillingClientStateListener)`
  ///
  /// [onBillingServiceConnected] has been converted from a callback parameter
  /// to the Future result returned by this function. This returns the
  /// `BillingClient.BillingResponse` `responseCode` of the connection result.
  Future<BillingResponse> startConnection(
      {@required
          OnBillingServiceDisconnected onBillingServiceDisconnected}) async {
    final Map<String, Function> callbacks = <String, Function>{
      'OnBillingServiceDisconnected': onBillingServiceDisconnected,
    };
    _callbacks.add(callbacks);
    return BillingResponse._(await _channel.invokeMethod(
        "BillingClient#startConnection(BillingClientStateListener)",
        <String, dynamic>{'handle': _callbacks.length - 1}));
  }

  Future<void> _callHandler(MethodCall call) async {
    switch (call.method) {
      case 'BillingClientStateListener#onBillingServiceDisconnected()':
        final int handle = call.arguments['handle'];
        await _callbacks[handle]['OnBillingServiceDisconnected']();
        break;
    }
  }
}

/// Wraps `com.android.billingclient.api.BillingClientStateListener.onServiceDisconnected()`.
typedef void OnBillingServiceDisconnected();

/// `BillingClient.BillingResponse`
///
/// See https://developer.android.com/reference/com/android/billingclient/api/BillingClient.BillingResponse.html
/// for an explanation of the different constants.
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
