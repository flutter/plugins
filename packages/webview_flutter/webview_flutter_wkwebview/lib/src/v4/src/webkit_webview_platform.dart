// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:webview_flutter_platform_interface/v4/webview_flutter_platform_interface.dart';
import 'package:webview_flutter_wkwebview/src/v4/src/webkit_webview_cookie_manager.dart';

import 'webkit_navigation_delegate.dart';
import 'webkit_webview_controller.dart';

/// Implementation of [WebViewPlatform] using the WebKit API.
class WebKitWebViewPlatform extends WebViewPlatform {
  @override
  WebKitWebViewController createPlatformWebViewController(
    PlatformWebViewControllerCreationParams params,
  ) {
    return WebKitWebViewController(params);
  }

  @override
  WebKitNavigationDelegate createPlatformNavigationDelegate(
    PlatformNavigationDelegateCreationParams params,
  ) {
    return WebKitNavigationDelegate(params);
  }

  @override
  WebKitWebViewCookieManager createPlatformCookieManager(
    PlatformWebViewCookieManagerCreationParams params,
  ) {
    return WebKitWebViewCookieManager(params);
  }
}
