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
  Future<List<Map<dynamic, dynamic>>> getProductList(List<String> identifiers) => SKPaymentQueueWrapper.getProductList(identifiers);
}
