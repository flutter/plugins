// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as path;
import 'package:webview_flutter_platform_interface/v4/webview_flutter_platform_interface.dart';

import '../../common/weak_reference_utils.dart';
import '../../foundation/foundation.dart';
import '../../web_kit/web_kit.dart';
import 'webkit_proxy.dart';

/// Object specifying creation parameters for a [WebKitWebViewController].
@immutable
class WebKitWebViewControllerCreationParams
    extends PlatformWebViewControllerCreationParams {
  /// Constructs a [WebKitWebViewControllerCreationParams].
  WebKitWebViewControllerCreationParams({
    @visibleForTesting WebKitProxy webKitProxy = const WebKitProxy(),
  }) : _configuration = webKitProxy.createWebViewConfiguration();

  /// Constructs a [WebKitWebViewControllerCreationParams] using a
  /// [PlatformWebViewControllerCreationParams].
  WebKitWebViewControllerCreationParams.fromPlatformWebViewControllerCreationParams(
    // Recommended placeholder to prevent being broken by platform interface.
    // ignore: avoid_unused_constructor_parameters
    PlatformWebViewControllerCreationParams params, {
    @visibleForTesting WebKitProxy webKitProxy = const WebKitProxy(),
  }) : this(webKitProxy: webKitProxy);

  final WKWebViewConfiguration _configuration;
}

/// An implementation of [PlatformWebViewController] with the WebKit api.
class WebKitWebViewController extends PlatformWebViewController {
  /// Constructs a [WebKitWebViewController].
  WebKitWebViewController(
    PlatformWebViewControllerCreationParams params, {
    @visibleForTesting WebKitProxy webKitProxy = const WebKitProxy(),
  }) : super.implementation(params is WebKitWebViewControllerCreationParams
            ? params
            : WebKitWebViewControllerCreationParams
                .fromPlatformWebViewControllerCreationParams(params)) {
    _webView = webKitProxy.createWebView(
        (params as WebKitWebViewControllerCreationParams)._configuration);
  }

  late final WKWebView _webView;

  final Map<String, WebKitJavaScriptChannelParams> _javaScriptChannelParams =
      <String, WebKitJavaScriptChannelParams>{};

  bool _zoomEnabled = true;

  @override
  Future<void> loadFile(String absoluteFilePath) {
    return _webView.loadFileUrl(
      absoluteFilePath,
      readAccessUrl: path.dirname(absoluteFilePath),
    );
  }

  @override
  Future<void> loadFlutterAsset(String key) {
    assert(key.isNotEmpty);
    return _webView.loadFlutterAsset(key);
  }

  @override
  Future<void> loadHtmlString(String html, {String? baseUrl}) {
    return _webView.loadHtmlString(html, baseUrl: baseUrl);
  }

  @override
  Future<void> loadRequest(LoadRequestParams params) {
    if (!params.uri.hasScheme) {
      throw ArgumentError(
        'LoadRequestParams#uri is required to have a scheme.',
      );
    }

    return _webView.loadRequest(NSUrlRequest(
      url: params.uri.toString(),
      allHttpHeaderFields: params.headers,
      httpMethod: describeEnum(params.method),
      httpBody: params.body,
    ));
  }

  @override
  Future<void> addJavaScriptChannel(
    JavaScriptChannelParams javaScriptChannelParams,
  ) {
    final WebKitJavaScriptChannelParams webKitParams =
        javaScriptChannelParams is WebKitJavaScriptChannelParams
            ? javaScriptChannelParams
            : WebKitJavaScriptChannelParams.fromJavaScriptChannelParams(
                javaScriptChannelParams);

    _javaScriptChannelParams[webKitParams.name] = webKitParams;

    final String wrapperSource =
        'window.${webKitParams.name} = webkit.messageHandlers.${webKitParams.name};';
    final WKUserScript wrapperScript = WKUserScript(
      wrapperSource,
      WKUserScriptInjectionTime.atDocumentStart,
      isMainFrameOnly: false,
    );
    _webView.configuration.userContentController.addUserScript(wrapperScript);
    return _webView.configuration.userContentController.addScriptMessageHandler(
      webKitParams._messageHandler,
      webKitParams.name,
    );
  }

  @override
  Future<void> removeJavaScriptChannel(String javaScriptChannelName) async {
    assert(javaScriptChannelName.isNotEmpty);
    if (!_javaScriptChannelParams.containsKey(javaScriptChannelName)) {
      return;
    }
    await _resetUserScripts(removedJavaScriptChannel: javaScriptChannelName);
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
  Future<void> clearCache() {
    return _webView.configuration.websiteDataStore.removeDataOfTypes(
      <WKWebsiteDataType>{
        WKWebsiteDataType.memoryCache,
        WKWebsiteDataType.diskCache,
        WKWebsiteDataType.offlineWebApplicationCache,
      },
      DateTime.fromMillisecondsSinceEpoch(0),
    );
  }

  @override
  Future<void> clearLocalStorage() {
    return _webView.configuration.websiteDataStore.removeDataOfTypes(
      <WKWebsiteDataType>{WKWebsiteDataType.localStorage},
      DateTime.fromMillisecondsSinceEpoch(0),
    );
  }

  @override
  Future<void> runJavaScript(String javaScript) async {
    try {
      await _webView.evaluateJavaScript(javaScript);
    } on PlatformException catch (exception) {
      // WebKit will throw an error when the type of the evaluated value is
      // unsupported. This also goes for `null` and `undefined` on iOS 14+. For
      // example, when running a void function. For ease of use, this specific
      // error is ignored when no return value is expected.
      if (exception.details is! NSError ||
          exception.details.code !=
              WKErrorCode.javaScriptResultTypeIsUnsupported) {
        rethrow;
      }
    }
  }

  @override
  Future<String> runJavaScriptReturningResult(String javaScript) async {
    final Object? result = await _webView.evaluateJavaScript(javaScript);
    if (result == null) {
      throw ArgumentError(
        'Result of JavaScript execution returned a `null` value. '
        'Use `runJavascript` when expecting a null return value.',
      );
    }
    return result.toString();
  }

  /// Controls whether inline playback of HTML5 videos is allowed.
  Future<void> setAllowsInlineMediaPlayback(bool allow) {
    return _webView.configuration.setAllowsInlineMediaPlayback(allow);
  }

  @override
  Future<String?> getTitle() => _webView.getTitle();

  @override
  Future<void> scrollTo(int x, int y) {
    return _webView.scrollView.setContentOffset(Point<double>(
      x.toDouble(),
      y.toDouble(),
    ));
  }

  @override
  Future<void> scrollBy(int x, int y) {
    return _webView.scrollView.scrollBy(Point<double>(
      x.toDouble(),
      y.toDouble(),
    ));
  }

  @override
  Future<Point<int>> getScrollPosition() async {
    final Point<double> offset = await _webView.scrollView.getContentOffset();
    return Point<int>(offset.x.round(), offset.y.round());
  }

  // TODO(bparrishMines): This is unique to iOS. Override should be removed if
  // this is removed from the platform interface before webview_flutter version
  // 4.0.0.
  @override
  Future<void> enableGestureNavigation(bool enabled) {
    return _webView.setAllowsBackForwardNavigationGestures(enabled);
  }

  @override
  Future<void> setBackgroundColor(Color color) {
    return Future.wait(<Future<void>>[
      _webView.scrollView.setBackgroundColor(color),
      _webView.setOpaque(false),
      _webView.setBackgroundColor(Colors.transparent),
    ]);
  }

  @override
  Future<void> setJavaScriptMode(JavaScriptMode javaScriptMode) {
    switch (javaScriptMode) {
      case JavaScriptMode.disabled:
        return _webView.configuration.preferences.setJavaScriptEnabled(false);
      case JavaScriptMode.unrestricted:
        return _webView.configuration.preferences.setJavaScriptEnabled(true);
    }
  }

  @override
  Future<void> setUserAgent(String? userAgent) {
    return _webView.setCustomUserAgent(userAgent);
  }

  @override
  Future<void> enableZoom(bool enabled) async {
    if (_zoomEnabled == enabled) {
      return;
    }

    _zoomEnabled = enabled;
    if (enabled) {
      await _resetUserScripts();
    } else {
      await _disableZoom();
    }
  }

  Future<void> _disableZoom() {
    const WKUserScript userScript = WKUserScript(
      "var meta = document.createElement('meta');\n"
      "meta.name = 'viewport';\n"
      "meta.content = 'width=device-width, initial-scale=1.0, maximum-scale=1.0, "
      "user-scalable=no';\n"
      "var head = document.getElementsByTagName('head')[0];head.appendChild(meta);",
      WKUserScriptInjectionTime.atDocumentEnd,
      isMainFrameOnly: true,
    );
    return _webView.configuration.userContentController
        .addUserScript(userScript);
  }

  // WKWebView does not support removing a single user script, so all user
  // scripts and all message handlers are removed instead. And the JavaScript
  // channels that shouldn't be removed are re-registered. Note that this
  // workaround could interfere with exposing support for custom scripts from
  // applications.
  Future<void> _resetUserScripts({String? removedJavaScriptChannel}) async {
    _webView.configuration.userContentController.removeAllUserScripts();
    // TODO(bparrishMines): This can be replaced with
    // `removeAllScriptMessageHandlers` once Dart supports runtime version
    // checking. (e.g. The equivalent to @availability in Objective-C.)
    _javaScriptChannelParams.keys.forEach(
      _webView.configuration.userContentController.removeScriptMessageHandler,
    );

    _javaScriptChannelParams.remove(removedJavaScriptChannel);

    await Future.wait(<Future<void>>[
      for (JavaScriptChannelParams params in _javaScriptChannelParams.values)
        addJavaScriptChannel(params),
      // Zoom is disabled with a WKUserScript, so this adds it back if it was
      // removed above.
      if (!_zoomEnabled) _disableZoom(),
    ]);
  }
}

/// An implementation of [JavaScriptChannelParams] with the WebKit api.
///
/// See [WebKitWebViewController.addJavaScriptChannel].
@immutable
class WebKitJavaScriptChannelParams extends JavaScriptChannelParams {
  /// Constructs a [WebKitJavaScriptChannelParams].
  WebKitJavaScriptChannelParams({
    required super.name,
    required super.onMessageReceived,
    @visibleForTesting WebKitProxy webKitProxy = const WebKitProxy(),
  })  : assert(name.isNotEmpty),
        _messageHandler = webKitProxy.createScriptMessageHandler(
          didReceiveScriptMessage: withWeakRefenceTo(
            onMessageReceived,
            (WeakReference<void Function(JavaScriptMessage)> weakReference) {
              return (
                WKUserContentController controller,
                WKScriptMessage message,
              ) {
                if (weakReference.target != null) {
                  weakReference.target!(
                    JavaScriptMessage(message: message.body!.toString()),
                  );
                }
              };
            },
          ),
        );

  /// Constructs a [WebKitJavaScriptChannelParams] using a
  /// [JavaScriptChannelParams].
  WebKitJavaScriptChannelParams.fromJavaScriptChannelParams(
    JavaScriptChannelParams params, {
    @visibleForTesting WebKitProxy webKitProxy = const WebKitProxy(),
  }) : this(
          name: params.name,
          onMessageReceived: params.onMessageReceived,
          webKitProxy: webKitProxy,
        );

  final WKScriptMessageHandler _messageHandler;
}
