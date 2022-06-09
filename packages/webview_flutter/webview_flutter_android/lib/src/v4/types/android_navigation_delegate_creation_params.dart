// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:webview_flutter_android/src/v4/android_navigation_delegate.dart';
import 'package:webview_flutter_platform_interface/v4/src/types/types.dart';

/// Object specifying creation parameters for creating a [AndroidNavigationDelegate].
///
/// When adding additional fields make sure they can be null or have a default
/// value to avoid breaking changes. See [PlatformNavigationDelegateCreationParams] for
/// more information.
@immutable
class AndroidNavigationDelegateCreationParams
    extends PlatformNavigationDelegateCreationParams {
  /// Creates a new [AndroidNavigationDelegateCreationParams] instance.
  const AndroidNavigationDelegateCreationParams._(
    // This parameter prevents breaking changes later.
    // ignore: avoid_unused_constructor_parameters
    PlatformNavigationDelegateCreationParams params, {
    required this.androidWebViewClient,
    required this.androidWebChromeClient,
    this.loadUrl,
  }) : super();

  /// Creates a [AndroidNavigationDelegateCreationParams] instance based on [PlatformNavigationDelegateCreationParams].
  factory AndroidNavigationDelegateCreationParams.fromPlatformNavigationDelegateCreationParams(
    PlatformNavigationDelegateCreationParams params, {
    required AndroidWebViewClient androidWebViewClient,
    required AndroidWebChromeClient androidWebChromeClient,
    Future<void> Function(String url, Map<String, String>? headers)? loadUrl,
  }) {
    return AndroidNavigationDelegateCreationParams._(
      params,
      androidWebViewClient: androidWebViewClient,
      androidWebChromeClient: androidWebChromeClient,
      loadUrl: loadUrl,
    );
  }

  /// The [AndroidWebViewClient] exposing navigation events triggered by [android_webview.WebView].
  final AndroidWebViewClient androidWebViewClient;

  /// The [AndroidWebChromeClient] exposing progress events triggered by [android_webview.WebView].
  final AndroidWebChromeClient androidWebChromeClient;

  /// Callback responsible for loading the [url] after a navigation request is approved.
  final Future<void> Function(String url, Map<String, String>? headers)?
      loadUrl;
}
