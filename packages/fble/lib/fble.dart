import 'dart:async';

import 'package:flutter/services.dart';

class Fble {
  static const MethodChannel _channel =
      const MethodChannel('fble');

  static Future<String> get platformVersion =>
      _channel.invokeMethod('getPlatformVersion');
}
