// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import '../../foundation/foundation.dart';
import '../../web_kit/web_kit.dart';

/// Handles constructing objects and calling static methods for the WebKit
/// native library.
///
/// This class provides dependency injection for the implementations of the
/// platform interface classes. Improving the ease of unit testing and/or
/// overriding the underlying WebKit classes.
///
/// By default each function calls the default constructor of the WebKit class
/// it intends to return.
class WebKitProxy {
  /// Constructs a [WebKitProxy].
  const WebKitProxy({
    this.createWebView = WKWebView.new,
    this.createWebViewConfiguration = WKWebViewConfiguration.new,
    this.createScriptMessageHandler = WKScriptMessageHandler.new,
    this.createNavigationDelegate = WKNavigationDelegate.new,
  });

  /// Constructs a [WKWebView].
  final WKWebView Function(
    WKWebViewConfiguration configuration, {
    void Function(
      String keyPath,
      NSObject object,
      Map<NSKeyValueChangeKey, Object?> change,
    )
        observeValue,
  }) createWebView;

  /// Constructs a [WKWebViewConfiguration].
  final WKWebViewConfiguration Function() createWebViewConfiguration;

  /// Constructs a [WKScriptMessageHandler].
  final WKScriptMessageHandler Function({
    required void Function(
      WKUserContentController userContentController,
      WKScriptMessage message,
    )
        didReceiveScriptMessage,
  }) createScriptMessageHandler;

  /// Constructs a [WKNavigationDelegate].
  final WKNavigationDelegate Function({
    void Function(WKWebView webView, String? url)? didFinishNavigation,
    void Function(WKWebView webView, String? url)?
        didStartProvisionalNavigation,
    Future<WKNavigationActionPolicy> Function(
      WKWebView webView,
      WKNavigationAction navigationAction,
    )?
        decidePolicyForNavigationAction,
    void Function(WKWebView webView, NSError error)? didFailNavigation,
    void Function(WKWebView webView, NSError error)?
        didFailProvisionalNavigation,
    void Function(WKWebView webView)? webViewWebContentProcessDidTerminate,
  }) createNavigationDelegate;
}
