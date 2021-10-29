// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.webviewflutter;

import android.os.Handler;
import android.os.Looper;
import android.webkit.JavascriptInterface;

class JavaScriptChannelHostApiImpl implements GeneratedAndroidWebView.JavaScriptChannelHostApi {
  private final InstanceManager instanceManager;
  private final JavaScriptChannelCreator javaScriptChannelCreator;
  private final JavaScriptChannelFlutterApiImpl flutterApi;
  private final Handler platformThreadHandler;

  static class JavaScriptChannelCreator {
    JavaScriptChannel createJavaScriptChannel(
        Long instanceId,
        JavaScriptChannelFlutterApiImpl flutterApi,
        String channelName,
        Handler platformThreadHandler) {
      return new JavaScriptChannel(instanceId, flutterApi, channelName, platformThreadHandler) {
        @JavascriptInterface
        @Override
        public void postMessage(String message) {
          if (!ignoreCallbacks) {
            final Runnable postMessageRunnable =
                () -> flutterApi.postMessage(instanceId, message, reply -> {});
            if (platformThreadHandler.getLooper() == Looper.myLooper()) {
              postMessageRunnable.run();
            } else {
              platformThreadHandler.post(postMessageRunnable);
            }
          }
        }
      };
    }
  }

  JavaScriptChannelHostApiImpl(
      InstanceManager instanceManager,
      JavaScriptChannelCreator javaScriptChannelCreator,
      JavaScriptChannelFlutterApiImpl flutterApi,
      Handler platformThreadHandler) {
    this.instanceManager = instanceManager;
    this.javaScriptChannelCreator = javaScriptChannelCreator;
    this.flutterApi = flutterApi;
    this.platformThreadHandler = platformThreadHandler;
  }

  @Override
  public void create(Long instanceId, String channelName) {
    final JavaScriptChannel javaScriptChannel =
        javaScriptChannelCreator.createJavaScriptChannel(
            instanceId, flutterApi, channelName, platformThreadHandler);
    instanceManager.addInstance(javaScriptChannel, instanceId);
  }
}
