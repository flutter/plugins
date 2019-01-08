import 'dart:async';

import 'billing_client_wrappers.dart';
import 'in_app_purchase_connection.dart';

/// An [InAppPurchaseConnection] that wraps Google Play Billing.
///
/// This translates various [BillingClient] calls and responses into the
/// common plugin API.
class GooglePlayConnection implements InAppPurchaseConnection {
  BillingClient _billingClient = BillingClient();

  @override
  Future<bool> isAvailable() async {
    return await _billingClient.isReady;
  }

  @override
  Future<bool> connect() async {
    final BillingResponse responseCode = await _billingClient.startConnection(
        onBillingServiceDisconnected: () {});
    final bool finishedSuccessfully = responseCode == BillingResponse.OK;
    if (!finishedSuccessfully) {
      print('Failed to connect to Play Billing. Response $responseCode');
    }

    if (finishedSuccessfully) {
      return await isAvailable();
    } else {
      return false;
    }
  }
}
