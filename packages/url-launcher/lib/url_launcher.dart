import 'dart:async';

import 'package:flutter/services.dart';

class UrlLauncher {
  static const MethodChannel _channel =
      const MethodChannel('plugins.flutter.io/URLLauncher');

  /// Parse the specified URL string and delegate handling of the same to the
  /// underlying platform.
  static Future<Null> launch(String urlString) =>
      _channel.invokeMethod('UrlLauncher.launch', urlString);
}
