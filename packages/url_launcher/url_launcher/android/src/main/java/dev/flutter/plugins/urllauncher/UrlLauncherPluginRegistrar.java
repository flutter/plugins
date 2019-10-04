// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package dev.flutter.plugins.urllauncher;

import io.flutter.plugin.common.PluginRegistry.Registrar;

/**
 * Automatically registers a plugin implementation that relies on the stable {@code
 * io.flutter.plugin.common} package.
 */
public class UrlLauncherPluginRegistrar {

  /**
   * Registers a plugin implementation that uses the stable {@code io.flutter.plugin.common}
   * package.
   *
   * <p>Calling this automatically initializes the plugin. However plugins initialized this way
   * won't react to changes in activity or context, unlike {@link UrlLauncherPlugin}.
   */
  public static void registerWith(Registrar registrar) {
    MethodCallHandlerImpl handler =
        new MethodCallHandlerImpl(new UrlLauncher(registrar.activeContext()));
    handler.startListening(registrar.messenger());
  }

  private UrlLauncherPluginRegistrar() {}
}
