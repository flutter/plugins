// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.webviewflutter;

import android.os.Handler;
import io.flutter.plugins.webviewflutter.GeneratedAndroidWebView.JavaScriptChannelFlutterApi;

class JavaScriptChannelHostApiImpl implements GeneratedAndroidWebView.JavaScriptChannelHostApi {
  private final InstanceManager instanceManager;
  private final JavaScriptChannelCreator javaScriptChannelCreator;
  private final JavaScriptChannelFlutterApi flutterApi;
  private final Handler platformThreadHandler;

  static class JavaScriptChannelCreator {
    JavaScriptChannel createJavaScriptChannel(
        Long instanceId,
        JavaScriptChannelFlutterApi flutterApi,
        String channelName,
        Handler platformThreadHandler) {
      return new JavaScriptChannel(instanceId, flutterApi, channelName, platformThreadHandler);
    }
  }

  JavaScriptChannelHostApiImpl(
      InstanceManager instanceManager,
      JavaScriptChannelCreator javaScriptChannelCreator,
      JavaScriptChannelFlutterApi flutterApi,
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
