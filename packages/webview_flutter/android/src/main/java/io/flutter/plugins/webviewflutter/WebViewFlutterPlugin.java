// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.webviewflutter;

import io.flutter.plugin.common.PluginRegistry.Registrar;

/** WebViewFlutterPlugin */
public class WebViewFlutterPlugin {
  /** Plugin registration. */
  public static void registerWith(Registrar registrar) {
    registrar
        .platformViewRegistry()
        .registerViewFactory(
            "plugins.flutter.io/webview",
            new WebViewFactory(registrar.messenger(), registrar.view()));
    FlutterCookieManager.registerWith(registrar.messenger());
  }
}
