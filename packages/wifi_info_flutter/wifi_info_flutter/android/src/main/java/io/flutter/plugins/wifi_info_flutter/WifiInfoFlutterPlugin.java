// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.wifi_info_flutter;

import android.content.Context;
import android.net.wifi.WifiManager;
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodChannel;

/** WifiInfoFlutterPlugin */
public class WifiInfoFlutterPlugin implements FlutterPlugin {
  private MethodChannel methodChannel;

  /** Plugin registration. */
  @SuppressWarnings("deprecation")
  public static void registerWith(io.flutter.plugin.common.PluginRegistry.Registrar registrar) {
    WifiInfoFlutterPlugin plugin = new WifiInfoFlutterPlugin();
    plugin.setupChannels(registrar.messenger(), registrar.context());
  }

  @Override
  public void onAttachedToEngine(FlutterPluginBinding binding) {
    setupChannels(binding.getBinaryMessenger(), binding.getApplicationContext());
  }

  @Override
  public void onDetachedFromEngine(FlutterPluginBinding binding) {
    methodChannel.setMethodCallHandler(null);
    methodChannel = null;
  }

  private void setupChannels(BinaryMessenger messenger, Context context) {
    methodChannel = new MethodChannel(messenger, "plugins.flutter.io/wifi_info_flutter");
    final WifiManager wifiManager =
        (WifiManager) context.getApplicationContext().getSystemService(Context.WIFI_SERVICE);

    final WifiInfoFlutter wifiInfoFlutter = new WifiInfoFlutter(wifiManager, context);

    final WifiInfoFlutterMethodChannelHandler methodChannelHandler =
        new WifiInfoFlutterMethodChannelHandler(wifiInfoFlutter);
    methodChannel.setMethodCallHandler(methodChannelHandler);
  }
}
