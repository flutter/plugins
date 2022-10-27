// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import '../../android_webview.dart' as android_webview;

/// Handles constructing objects and calling static methods for the Android
/// WebView native library.
///
/// This class provides dependency injection for the implementations of the
/// platform interface classes. Improving the ease of unit testing and/or
/// overriding the underlying Android WebView classes.
///
/// By default each function calls the default constructor of the WebView class
/// it intends to return.
class AndroidWebViewProxy {
  /// Constructs a [AndroidWebViewProxy].
  const AndroidWebViewProxy({
    this.createAndroidWebChromeClient = android_webview.WebChromeClient.new,
    this.createAndroidWebViewClient = android_webview.WebViewClient.new,
  });

  /// Constructs a [android_webview.WebChromeClient].
  final android_webview.WebChromeClient Function({
    void Function(android_webview.WebView webView, int progress)?
        onProgressChanged,
  }) createAndroidWebChromeClient;

  /// Constructs a [android_webview.WebViewClient].
  final android_webview.WebViewClient Function({
    void Function(android_webview.WebView webView, String url)? onPageStarted,
    void Function(android_webview.WebView webView, String url)? onPageFinished,
    void Function(
      android_webview.WebView webView,
      android_webview.WebResourceRequest request,
      android_webview.WebResourceError error,
    )?
        onReceivedRequestError,
    @Deprecated('Only called on Android version < 23.')
        void Function(
      android_webview.WebView webView,
      int errorCode,
      String description,
      String failingUrl,
    )?
            onReceivedError,
    void Function(
      android_webview.WebView webView,
      android_webview.WebResourceRequest request,
    )?
        requestLoading,
    void Function(android_webview.WebView webView, String url)? urlLoading,
  }) createAndroidWebViewClient;
}
