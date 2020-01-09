import 'dart:async';

import 'package:flutter/services.dart';

class Espresso {
  static const MethodChannel _channel = const MethodChannel('espresso');

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }
}
