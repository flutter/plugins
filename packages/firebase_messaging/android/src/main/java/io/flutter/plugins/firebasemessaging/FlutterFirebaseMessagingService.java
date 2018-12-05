// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.firebasemessaging;

import android.content.Intent;
import android.support.v4.content.LocalBroadcastManager;
import com.google.firebase.messaging.FirebaseMessagingService;
import com.google.firebase.messaging.RemoteMessage;

public class FlutterFirebaseMessagingService extends FirebaseMessagingService {

  public static final String ACTION_FOREGROUND_REMOTE_MESSAGE =
          "io.flutter.plugins.firebasemessaging.FOREGROUND_NOTIFICATION";
  public static final String ACTION_BACKGROUND_REMOTE_MESSAGE =
          "io.flutter.plugins.firebasemessaging.BACKGROUND_NOTIFICATION";
  public static final String EXTRA_REMOTE_MESSAGE = "notification";

  /**
   * true, if application receive messages with type "Data messages"
   * About FCM messages {@https://firebase.google.com/docs/cloud-messaging/concept-options}
   */
  private boolean isDataMessages;

  @Override
  public void onCreate() {
    super.onCreate();
    isDataMessages = FlutterFirebaseMessagingUtils.isDataMessages(this);
  }

  /**
   * Called when message is received.
   *
   * @param remoteMessage Object representing the message received from Firebase Cloud Messaging.
   */
  @Override
  public void onMessageReceived(RemoteMessage remoteMessage) {
    if (!isDataMessages) {
      sendForegroundBroadcast(remoteMessage);
    }

    boolean applicationForeground = FlutterFirebaseMessagingUtils.isApplicationForeground(getApplicationContext());

    if (applicationForeground) {
      sendForegroundBroadcast(remoteMessage);
    } else {
      sendBackgroundBroadcast(remoteMessage);
    }
  }

  private void sendForegroundBroadcast(RemoteMessage remoteMessage) {
    Intent intent = new Intent(ACTION_FOREGROUND_REMOTE_MESSAGE);
    intent.putExtra(EXTRA_REMOTE_MESSAGE, remoteMessage);
    LocalBroadcastManager.getInstance(this).sendBroadcast(intent);
  }

  private void sendBackgroundBroadcast(RemoteMessage remoteMessage) {
    Intent intent = new Intent(ACTION_BACKGROUND_REMOTE_MESSAGE);
    intent.putExtra(EXTRA_REMOTE_MESSAGE, remoteMessage);
    intent.setPackage(getPackageName());
    sendBroadcast(intent);
  }
}
