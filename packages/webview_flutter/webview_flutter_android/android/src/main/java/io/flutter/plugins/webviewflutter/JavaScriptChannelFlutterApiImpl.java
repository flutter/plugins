// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.webviewflutter;

import io.flutter.plugin.common.BinaryMessenger;

public class JavaScriptChannelFlutterApiImpl
    extends GeneratedAndroidWebView.JavaScriptChannelFlutterApi {
  private final InstanceManager instanceManager;

  public JavaScriptChannelFlutterApiImpl(
      BinaryMessenger argBinaryMessenger, InstanceManager instanceManager) {
    super(argBinaryMessenger);
    this.instanceManager = instanceManager;
  }

  public void dispose(JavaScriptChannel javaScriptChannel, Reply<Void> callback) {
    final Long instanceId = instanceManager.removeInstance(javaScriptChannel);
    if (instanceId != null) {
      dispose(instanceId, callback);
    } else {
      callback.reply(null);
    }
  }
}
