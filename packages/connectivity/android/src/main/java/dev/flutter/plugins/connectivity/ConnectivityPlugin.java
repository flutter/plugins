// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package dev.flutter.plugins.connectivity;

import android.content.Context;
import android.net.ConnectivityManager;
import android.net.wifi.WifiManager;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugins.connectivity.Connectivity;
import io.flutter.plugins.connectivity.ConnectivityBroadcastReceiver;
import io.flutter.plugins.connectivity.ConnectivityMethodChannelHandler;

/**
 * Entry point of the plugin.
 *
 * <p>The ConnectivityPlugin links up dependencies and set up the {@link io.flutter.plugin.common.MethodChannel.MethodCallHandler} and the
 * {@link io.flutter.plugin.common.EventChannel.StreamHandler} during {@link #onAttachedToEngine(FlutterPluginBinding)}.
 * To register the plugin, add an instance of this class to the {@link FlutterEngine}.
 * </p>
 *
 * See also {@link FlutterPlugin} for more details.
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
    ConnectivityBroadcastReceiver receiver =
        new ConnectivityBroadcastReceiver(binding.getApplicationContext(), connectivity);

    channel.setMethodCallHandler(methodChannelHandler);
    eventChannel.setStreamHandler(receiver);
  }

  @Override
  public void onDetachedFromEngine(FlutterPluginBinding binding) {}
}
