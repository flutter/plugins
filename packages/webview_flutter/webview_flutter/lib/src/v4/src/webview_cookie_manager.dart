// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:webview_flutter_platform_interface/v4/webview_flutter_platform_interface.dart';

/// Manages cookies pertaining to all WebViews.
class WebViewCookieManager {
  /// Constructs a [WebViewCookieManager].
  WebViewCookieManager()
      : this.withPlatform(
          platform: PlatformWebViewCookieManager(
            const PlatformWebViewCookieManagerCreationParams(),
          ),
        );

  /// Constructs a [WebViewCookieManager] with creation params for a specific
  /// platform.
  WebViewCookieManager.withPlatformCreationParams(
    PlatformWebViewCookieManagerCreationParams params,
  ) : this.withPlatform(platform: PlatformWebViewCookieManager(params));

  /// Constructs a [WebViewCookieManager] with a specific platform
  /// implementation.
  WebViewCookieManager.withPlatform({required this.platform});

  /// Implementation of [PlatformWebViewCookieManager] for the current platform.
  final PlatformWebViewCookieManager platform;

  /// Clears all cookies for all WebViews.
  ///
  /// Returns true if cookies were present before clearing, else false.
  Future<bool> clearCookies() => platform.clearCookies();

  /// Sets a cookie for all WebView instances.
  ///
  /// This is a no op on iOS versions below 11.
  Future<void> setCookie(WebViewCookie cookie) => platform.setCookie(cookie);
}
