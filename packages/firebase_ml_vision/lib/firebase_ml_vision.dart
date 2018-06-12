import 'dart:async';

import 'package:flutter/services.dart';

class FirebaseMlVision {
  static const MethodChannel _channel =
      const MethodChannel('firebase_ml_vision');

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }
}
