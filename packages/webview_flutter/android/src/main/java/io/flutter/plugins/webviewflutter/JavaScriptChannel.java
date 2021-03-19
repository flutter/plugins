// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.webviewflutter;

import android.os.Handler;
import android.os.Looper;
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
  private final Handler platformThreadHandler;

  /**
   * @param methodChannel the Flutter WebView method channel to which JS messages are sent
   * @param javaScriptChannelName the name of the JavaScript channel, this is sent over the method
   *     channel with each message to let the Dart code know which JavaScript channel the message
   *     was sent through
   */
  JavaScriptChannel(
      MethodChannel methodChannel, String javaScriptChannelName, Handler platformThreadHandler) {
    this.methodChannel = methodChannel;
    this.javaScriptChannelName = javaScriptChannelName;
    this.platformThreadHandler = platformThreadHandler;
  }

  // Suppressing unused warning as this is invoked from JavaScript.
  @SuppressWarnings("unused")
  @JavascriptInterface
  public void postMessage(final String message) {
    Runnable postMessageRunnable =
        new Runnable() {
          @Override
          public void run() {
            HashMap<String, String> arguments = new HashMap<>();
            arguments.put("channel", javaScriptChannelName);
            arguments.put("message", message);
            methodChannel.invokeMethod("javascriptChannelMessage", arguments);
          }
        };
    if (platformThreadHandler.getLooper() == Looper.myLooper()) {
      postMessageRunnable.run();
    } else {
      platformThreadHandler.post(postMessageRunnable);
    }
  }
}
