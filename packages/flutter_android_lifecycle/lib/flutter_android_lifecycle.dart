import 'dart:async';

import 'package:flutter/services.dart';

class FlutterAndroidLifecycle {
  static const MethodChannel _channel =
      const MethodChannel('flutter_android_lifecycle');

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }
}
