import 'dart:async';

import 'package:flutter/services.dart';

class InAppPurchase {
  static const MethodChannel _channel = MethodChannel('in_app_purchase');

  static Future<String> get platformVersion async {
    // TODO(amirh): remove this on when the invokeMethod update makes it to stable Flutter.
    // https://github.com/flutter/flutter/issues/26431
    // ignore: strong_mode_implicit_dynamic_method
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }
}
