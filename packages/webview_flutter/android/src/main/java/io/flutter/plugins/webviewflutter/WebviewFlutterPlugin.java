package io.flutter.plugins.webviewflutter;

import io.flutter.plugin.common.PluginRegistry.Registrar;

/** WebviewFlutterPlugin */
public class WebviewFlutterPlugin {
  /** Plugin registration. */
  public static void registerWith(Registrar registrar) {
    registrar
        .platformViewRegistry()
        .registerViewFactory(
            "plugins.flutter.io/webview", new WebViewFactory(registrar.messenger()));
  }
}
