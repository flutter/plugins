// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package dev.flutter.plugins.connectivity;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugins.connectivity.ConnectivityMethodChannelHandler;

public class ConnectivityPlugin implements FlutterPlugin {

  private FlutterPluginBinding pluginBinding;

  @Override
  public void onAttachedToEngine(FlutterPluginBinding binding) {
    this.pluginBinding = binding;
    final MethodChannel channel =
        new MethodChannel(
            pluginBinding.getFlutterEngine().getDartExecutor(), "plugins.flutter.io/connectivity");
    final EventChannel eventChannel =
        new EventChannel(
            pluginBinding.getFlutterEngine().getDartExecutor(),
            "plugins.flutter.io/connectivity_status");

    ConnectivityMethodChannelHandler handler =
        new ConnectivityMethodChannelHandler(pluginBinding.getApplicationContext());

    channel.setMethodCallHandler(handler);
    eventChannel.setStreamHandler(handler);
  }

  @Override
  public void onDetachedFromEngine(FlutterPluginBinding binding) {
    this.pluginBinding = null;
  }
}
