// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';

import 'webview_flutter.dart';

/// Interface for callbacks made by [WebViewPlatformController].
///
/// The webview plugin implements this class, and passes an instance to the [WebViewPlatformController].
/// [WebViewPlatformController] is notifying this handler on events that happened on the platform's webview.
abstract class WebViewPlatformCallbacksHandler {
  /// Invoked by [WebViewPlatformController] when a JavaScript channel message is received.
  void onJavaScriptChannelMessage(String channel, String message);

  /// Invoked by [WebViewPlatformController] when a navigation request is pending.
  ///
  /// If true is returned the navigation is allowed, otherwise it is blocked.
  FutureOr<bool> onNavigationRequest({String url, bool isForMainFrame});

  /// Invoked by [WebViewPlatformController] when a page has started loading.
  void onPageStarted(String url);

  /// Invoked by [WebViewPlatformController] when a page has finished loading.
  void onPageFinished(String url);
}

/// Interface for talking to the webview's platform implementation.
///
/// An instance implementing this interface is passed to the `onWebViewPlatformCreated` callback that is
/// passed to [WebViewPlatformBuilder#onWebViewPlatformCreated].
///
/// Platform implementations that live in a separate package should extend this class rather than
/// implement it as webview_flutter does not consider newly added methods to be breaking changes.
/// Extending this class (using `extends`) ensures that the subclass will get the default
/// implementation, while platform implementations that `implements` this interface will be broken
/// by newly added [WebViewPlatformController] methods.
abstract class WebViewPlatformController {
  /// Creates a new WebViewPlatform.
  ///
  /// Callbacks made by the WebView will be delegated to `handler`.
  ///
  /// The `handler` parameter must not be null.
  WebViewPlatformController(WebViewPlatformCallbacksHandler handler);

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

  /// Accessor to the current URL that the WebView is displaying.
  ///
  /// If no URL was ever loaded, returns `null`.
  Future<String> currentUrl() {
    throw UnimplementedError(
        "WebView currentUrl is not implemented on the current platform");
  }

  /// Checks whether there's a back history item.
  Future<bool> canGoBack() {
    throw UnimplementedError(
        "WebView canGoBack is not implemented on the current platform");
  }

  /// Checks whether there's a forward history item.
  Future<bool> canGoForward() {
    throw UnimplementedError(
        "WebView canGoForward is not implemented on the current platform");
  }

  /// Goes back in the history of this WebView.
  ///
  /// If there is no back history item this is a no-op.
  Future<void> goBack() {
    throw UnimplementedError(
        "WebView goBack is not implemented on the current platform");
  }

  /// Goes forward in the history of this WebView.
  ///
  /// If there is no forward history item this is a no-op.
  Future<void> goForward() {
    throw UnimplementedError(
        "WebView goForward is not implemented on the current platform");
  }

  /// Reloads the current URL.
  Future<void> reload() {
    throw UnimplementedError(
        "WebView reload is not implemented on the current platform");
  }

  /// Clears all caches used by the [WebView].
  ///
  /// The following caches are cleared:
  ///	1. Browser HTTP Cache.
  ///	2. [Cache API](https://developers.google.com/web/fundamentals/instant-and-offline/web-storage/cache-api) caches.
  ///    These are not yet supported in iOS WkWebView. Service workers tend to use this cache.
  ///	3. Application cache.
  ///	4. Local Storage.
  Future<void> clearCache() {
    throw UnimplementedError(
        "WebView clearCache is not implemented on the current platform");
  }

  /// Evaluates a JavaScript expression in the context of the current page.
  ///
  /// The Future completes with an error if a JavaScript error occurred, or if the type of the
  /// evaluated expression is not supported(e.g on iOS not all non primitive type can be evaluated).
  Future<String> evaluateJavascript(String javascriptString) {
    throw UnimplementedError(
        "WebView evaluateJavascript is not implemented on the current platform");
  }

  /// Adds new JavaScript channels to the set of enabled channels.
  ///
  /// For each value in this list the platform's webview should make sure that a corresponding
  /// property with a postMessage method is set on `window`. For example for a JavaScript channel
  /// named `Foo` it should be possible for JavaScript code executing in the webview to do
  ///
  /// ```javascript
  /// Foo.postMessage('hello');
  /// ```
  ///
  /// See also: [CreationParams.javascriptChannelNames].
  Future<void> addJavascriptChannels(Set<String> javascriptChannelNames) {
    throw UnimplementedError(
        "WebView addJavascriptChannels is not implemented on the current platform");
  }

  /// Removes JavaScript channel names from the set of enabled channels.
  ///
  /// This disables channels that were previously enabled by [addJavaScriptChannels] or through
  /// [CreationParams.javascriptChannelNames].
  Future<void> removeJavascriptChannels(Set<String> javascriptChannelNames) {
    throw UnimplementedError(
        "WebView removeJavascriptChannels is not implemented on the current platform");
  }

  /// Returns the title of the currently loaded page.
  Future<String> getTitle() {
    throw UnimplementedError(
        "WebView getTitle is not implemented on the current platform");
  }
}

/// A single setting for configuring a WebViewPlatform which may be absent.
class WebSetting<T> {
  /// Constructs an absent setting instance.
  ///
  /// The [isPresent] field for the instance will be false.
  ///
  /// Accessing [value] for an absent instance will throw.
  WebSetting.absent()
      : _value = null,
        isPresent = false;

  /// Constructs a setting of the given `value`.
  ///
  /// The [isPresent] field for the instance will be true.
  WebSetting.of(T value)
      : _value = value,
        isPresent = true;

  final T _value;

  /// The setting's value.
  ///
  /// Throws if [WebSetting.isPresent] is false.
  T get value {
    if (!isPresent) {
      throw StateError('Cannot access a value of an absent WebSetting');
    }
    assert(isPresent);
    return _value;
  }

  /// True when this web setting instance contains a value.
  ///
  /// When false the [WebSetting.value] getter throws.
  final bool isPresent;

  @override
  bool operator ==(Object other) {
    if (other.runtimeType != runtimeType) return false;
    final WebSetting<T> typedOther = other;
    return typedOther.isPresent == isPresent && typedOther._value == _value;
  }

  @override
  int get hashCode => hashValues(_value, isPresent);
}

/// Settings for configuring a WebViewPlatform.
///
/// Initial settings are passed as part of [CreationParams], settings updates are sent with
/// [WebViewPlatform#updateSettings].
///
/// The `userAgent` parameter must not be null.
class WebSettings {
  /// Construct an instance with initial settings. Future setting changes can be
  /// sent with [WebviewPlatform#updateSettings].
  ///
  /// The `userAgent` parameter must not be null.
  WebSettings({
    this.javascriptMode,
    this.hasNavigationDelegate,
    this.debuggingEnabled,
    this.gestureNavigationEnabled,
    @required this.userAgent,
  }) : assert(userAgent != null);

  /// The JavaScript execution mode to be used by the webview.
  final JavascriptMode javascriptMode;

  /// Whether the [WebView] has a [NavigationDelegate] set.
  final bool hasNavigationDelegate;

  /// Whether to enable the platform's webview content debugging tools.
  ///
  /// See also: [WebView.debuggingEnabled].
  final bool debuggingEnabled;

  /// The value used for the HTTP `User-Agent:` request header.
  ///
  /// If [userAgent.value] is null the platform's default user agent should be used.
  ///
  /// An absent value ([userAgent.isPresent] is false) represents no change to this setting from the
  /// last time it was set.
  ///
  /// See also [WebView.userAgent].
  final WebSetting<String> userAgent;

  /// Whether to allow swipe based navigation in iOS.
  ///
  /// See also: [WebView.gestureNavigationEnabled]
  final bool gestureNavigationEnabled;

  @override
  String toString() {
    return 'WebSettings(javascriptMode: $javascriptMode, hasNavigationDelegate: $hasNavigationDelegate, debuggingEnabled: $debuggingEnabled, gestureNavigationEnabled: $gestureNavigationEnabled, userAgent: $userAgent)';
  }
}

/// Configuration to use when creating a new [WebViewPlatformController].
///
/// The `autoMediaPlaybackPolicy` parameter must not be null.
class CreationParams {
  /// Constructs an instance to use when creating a new
  /// [WebViewPlatformController].
  ///
  /// The `autoMediaPlaybackPolicy` parameter must not be null.
  CreationParams({
    this.initialUrl,
    this.webSettings,
    this.javascriptChannelNames,
    this.userAgent,
    this.autoMediaPlaybackPolicy =
        AutoMediaPlaybackPolicy.require_user_action_for_all_media_types,
  }) : assert(autoMediaPlaybackPolicy != null);

  /// The initialUrl to load in the webview.
  ///
  /// When null the webview will be created without loading any page.
  final String initialUrl;

  /// The initial [WebSettings] for the new webview.
  ///
  /// This can later be updated with [WebViewPlatformController.updateSettings].
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

  /// The value used for the HTTP User-Agent: request header.
  ///
  /// When null the platform's webview default is used for the User-Agent header.
  final String userAgent;

  /// Which restrictions apply on automatic media playback.
  final AutoMediaPlaybackPolicy autoMediaPlaybackPolicy;

  @override
  String toString() {
    return '$runtimeType(initialUrl: $initialUrl, settings: $webSettings, javascriptChannelNames: $javascriptChannelNames, UserAgent: $userAgent)';
  }
}

typedef WebViewPlatformCreatedCallback = void Function(
    WebViewPlatformController webViewPlatformController);

/// Interface for a platform implementation of a WebView.
///
/// [WebView.platform] controls the builder that is used by [WebView].
/// [AndroidWebViewPlatform] and [CupertinoWebViewPlatform] are the default implementations
/// for Android and iOS respectively.
abstract class WebViewPlatform {
  /// Builds a new WebView.
  ///
  /// Returns a Widget tree that embeds the created webview.
  ///
  /// `creationParams` are the initial parameters used to setup the webview.
  ///
  /// `webViewPlatformHandler` will be used for handling callbacks that are made by the created
  /// [WebViewPlatformController].
  ///
  /// `onWebViewPlatformCreated` will be invoked after the platform specific [WebViewPlatformController]
  /// implementation is created with the [WebViewPlatformController] instance as a parameter.
  ///
  /// `gestureRecognizers` specifies which gestures should be consumed by the web view.
  /// It is possible for other gesture recognizers to be competing with the web view on pointer
  /// events, e.g if the web view is inside a [ListView] the [ListView] will want to handle
  /// vertical drags. The web view will claim gestures that are recognized by any of the
  /// recognizers on this list.
  /// When `gestureRecognizers` is empty or null, the web view will only handle pointer events for gestures that
  /// were not claimed by any other gesture recognizer.
  ///
  /// `webViewPlatformHandler` must not be null.
  Widget build({
    BuildContext context,
    // TODO(amirh): convert this to be the actual parameters.
    // I'm starting without it as the PR is starting to become pretty big.
    // I'll followup with the conversion PR.
    CreationParams creationParams,
    @required WebViewPlatformCallbacksHandler webViewPlatformCallbacksHandler,
    WebViewPlatformCreatedCallback onWebViewPlatformCreated,
    Set<Factory<OneSequenceGestureRecognizer>> gestureRecognizers,
  });

  /// Clears all cookies for all [WebView] instances.
  ///
  /// Returns true if cookies were present before clearing, else false.
  Future<bool> clearCookies() {
    throw UnimplementedError(
        "WebView clearCookies is not implemented on the current platform");
  }
}
