// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.webviewflutter;

import android.annotation.SuppressLint;
import android.annotation.TargetApi;
import android.graphics.Bitmap;
import android.os.Build;
import android.view.KeyEvent;
import android.webkit.WebResourceError;
import android.webkit.WebResourceRequest;
import android.webkit.WebView;
import android.webkit.WebViewClient;
import androidx.annotation.NonNull;
import androidx.annotation.RequiresApi;
import androidx.webkit.WebResourceErrorCompat;
import androidx.webkit.WebViewClientCompat;
import io.flutter.plugins.webviewflutter.GeneratedAndroidWebView.WebViewClientFlutterApi;

class WebViewClientHostApiImpl implements GeneratedAndroidWebView.WebViewClientHostApi {
  private final InstanceManager instanceManager;
  private final WebViewClientCreator webViewClientCreator;
  private final WebViewClientFlutterApi webViewClientFlutterApi;

  @RequiresApi(api = Build.VERSION_CODES.M)
  static GeneratedAndroidWebView.WebResourceErrorData createWebResourceErrorData(
      WebResourceError error) {
    final GeneratedAndroidWebView.WebResourceErrorData errorData =
        new GeneratedAndroidWebView.WebResourceErrorData();
    errorData.setErrorCode((long) error.getErrorCode());
    errorData.setDescription(error.getDescription().toString());

    return errorData;
  }

  @SuppressLint("RequiresFeature")
  static GeneratedAndroidWebView.WebResourceErrorData createWebResourceErrorData(
      WebResourceErrorCompat error) {
    final GeneratedAndroidWebView.WebResourceErrorData errorData =
        new GeneratedAndroidWebView.WebResourceErrorData();
    errorData.setErrorCode((long) error.getErrorCode());
    errorData.setDescription(error.getDescription().toString());

    return errorData;
  }

  @RequiresApi(api = Build.VERSION_CODES.LOLLIPOP)
  static GeneratedAndroidWebView.WebResourceRequestData createWebResourceRequestData(
      WebResourceRequest request) {
    final GeneratedAndroidWebView.WebResourceRequestData requestData =
        new GeneratedAndroidWebView.WebResourceRequestData();
    requestData.setUrl(request.getUrl().toString());
    requestData.setIsForMainFrame(request.isForMainFrame());
    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
      requestData.setIsRedirect(request.isRedirect());
    }
    requestData.setHasGesture(request.hasGesture());
    requestData.setMethod(request.getMethod());
    requestData.setRequestHeaders(request.getRequestHeaders());

    return requestData;
  }

  static class WebViewClientCreator {
    WebViewClient createWebViewClient(
        Long instanceId,
        InstanceManager instanceManager,
        Boolean shouldOverrideUrlLoading,
        WebViewClientFlutterApi webViewClientFlutterApi) {
      // WebViewClientCompat is used to get
      // shouldOverrideUrlLoading(WebView view, WebResourceRequest request)
      // invoked by the webview on older Android devices, without it pages that use iframes will
      // be broken when a navigationDelegate is set on Android version earlier than N.
      //
      // However, this if statement attempts to avoid using WebViewClientCompat on versions >= N due
      // to bug https://bugs.chromium.org/p/chromium/issues/detail?id=925887. Also, see
      // https://github.com/flutter/flutter/issues/29446.
      if (android.os.Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
        return new WebViewClient() {
          @Override
          public void onPageStarted(WebView view, String url, Bitmap favicon) {
            webViewClientFlutterApi.onPageStarted(
                instanceId, instanceManager.getInstanceId(view), url, reply -> {});
          }

          @Override
          public void onPageFinished(WebView view, String url) {
            webViewClientFlutterApi.onPageFinished(
                instanceId, instanceManager.getInstanceId(view), url, reply -> {});
          }

          @Override
          public void onReceivedError(
              WebView view, WebResourceRequest request, WebResourceError error) {
            webViewClientFlutterApi.onReceivedRequestError(
                instanceId,
                instanceManager.getInstanceId(view),
                createWebResourceRequestData(request),
                createWebResourceErrorData(error),
                reply -> {});
          }

          @SuppressWarnings("deprecation")
          @Override
          public void onReceivedError(
              WebView view, int errorCode, String description, String failingUrl) {
            webViewClientFlutterApi.onReceivedError(
                instanceId,
                instanceManager.getInstanceId(view),
                (long) errorCode,
                description,
                failingUrl,
                reply -> {});
          }

          @Override
          public boolean shouldOverrideUrlLoading(WebView view, WebResourceRequest request) {
            webViewClientFlutterApi.requestLoading(
                instanceId,
                instanceManager.getInstanceId(view),
                createWebResourceRequestData(request),
                reply -> {});
            return shouldOverrideUrlLoading;
          }

          @SuppressWarnings("deprecation")
          @Override
          public boolean shouldOverrideUrlLoading(WebView view, String url) {
            webViewClientFlutterApi.urlLoading(
                instanceId, instanceManager.getInstanceId(view), url, reply -> {});
            return shouldOverrideUrlLoading;
          }

          @Override
          public void onUnhandledKeyEvent(WebView view, KeyEvent event) {
            // Deliberately empty. Occasionally the webview will mark events as having failed to be
            // handled even though they were handled. We don't want to propagate those as they're not
            // truly lost.
          }
        };
      } else {
        return new WebViewClientCompat() {
          @Override
          public void onPageStarted(WebView view, String url, Bitmap favicon) {
            webViewClientFlutterApi.onPageStarted(
                instanceId, instanceManager.getInstanceId(view), url, reply -> {});
          }

          @Override
          public void onPageFinished(WebView view, String url) {
            webViewClientFlutterApi.onPageFinished(
                instanceId, instanceManager.getInstanceId(view), url, reply -> {});
          }

          // This method is only called when the WebViewFeature.RECEIVE_WEB_RESOURCE_ERROR feature is
          // enabled. The deprecated method is called when a device doesn't support this.
          @RequiresApi(api = Build.VERSION_CODES.LOLLIPOP)
          @SuppressLint("RequiresFeature")
          @Override
          public void onReceivedError(
              @NonNull WebView view,
              @NonNull WebResourceRequest request,
              @NonNull WebResourceErrorCompat error) {
            webViewClientFlutterApi.onReceivedRequestError(
                instanceId,
                instanceManager.getInstanceId(view),
                createWebResourceRequestData(request),
                createWebResourceErrorData(error),
                reply -> {});
          }

          @SuppressWarnings("deprecation")
          @Override
          public void onReceivedError(
              WebView view, int errorCode, String description, String failingUrl) {
            webViewClientFlutterApi.onReceivedError(
                instanceId,
                instanceManager.getInstanceId(view),
                (long) errorCode,
                description,
                failingUrl,
                reply -> {});
          }

          @TargetApi(Build.VERSION_CODES.LOLLIPOP)
          @Override
          public boolean shouldOverrideUrlLoading(
              @NonNull WebView view, @NonNull WebResourceRequest request) {
            webViewClientFlutterApi.requestLoading(
                instanceId,
                instanceManager.getInstanceId(view),
                createWebResourceRequestData(request),
                reply -> {});
            return shouldOverrideUrlLoading;
          }

          @SuppressWarnings("deprecation")
          @Override
          public boolean shouldOverrideUrlLoading(WebView view, String url) {
            webViewClientFlutterApi.urlLoading(
                instanceId, instanceManager.getInstanceId(view), url, reply -> {});
            return shouldOverrideUrlLoading;
          }

          @Override
          public void onUnhandledKeyEvent(WebView view, KeyEvent event) {
            // Deliberately empty. Occasionally the webview will mark events as having failed to be
            // handled even though they were handled. We don't want to propagate those as they're not
            // truly lost.
          }
        };
      }
    }
  }

  WebViewClientHostApiImpl(
      InstanceManager instanceManager,
      WebViewClientCreator webViewClientCreator,
      WebViewClientFlutterApi webViewClientFlutterApi) {
    this.instanceManager = instanceManager;
    this.webViewClientCreator = webViewClientCreator;
    this.webViewClientFlutterApi = webViewClientFlutterApi;
  }

  @Override
  public void create(Long instanceId, Boolean shouldOverrideUrlLoading) {
    final WebViewClient webViewClient =
        webViewClientCreator.createWebViewClient(
            instanceId, instanceManager, shouldOverrideUrlLoading, webViewClientFlutterApi);
    instanceManager.addInstance(webViewClient, instanceId);
  }

  @Override
  public void dispose(Long instanceId) {
    instanceManager.removeInstance(instanceId);
  }
}
