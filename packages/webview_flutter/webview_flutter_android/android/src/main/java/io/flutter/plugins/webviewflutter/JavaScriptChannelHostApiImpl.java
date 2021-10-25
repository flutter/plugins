// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.webviewflutter;

import android.os.Handler;
import android.os.Looper;
import io.flutter.plugins.webviewflutter.GeneratedAndroidWebView.JavaScriptChannelFlutterApi;

class JavaScriptChannelHostApiImpl implements GeneratedAndroidWebView.JavaScriptChannelHostApi {
  private final InstanceManager instanceManager;
  private final JavaScriptChannelCreator javaScriptChannelCreator;
  private final JavaScriptChannelFlutterApi javaScriptChannelFlutterApi;
  private final Handler platformThreadHandler;

  static class JavaScriptChannelCreator {
    JavaScriptChannel createJavaScriptChannel(
        Long instanceId,
        JavaScriptChannelFlutterApi javaScriptChannelFlutterApi,
        String channelName,
        Handler platformThreadHandler) {
      return new JavaScriptChannel(null, channelName, platformThreadHandler) {
        @Override
        public void postMessage(String message) {
          final Runnable postMessageRunnable =
              () -> javaScriptChannelFlutterApi.postMessage(instanceId, message, reply -> {});
          if (platformThreadHandler.getLooper() == Looper.myLooper()) {
            postMessageRunnable.run();
          } else {
            platformThreadHandler.post(postMessageRunnable);
          }
        }
      };
    }
  }

  JavaScriptChannelHostApiImpl(
      InstanceManager instanceManager,
      JavaScriptChannelCreator javaScriptChannelCreator,
      JavaScriptChannelFlutterApi javaScriptChannelFlutterApi,
      Handler platformThreadHandler) {
    this.instanceManager = instanceManager;
    this.javaScriptChannelCreator = javaScriptChannelCreator;
    this.javaScriptChannelFlutterApi = javaScriptChannelFlutterApi;
    this.platformThreadHandler = platformThreadHandler;
  }

  @Override
  public void create(Long instanceId, String channelName) {
    final JavaScriptChannel javaScriptChannel =
        javaScriptChannelCreator.createJavaScriptChannel(
            instanceId, javaScriptChannelFlutterApi, channelName, platformThreadHandler);
    instanceManager.addInstance(javaScriptChannel, instanceId);
  }

  @Override
  public void dispose(Long instanceId) {
    instanceManager.removeInstance(instanceId);
  }
}
