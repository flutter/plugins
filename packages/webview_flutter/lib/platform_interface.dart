// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';

/// Interface for talking to the webview's platform implementation.
///
/// An instance implementing this interface is passed to the `onWebViewPlatformCreated` callback that is
/// passed to [WebViewPlatformBuilder#onWebViewPlatformCreated].
abstract class WebViewPlatform {
  /// Loads the specified URL.
  ///
  /// If `headers` is not null and the URL is an HTTP URL, the key value paris in `headers` will
  /// be added as key value pairs of HTTP headers for the request.
  ///
  /// `url` must not be null.
  ///
  /// Throws an ArgumentError if `url` is not a valid URL string.
  Future<void> loadUrl(
    String url,
    Map<String, String> headers,
  ) {
    throw UnimplementedError(
        "WebView loadUrl is not implemented on the current platform");
  }

  // As the PR currently focus about the wiring I've only moved loadUrl to the new way, so
  // the discussion is more focused.
  // In this temporary state WebViewController still uses a method channel directly for all other
  // method calls so we need to expose the webview ID.
  // TODO(amirh): remove this before publishing this package.
  int get id;
}

typedef WebViewPlatformCreatedCallback = void Function(
    WebViewPlatform webViewPlatform);

/// Interface building a platform WebView implementation.
///
/// [WebView#platformBuilder] controls the builder that is used by [WebView].
/// [AndroidWebViewPlatform] and [CupertinoWebViewPlatform] are the default implementations
/// for Android and iOS respectively.
abstract class WebViewBuilder {
  /// Builds a new WebView.
  ///
  /// Returns a Widget tree that embeds the created webview.
  ///
  /// `creationParams` are the initial parameters used to setup the webview.
  ///
  /// `onWebViewPlatformCreated` will be invoked after the platform specific [WebViewPlatform]
  /// implementation is created with the [WebViewPlatform] instance as a parameter.
  ///
  /// `gestureRecognizers` specifies which gestures should be consumed by the web view.
  /// It is possible for other gesture recognizers to be competing with the web view on pointer
  /// events, e.g if the web view is inside a [ListView] the [ListView] will want to handle
  /// vertical drags. The web view will claim gestures that are recognized by any of the
  /// recognizers on this list.
  /// When `gestureRecognizers` is empty or null, the web view will only handle pointer events for gestures that
  /// were not claimed by any other gesture recognizer.
  Widget build({
    BuildContext context,
    // TODO(amirh): convert this to be the actual parameters.
    // I'm starting without it as the PR is starting to become pretty big.
    // I'll followup with the conversion PR.
    Map<String, dynamic> creationParams,
    WebViewPlatformCreatedCallback onWebViewPlatformCreated,
    Set<Factory<OneSequenceGestureRecognizer>> gestureRecognizers,
  });
}
