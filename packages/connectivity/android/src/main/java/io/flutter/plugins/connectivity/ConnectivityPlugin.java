// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.connectivity;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.net.ConnectivityManager;
import android.net.wifi.WifiManager;

import androidx.annotation.NonNull;

import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.PluginRegistry.Registrar;

/** ConnectivityPlugin */
public class ConnectivityPlugin {

  /** Plugin registration. */
  public static void registerWith(Registrar registrar) {
    final MethodChannel channel =
        new MethodChannel(registrar.messenger(), "plugins.flutter.io/connectivity");
    final EventChannel eventChannel =
        new EventChannel(registrar.messenger(), "plugins.flutter.io/connectivity_status");

    ConnectivityManager connectivityManager =
            (ConnectivityManager)
                    registrar.context().getApplicationContext().getSystemService(Context.CONNECTIVITY_SERVICE);
    WifiManager wifiManager =
            (WifiManager)registrar.context().getApplicationContext().getSystemService(Context.WIFI_SERVICE);

    ConnectivityChecker checker = new ConnectivityChecker(connectivityManager);

    ConnectivityMethodChannelHandler methodChannelHandler =
        new ConnectivityMethodChannelHandler(checker, wifiManager);
    channel.setMethodCallHandler(methodChannelHandler);

    ConnectivityBroadcastReceiverRegistrar receiverRegistrar = new ConnectivityBroadcastReceiverRegistrar(registrar.context(), checker);
    ConnectivityEventChannelHandler eventChannelHandler = new ConnectivityEventChannelHandler(receiverRegistrar);
    eventChannel.setStreamHandler(eventChannelHandler);
  }
}