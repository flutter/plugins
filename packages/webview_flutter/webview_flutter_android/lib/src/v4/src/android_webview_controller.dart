// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:math';

// TODO(a14n): remove this import once Flutter 3.1 or later reaches stable (including flutter/flutter#104231)
// ignore: unnecessary_import
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter_platform_interface/v4/webview_flutter_platform_interface.dart';

import '../../android_webview.dart' as android_webview;
import '../../android_webview.dart';
import '../../weak_reference_utils.dart';
import 'android_navigation_delegate.dart';
import 'android_proxy.dart';

// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/// Specifies possible restrictions on automatic media playback.
///
/// This is typically used in [WebView.initialMediaPlaybackPolicy].
// The method channel implementation is marshalling this enum to the value's index, so the order
// is important.
enum AutoMediaPlaybackPolicy {
  /// Starting any kind of media playback requires a user action.
  ///
  /// For example: JavaScript code cannot start playing media unless the code was executed
  /// as a result of a user action (like a touch event).
  require_user_action_for_all_media_types,

  /// Starting any kind of media playback is always allowed.
  ///
  /// For example: JavaScript code that's triggered when the page is loaded can start playing
  /// video or audio.
  always_allow,
}

/// Object specifying creation parameters for creating a [AndroidWebViewController].
///
/// When adding additional fields make sure they can be null or have a default
/// value to avoid breaking changes. See [PlatformWebViewControllerCreationParams] for
/// more information.
@immutable
class AndroidWebViewControllerCreationParams
    extends PlatformWebViewControllerCreationParams {
  /// Creates a new [AndroidWebViewControllerCreationParams] instance.
  AndroidWebViewControllerCreationParams({
    @visibleForTesting this.androidWebViewProxy = const AndroidWebViewProxy(),
    @visibleForTesting android_webview.WebStorage? androidWebStorage,
  })  : androidWebStorage =
            androidWebStorage ?? android_webview.WebStorage.instance,
        super();

  /// Creates a [AndroidWebViewControllerCreationParams] instance based on [PlatformWebViewControllerCreationParams].
  factory AndroidWebViewControllerCreationParams.fromPlatformWebViewControllerCreationParams(
    // Recommended placeholder to prevent being broken by platform interface.
    // ignore: avoid_unused_constructor_parameters
    PlatformWebViewControllerCreationParams params, {
    @visibleForTesting
        AndroidWebViewProxy androidWebViewProxy = const AndroidWebViewProxy(),
    @visibleForTesting android_webview.WebStorage? androidWebStorage,
  }) {
    return AndroidWebViewControllerCreationParams(
      androidWebViewProxy: androidWebViewProxy,
      androidWebStorage:
          androidWebStorage ?? android_webview.WebStorage.instance,
    );
  }

  /// Handles constructing objects and calling static methods for the Android WebView
  /// native library.
  @visibleForTesting
  final AndroidWebViewProxy androidWebViewProxy;

  /// Manages the JavaScript storage APIs provided by the [android_webview.WebView].
  @visibleForTesting
  final android_webview.WebStorage androidWebStorage;
}

/// Implementation of the [PlatformWebViewController] with the Android WebView API.
class AndroidWebViewController extends PlatformWebViewController {
  /// Creates a new [AndroidWebViewCookieManager].
  AndroidWebViewController(PlatformWebViewControllerCreationParams params)
      : super.implementation(params is AndroidWebViewControllerCreationParams
            ? params
            : AndroidWebViewControllerCreationParams
                .fromPlatformWebViewControllerCreationParams(params));

  AndroidWebViewControllerCreationParams get _androidWebViewParams =>
      params as AndroidWebViewControllerCreationParams;

  /// The native [android_webview.WebView] being controlled.
  late final android_webview.WebView _webView =
      _androidWebViewParams.androidWebViewProxy.createAndroidWebView(
    // Due to changes in Flutter 3.0 the `useHybridComposition` doesn't have
    // any effect and is purposefully not exposed publicly by the
    // [AndroidWebViewController]. More info here:
    // https://github.com/flutter/flutter/issues/108106
    useHybridComposition: true,
  );

  /// The native [android_webview.FlutterAssetManager] allows managing assets.
  late final android_webview.FlutterAssetManager _flutterAssetManager =
      _androidWebViewParams.androidWebViewProxy.createFlutterAssetManager();

  final Map<String, AndroidJavaScriptChannelParams> _javaScriptChannelParams =
      <String, AndroidJavaScriptChannelParams>{};

  @override
  Future<void> loadFile(
    String absoluteFilePath,
  ) {
    final String url = absoluteFilePath.startsWith('file://')
        ? absoluteFilePath
        : Uri.file(absoluteFilePath).toString();

    _webView.settings.setAllowFileAccess(true);
    return _webView.loadUrl(url, <String, String>{});
  }

  @override
  Future<void> loadFlutterAsset(
    String key,
  ) async {
    final String assetFilePath =
        await _flutterAssetManager.getAssetFilePathByName(key);
    final List<String> pathElements = assetFilePath.split('/');
    final String fileName = pathElements.removeLast();
    final List<String?> paths =
        await _flutterAssetManager.list(pathElements.join('/'));

    if (!paths.contains(fileName)) {
      throw ArgumentError(
        'Asset for key "$key" not found.',
        'key',
      );
    }

    return _webView.loadUrl(
      Uri.file('/android_asset/$assetFilePath').toString(),
      <String, String>{},
    );
  }

  @override
  Future<void> loadHtmlString(
    String html, {
    String? baseUrl,
  }) {
    return _webView.loadDataWithBaseUrl(
      baseUrl: baseUrl,
      data: html,
      mimeType: 'text/html',
    );
  }

  @override
  Future<void> loadRequest(
    LoadRequestParams params,
  ) {
    if (!params.uri.hasScheme) {
      throw ArgumentError('WebViewRequest#uri is required to have a scheme.');
    }
    switch (params.method) {
      case LoadRequestMethod.get:
        return _webView.loadUrl(params.uri.toString(), params.headers);
      case LoadRequestMethod.post:
        return _webView.postUrl(
            params.uri.toString(), params.body ?? Uint8List(0));
      default:
        throw UnimplementedError(
          'This version of `AndroidWebViewController` currently has no implementation for HTTP method ${params.method.serialize()} in loadRequest.',
        );
    }
  }

  @override
  Future<String?> currentUrl() => _webView.getUrl();

  @override
  Future<bool> canGoBack() => _webView.canGoBack();

  @override
  Future<bool> canGoForward() => _webView.canGoForward();

  @override
  Future<void> goBack() => _webView.goBack();

  @override
  Future<void> goForward() => _webView.goForward();

  @override
  Future<void> reload() => _webView.reload();

  @override
  Future<void> clearCache() => _webView.clearCache(true);

  @override
  Future<void> clearLocalStorage() =>
      _androidWebViewParams.androidWebStorage.deleteAllData();

  @override
  Future<void> setPlatformNavigationDelegate(
      covariant AndroidNavigationDelegate handler) async {
    _webView.setWebViewClient(handler.androidWebViewClient);
    _webView.setWebChromeClient(handler.androidWebChromeClient);
  }

  @override
  Future<void> runJavaScript(String javaScript) {
    return _webView.evaluateJavascript(javaScript);
  }

  @override
  Future<String> runJavaScriptReturningResult(String javaScript) async {
    return await _webView.evaluateJavascript(javaScript) ?? '';
  }

  @override
  Future<void> addJavaScriptChannel(
    JavaScriptChannelParams javaScriptChannelParams,
  ) {
    final AndroidJavaScriptChannelParams androidJavaScriptParams =
        javaScriptChannelParams is AndroidJavaScriptChannelParams
            ? javaScriptChannelParams
            : AndroidJavaScriptChannelParams.fromJavaScriptChannelParams(
                javaScriptChannelParams);

    // When JavaScript channel with the same name exists make sure to remove it
    // before registering the new channel.
    if (_javaScriptChannelParams.containsKey(androidJavaScriptParams.name)) {
      _webView
          .removeJavaScriptChannel(androidJavaScriptParams._javaScriptChannel);
    }

    _javaScriptChannelParams[androidJavaScriptParams.name] =
        androidJavaScriptParams;

    return _webView
        .addJavaScriptChannel(androidJavaScriptParams._javaScriptChannel);
  }

  @override
  Future<void> removeJavaScriptChannel(String javaScriptChannelName) async {
    final AndroidJavaScriptChannelParams? javaScriptChannelParams =
        _javaScriptChannelParams[javaScriptChannelName];
    if (javaScriptChannelParams == null) {
      return;
    }

    _javaScriptChannelParams.remove(javaScriptChannelName);
    return _webView
        .removeJavaScriptChannel(javaScriptChannelParams._javaScriptChannel);
  }

  @override
  Future<String?> getTitle() => _webView.getTitle();

  @override
  Future<void> scrollTo(int x, int y) => _webView.scrollTo(x, y);

  @override
  Future<void> scrollBy(int x, int y) => _webView.scrollBy(x, y);

  @override
  Future<Point<int>> getScrollPosition() async {
    final Offset position = await _webView.getScrollPosition();
    return Point<int>(position.dx.round(), position.dy.round());
  }

  @override
  Future<void> enableDebugging(bool enabled) =>
      _androidWebViewParams.androidWebViewProxy
          .setWebContentsDebuggingEnabled(enabled);

  /// Sets whether the DOM storage API is enabled.
  ///
  /// The default value is false.
  Future<void> enableDomStorage(bool enabled) =>
      _webView.settings.setDomStorageEnabled(enabled);

  /// Enables or disables file access within WebView.
  ///
  /// This enables or disables file system access only. Assets and resources are
  /// still accessible using file:///android_asset and file:///android_res. The
  /// default value is true for apps targeting Build.VERSION_CODES.Q and below,
  /// and false when targeting Build.VERSION_CODES.R and above.
  Future<void> enableFileAccess(bool enabled) =>
      _webView.settings.setAllowFileAccess(enabled);

  @override
  Future<void> enableZoom(bool enabled) =>
      _webView.settings.setSupportZoom(enabled);

  @override
  Future<void> setBackgroundColor(Color color) =>
      _webView.setBackgroundColor(color);

  // TODO(bparrishMines): Update documentation when ZoomButtonsController is added.
  /// Sets whether the WebView should display on-screen zoom controls when using the built-in zoom mechanisms.
  ///
  /// See [setBuiltInZoomControls]. The default is true. However, on-screen zoom
  /// controls are deprecated in Android so it's recommended to set this to
  /// false.
  Future<void> setBuiltInZoomControls(bool enabled) =>
      _webView.settings.setBuiltInZoomControls(enabled);

  // TODO(bparrishMines): Update documentation when ZoomButtonsController is added.
  /// Sets whether the WebView should use its built-in zoom mechanisms.
  ///
  /// The built-in zoom mechanisms comprise on-screen zoom controls, which are
  /// displayed over the WebView's content, and the use of a pinch gesture to
  /// control zooming. Whether or not these on-screen controls are displayed can
  /// be set with [setDisplayZoomControls]. The default is false.
  ///
  /// The built-in mechanisms are the only currently supported zoom mechanisms,
  /// so it is recommended that this setting is always enabled. However,
  /// on-screen zoom controls are deprecated in Android so it's recommended to
  /// disable [setDisplayZoomControls].
  Future<void> setDisplayZoomControls(bool enabled) =>
      _webView.settings.setDisplayZoomControls(enabled);

  /// Sets whether the WebView loads pages in overview mode, that is, zooms out the content to fit on screen by width.
  ///
  /// This setting is taken into account when the content width is greater than
  /// the width of the WebView control, for example, when [setUseWideViewPort]
  /// is enabled.
  ///
  /// The default is false.
  Future<void> setLoadWithOverviewMode(bool enabled) =>
      _webView.settings.setLoadWithOverviewMode(enabled);

  @override
  Future<void> setJavaScriptMode(JavaScriptMode javaScriptMode) =>
      _webView.settings
          .setJavaScriptEnabled(javaScriptMode == JavaScriptMode.unrestricted);

  /// Sets wether JavaScript is allowed to open windows automatically.
  ///
  /// This applies to the JavaScript function `window.open()`. The default is
  /// false.
  Future<void> setJavaScriptCanOpenWindowsAutomatically(bool enabled) =>
      _webView.settings.setJavaScriptCanOpenWindowsAutomatically(enabled);

  // TODO(bparrishMines): Update documentation when WebChromeClient.onCreateWindow is added.
  /// Sets whether the WebView should supports multiple windows.
  ///
  /// The default is false.
  Future<void> setSupportMultipleWindows(bool support) =>
      _webView.settings.setSupportMultipleWindows(support);

  /// Sets whether the WebView should enable support for the "viewport" HTML meta tag or should use a wide viewport.
  ///
  /// When the value of the setting is false, the layout width is always set to
  /// the width of the WebView control in device-independent (CSS) pixels. When
  /// the value is true and the page contains the viewport meta tag, the value
  /// of the width specified in the tag is used. If the page does not contain
  /// the tag or does not provide a width, then a wide viewport will be used.
  Future<void> setUseWideViewPort(bool enabled) =>
      _webView.settings.setUseWideViewPort(enabled);

  @override
  Future<void> setUserAgent(String? userAgent) =>
      _webView.settings.setUserAgentString(userAgent);

  /// Sets the restrictions that apply on automatic media playback.
  Future<void> setAutoMediaPlaybackPolicy(
      AutoMediaPlaybackPolicy autoMediaPlaybackPolicy) {
    return _webView.settings.setMediaPlaybackRequiresUserGesture(
        autoMediaPlaybackPolicy != AutoMediaPlaybackPolicy.always_allow);
  }
}

/// An implementation of [JavaScriptChannelParams] with the Android WebView API.
///
/// See [AndroidWebViewController.addJavaScriptChannel].
@immutable
class AndroidJavaScriptChannelParams extends JavaScriptChannelParams {
  /// Constructs a [AndroidJavaScriptChannelParams].
  AndroidJavaScriptChannelParams({
    required super.name,
    required super.onMessageReceived,
    @visibleForTesting
        AndroidWebViewProxy webViewProxy = const AndroidWebViewProxy(),
  })  : assert(name.isNotEmpty),
        _javaScriptChannel = webViewProxy.createJavaScriptChannel(
          name,
          postMessage: withWeakRefenceTo(
            onMessageReceived,
            (WeakReference<void Function(JavaScriptMessage)> weakReference) {
              return (
                String message,
              ) {
                if (weakReference.target != null) {
                  weakReference.target!(
                    JavaScriptMessage(message: message),
                  );
                }
              };
            },
          ),
        );

  /// Constructs a [AndroidJavaScriptChannelParams] using a
  /// [JavaScriptChannelParams].
  AndroidJavaScriptChannelParams.fromJavaScriptChannelParams(
    JavaScriptChannelParams params, {
    @visibleForTesting
        AndroidWebViewProxy webViewProxy = const AndroidWebViewProxy(),
  }) : this(
          name: params.name,
          onMessageReceived: params.onMessageReceived,
          webViewProxy: webViewProxy,
        );

  final android_webview.JavaScriptChannel _javaScriptChannel;
}
