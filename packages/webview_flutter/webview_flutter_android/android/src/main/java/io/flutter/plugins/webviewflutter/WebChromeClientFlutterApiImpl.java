// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.webviewflutter;

import android.webkit.WebChromeClient;
import io.flutter.plugin.common.BinaryMessenger;

public class WebChromeClientFlutterApiImpl
    extends GeneratedAndroidWebView.WebChromeClientFlutterApi {
  private final InstanceManager instanceManager;

  public WebChromeClientFlutterApiImpl(
      BinaryMessenger argBinaryMessenger, InstanceManager instanceManager) {
    super(argBinaryMessenger);
    this.instanceManager = instanceManager;
  }

  public void dispose(WebChromeClient webChromeClient, Reply<Void> callback) {
    final Long instanceId = instanceManager.removeInstance(webChromeClient);
    if (instanceId != null) {
      dispose(instanceId, callback);
    } else {
      callback.reply(null);
    }
  }
}
