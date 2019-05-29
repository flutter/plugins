// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';

import 'webview_flutter.dart';

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

  /// Updates the webview settings.
  ///
  /// Any non null field in `settings` will be set as the new setting value.
  /// All null fields in `settings` are ignored.
  Future<void> updateSettings(WebSettings setting) {
    throw UnimplementedError(
        "WebView updateSettings is not implemented on the current platform");
  }

  // As the PR currently focus about the wiring I've only moved loadUrl to the new way, so
  // the discussion is more focused.
  // In this temporary state WebViewController still uses a method channel directly for all other
  // method calls so we need to expose the webview ID.
  // TODO(amirh): remove this before publishing this package.
  int get id;
}

/// Settings for configuring a WebViewPlatform.
///
/// Initial settings are passed as part of [CreationParams], settings updates are sent with
/// [WebViewPlatform#updateSettings].
class WebSettings {
  WebSettings({
    this.javascriptMode,
    this.hasNavigationDelegate,
    this.debuggingEnabled,
  });

  /// The JavaScript execution mode to be used by the webview.
  final JavascriptMode javascriptMode;

  /// Whether the [WebView] has a [NavigationDelegate] set.
  final bool hasNavigationDelegate;

  /// Whether to enable the platform's webview content debugging tools.
  ///
  /// See also: [WebView.debuggingEnabled].
  final bool debuggingEnabled;

  @override
  String toString() {
    return 'WebSettings(javascriptMode: $javascriptMode, hasNavigationDelegate: $hasNavigationDelegate, debuggingEnabled: $debuggingEnabled)';
  }
}

/// Configuration to use when creating a new [WebViewPlatform].
class CreationParams {
  CreationParams(
      {this.initialUrl, this.webSettings, this.javascriptChannelNames});

  /// The initialUrl to load in the webview.
  ///
  /// When null the webview will be created without loading any page.
  final String initialUrl;

  /// The initial [WebSettings] for the new webview.
  ///
  /// This can later be updated with [WebViewPlatform.updateSettings].
  final WebSettings webSettings;

  /// The initial set of JavaScript channels that are configured for this webview.
  ///
  /// For each value in this set the platform's webview should make sure that a corresponding
  /// property with a postMessage method is set on `window`. For example for a JavaScript channel
  /// named `Foo` it should be possible for JavaScript code executing in the webview to do
  ///
  /// ```javascript
  /// Foo.postMessage('hello');
  /// ```
  // TODO(amirh): describe what should happen when postMessage is called once that code is migrated
  // to PlatformWebView.
  final Set<String> javascriptChannelNames;

  @override
  String toString() {
    return '$runtimeType(initialUrl: $initialUrl, settings: $webSettings, javascriptChannelNames: $javascriptChannelNames)';
  }
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
    CreationParams creationParams,
    WebViewPlatformCreatedCallback onWebViewPlatformCreated,
    Set<Factory<OneSequenceGestureRecognizer>> gestureRecognizers,
  });
}
