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

  static class DownloadListenerImpl implements DownloadListener, Releasable {
    private final Long instanceId;
    private final DownloadListenerFlutterApi flutterApi;
    private boolean ignoreCallbacks = false;

    DownloadListenerImpl(Long instanceId, DownloadListenerFlutterApi downloadListenerFlutterApi) {
      this.instanceId = instanceId;
      this.flutterApi = downloadListenerFlutterApi;
    }

    @Override
    public void onDownloadStart(
        String url,
        String userAgent,
        String contentDisposition,
        String mimetype,
        long contentLength) {
      if (!ignoreCallbacks) {
        flutterApi.onDownloadStart(
            instanceId, url, userAgent, contentDisposition, mimetype, contentLength, reply -> {});
      }
    }

    @Override
    public void release() {
      ignoreCallbacks = true;
      flutterApi.dispose(instanceId, reply -> {});
    }
  }

  static class DownloadListenerCreator {
    DownloadListener createDownloadListener(
        Long instanceId, DownloadListenerFlutterApi flutterApi) {
      return new DownloadListenerImpl(instanceId, flutterApi);
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
}
