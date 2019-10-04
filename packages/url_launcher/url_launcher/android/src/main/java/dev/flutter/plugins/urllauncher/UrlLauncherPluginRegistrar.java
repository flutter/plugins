// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package dev.flutter.plugins.urllauncher;

import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.PluginRegistry.Registrar;

/** UrlLauncherPlugin */
public class UrlLauncherPluginRegistrar {
  public static void registerWith(Registrar registrar) {
    MethodChannel channel =
        new MethodChannel(registrar.messenger(), "plugins.flutter.io/url_launcher");
    UrlLauncher plugin = new UrlLauncher(registrar.activeContext());
    channel.setMethodCallHandler(new MethodCallHandlerImpl(plugin));
  }

  private UrlLauncherPluginRegistrar() {}
}
