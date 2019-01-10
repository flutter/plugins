// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

part of firebase_in_app_messaging;

/// Firebase In-App Messages API.
///
/// You can get an instance by calling [FirebaseInAppMessaging.instance].
class FirebaseInAppMessaging {
  FirebaseInAppMessaging._();

  @visibleForTesting
  static const MethodChannel channel =
      MethodChannel('plugins.flutter.io/firebase_in_app_messaging');

  /// Singleton of [FirebaseInAppMessaging].
  static final FirebaseInAppMessaging instance = FirebaseInAppMessaging._();

  Future<void> setMessageDisplaySuppressed(bool suppressed) {
    return channel.invokeMethod('FirebaseInAppMessaging#setMessageDisplaySuppressed', suppressed);
  }

  Future<void> setAutomaticDataCollectionEnabled(bool enabled) {
    return channel.invokeMethod('FirebaseInAppMessaging#setAutomaticDataCollectionEnabled', enabled);
  }

  Future<void> setMessagingDisplay(InAppMessagingDisplay messageDisplay) async {
    channel.setMethodCallHandler((MethodCall call) {
      assert(call.method == 'FirebaseInAppMessaging#_displayMessage');
      String messageID = call.arguments['messageID'];
      bool renderAsTestMessage = call.arguments['renderAsTestMessage'];
      InAppMessagingDisplayMessage message = InAppMessagingDisplayMessage._(
        messageID: messageID,
        renderAsTestMessage: renderAsTestMessage,
      );
      InAppMessagingDisplayDelegate delegate = InAppMessagingDisplayDelegate();
      if (messageDisplay != null)
        messageDisplay(message, delegate);
    });
    return channel.invokeMethod('FirebaseInAppMessaging#useFlutterMessageDisplayComponent', messageDisplay != null);
  }
}
