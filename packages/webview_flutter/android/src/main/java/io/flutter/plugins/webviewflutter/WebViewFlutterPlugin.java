package io.flutter.plugins.webviewflutter;

import io.flutter.plugin.common.PluginRegistry.Registrar;

/** WebViewFlutterPlugin */
public class WebViewFlutterPlugin {

  /** Plugin registration. */
  public static void registerWith(Registrar registrar) {
    registrar
        .platformViewRegistry()
        .registerViewFactory(
            "plugins.flutter.io/webview", new WebViewFactory(registrar.messenger()));
    FlutterCookieManager.registerWith(registrar.messenger());
  }
}
