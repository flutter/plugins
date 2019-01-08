import 'dart:async';
import 'dart:io';
import 'app_store_connection.dart';
import 'google_play_connection.dart';

/// Basic generic API for making in app purchases across multiple platforms.
abstract class InAppPurchaseConnection {
  /// Returns true if the payment platform is ready and available.
  Future<bool> isAvailable();

  /// Connect to the in app purchasing platform.
  ///
  /// Does nothing if the user is already connected and can already make in app
  /// purchases. Returns whether the payment platform is connected.
  Future<bool> connect();
}

class InAppPurchasePlugin {
  /// The [InAppPurchaseConnection] implemented for this platform.
  ///
  /// Throws an [UnsupportedError] when accessed on a platform other than
  /// Android or iOS.
  InAppPurchaseConnection connection = _createConnection();

  static InAppPurchaseConnection _createConnection() {
    if (Platform.isAndroid) {
      return GooglePlayConnection();
    } else if (Platform.isIOS) {
      return AppStoreConnection();
    }

    throw UnsupportedError(
        'InAppPurchase plugin only works on Android and iOS.');
  }
}
