// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.firebasemessaging;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.os.Bundle;
import android.util.Log;
import androidx.annotation.NonNull;
import androidx.localbroadcastmanager.content.LocalBroadcastManager;
import com.google.android.gms.tasks.OnCompleteListener;
import com.google.android.gms.tasks.Task;
import com.google.firebase.FirebaseApp;
import com.google.firebase.iid.FirebaseInstanceId;
import com.google.firebase.iid.InstanceIdResult;
import com.google.firebase.messaging.FirebaseMessaging;
import com.google.firebase.messaging.RemoteMessage;

import io.flutter.plugin.common.JSONMethodCodec;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.NewIntentListener;
import io.flutter.plugin.common.PluginRegistry.Registrar;
import java.io.IOException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/** FirebaseMessagingPlugin */
public class FirebaseMessagingPlugin extends BroadcastReceiver
    implements MethodCallHandler, NewIntentListener {
  private final Registrar registrar;
  private final MethodChannel channel;

  private static final String CLICK_ACTION_VALUE = "FLUTTER_NOTIFICATION_CLICK";
  private static final String TAG = "FirebaseMessagingPlugin";

  public static void registerWith(Registrar registrar) {
    final MethodChannel channel =
        new MethodChannel(registrar.messenger(), "plugins.flutter.io/firebase_messaging");
    final MethodChannel backgroundCallbackChannel =
        new MethodChannel(
            registrar.messenger(),
            "plugins.flutter.io/android_fcm_background",
            JSONMethodCodec.INSTANCE);
    final FirebaseMessagingPlugin plugin = new FirebaseMessagingPlugin(registrar, channel);
    registrar.addNewIntentListener(plugin);
    channel.setMethodCallHandler(plugin);
    backgroundCallbackChannel.setMethodCallHandler(plugin);

    FlutterFirebaseMessagingService.setBackgroundChannel(backgroundCallbackChannel);
  }

  private FirebaseMessagingPlugin(Registrar registrar, MethodChannel channel) {
    this.registrar = registrar;
    this.channel = channel;
    FirebaseApp.initializeApp(registrar.context());

    IntentFilter intentFilter = new IntentFilter();
    intentFilter.addAction(FlutterFirebaseMessagingService.ACTION_TOKEN);
    intentFilter.addAction(FlutterFirebaseMessagingService.ACTION_REMOTE_MESSAGE);
    LocalBroadcastManager manager = LocalBroadcastManager.getInstance(registrar.context());
    manager.registerReceiver(this, intentFilter);
  }

  // BroadcastReceiver implementation.
  @Override
  public void onReceive(Context context, Intent intent) {
    String action = intent.getAction();

    if (action == null) {
      return;
    }

    if (action.equals(FlutterFirebaseMessagingService.ACTION_TOKEN)) {
      String token = intent.getStringExtra(FlutterFirebaseMessagingService.EXTRA_TOKEN);
      channel.invokeMethod("onToken", token);
    } else if (action.equals(FlutterFirebaseMessagingService.ACTION_REMOTE_MESSAGE)) {
      RemoteMessage message =
          intent.getParcelableExtra(FlutterFirebaseMessagingService.EXTRA_REMOTE_MESSAGE);
      Map<String, Object> content = parseRemoteMessage(message);
      channel.invokeMethod("onMessage", content);
    }
  }

  @NonNull
  private Map<String, Object> parseRemoteMessage(RemoteMessage message) {
    Map<String, Object> content = new HashMap<>();
    content.put("data", message.getData());

    RemoteMessage.Notification notification = message.getNotification();

    Map<String, Object> notificationMap = new HashMap<>();

    String title = notification != null ? notification.getTitle() : null;
    notificationMap.put("title", title);

    String body = notification != null ? notification.getBody() : null;
    notificationMap.put("body", body);

    content.put("notification", notificationMap);
    return content;
  }

  @Override
  public void onMethodCall(final MethodCall call, final Result result) {
    if ("FcmDartService.start".equals(call.method)) {
      long callbackHandle = 0;
      long onMessageHandle = 0;
      try {
        List<Long> callbacks = ((ArrayList<Long>) call.arguments);
        callbackHandle = callbacks.get(0);
        onMessageHandle = callbacks.get(1);
      } catch (Exception e) {
        Log.e(TAG, "There was an exception when getting callback handle from dart side");
        e.printStackTrace();
      }
      FlutterFirebaseMessagingService.setBackgroundSetupHandle(this.registrar.context(), callbackHandle);
      FlutterFirebaseMessagingService.startBackgroundIsolate(this.registrar.context(), callbackHandle);
      FlutterFirebaseMessagingService.setBackgroundMessageHandle(this.registrar.context(), onMessageHandle);
      result.success(true);
    } else if ("FcmDartService.initialized".equals(call.method)) {
      FlutterFirebaseMessagingService.onInitialized();
      result.success(true);
    } else if ("configure".equals(call.method)) {
      FirebaseInstanceId.getInstance()
          .getInstanceId()
          .addOnCompleteListener(
              new OnCompleteListener<InstanceIdResult>() {
                @Override
                public void onComplete(@NonNull Task<InstanceIdResult> task) {
                  if (!task.isSuccessful()) {
                    Log.w(TAG, "getToken, error fetching instanceID: ", task.getException());
                    return;
                  }
                  channel.invokeMethod("onToken", task.getResult().getToken());
                }
              });
      if (registrar.activity() != null) {
        sendMessageFromIntent("onLaunch", registrar.activity().getIntent());
      }
      result.success(null);
    } else if ("subscribeToTopic".equals(call.method)) {
      String topic = call.arguments();
      FirebaseMessaging.getInstance()
          .subscribeToTopic(topic)
          .addOnCompleteListener(
              new OnCompleteListener<Void>() {
                @Override
                public void onComplete(@NonNull Task<Void> task) {
                  if (!task.isSuccessful()) {
                    Exception e = task.getException();
                    Log.w(TAG, "subscribeToTopic error", e);
                    result.error("subscribeToTopic", e.getMessage(), null);
                    return;
                  }
                  result.success(null);
                }
              });
    } else if ("unsubscribeFromTopic".equals(call.method)) {
      String topic = call.arguments();
      FirebaseMessaging.getInstance()
          .unsubscribeFromTopic(topic)
          .addOnCompleteListener(
              new OnCompleteListener<Void>() {
                @Override
                public void onComplete(@NonNull Task<Void> task) {
                  if (!task.isSuccessful()) {
                    Exception e = task.getException();
                    Log.w(TAG, "unsubscribeFromTopic error", e);
                    result.error("unsubscribeFromTopic", e.getMessage(), null);
                    return;
                  }
                  result.success(null);
                }
              });
    } else if ("getToken".equals(call.method)) {
      FirebaseInstanceId.getInstance()
          .getInstanceId()
          .addOnCompleteListener(
              new OnCompleteListener<InstanceIdResult>() {
                @Override
                public void onComplete(@NonNull Task<InstanceIdResult> task) {
                  if (!task.isSuccessful()) {
                    Log.w(TAG, "getToken, error fetching instanceID: ", task.getException());
                    result.success(null);
                    return;
                  }

                  result.success(task.getResult().getToken());
                }
              });
    } else if ("deleteInstanceID".equals(call.method)) {
      new Thread(
              new Runnable() {
                @Override
                public void run() {
                  try {
                    FirebaseInstanceId.getInstance().deleteInstanceId();
                    if (registrar.activity() != null) {
                      registrar
                          .activity()
                          .runOnUiThread(
                              new Runnable() {
                                @Override
                                public void run() {
                                  result.success(true);
                                }
                              });
                    }
                  } catch (IOException ex) {
                    Log.e(TAG, "deleteInstanceID, error:", ex);
                    if (registrar.activity() != null) {
                      registrar
                          .activity()
                          .runOnUiThread(
                              new Runnable() {
                                @Override
                                public void run() {
                                  result.success(false);
                                }
                              });
                    }
                  }
                }
              })
          .start();
    } else if ("autoInitEnabled".equals(call.method)) {
      result.success(FirebaseMessaging.getInstance().isAutoInitEnabled());
    } else if ("setAutoInitEnabled".equals(call.method)) {
      Boolean isEnabled = (Boolean) call.arguments();
      FirebaseMessaging.getInstance().setAutoInitEnabled(isEnabled);
      result.success(null);
    } else {
      result.notImplemented();
    }
  }

  @Override
  public boolean onNewIntent(Intent intent) {
    boolean res = sendMessageFromIntent("onResume", intent);
    if (res && registrar.activity() != null) {
      registrar.activity().setIntent(intent);
    }
    return res;
  }

  /** @return true if intent contained a message to send. */
  private boolean sendMessageFromIntent(String method, Intent intent) {
    if (CLICK_ACTION_VALUE.equals(intent.getAction())
        || CLICK_ACTION_VALUE.equals(intent.getStringExtra("click_action"))) {
      Map<String, Object> message = new HashMap<>();
      Bundle extras = intent.getExtras();

      if (extras == null) {
        return false;
      }

      Map<String, Object> notificationMap = new HashMap<>();
      Map<String, Object> dataMap = new HashMap<>();

      for (String key : extras.keySet()) {
        Object extra = extras.get(key);
        if (extra != null) {
          dataMap.put(key, extra);
        }
      }

      message.put("notification", notificationMap);
      message.put("data", dataMap);

      channel.invokeMethod(method, message);
      return true;
    }
    return false;
  }
}
