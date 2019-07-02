import 'dart:async';

import 'package:flutter/services.dart';

class FirebaseInAppMessaging {
  static const MethodChannel _channel =
      const MethodChannel('plugins.flutter.io/firebase_inappmessaging');

  static Future<void> triggerEvent(String eventName) async {
    await _channel.invokeMethod('triggerEvent', {'eventName': eventName});
  }

  static Future<void> configure({bool suppress, bool dataCollectionEnabled}) async {
    await _channel.invokeMethod('configure', {
      "suppress": suppress, "dataCollectionEnabled": dataCollectionEnabled});
  }

  static Future<void> setMessagesSuppressed(bool suppress) async {
    await _channel.invokeMethod('setMessagesSuppressed', {suppress: suppress});
  }

  static Future<void> dataCollectionEnabled(bool dataCollectionEnabled) async {
    await _channel.invokeMethod('dataCollectionEnabled', {dataCollectionEnabled: dataCollectionEnabled});
  }
}
