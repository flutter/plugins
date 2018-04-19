import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';

class FirebasePerformance {
  @visibleForTesting
  static const MethodChannel _channel =
      const MethodChannel('plugins.flutter.io/firebase_performance');

  static Future<bool> isPerformanceCollectionEnabled() async {
    final bool isEnabled = await _channel.invokeMethod('FirebasePerformance#isPerformanceCollectionEnabled');
    return isEnabled;
  }

  static Future<void> setPerformanceCollectionEnabled(bool enabled) async {
    await _channel.invokeMethod('FirebasePerformance#setPerformanceCollectionEnabled', enabled);
  }
}