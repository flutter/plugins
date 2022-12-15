// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as path;
import 'package:webview_flutter_platform_interface/webview_flutter_platform_interface.dart';

import 'common/instance_manager.dart';
import 'common/weak_reference_utils.dart';
import 'foundation/foundation.dart';
import 'web_kit/web_kit.dart';
import 'webkit_proxy.dart';

/// Media types that can require a user gesture to begin playing.
///
/// See [WebKitWebViewControllerCreationParams.mediaTypesRequiringUserAction].
enum PlaybackMediaTypes {
  /// A media type that contains audio.
  audio,

  /// A media type that contains video.
  video;

  WKAudiovisualMediaType _toWKAudiovisualMediaType() {
    switch (this) {
      case PlaybackMediaTypes.audio:
        return WKAudiovisualMediaType.audio;
      case PlaybackMediaTypes.video:
        return WKAudiovisualMediaType.video;
    }
  }
}

/// Object specifying creation parameters for a [WebKitWebViewController].
@immutable
class WebKitWebViewControllerCreationParams
    extends PlatformWebViewControllerCreationParams {
  /// Constructs a [WebKitWebViewControllerCreationParams].
  WebKitWebViewControllerCreationParams({
    @visibleForTesting this.webKitProxy = const WebKitProxy(),
    this.mediaTypesRequiringUserAction = const <PlaybackMediaTypes>{
      PlaybackMediaTypes.audio,
      PlaybackMediaTypes.video,
    },
    this.allowsInlineMediaPlayback = false,
  }) : _configuration = webKitProxy.createWebViewConfiguration() {
    if (mediaTypesRequiringUserAction.isEmpty) {
      _configuration.setMediaTypesRequiringUserActionForPlayback(
        <WKAudiovisualMediaType>{WKAudiovisualMediaType.none},
      );
    } else {
      _configuration.setMediaTypesRequiringUserActionForPlayback(
        mediaTypesRequiringUserAction
            .map<WKAudiovisualMediaType>(
              (PlaybackMediaTypes type) => type._toWKAudiovisualMediaType(),
            )
            .toSet(),
      );
    }
    _configuration.setAllowsInlineMediaPlayback(allowsInlineMediaPlayback);
  }

  /// Constructs a [WebKitWebViewControllerCreationParams] using a
  /// [PlatformWebViewControllerCreationParams].
  WebKitWebViewControllerCreationParams.fromPlatformWebViewControllerCreationParams(
    // Recommended placeholder to prevent being broken by platform interface.
    // ignore: avoid_unused_constructor_parameters
    PlatformWebViewControllerCreationParams params, {
    @visibleForTesting WebKitProxy webKitProxy = const WebKitProxy(),
    Set<PlaybackMediaTypes> mediaTypesRequiringUserAction =
        const <PlaybackMediaTypes>{
      PlaybackMediaTypes.audio,
      PlaybackMediaTypes.video,
    },
    bool allowsInlineMediaPlayback = false,
  }) : this(
          webKitProxy: webKitProxy,
          mediaTypesRequiringUserAction: mediaTypesRequiringUserAction,
          allowsInlineMediaPlayback: allowsInlineMediaPlayback,
        );

  final WKWebViewConfiguration _configuration;

  /// Media types that require a user gesture to begin playing.
  ///
  /// Defaults to include [PlaybackMediaTypes.audio] and
  /// [PlaybackMediaTypes.video].
  final Set<PlaybackMediaTypes> mediaTypesRequiringUserAction;

  /// Whether inline playback of HTML5 videos is allowed.
  ///
  /// Defaults to false.
  final bool allowsInlineMediaPlayback;

  /// Handles constructing objects and calling static methods for the WebKit
  /// native library.
  @visibleForTesting
  final WebKitProxy webKitProxy;
}

/// An implementation of [PlatformWebViewController] with the WebKit api.
class WebKitWebViewController extends PlatformWebViewController {
  /// Constructs a [WebKitWebViewController].
  WebKitWebViewController(PlatformWebViewControllerCreationParams params)
      : super.implementation(params is WebKitWebViewControllerCreationParams
            ? params
            : WebKitWebViewControllerCreationParams
                .fromPlatformWebViewControllerCreationParams(params)) {
    _webView.addObserver(
      _webView,
      keyPath: 'estimatedProgress',
      options: <NSKeyValueObservingOptions>{
        NSKeyValueObservingOptions.newValue,
      },
    );
  }

  /// The WebKit WebView being controlled.
  late final WKWebView _webView = withWeakRefenceTo(this, (
    WeakReference<WebKitWebViewController> weakReference,
  ) {
    return _webKitParams.webKitProxy.createWebView(
      _webKitParams._configuration,
      observeValue: (
        String keyPath,
        NSObject object,
        Map<NSKeyValueChangeKey, Object?> change,
      ) {
        final ProgressCallback? progressCallback =
            weakReference.target?._currentNavigationDelegate?._onProgress;
        if (progressCallback != null) {
          final double progress =
              change[NSKeyValueChangeKey.newValue]! as double;
          progressCallback((progress * 100).round());
        }
      },
    );
  });

  final Map<String, WebKitJavaScriptChannelParams> _javaScriptChannelParams =
      <String, WebKitJavaScriptChannelParams>{};

  bool _zoomEnabled = true;
  WebKitNavigationDelegate? _currentNavigationDelegate;

  WebKitWebViewControllerCreationParams get _webKitParams =>
      params as WebKitWebViewControllerCreationParams;

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
  Future<Object> runJavaScriptReturningResult(String javaScript) async {
    final Object? result = await _webView.evaluateJavaScript(javaScript);
    if (result == null) {
      throw ArgumentError(
        'Result of JavaScript execution returned a `null` value. '
        'Use `runJavascript` when expecting a null return value.',
      );
    }
    return result;
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
  Future<Offset> getScrollPosition() async {
    final Point<double> offset = await _webView.scrollView.getContentOffset();
    return Offset(offset.x, offset.y);
  }

  /// Whether horizontal swipe gestures trigger page navigation.
  Future<void> setAllowsBackForwardNavigationGestures(bool enabled) {
    return _webView.setAllowsBackForwardNavigationGestures(enabled);
  }

  @override
  Future<void> setBackgroundColor(Color color) {
    return Future.wait(<Future<void>>[
      _webView.setOpaque(false),
      _webView.setBackgroundColor(Colors.transparent),
      // This method must be called last.
      _webView.scrollView.setBackgroundColor(color),
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

  @override
  Future<void> setPlatformNavigationDelegate(
    covariant WebKitNavigationDelegate handler,
  ) {
    _currentNavigationDelegate = handler;
    return Future.wait(<Future<void>>[
      _webView.setUIDelegate(handler._uiDelegate),
      _webView.setNavigationDelegate(handler._navigationDelegate)
    ]);
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

/// Object specifying creation parameters for a [WebKitWebViewWidget].
@immutable
class WebKitWebViewWidgetCreationParams
    extends PlatformWebViewWidgetCreationParams {
  /// Constructs a [WebKitWebViewWidgetCreationParams].
  WebKitWebViewWidgetCreationParams({
    super.key,
    required super.controller,
    super.layoutDirection,
    super.gestureRecognizers,
    @visibleForTesting InstanceManager? instanceManager,
  }) : _instanceManager = instanceManager ?? NSObject.globalInstanceManager;

  /// Constructs a [WebKitWebViewWidgetCreationParams] using a
  /// [PlatformWebViewWidgetCreationParams].
  WebKitWebViewWidgetCreationParams.fromPlatformWebViewWidgetCreationParams(
    PlatformWebViewWidgetCreationParams params, {
    InstanceManager? instanceManager,
  }) : this(
          key: params.key,
          controller: params.controller,
          layoutDirection: params.layoutDirection,
          gestureRecognizers: params.gestureRecognizers,
          instanceManager: instanceManager,
        );

  // Maintains instances used to communicate with the native objects they
  // represent.
  final InstanceManager _instanceManager;
}

/// An implementation of [PlatformWebViewWidget] with the WebKit api.
class WebKitWebViewWidget extends PlatformWebViewWidget {
  /// Constructs a [WebKitWebViewWidget].
  WebKitWebViewWidget(PlatformWebViewWidgetCreationParams params)
      : super.implementation(
          params is WebKitWebViewWidgetCreationParams
              ? params
              : WebKitWebViewWidgetCreationParams
                  .fromPlatformWebViewWidgetCreationParams(params),
        );

  WebKitWebViewWidgetCreationParams get _webKitParams =>
      params as WebKitWebViewWidgetCreationParams;

  @override
  Widget build(BuildContext context) {
    return UiKitView(
      key: _webKitParams.key,
      viewType: 'plugins.flutter.io/webview',
      onPlatformViewCreated: (_) {},
      layoutDirection: params.layoutDirection,
      gestureRecognizers: params.gestureRecognizers,
      creationParams: _webKitParams._instanceManager.getIdentifier(
          (params.controller as WebKitWebViewController)._webView),
      creationParamsCodec: const StandardMessageCodec(),
    );
  }
}

/// An implementation of [WebResourceError] with the WebKit API.
class WebKitWebResourceError extends WebResourceError {
  WebKitWebResourceError._(this._nsError, {required bool isForMainFrame})
      : super(
          errorCode: _nsError.code,
          description: _nsError.localizedDescription,
          errorType: _toWebResourceErrorType(_nsError.code),
          isForMainFrame: isForMainFrame,
        );

  static WebResourceErrorType? _toWebResourceErrorType(int code) {
    switch (code) {
      case WKErrorCode.unknown:
        return WebResourceErrorType.unknown;
      case WKErrorCode.webContentProcessTerminated:
        return WebResourceErrorType.webContentProcessTerminated;
      case WKErrorCode.webViewInvalidated:
        return WebResourceErrorType.webViewInvalidated;
      case WKErrorCode.javaScriptExceptionOccurred:
        return WebResourceErrorType.javaScriptExceptionOccurred;
      case WKErrorCode.javaScriptResultTypeIsUnsupported:
        return WebResourceErrorType.javaScriptResultTypeIsUnsupported;
    }

    return null;
  }

  /// A string representing the domain of the error.
  String? get domain => _nsError.domain;

  final NSError _nsError;
}

/// Object specifying creation parameters for a [WebKitNavigationDelegate].
@immutable
class WebKitNavigationDelegateCreationParams
    extends PlatformNavigationDelegateCreationParams {
  /// Constructs a [WebKitNavigationDelegateCreationParams].
  const WebKitNavigationDelegateCreationParams({
    @visibleForTesting this.webKitProxy = const WebKitProxy(),
  });

  /// Constructs a [WebKitNavigationDelegateCreationParams] using a
  /// [PlatformNavigationDelegateCreationParams].
  const WebKitNavigationDelegateCreationParams.fromPlatformNavigationDelegateCreationParams(
    // Recommended placeholder to prevent being broken by platform interface.
    // ignore: avoid_unused_constructor_parameters
    PlatformNavigationDelegateCreationParams params, {
    @visibleForTesting WebKitProxy webKitProxy = const WebKitProxy(),
  }) : this(webKitProxy: webKitProxy);

  /// Handles constructing objects and calling static methods for the WebKit
  /// native library.
  @visibleForTesting
  final WebKitProxy webKitProxy;
}

/// An implementation of [PlatformNavigationDelegate] with the WebKit API.
class WebKitNavigationDelegate extends PlatformNavigationDelegate {
  /// Constructs a [WebKitNavigationDelegate].
  WebKitNavigationDelegate(PlatformNavigationDelegateCreationParams params)
      : super.implementation(params is WebKitNavigationDelegateCreationParams
            ? params
            : WebKitNavigationDelegateCreationParams
                .fromPlatformNavigationDelegateCreationParams(params)) {
    final WeakReference<WebKitNavigationDelegate> weakThis =
        WeakReference<WebKitNavigationDelegate>(this);
    _navigationDelegate =
        (this.params as WebKitNavigationDelegateCreationParams)
            .webKitProxy
            .createNavigationDelegate(
      didFinishNavigation: (WKWebView webView, String? url) {
        if (weakThis.target?._onPageFinished != null) {
          weakThis.target!._onPageFinished!(url ?? '');
        }
      },
      didStartProvisionalNavigation: (WKWebView webView, String? url) {
        if (weakThis.target?._onPageStarted != null) {
          weakThis.target!._onPageStarted!(url ?? '');
        }
      },
      decidePolicyForNavigationAction: (
        WKWebView webView,
        WKNavigationAction action,
      ) async {
        if (weakThis.target?._onNavigationRequest != null) {
          final NavigationDecision decision =
              await weakThis.target!._onNavigationRequest!(NavigationRequest(
            url: action.request.url,
            isMainFrame: action.targetFrame.isMainFrame,
          ));
          switch (decision) {
            case NavigationDecision.prevent:
              return WKNavigationActionPolicy.cancel;
            case NavigationDecision.navigate:
              return WKNavigationActionPolicy.allow;
          }
        }
        return WKNavigationActionPolicy.allow;
      },
      didFailNavigation: (WKWebView webView, NSError error) {
        if (weakThis.target?._onWebResourceError != null) {
          weakThis.target!._onWebResourceError!(
            WebKitWebResourceError._(error, isForMainFrame: true),
          );
        }
      },
      didFailProvisionalNavigation: (WKWebView webView, NSError error) {
        if (weakThis.target?._onWebResourceError != null) {
          weakThis.target!._onWebResourceError!(
            WebKitWebResourceError._(error, isForMainFrame: true),
          );
        }
      },
      webViewWebContentProcessDidTerminate: (WKWebView webView) {
        if (weakThis.target?._onWebResourceError != null) {
          weakThis.target!._onWebResourceError!(
            WebKitWebResourceError._(
              const NSError(
                code: WKErrorCode.webContentProcessTerminated,
                // Value from https://developer.apple.com/documentation/webkit/wkerrordomain?language=objc.
                domain: 'WKErrorDomain',
                localizedDescription: '',
              ),
              isForMainFrame: true,
            ),
          );
        }
      },
    );

    _uiDelegate = (this.params as WebKitNavigationDelegateCreationParams)
        .webKitProxy
        .createUIDelegate(
      onCreateWebView: (
        WKWebView webView,
        WKWebViewConfiguration configuration,
        WKNavigationAction navigationAction,
      ) {
        if (!navigationAction.targetFrame.isMainFrame) {
          webView.loadRequest(navigationAction.request);
        }
      },
    );
  }

  // Used to set `WKWebView.setNavigationDelegate` in `WebKitWebViewController`.
  late final WKNavigationDelegate _navigationDelegate;

  // Used to set `WKWebView.setUIDelegate` in `WebKitWebViewController`.
  late final WKUIDelegate _uiDelegate;

  PageEventCallback? _onPageFinished;
  PageEventCallback? _onPageStarted;
  ProgressCallback? _onProgress;
  WebResourceErrorCallback? _onWebResourceError;
  NavigationRequestCallback? _onNavigationRequest;

  @override
  Future<void> setOnPageFinished(PageEventCallback onPageFinished) async {
    _onPageFinished = onPageFinished;
  }

  @override
  Future<void> setOnPageStarted(PageEventCallback onPageStarted) async {
    _onPageStarted = onPageStarted;
  }

  @override
  Future<void> setOnProgress(ProgressCallback onProgress) async {
    _onProgress = onProgress;
  }

  @override
  Future<void> setOnWebResourceError(
    WebResourceErrorCallback onWebResourceError,
  ) async {
    _onWebResourceError = onWebResourceError;
  }

  @override
  Future<void> setOnNavigationRequest(
    NavigationRequestCallback onNavigationRequest,
  ) async {
    _onNavigationRequest = onNavigationRequest;
  }
}
