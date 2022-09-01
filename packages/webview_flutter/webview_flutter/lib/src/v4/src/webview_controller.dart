// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:math';

// TODO(a14n): remove this import once Flutter 3.1 or later reaches stable (including flutter/flutter#104231)
// ignore: unnecessary_import
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:webview_flutter_platform_interface/v4/webview_flutter_platform_interface.dart';

/// Controls a WebView provided by the host platform.
///
/// Pass this to a [WebViewWidget] to display the WebView.
class WebViewController {
  /// Constructs a [WebViewController].
  WebViewController()
      : this.fromPlatformCreationParams(
          const PlatformWebViewControllerCreationParams(),
        );

  /// Constructs a [WebViewController] from creation params for a specific
  /// platform.
  WebViewController.fromPlatformCreationParams(
    PlatformWebViewControllerCreationParams params,
  ) : this.fromPlatform(PlatformWebViewController(params));

  /// Constructs a [WebViewController] from a specific platform implementation.
  WebViewController.fromPlatform(this.platform);

  /// Implementation of [PlatformWebViewController] for the current platform.
  final PlatformWebViewController platform;

  /// Loads the file located on the specified [absoluteFilePath].
  ///
  /// The [absoluteFilePath] parameter should contain the absolute path to the
  /// file as it is stored on the device. For example:
  /// `/Users/username/Documents/www/index.html`.
  ///
  /// Throws a `PlatformException` if the [absoluteFilePath] does not exist.
  Future<void> loadFile(String absoluteFilePath) {
    return platform.loadFile(absoluteFilePath);
  }

  /// Loads the Flutter asset specified in the pubspec.yaml file.
  ///
  /// Throws a `PlatformException` if [key] is not part of the specified assets
  /// in the pubspec.yaml file.
  Future<void> loadFlutterAsset(String key) {
    assert(key.isNotEmpty);
    return platform.loadFlutterAsset(key);
  }

  /// Loads the supplied HTML string.
  ///
  /// The [baseUrl] parameter is used when resolving relative URLs within the
  /// HTML string.
  Future<void> loadHtmlString(String html, {String? baseUrl}) {
    assert(html.isNotEmpty);
    return platform.loadHtmlString(html, baseUrl: baseUrl);
  }

  /// Makes a specific HTTP request ands loads the response in the webview.
  ///
  /// [method] must be one of the supported HTTP methods in [LoadRequestMethod].
  ///
  /// If [headers] is not empty, its key-value pairs will be added as the
  /// headers for the request.
  ///
  /// If [body] is not null, it will be added as the body for the request.
  ///
  /// Throws an ArgumentError if [uri] has an empty scheme.
  Future<void> loadRequest(
    Uri uri, {
    LoadRequestMethod method = LoadRequestMethod.get,
    Map<String, String> headers = const <String, String>{},
    Uint8List? body,
  }) {
    if (uri.scheme.isEmpty) {
      throw ArgumentError('Missing scheme in uri: $uri');
    }
    return platform.loadRequest(LoadRequestParams(
      uri: uri,
      method: method,
      headers: headers,
      body: body,
    ));
  }

  /// Returns the current URL that the WebView is displaying.
  ///
  /// If no URL was ever loaded, returns `null`.
  Future<String?> currentUrl() {
    return platform.currentUrl();
  }

  /// Checks whether there's a back history item.
  Future<bool> canGoBack() {
    return platform.canGoBack();
  }

  /// Checks whether there's a forward history item.
  Future<bool> canGoForward() {
    return platform.canGoForward();
  }

  /// Goes back in the history of this WebView.
  ///
  /// If there is no back history item this is a no-op.
  Future<void> goBack() {
    return platform.goBack();
  }

  /// Goes forward in the history of this WebView.
  ///
  /// If there is no forward history item this is a no-op.
  Future<void> goForward() {
    return platform.goForward();
  }

  /// Reloads the current URL.
  Future<void> reload() {
    return platform.reload();
  }

  /// Clears all caches used by the WebView.
  ///
  /// The following caches are cleared:
  ///	1. Browser HTTP Cache.
  ///	2. [Cache API](https://developers.google.com/web/fundamentals/instant-and-offline/web-storage/cache-api)
  ///    caches. Service workers tend to use this cache.
  ///	3. Application cache.
  Future<void> clearCache() {
    return platform.clearCache();
  }

  /// Clears the local storage used by the WebView.
  Future<void> clearLocalStorage() {
    return platform.clearLocalStorage();
  }

  /// Runs the given JavaScript in the context of the current page.
  ///
  /// The Future completes with an error if a JavaScript error occurred.
  Future<void> runJavaScript(String javaScript) {
    return platform.runJavaScript(javaScript);
  }

  /// Runs the given JavaScript in the context of the current page, and returns
  /// the result.
  ///
  /// The Future completes with an error if a JavaScript error occurred, or if
  /// the type the given expression evaluates to is unsupported. Unsupported
  /// values include certain non-primitive types on iOS, as well as `undefined`
  /// or `null` on iOS 14+.
  Future<Object> runJavaScriptReturningResult(String javaScript) {
    return platform.runJavaScriptReturningResult(javaScript);
  }

  /// Adds a new JavaScript channel to the set of enabled channels.
  ///
  /// The JavaScript code can then call `postMessage` on that object to send a
  /// message that will be passed to [onMessageReceived].
  ///
  /// For example, after adding the following JavaScript channel:
  ///
  /// ```dart
  /// final WebViewController controller = WebViewController();
  /// controller.addJavaScriptChannel(
  ///   name: 'Print',
  ///   onMessageReceived: (JavascriptMessage message) {
  ///     print(message.message);
  ///   },
  /// );
  /// ```
  ///
  /// JavaScript code can call:
  ///
  /// ```javascript
  /// Print.postMessage('Hello');
  /// ```
  ///
  /// to asynchronously invoke the message handler which will print the message
  /// to standard output.
  ///
  /// Adding a new JavaScript channel only takes affect after the next page is
  /// loaded.
  ///
  /// A channel [name] cannot be the same for multiple channels.
  Future<void> addJavaScriptChannel(
    String name, {
    required void Function(JavaScriptMessage) onMessageReceived,
  }) {
    assert(name.isNotEmpty);
    return platform.addJavaScriptChannel(JavaScriptChannelParams(
      name: name,
      onMessageReceived: onMessageReceived,
    ));
  }

  /// Removes the JavaScript channel with the matching name from the set of
  /// enabled channels.
  ///
  /// This disables the channel with the matching name if it was previously
  /// enabled through the [addJavaScriptChannel].
  Future<void> removeJavaScriptChannel(String javaScriptChannelName) {
    return platform.removeJavaScriptChannel(javaScriptChannelName);
  }

  /// The title of the currently loaded page.
  Future<String?> getTitle() {
    return platform.getTitle();
  }

  /// Sets the scrolled position of this view.
  ///
  /// The parameters `x` and `y` specify the position to scroll to in WebView
  /// pixels.
  Future<void> scrollTo(int x, int y) {
    return platform.scrollTo(x, y);
  }

  /// Moves the scrolled position of this view.
  ///
  /// The parameters `x` and `y` specify the amount of WebView pixels to scroll
  /// by.
  Future<void> scrollBy(int x, int y) {
    return platform.scrollBy(x, y);
  }

  /// Returns the current scroll position of this view.
  ///
  /// Scroll position is measured from the top left.
  Future<Offset> getScrollPosition() async {
    final Point<int> position = await platform.getScrollPosition();
    return Offset(position.x.toDouble(), position.y.toDouble());
  }

  /// Whether to support zooming using the on-screen zoom controls and gestures.
  Future<void> enableZoom(bool enabled) {
    return platform.enableZoom(enabled);
  }

  /// Sets the current background color of this view.
  Future<void> setBackgroundColor(Color color) {
    return platform.setBackgroundColor(color);
  }

  /// Sets the JavaScript execution mode to be used by the WebView.
  Future<void> setJavaScriptMode(JavaScriptMode javaScriptMode) {
    return platform.setJavaScriptMode(javaScriptMode);
  }

  /// Sets the value used for the HTTP `User-Agent:` request header.
  Future<void> setUserAgent(String? userAgent) {
    return platform.setUserAgent(userAgent);
  }
}
