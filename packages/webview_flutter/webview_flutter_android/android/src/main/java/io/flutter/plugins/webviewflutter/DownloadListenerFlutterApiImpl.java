// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.webviewflutter;

import android.webkit.DownloadListener;
import io.flutter.plugin.common.BinaryMessenger;

public class DownloadListenerFlutterApiImpl
    extends GeneratedAndroidWebView.DownloadListenerFlutterApi {
  private final InstanceManager instanceManager;

  public DownloadListenerFlutterApiImpl(
      BinaryMessenger argBinaryMessenger, InstanceManager instanceManager) {
    super(argBinaryMessenger);
    this.instanceManager = instanceManager;
  }

  public void dispose(DownloadListener downloadListener, Reply<Void> callback) {
    final Long instanceId = instanceManager.removeInstance(downloadListener);
    if (instanceId != null) {
      dispose(instanceId, callback);
    } else {
      callback.reply(null);
    }
  }
}
