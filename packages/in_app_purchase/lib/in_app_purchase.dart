import 'dart:async';

import 'package:flutter/services.dart';

class InAppPurchase {
  static const MethodChannel _channel = MethodChannel('in_app_purchase');

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }
}
