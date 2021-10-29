// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.webviewflutter;

import android.os.Handler;
import android.os.Looper;
import android.webkit.JavascriptInterface;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugins.webviewflutter.GeneratedAndroidWebView.JavaScriptChannelFlutterApi;
import java.util.HashMap;

/**
 * Added as a JavaScript interface to the WebView for any JavaScript channel that the Dart code sets
 * up.
 *
 * <p>Exposes a single method named `postMessage` to JavaScript, which sends a message over a method
 * channel to the Dart code.
 */
class JavaScriptChannel implements Releasable {
  private final Long instanceId;
  private final MethodChannel methodChannel;
  private final Handler platformThreadHandler;
  final String javaScriptChannelName;
  final JavaScriptChannelFlutterApi javaScriptChannelFlutterApi;
  boolean ignoreCallbacks = false;

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
    this.instanceId = null;
    javaScriptChannelFlutterApi = null;
  }

  /**
   * @param instanceId identifier for this object when messages are sent to Dart
   * @param javaScriptChannelFlutterApi the Flutter Api to which JS messages are sent
   * @param channelName the name of the JavaScript channel, this is sent over the method channel
   *     with each message to let the Dart code know which JavaScript channel the message was sent
   *     through
   * @param platformThreadHandler handles making callbacks on the desired thread
   */
  JavaScriptChannel(
      Long instanceId,
      JavaScriptChannelFlutterApi javaScriptChannelFlutterApi,
      String channelName,
      Handler platformThreadHandler) {
    this.instanceId = instanceId;
    this.javaScriptChannelFlutterApi = javaScriptChannelFlutterApi;
    this.javaScriptChannelName = channelName;
    this.platformThreadHandler = platformThreadHandler;
    methodChannel = null;
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

  @Override
  public void release() {
    ignoreCallbacks = true;
    javaScriptChannelFlutterApi.dispose(instanceId, reply -> {});
  }
}
