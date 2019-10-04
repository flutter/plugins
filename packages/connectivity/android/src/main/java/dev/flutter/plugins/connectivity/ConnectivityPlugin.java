// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package dev.flutter.plugins.connectivity;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.MethodChannel;
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
                binding.getFlutterEngine().getDartExecutor(),
            "plugins.flutter.io/connectivity_status");

    ConnectivityMethodChannelHandler handler =
        new ConnectivityMethodChannelHandler(binding.getApplicationContext());

    channel.setMethodCallHandler(handler);
    eventChannel.setStreamHandler(handler);
  }

  @Override
  public void onDetachedFromEngine(FlutterPluginBinding binding){}
}
