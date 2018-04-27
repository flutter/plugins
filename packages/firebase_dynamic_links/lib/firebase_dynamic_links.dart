import 'dart:async';

import 'package:flutter/services.dart';

class FirebaseDynamicLinks {
  static const MethodChannel _channel =
      const MethodChannel('firebase_dynamic_links');

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }
}
