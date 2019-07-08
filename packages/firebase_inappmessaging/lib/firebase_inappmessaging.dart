import 'dart:async';

import 'package:meta/meta.dart';
import 'package:flutter/services.dart';

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
    await channel.invokeMethod<void>(
        'setMessagesSuppressed', <bool, bool>{suppress: suppress});
  }

  /// Disable data collection for the app.
  Future<void> setDataCollectionEnabled(bool dataCollectionEnabled) async {
    await channel.invokeMethod<void>('dataCollectionEnabled',
        <bool, bool>{dataCollectionEnabled: dataCollectionEnabled});
  }
}
