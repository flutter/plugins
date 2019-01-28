package io.flutter.plugins.webviewflutter;

import android.webkit.JavascriptInterface;
import io.flutter.plugin.common.MethodChannel;
import java.util.HashMap;

/**
 * Added as a JavaScript interface to the WebView for any JavaScript channel that the Dart code sets
 * up.
 *
 * <p>Exposes a single method named `postMessage` to JavaScript, which sends a message over a method
 * channel to the Dart code.
 */
class JavaScriptChannel {
  private final MethodChannel methodChannel;
  private final String javaScriptChannelName;

  JavaScriptChannel(MethodChannel methodChannel, String javaScriptChannelName) {
    this.methodChannel = methodChannel;
    this.javaScriptChannelName = javaScriptChannelName;
  }

  // Suppressing unused warning as this is invoked from JavaScript.
  @SuppressWarnings("unused")
  @JavascriptInterface
  public void postMessage(String message) {
    HashMap<String, String> arguments = new HashMap<>();
    arguments.put("channel", javaScriptChannelName);
    arguments.put("message", message);
    methodChannel.invokeMethod("javascriptChannelMessage", arguments);
  }
}
