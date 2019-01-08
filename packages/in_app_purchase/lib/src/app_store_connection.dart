import 'dart:async';

import 'in_app_purchase_connection.dart';
import 'store_kit_wrappers.dart';

/// An [InAppPurchaseConnection] that wraps StoreKit.
///
/// This translates various `StoreKit` calls and responses into the
/// generic plugin API.
class AppStoreConnection implements InAppPurchaseConnection {
  @override
  Future<bool> isAvailable() => SKPaymentQueueWrapper.canMakePayments;

  @override
  // There's no such thing as "connecting" to the App Store like there is for
  // the Play Billing service. Always just return whether or not the user can
  // make payments here.
  Future<bool> connect() => isAvailable();
}
