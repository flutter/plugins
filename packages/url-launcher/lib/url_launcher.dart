import 'dart:async';

import 'package:flutter/services.dart';

/// Parse the specified URL string and delegate handling of the same to the
/// underlying platform.
Future<Null> launch(String urlString) {
  return const MethodChannel('plugins.flutter.io/URLLauncher').invokeMethod(
    'UrlLauncher.launch',
    urlString,
  );
}
