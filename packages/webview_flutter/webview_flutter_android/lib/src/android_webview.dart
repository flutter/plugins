// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/widgets.dart' show AndroidViewSurface;

import 'android_webview_api_impls.dart';

// TODO(bparrishMines): This can be removed once pigeon supports null values.
// Workaround to represent null Strings since pigeon doesn't support null
// values.
const String _nullStringIdentifier = '<null-value>';

/// An Android View that displays web pages.
///
/// **Basic usage**
/// In most cases, we recommend using a standard web browser, like Chrome, to
/// deliver content to the user. To learn more about web browsers, read the
/// guide on invoking a browser with
/// [url_launcher](https://pub.dev/packages/url_launcher).
///
/// WebView objects allow you to display web content as part of your wiget
/// layout, but lack some of the features of fully-developed browsers. A WebView
/// is useful when you need increased control over the UI and advanced
/// configuration options that will allow you to embed web pages in a
/// specially-designed environment for your app.
///
/// To learn more about WebView and alternatives for serving web content, read
/// the documentation on
/// [Web-based content](https://developer.android.com/guide/webapps).
class WebView {
  /// Constructs a new WebView.
  WebView({this.useHybridComposition = false}) {
    _api.createFromInstance(this, useHybridComposition);
  }

  static final WebViewHostApiImpl _api = WebViewHostApiImpl();

  /// Whether the [WebView] will be rendered with an [AndroidViewSurface].
  ///
  /// This implementation uses hybrid composition to render the WebView Widget.
  /// This comes at the cost of some performance on Android versions below 10.
  /// See
  /// https://flutter.dev/docs/development/platform-integration/platform-views#performance
  /// for more information.
  ///
  /// Defaults to false.
  final bool useHybridComposition;

  late final WebViewSettings webViewSettings = WebViewSettings._(this);

  static Future<void> setWebContentsDebuggingEnabled(bool enabled) {
    return _api.setWebContentsDebuggingEnabled(enabled);
  }

  /// Loads the given URL with additional HTTP headers, specified as a map from name to value.
  ///
  /// Note that if this map contains any of the headers that are set by default
  /// by this WebView, such as those controlling caching, accept types or the
  /// User-Agent, their values may be overridden by this WebView's defaults.
  ///
  /// Also see compatibility note on [evaluateJavascript].
  Future<void> loadUrl(String url, Map<String, String> headers) {
    return _api.loadUrlFromInstance(this, url, headers);
  }

  /// Gets the URL for the current page.
  ///
  /// This is not always the same as the URL passed to
  /// [WebViewClient.onPageStarted] because although the load for that URL has
  /// begun, the current page may not have changed.
  ///
  /// Returns null if no page has been loaded.
  Future<String?> getUrl() async {
    final String result = await _api.getUrlFromInstance(this);
    if (result == _nullStringIdentifier) return null;
    return result;
  }

  /// Whether this WebView has a back history item.
  Future<bool> canGoBack() {
    return _api.canGoBackFromInstance(this);
  }

  /// Whether this WebView has a forward history item.
  Future<bool> canGoForward() {
    return _api.canGoForwardFromInstance(this);
  }

  /// Goes back in the history of this WebView.
  Future<void> goBack() {
    return _api.goBackFromInstance(this);
  }

  /// Goes forward in the history of this WebView.
  Future<void> goForward() {
    return _api.goForwardFromInstance(this);
  }

  /// Reloads the current URL.
  Future<void> reload() {
    return _api.reloadFromInstance(this);
  }

  /// Clears the resource cache.
  ///
  /// Note that the cache is per-application, so this will clear the cache for
  /// all WebViews used.
  Future<void> clearCache(bool includeDiskFiles) {
    return _api.clearCacheFromInstance(this, includeDiskFiles);
  }

  // TODO(bparrishMines): Update documentation once addJavascriptInterface is added.
  /// Asynchronously evaluates JavaScript in the context of the currently displayed page.
  ///
  /// If non-null, the returned value will be any result returned from that
  /// execution.
  ///
  /// Compatibility note. Applications targeting Android versions N or later,
  /// JavaScript state from an empty WebView is no longer persisted across
  /// navigations like [loadUrl]. For example, global variables and functions
  /// defined before calling [loadUrl]) will not exist in the loaded page.
  Future<String?> evaluateJavascript(String javascriptString) async {
    final String result = await _api.evaluateJavascriptFromInstance(
      this,
      javascriptString,
    );
    if (result == _nullStringIdentifier) return null;
    return result;
  }

  // TODO(bparrishMines): Update documentation when WebViewClient.onReceivedTitle is added.
  /// Gets the title for the current page.
  ///
  /// Returns null if no page has been loaded.
  Future<String?> getTitle() async {
    final String result = await _api.getTitleFromInstance(this);
    if (result == _nullStringIdentifier) return null;
    return result;
  }

  // TODO(bparrishMines): Update documentation when onScrollChanged is added.
  /// Set the scrolled position of your view.
  Future<void> scrollTo(int x, int y) {
    return _api.scrollToFromInstance(this, x, y);
  }

  // TODO(bparrishMines): Update documentation when onScrollChanged is added.
  /// Move the scrolled position of your view.
  Future<void> scrollBy(int x, int y) {
    return _api.scrollByFromInstance(this, x, y);
  }

  /// Return the scrolled left position of this view.
  ///
  /// This is the left edge of the displayed part of your view. You do not
  /// need to draw any pixels farther left, since those are outside of the frame
  /// of your view on screen.
  Future<int> getScrollX() {
    return _api.getScrollXFromInstance(this);
  }

  /// Return the scrolled top position of this view.
  ///
  /// This is the top edge of the displayed part of your view. You do not need
  /// to draw any pixels above it, since those are outside of the frame of your
  /// view on screen.
  Future<int> getScrollY() {
    return _api.getScrollYFromInstance(this);
  }
}

class WebViewSettings {
  WebViewSettings._(WebView webView) {
    _api.createFromInstance(this, webView);
  }

  static final WebViewSettingsHostApiImpl _api = WebViewSettingsHostApiImpl();
}

abstract class JavaScriptChannel {
  JavaScriptChannel(this.channelName);

  final String channelName;

  void postMessage(String message);
}

abstract class WebViewClient {
  void onPageStarted(WebView webView, String url);

  void onPageFinished(WebView webView, String url);

  void onReceivedRequestError(
    WebView webView,
    WebResourceRequest request,
    WebResourceError error,
  );

  void onReceivedError(
    WebView webView,
    int errorCode,
    String description,
    String failingUrl,
  );

  void shouldOverrideRequestLoading(
    WebView webView,
    WebResourceRequest request,
  );

  void shouldOverrideUrlLoading(
    WebView webView,
    String url,
  );
}

abstract class DownloadListener {
  void onDownloadStart(
    String url,
    String userAgent,
    String contentDisposition,
    String mimetype,
    int contentLength,
  );
}

class WebResourceRequest {
  WebResourceRequest({
    required this.url,
    required this.isForMainFrame,
    required this.isRedirect,
    required this.hasGesture,
    required this.method,
    required this.requestHeaders,
  });

  final String url;
  final isForMainFrame;
  final bool? isRedirect;
  final bool hasGesture;
  final String method;
  final Map<String, String> requestHeaders;
}

class WebResourceError {
  WebResourceError({
    required this.errorCode,
    required this.description,
  });

  final int errorCode;
  final String description;
}
