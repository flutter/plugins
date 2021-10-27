// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.webviewflutter;

import android.webkit.DownloadListener;
import io.flutter.plugins.webviewflutter.GeneratedAndroidWebView.DownloadListenerFlutterApi;

class DownloadListenerHostApiImpl implements GeneratedAndroidWebView.DownloadListenerHostApi {
  private final InstanceManager instanceManager;
  private final DownloadListenerCreator downloadListenerCreator;
  private final GeneratedAndroidWebView.DownloadListenerFlutterApi downloadListenerFlutterApi;

  static class DownloadListenerCreator {
    DownloadListener createDownloadListener(
        Long instanceId, DownloadListenerFlutterApi downloadListenerFlutterApi) {
      return (url, userAgent, contentDisposition, mimetype, contentLength) ->
          downloadListenerFlutterApi.onDownloadStart(
              instanceId, url, userAgent, contentDisposition, mimetype, contentLength, reply -> {});
    }
  }

  DownloadListenerHostApiImpl(
      InstanceManager instanceManager,
      DownloadListenerCreator downloadListenerCreator,
      DownloadListenerFlutterApi downloadListenerFlutterApi) {
    this.instanceManager = instanceManager;
    this.downloadListenerCreator = downloadListenerCreator;
    this.downloadListenerFlutterApi = downloadListenerFlutterApi;
  }

  @Override
  public void create(Long instanceId) {
    final DownloadListener downloadListener =
        downloadListenerCreator.createDownloadListener(instanceId, downloadListenerFlutterApi);
    instanceManager.addInstance(downloadListener, instanceId);
  }

  @Override
  public void dispose(Long instanceId) {
    instanceManager.removeInstance(instanceId);
  }
}
