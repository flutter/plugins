// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.sharedpreferences;

import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.PluginRegistry;

/** SharedPreferencesPlugin */
@SuppressWarnings("unchecked")
public class SharedPreferencesPlugin {
  private static final String CHANNEL_NAME = "plugins.flutter.io/shared_preferences";

  public static void registerWith(PluginRegistry.Registrar registrar) {
    MethodChannel channel = new MethodChannel(registrar.messenger(), CHANNEL_NAME);

    MethodCallHandlerImpl handler = new MethodCallHandlerImpl(registrar.context());
    channel.setMethodCallHandler(handler);
  }
}
