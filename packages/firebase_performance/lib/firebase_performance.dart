import 'dart:async';

import 'package:flutter/services.dart';

class FirebasePerformance {
  static const MethodChannel _channel =
      const MethodChannel('firebase_performance');

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }
}
