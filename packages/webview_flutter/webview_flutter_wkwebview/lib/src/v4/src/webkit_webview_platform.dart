// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:webview_flutter_platform_interface/v4/webview_flutter_platform_interface.dart';

import 'webkit_webview_controller.dart';

/// Implementation of [WebViewPlatform] using the WebKit Api.
class WebKitWebViewPlatform extends WebViewPlatform {
  @override
  WebKitWebViewController createPlatformWebViewController(
    PlatformWebViewControllerCreationParams params,
  ) {
    return WebKitWebViewController(params);
  }
}
