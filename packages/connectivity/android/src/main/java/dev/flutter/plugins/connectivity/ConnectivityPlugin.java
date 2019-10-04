// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package dev.flutter.plugins.connectivity;

import android.content.Context;
import android.net.ConnectivityManager;
import android.net.wifi.WifiManager;
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugins.connectivity.BroadcastReceiverRegistrarImpl;
import io.flutter.plugins.connectivity.Connectivity;
import io.flutter.plugins.connectivity.ConnectivityEventChannelHandler;
import io.flutter.plugins.connectivity.ConnectivityMethodChannelHandler;

/**
 * Plugin implementation that uses the new {@code io.flutter.embedding} package.
 *
 * <p>Instantiate this in an add to app scenario to gracefully handle activity and context changes.
 */
public class ConnectivityPlugin implements FlutterPlugin {

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
    channel.setMethodCallHandler(methodChannelHandler);

    BroadcastReceiverRegistrarImpl receiverRegistrar =
        new BroadcastReceiverRegistrarImpl(binding.getApplicationContext(), connectivity);
    ConnectivityEventChannelHandler eventChannelHandler =
        new ConnectivityEventChannelHandler(receiverRegistrar);
    eventChannel.setStreamHandler(eventChannelHandler);
  }

  @Override
  public void onDetachedFromEngine(FlutterPluginBinding binding) {}
}
