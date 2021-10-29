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
import io.flutter.plugins.webviewflutter.GeneratedAndroidWebView.WebChromeClientFlutterApi;

class WebChromeClientHostApiImpl implements GeneratedAndroidWebView.WebChromeClientHostApi {
  private final InstanceManager instanceManager;
  private final WebChromeClientCreator webChromeClientCreator;
  private final WebChromeClientFlutterApi webChromeClientFlutterApi;

  static class WebChromeClientCreator {
    WebChromeClient createWebChromeClient(
        Long instanceId,
        InstanceManager instanceManager,
        WebViewClient webViewClient,
        WebChromeClientFlutterApi webChromeClientFlutterApi) {
      return new WebChromeClient() {
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
          webChromeClientFlutterApi.onProgressChanged(
              instanceId, instanceManager.getInstanceId(view), (long) progress, reply -> {});
        }
      };
    }
  }

  WebChromeClientHostApiImpl(
      InstanceManager instanceManager,
      WebChromeClientCreator webChromeClientCreator,
      WebChromeClientFlutterApi webChromeClientFlutterApi) {
    this.instanceManager = instanceManager;
    this.webChromeClientCreator = webChromeClientCreator;
    this.webChromeClientFlutterApi = webChromeClientFlutterApi;
  }

  @Override
  public void create(Long instanceId, Long webViewClientInstanceId) {
    final WebViewClient webViewClient =
        (WebViewClient) instanceManager.getInstance(webViewClientInstanceId);
    final WebChromeClient webChromeClient =
        webChromeClientCreator.createWebChromeClient(
            instanceId, instanceManager, webViewClient, webChromeClientFlutterApi);
    instanceManager.addInstance(webChromeClient, instanceId);
  }

  @Override
  public void dispose(Long instanceId) {
    instanceManager.removeInstance(instanceId);
  }
}
