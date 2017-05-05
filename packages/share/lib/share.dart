import 'dart:async';

import 'package:flutter/services.dart';

class Share {
  static const MethodChannel _channel =
      const MethodChannel('share');

  static Future<String> get platformVersion =>
      _channel.invokeMethod('getPlatformVersion');
}
