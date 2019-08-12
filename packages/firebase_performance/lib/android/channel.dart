import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class Channel {
  @visibleForTesting
  static const MethodChannel channel =
      MethodChannel('io.flutter.plugins/firebase_performance');

  @visibleForTesting
  static String nextHandle() => 'dart${DateTime.now().toIso8601String()}';
}
