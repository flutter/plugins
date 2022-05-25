// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:webview_flutter_platform_interface/v4/webview_flutter_platform_interface.dart';

import 'android_webview_cookie_manager.dart';
import 'types/android_webview_cookie_manager_creation_params.dart';

/// Provides Android specific implementations of a webview.
class AndroidWebViewPlatform extends WebViewPlatform {
  @override
  PlatformWebViewCookieManager createPlatformCookieManager(
      PlatformWebViewCookieManagerCreationParams params) {
    if (params is AndroidWebViewCookieManagerCreationParams) {
      return AndroidWebViewCookieManager(params);
    }

    return AndroidWebViewCookieManager(
      AndroidWebViewCookieManagerCreationParams
          .fromPlatformWebViewCookieManagerCreationParams(params),
    );
  }
}
