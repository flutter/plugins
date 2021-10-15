// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'android_webview_api_impls.dart';
import 'instance_manager.dart';

// TODO: This can be removed once pigeon supports null values.
// Workaround since pigeon doesn't support null values.
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
  int get _instanceId => InstanceManager.instance.getInstanceId(this)!;

  final bool useHybridComposition;

  /// Loads the given URL with additional HTTP headers, specified as a map from name to value.
  ///
  /// Note that if this map contains any of the headers that are set by default
  /// by this WebView, such as those controlling caching, accept types or the
  /// User-Agent, their values may be overridden by this WebView's defaults.
  ///
  /// Also see compatibility note on [evaluateJavascript].
  Future<void> loadUrl(String url, Map<String, String> headers) {
    return _api.loadUrl(_instanceId, url, headers);
  }

  /// Gets the URL for the current page.
  ///
  /// This is not always the same as the URL passed to
  /// [WebViewClient.onPageStarted] because although the load for that URL has
  /// begun, the current page may not have changed.
  ///
  /// Returns null if no page has been loaded.
  Future<String?> getUrl() async {
    final String result = await _api.getUrl(_instanceId);
    if (result == _nullStringIdentifier) return null;
    return result;
  }

  /// Whether this WebView has a back history item.
  Future<bool> canGoBack() {
    return _api.canGoBack(_instanceId);
  }

  /// Whether this WebView has a forward history item.
  Future<bool> canGoForward() {
    return _api.canGoForward(_instanceId);
  }

  /// Goes back in the history of this WebView.
  Future<void> goBack() {
    return _api.goBack(_instanceId);
  }

  /// Goes forward in the history of this WebView.
  Future<void> goForward() {
    return _api.goForward(_instanceId);
  }

  /// Reloads the current URL.
  Future<void> reload() {
    return _api.reload(_instanceId);
  }

  /// Clears the resource cache.
  ///
  /// Note that the cache is per-application, so this will clear the cache for
  /// all WebViews used.
  Future<void> clearCache(bool includeDiskFiles) {
    return _api.clearCache(_instanceId, includeDiskFiles);
  }

  // TODO: Update documentation once addJavascriptInterface is added.
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
    final String result = await _api.evaluateJavascript(
      _instanceId,
      javascriptString,
    );
    if (result == _nullStringIdentifier) return null;
    return result;
  }

  // TODO: Update documentation when WebViewClient.onReceivedTitle is added.
  /// Gets the title for the current page.
  ///
  /// Returns null if no page has been loaded.
  Future<String?> getTitle() async {
    final String result = await _api.getTitle(_instanceId);
    if (result == _nullStringIdentifier) return null;
    return result;
  }

  // TODO: Update documentation when onScrollChanged is added.
  /// Set the scrolled position of your view.
  Future<void> scrollTo(int x, int y) {
    return _api.scrollTo(_instanceId, x, y);
  }

  // TODO: Update documentation when onScrollChanged is added.
  /// Move the scrolled position of your view.
  Future<void> scrollBy(int x, int y) {
    return _api.scrollBy(_instanceId, x, y);
  }

  /// Return the scrolled left position of this view.
  ///
  /// This is the left edge of the displayed part of your view. You do not
  /// need to draw any pixels farther left, since those are outside of the frame
  /// of your view on screen.
  Future<int> getScrollX() {
    return _api.getScrollX(_instanceId);
  }

  /// Return the scrolled top position of this view.
  ///
  /// This is the top edge of the displayed part of your view. You do not need
  /// to draw any pixels above it, since those are outside of the frame of your
  /// view on screen.
  Future<int> getScrollY() {
    return _api.getScrollY(_instanceId);
  }
}
