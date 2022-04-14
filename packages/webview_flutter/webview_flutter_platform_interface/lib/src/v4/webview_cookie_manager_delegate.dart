// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/foundation.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'types/types.dart';
import 'webview_platform.dart';

/// Interface for a platform implementation of a cookie manager.
///
/// Platform implementations should extend this class rather than implement it
/// as `webview_flutter` does not consider newly added methods to be breaking
/// changes. Extending this class (using `extends`) ensures that the subclass
/// will get the default implementation, while platform implementations that
/// `implements` this interface will be broken by newly added
/// [WebViewCookieManagerDelegate] methods.
abstract class WebViewCookieManagerDelegate extends PlatformInterface {
  /// Creates a new [WebViewCookieManagerDelegate]
  factory WebViewCookieManagerDelegate(
      WebViewCookieManagerCreationParams params) {
    final WebViewCookieManagerDelegate cookieManagerDelegate =
        WebViewPlatform.instance!.createCookieManagerDelegate(params);
    PlatformInterface.verify(cookieManagerDelegate, _token);
    return cookieManagerDelegate;
  }

  /// Used by the platform implementation to create a new
  /// [WebViewCookieManagerDelegate].
  ///
  /// Should only be used by platform implementations because they can't extend
  /// a class that only contains a factory constructor.
  @protected
  WebViewCookieManagerDelegate.implementation(this.params)
      : super(token: _token);

  static final Object _token = Object();

  /// The parameters used to initialize the [WebViewCookieManagerDelegate].
  final WebViewCookieManagerCreationParams params;

  /// Clears all cookies for all [WebView] instances.
  ///
  /// Returns true if cookies were present before clearing, else false.
  Future<bool> clearCookies() {
    throw UnimplementedError(
        'clearCookies is not implemented on the current platform');
  }

  /// Sets a cookie for all [WebView] instances.
  Future<void> setCookie(WebViewCookie cookie) {
    throw UnimplementedError(
        'setCookie is not implemented on the current platform');
  }
}
