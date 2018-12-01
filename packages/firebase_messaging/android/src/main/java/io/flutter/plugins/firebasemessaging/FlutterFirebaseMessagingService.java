// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.firebasemessaging;

import android.content.Context;
import android.content.Intent;
import android.support.annotation.NonNull;
import android.support.v4.content.LocalBroadcastManager;
import android.util.Log;

import com.google.android.gms.tasks.OnCompleteListener;
import com.google.android.gms.tasks.Task;
import com.google.firebase.iid.FirebaseInstanceId;
import com.google.firebase.iid.InstanceIdResult;
import com.google.firebase.messaging.FirebaseMessagingService;
import com.google.firebase.messaging.RemoteMessage;

public class FlutterFirebaseMessagingService extends FirebaseMessagingService {

  public static final String ACTION_REMOTE_MESSAGE =
      "io.flutter.plugins.firebasemessaging.NOTIFICATION";
  public static final String EXTRA_REMOTE_MESSAGE = "notification";
  public static final String ACTION_TOKEN = "io.flutter.plugins.firebasemessaging.TOKEN";
  public static final String EXTRA_TOKEN = "token";
  /**
   * Called when message is received.
   *
   * @param remoteMessage Object representing the message received from Firebase Cloud Messaging.
   */
  @Override
  public void onMessageReceived(RemoteMessage remoteMessage) {
    Intent intent = new Intent(ACTION_REMOTE_MESSAGE);
    intent.putExtra(EXTRA_REMOTE_MESSAGE, remoteMessage);
    LocalBroadcastManager.getInstance(this).sendBroadcast(intent);
  }


  public static void broadcastToken(final Context context)
  {
    FirebaseInstanceId.getInstance().getInstanceId()
            .addOnCompleteListener(new OnCompleteListener<InstanceIdResult>() {
              @Override
              public void onComplete(@NonNull Task<InstanceIdResult> task) {
                if (!task.isSuccessful()) {
                  Log.w("broadcastToken", "getInstanceId failed", task.getException());
                  return;
                }

                // Get new Instance ID token
                String token = task.getResult().getToken();

                Intent intent = new Intent(ACTION_TOKEN);
                intent.putExtra(EXTRA_TOKEN, token);
                LocalBroadcastManager.getInstance(context).sendBroadcast(intent);
              }
            });
  }

  @Override
  public void onNewToken(String s) {
    super.onNewToken(s);
    Intent intent = new Intent(ACTION_TOKEN);
    intent.putExtra(EXTRA_TOKEN, s);
    LocalBroadcastManager.getInstance(getApplicationContext()).sendBroadcast(intent);
  }
}
