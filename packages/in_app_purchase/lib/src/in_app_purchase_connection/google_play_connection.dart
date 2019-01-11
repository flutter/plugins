import 'dart:async';

import 'package:flutter/widgets.dart';
import '../../billing_client_wrappers.dart';
import 'in_app_purchase_connection.dart';

/// An [InAppPurchaseConnection] that wraps Google Play Billing.
///
/// This translates various [BillingClient] calls and responses into the
/// common plugin API.
class GooglePlayConnection
    with WidgetsBindingObserver
    implements InAppPurchaseConnection {
  GooglePlayConnection() : _billingClient = BillingClient() {
    _readyFuture = _connect();
    WidgetsBinding.instance.addObserver(this);
  }
  final BillingClient _billingClient;
  Future<void> _readyFuture;

  @override
  Future<bool> isAvailable() async {
    await _readyFuture;
    return _billingClient.isReady();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.paused:
      case AppLifecycleState.suspending:
        _disconnect();
        break;
      case AppLifecycleState.resumed:
        _readyFuture = _connect();
        break;
      default:
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getProductList(List<String> identifiers) =>
      null;

  Future<void> _connect() =>
      _billingClient.startConnection(onBillingServiceDisconnected: () {});

  Future<void> _disconnect() => _billingClient.endConnection();
}
