// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.connectivity;

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

    ConnectivityMethodChannelHandler methodChannelHandler =
        new ConnectivityMethodChannelHandler(registrar.context());
    channel.setMethodCallHandler(methodChannelHandler);
    eventChannel.setStreamHandler(methodChannelHandler);
  }
}
