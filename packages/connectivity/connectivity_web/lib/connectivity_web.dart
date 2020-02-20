import 'dart:async';

import 'package:flutter/services.dart';

class ConnectivityWeb {
  static const MethodChannel _channel =
      const MethodChannel('connectivity_web');

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }
}
