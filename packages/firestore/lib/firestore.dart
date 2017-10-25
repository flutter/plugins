import 'dart:async';

import 'package:flutter/services.dart';

class Firestore {
  static const MethodChannel _channel =
      const MethodChannel('firestore');

  static Future<String> get platformVersion =>
      _channel.invokeMethod('getPlatformVersion');
}
