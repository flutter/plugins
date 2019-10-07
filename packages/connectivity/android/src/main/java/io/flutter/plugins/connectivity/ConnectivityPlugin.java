// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.connectivity;

import android.content.Context;
import android.net.ConnectivityManager;
import android.net.wifi.WifiManager;
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.PluginRegistry.Registrar;

/** ConnectivityPlugin */
public class ConnectivityPlugin implements FlutterPlugin {

  /** Plugin registration. */
  public static void registerWith(Registrar registrar) {
    final MethodChannel channel =
        new MethodChannel(registrar.messenger(), "plugins.flutter.io/connectivity");
    final EventChannel eventChannel =
        new EventChannel(registrar.messenger(), "plugins.flutter.io/connectivity_status");

    ConnectivityManager connectivityManager =
        (ConnectivityManager)
            registrar
                .context()
                .getApplicationContext()
                .getSystemService(Context.CONNECTIVITY_SERVICE);
    WifiManager wifiManager =
        (WifiManager)
            registrar.context().getApplicationContext().getSystemService(Context.WIFI_SERVICE);

    Connectivity connectivity = new Connectivity(connectivityManager, wifiManager);

    ConnectivityMethodChannelHandler methodChannelHandler =
        new ConnectivityMethodChannelHandler(connectivity);
    ConnectivityBroadcastReceiver receiver =
        new ConnectivityBroadcastReceiver(registrar.context(), connectivity);

    channel.setMethodCallHandler(methodChannelHandler);
    eventChannel.setStreamHandler(receiver);
  }

  @Override
  public void onAttachedToEngine(FlutterPluginBinding binding) {
    final MethodChannel channel =
        new MethodChannel(
            binding.getFlutterEngine().getDartExecutor(), "plugins.flutter.io/connectivity");
    final EventChannel eventChannel =
        new EventChannel(
            binding.getFlutterEngine().getDartExecutor(), "plugins.flutter.io/connectivity_status");
    ConnectivityManager connectivityManager =
        (ConnectivityManager)
            binding
                .getApplicationContext()
                .getApplicationContext()
                .getSystemService(Context.CONNECTIVITY_SERVICE);
    WifiManager wifiManager =
        (WifiManager)
            binding
                .getApplicationContext()
                .getApplicationContext()
                .getSystemService(Context.WIFI_SERVICE);

    Connectivity connectivity = new Connectivity(connectivityManager, wifiManager);

    ConnectivityMethodChannelHandler methodChannelHandler =
        new ConnectivityMethodChannelHandler(connectivity);
    ConnectivityBroadcastReceiver receiver =
        new ConnectivityBroadcastReceiver(binding.getApplicationContext(), connectivity);

    channel.setMethodCallHandler(methodChannelHandler);
    eventChannel.setStreamHandler(receiver);
  }

  @Override
  public void onDetachedFromEngine(FlutterPluginBinding binding) {}
}
