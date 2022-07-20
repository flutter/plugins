// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import '../../foundation/foundation.dart';
import '../../web_kit/web_kit.dart';

/// Handles constructing objects and calling static methods for the WebKit
/// native library.
class WebKitProxy {
  /// Constructs a [WebKitProxy].
  const WebKitProxy({
    this.onCreateNavigationDelegate = WKNavigationDelegate.new,
  });

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
  }) onCreateNavigationDelegate;
}
