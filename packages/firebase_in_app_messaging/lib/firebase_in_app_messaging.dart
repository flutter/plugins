import 'dart:async';

import 'package:flutter/services.dart';
import 'package:meta/meta.dart';

class FirebaseInAppMessaging {
  @visibleForTesting
  static const MethodChannel channel =
      MethodChannel('plugins.flutter.io/firebase_inappmessaging');

  static FirebaseInAppMessaging _instance = FirebaseInAppMessaging();

  /// Gets the instance of In-App Messaging for the default Firebase app.
  static FirebaseInAppMessaging get instance => _instance;

  /// Triggers an analytics event from the [FirebaseInAppMessaging] instance
  Future<void> triggerEvent(String eventName) async {
    await channel.invokeMethod<void>(
        'triggerEvent', <String, String>{'eventName': eventName});
  }

  /// Suppress message displays for the [FirebaseInAppMessaging] instance
  Future<void> setMessagesSuppressed(bool suppress) async {
    if (suppress == null) {
      throw ArgumentError.notNull('suppress');
    }
    await channel.invokeMethod<void>('setMessagesSuppressed', suppress);
  }

  /// Disable data collection for the app.
  Future<void> setAutomaticDataCollectionEnabled(bool enabled) async {
    if (enabled == null) {
      throw ArgumentError.notNull('enabled');
    }
    await channel.invokeMethod<void>(
        'setAutomaticDataCollectionEnabled', enabled);
  }
}
