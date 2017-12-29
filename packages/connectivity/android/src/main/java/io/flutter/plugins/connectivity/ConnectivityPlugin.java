// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.connectivity;

import android.app.Activity;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.net.ConnectivityManager;
import android.net.NetworkInfo;
import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.EventChannel.EventSink;
import io.flutter.plugin.common.EventChannel.StreamHandler;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;

/** ConnectivityPlugin */
public class ConnectivityPlugin implements MethodCallHandler, StreamHandler {
  private final Activity activity;
  private final ConnectivityManager manager;
  private BroadcastReceiver receiver;

  /** Plugin registration. */
  public static void registerWith(Registrar registrar) {
    final MethodChannel channel =
        new MethodChannel(registrar.messenger(), "plugins.flutter.io/connectivity");
    final EventChannel eventChannel =
        new EventChannel(registrar.messenger(), "plugins.flutter.io/connectivity_status");
    ConnectivityPlugin instance = new ConnectivityPlugin(registrar.activity());
    channel.setMethodCallHandler(instance);
    eventChannel.setStreamHandler(instance);
  }

  private ConnectivityPlugin(Activity activity) {
    this.activity = activity;
    this.manager = (ConnectivityManager) activity.getSystemService(Context.CONNECTIVITY_SERVICE);
  }

  @Override
  public void onListen(Object arguments, EventSink events) {
    receiver = createReceiver(events);
    activity.registerReceiver(receiver, new IntentFilter(ConnectivityManager.CONNECTIVITY_ACTION));
  }

  @Override
  public void onCancel(Object arguments) {
    activity.unregisterReceiver(receiver);
    receiver = null;
  }

  private static String getNetworkType(int type) {
    switch (type) {
      case ConnectivityManager.TYPE_ETHERNET:
      case ConnectivityManager.TYPE_WIFI:
      case ConnectivityManager.TYPE_WIMAX:
        return "wifi";
      case ConnectivityManager.TYPE_MOBILE:
      case ConnectivityManager.TYPE_MOBILE_DUN:
        return "mobile";
      default:
        return "none";
    }
  }

  @Override
  public void onMethodCall(MethodCall call, Result result) {
    if (call.method.equals("check")) {
      NetworkInfo info = manager.getActiveNetworkInfo();
      if (info != null && info.isConnected()) {
        result.success(getNetworkType(info.getType()));
      } else {
        result.success("none");
      }
    } else {
      result.notImplemented();
    }
  }

  private BroadcastReceiver createReceiver(final EventSink events) {
    return new BroadcastReceiver() {
      @Override
      public void onReceive(Context context, Intent intent) {
        boolean isLost = intent.getBooleanExtra(ConnectivityManager.EXTRA_NO_CONNECTIVITY, false);
        if (isLost) {
          events.success("none");
          return;
        }

        int type = intent.getIntExtra(ConnectivityManager.EXTRA_NETWORK_TYPE, -1);
        events.success(getNetworkType(type));
      }
    };
  }
}
