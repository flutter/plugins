// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.webviewflutter;

import android.webkit.WebViewClient;
import io.flutter.plugin.common.BinaryMessenger;

public class WebViewClientFlutterApiImpl extends GeneratedAndroidWebView.WebViewClientFlutterApi {
  private final InstanceManager instanceManager;

  public WebViewClientFlutterApiImpl(
      BinaryMessenger argBinaryMessenger, InstanceManager instanceManager) {
    super(argBinaryMessenger);
    this.instanceManager = instanceManager;
  }

  public void dispose(WebViewClient webViewClient, Reply<Void> callback) {
    final Long instanceId = instanceManager.removeInstance(webViewClient);
    if (instanceId != null) {
      dispose(instanceId, callback);
    } else {
      callback.reply(null);
    }
  }
}
