// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.webviewflutter;

import android.os.Build;
import android.os.Message;
import android.webkit.WebChromeClient;
import android.webkit.WebResourceRequest;
import android.webkit.WebView;
import android.webkit.WebViewClient;
import androidx.annotation.NonNull;
import androidx.annotation.RequiresApi;

class WebChromeClientHostApiImpl implements GeneratedAndroidWebView.WebChromeClientHostApi {
  private final InstanceManager instanceManager;
  private final WebChromeClientCreator webChromeClientCreator;
  private final WebChromeClientFlutterApiImpl flutterApi;

  static class WebChromeClientImpl extends WebChromeClient implements Releasable {
    private final Long instanceId;
    private final InstanceManager instanceManager;
    private final WebChromeClientFlutterApiImpl flutterApi;
    private WebViewClient webViewClient;
    private boolean ignoreCallbacks = false;

    WebChromeClientImpl(
        Long instanceId,
        InstanceManager instanceManager,
        WebChromeClientFlutterApiImpl flutterApi,
        WebViewClient webViewClient) {
      this.instanceId = instanceId;
      this.instanceManager = instanceManager;
      this.flutterApi = flutterApi;
      this.webViewClient = webViewClient;
    }

    // Verifies that a url opened by `Window.open` has a secure url.
    @Override
    public boolean onCreateWindow(
        final WebView view, boolean isDialog, boolean isUserGesture, Message resultMsg) {
      final WebViewClient newWindowWebViewClient =
          new WebViewClient() {
            @RequiresApi(api = Build.VERSION_CODES.N)
            @Override
            public boolean shouldOverrideUrlLoading(
                @NonNull WebView view, @NonNull WebResourceRequest request) {
              webViewClient.shouldOverrideUrlLoading(view, request);
              return true;
            }

            @Override
            public boolean shouldOverrideUrlLoading(WebView view, String url) {
              webViewClient.shouldOverrideUrlLoading(view, url);
              return true;
            }
          };

      final WebView newWebView = new WebView(view.getContext());
      newWebView.setWebViewClient(newWindowWebViewClient);

      final WebView.WebViewTransport transport = (WebView.WebViewTransport) resultMsg.obj;
      transport.setWebView(newWebView);
      resultMsg.sendToTarget();

      return true;
    }

    @Override
    public void onProgressChanged(WebView view, int progress) {
      if (!ignoreCallbacks) {
        flutterApi.onProgressChanged(
            instanceId, instanceManager.getInstanceId(view), (long) progress, reply -> {});
      }
    }

    void setWebViewClient(WebViewClient webViewClient) {
      this.webViewClient = webViewClient;
    }

    public void release() {
      ignoreCallbacks = true;
      flutterApi.dispose(this, reply -> {});
    }
  }

  static class WebChromeClientCreator {
    WebChromeClient createWebChromeClient(
        Long instanceId,
        InstanceManager instanceManager,
        WebChromeClientFlutterApiImpl flutterApi,
        WebViewClient webViewClient) {
      return new WebChromeClientImpl(instanceId, instanceManager, flutterApi, webViewClient);
    }
  }

  WebChromeClientHostApiImpl(
      InstanceManager instanceManager,
      WebChromeClientCreator webChromeClientCreator,
      WebChromeClientFlutterApiImpl flutterApi) {
    this.instanceManager = instanceManager;
    this.webChromeClientCreator = webChromeClientCreator;
    this.flutterApi = flutterApi;
  }

  @Override
  public void create(Long instanceId, Long webViewClientInstanceId) {
    final WebViewClient webViewClient =
        (WebViewClient) instanceManager.getInstance(webViewClientInstanceId);
    final WebChromeClient webChromeClient =
        webChromeClientCreator.createWebChromeClient(
            instanceId, instanceManager, flutterApi, webViewClient);
    instanceManager.addInstance(webChromeClient, instanceId);
  }
}
