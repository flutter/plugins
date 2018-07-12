import 'dart:async';

import 'package:flutter/services.dart';

class WebviewFlutter {
  static const MethodChannel _channel =
      const MethodChannel('webview_flutter');

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }
}
