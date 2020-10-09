// ignore_for_file: public_member_api_docs

import 'dart:async';

import 'package:flutter/services.dart';

class WifiInfoFlutter {
  static const MethodChannel _channel =
      const MethodChannel('wifi_info_flutter');

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }
}
