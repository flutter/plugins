// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter/services.dart';
import 'package:meta/meta.dart';
import 'package:platform/platform.dart';

typedef Future<dynamic> MessageHandler(Map<String, dynamic> message);

/// Implementation of the Firebase Cloud Messaging API for Flutter.
///
/// Your app should call [requestNotificationPermissions] first and then
/// register handlers for incoming messages with [configure].
class FirebaseMessaging {
  factory FirebaseMessaging() => _instance;

  @visibleForTesting
  FirebaseMessaging.private(MethodChannel channel, Platform platform)
      : _channel = channel,
        _platform = platform;

  static final FirebaseMessaging _instance = FirebaseMessaging.private(
      const MethodChannel('plugins.flutter.io/firebase_messaging'),
      const LocalPlatform());

  final MethodChannel _channel;
  final Platform _platform;

  MessageHandler _onMessage;
  MessageHandler _onLaunch;
  MessageHandler _onResume;
  String _token;

  /// On iOS, prompts the user for notification permissions the first time
  /// it is called.
  ///
  /// Does nothing on Android.
  void requestNotificationPermissions(
      [IosNotificationSettings iosSettings = const IosNotificationSettings()]) {
    if (!_platform.isIOS) {
      return;
    }
    _channel.invokeMethod(
        'requestNotificationPermissions', iosSettings.toMap());
  }

  final StreamController<IosNotificationSettings> _iosSettingsStreamController =
      StreamController<IosNotificationSettings>.broadcast();

  /// Stream that fires when the user changes their notification settings.
  ///
  /// Only fires on iOS.
  Stream<IosNotificationSettings> get onIosSettingsRegistered {
    return _iosSettingsStreamController.stream;
  }

  /// Sets up [MessageHandler] for incoming messages.
  void configure({
    MessageHandler onMessage,
    MessageHandler onLaunch,
    MessageHandler onResume,
  }) {
    _onMessage = onMessage;
    _onLaunch = onLaunch;
    _onResume = onResume;
    _channel.setMethodCallHandler(_handleMethod);
    _channel.invokeMethod('configure');
  }

  final StreamController<String> _tokenStreamController =
      StreamController<String>.broadcast();

  /// Fires when a new FCM token is generated.
  Stream<String> get onTokenRefresh {
    return _tokenStreamController.stream;
  }

  /// Returns the FCM token.
  Future<String> getToken() {
    return _token != null ? Future<String>.value(_token) : onTokenRefresh.first;
  }

  /// Subscribe to topic in background.
  ///
  /// [topic] must match the following regular expression:
  /// "[a-zA-Z0-9-_.~%]{1,900}".
  void subscribeToTopic(String topic) {
    _channel.invokeMethod('subscribeToTopic', topic);
  }

  /// Unsubscribe from topic in background.
  void unsubscribeFromTopic(String topic) {
    _channel.invokeMethod('unsubscribeFromTopic', topic);
  }

  Future<Null> _handleMethod(MethodCall call) async {
    switch (call.method) {
      case "onToken":
        final String token = call.arguments;
        if (_token != token) {
          _token = token;
          _tokenStreamController.add(_token);
        }
        return null;
      case "onIosSettingsRegistered":
        _iosSettingsStreamController.add(IosNotificationSettings._fromMap(
            call.arguments.cast<String, bool>()));
        return null;
      case "onMessage":
        return _onMessage(call.arguments.cast<String, dynamic>());
      case "onLaunch":
        return _onLaunch(call.arguments.cast<String, dynamic>());
      case "onResume":
        return _onResume(call.arguments.cast<String, dynamic>());
      default:
        throw UnsupportedError("Unrecognized JSON message");
    }
  }
}

class IosNotificationSettings {
  const IosNotificationSettings({
    this.sound = true,
    this.alert = true,
    this.badge = true,
  });

  IosNotificationSettings._fromMap(Map<String, bool> settings)
      : sound = settings['sound'],
        alert = settings['alert'],
        badge = settings['badge'];

  final bool sound;
  final bool alert;
  final bool badge;

  @visibleForTesting
  Map<String, dynamic> toMap() {
    return <String, bool>{'sound': sound, 'alert': alert, 'badge': badge};
  }

  @override
  String toString() => 'PushNotificationSettings ${toMap()}';
}
