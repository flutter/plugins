import 'package:flutter/services.dart';
import 'package:meta/meta.dart';

const MethodChannel channel =
    MethodChannel('plugins.flutter.io/in_app_purchase');

class Channel {
  static MethodChannel _channel =
      const MethodChannel('plugins.flutter.io/in_app_purchase');
  static MethodChannel _override;

  static MethodChannel get instance => _override ?? _channel;

  @visibleForTesting
  static set override(MethodChannel override) => _override = override;
}
