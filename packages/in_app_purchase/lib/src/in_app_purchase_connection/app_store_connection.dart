import 'dart:async';

import '../../store_kit_wrappers.dart';
import 'in_app_purchase_connection.dart';
import 'product.dart';

/// An [InAppPurchaseConnection] that wraps StoreKit.
///
/// This translates various `StoreKit` calls and responses into the
/// generic plugin API.
class AppStoreConnection implements InAppPurchaseConnection {
  @override
  Future<bool> isAvailable() => SKPaymentQueueWrapper.canMakePayments;

  @override
  Future<List<Product>> getProductList(List<String> identifiers) =>
      SKProductRequestWrapper.getProductList(identifiers);
}
