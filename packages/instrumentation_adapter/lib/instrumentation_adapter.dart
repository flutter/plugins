import 'dart:async';

import 'package:flutter/services.dart';

class InstrumentationAdapter {
  static const MethodChannel _channel = MethodChannel('instrumentation_adapter');

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }
}
