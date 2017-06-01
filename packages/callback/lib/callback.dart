import 'dart:async';

import 'package:flutter/services.dart';

/// Callback plugin for invoking native callbacks using an identifier.
class Callback {
  static const MethodChannel _channel =
      const MethodChannel('callback');

  /// Invokes the callback identified with [id].
  ///
  /// Will throw [PlatformException] if the callback is not found.
  static Future<Null> call(String id) {
    assert(id != null && id.isNotEmpty);
    return _channel.invokeMethod('call', {
      'callbackId': id
    });
  }
}
