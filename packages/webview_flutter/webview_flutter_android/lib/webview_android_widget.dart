// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter/widgets.dart';

import 'package:webview_flutter_platform_interface/webview_flutter_platform_interface.dart';

import 'src/android_webview.dart' as android_webview;

/// Creates a [Widget] with a [android_webview.WebView].
class WebViewAndroidWidget extends StatefulWidget {
  /// Constructs a [WebViewAndroidWidget].
  WebViewAndroidWidget({required this.controller, required this.onBuildWidget});

  /// Controls the Android WebView platform API.
  final WebViewAndroidPlatformController controller;

  /// Callback to build a widget once [android_webview.WebView] has been initialized.
  final Widget Function() onBuildWidget;

  @override
  State<StatefulWidget> createState() => _WebViewAndroidWidgetState();
}

class _WebViewAndroidWidgetState extends State<WebViewAndroidWidget> {
  @override
  void dispose() {
    super.dispose();
    widget.controller._release();
  }

  @override
  Widget build(BuildContext context) {
    return widget.onBuildWidget();
  }
}

/// Implementation of [WebViewPlatformController] with the Android WebView api.
class WebViewAndroidPlatformController extends WebViewPlatformController {
  /// Construct a [WebViewAndroidPlatformController].
  WebViewAndroidPlatformController({
    required this.webView,
    required this.creationParams,
    required this.callbacksHandler,
    required this.javascriptChannelRegistry,
  })  : assert(creationParams.webSettings?.hasNavigationDelegate != null),
        super(callbacksHandler) {
    webView.settings.setDomStorageEnabled(true);
    webView.settings.setJavaScriptCanOpenWindowsAutomatically(true);
    webView.settings.setSupportMultipleWindows(true);
    webView.settings.setLoadWithOverviewMode(true);
    webView.settings.setUseWideViewPort(true);
    webView.settings.setDisplayZoomControls(false);
    webView.settings.setBuiltInZoomControls(true);

    this.downloadListener =WebViewAndroidDownloadListener(loadUrl: loadUrl);
    this.webChromeClient = WebViewAndroidWebChromeClient();

    // Also sets WebViewClient depending on WebSettings.hasNavigationDelegate.
    _setCreationParams(creationParams);

    webView.setDownloadListener(this.downloadListener);
    webView.setWebChromeClient(this.webChromeClient);

    final String? initialUrl = creationParams.initialUrl;
    if (initialUrl != null) {
      loadUrl(initialUrl, <String, String>{});
    }
  }

  final Map<String, WebViewAndroidJavaScriptChannel> _javaScriptChannels =
  <String, WebViewAndroidJavaScriptChannel>{};

  late WebViewAndroidWebViewClient _webViewClient;

  /// Initial parameters used to setup the WebView.
  final CreationParams creationParams;

  /// Represents the WebView maintained by platform code.
  final android_webview.WebView webView;

  /// Handles callbacks that are made by [android_webview.WebViewClient], [android_webview.DownloadListener], and [android_webview.WebChromeClient].
  final WebViewPlatformCallbacksHandler callbacksHandler;

  /// Manages named JavaScript channels and forwarding incoming messages on the correct channel.
  final JavascriptChannelRegistry javascriptChannelRegistry;

  /// Receives callbacks when content can not be handled by the rendering engine for [android_webview.WebView], and should be downloaded instead.
  late final WebViewAndroidDownloadListener downloadListener;

  /// Handles JavaScript dialogs, favicons, titles, new windows, and the progress for [android_webview.WebView].
  late final WebViewAndroidWebChromeClient webChromeClient;

  /// Receive various notifications and requests for [android_webview.WebView].
  WebViewAndroidWebViewClient get webViewClient => _webViewClient;

  @override
  Future<void> loadUrl(
    String url,
    Map<String, String>? headers,
  ) {
    return webView.loadUrl(url, headers ?? <String, String>{});
  }

  @override
  Future<String?> currentUrl() => webView.getUrl();

  @override
  Future<bool> canGoBack() => webView.canGoBack();

  @override
  Future<bool> canGoForward() => webView.canGoForward();

  @override
  Future<void> goBack() => webView.goBack();

  @override
  Future<void> goForward() => webView.goForward();

  @override
  Future<void> reload() => webView.reload();

  @override
  Future<void> clearCache() => webView.clearCache(true);

  @override
  Future<void> updateSettings(WebSettings settings) {
    return Future.wait(<Future<void>>[
      _trySetHasProgressTracking(settings.hasProgressTracking),
      _trySetHasNavigationDelegate(settings.hasNavigationDelegate),
      _trySetJavaScriptMode(settings.javascriptMode),
      _trySetDebuggingEnabled(settings.debuggingEnabled),
      _trySetUserAgent(settings.userAgent),
      _trySetZoomEnabled(settings.zoomEnabled),
    ]);
  }

  @override
  Future<String> evaluateJavascript(String javascript) async {
    return runJavascriptReturningResult(javascript);
  }

  @override
  Future<void> runJavascript(String javascript) async {
    await webView.evaluateJavascript(javascript);
  }

  @override
  Future<String> runJavascriptReturningResult(String javascript) async {
    return await webView.evaluateJavascript(javascript) ?? '';
  }

  @override
  Future<void> addJavascriptChannels(Set<String> javascriptChannelNames) {
    return Future.wait(
      javascriptChannelNames.where(
        (String channelName) {
          return !_javaScriptChannels.containsKey(channelName);
        },
      ).map<Future<void>>(
        (String channelName) {
          final WebViewAndroidJavaScriptChannel javaScriptChannel =
              WebViewAndroidJavaScriptChannel(
                  channelName, javascriptChannelRegistry);
          _javaScriptChannels[channelName] = javaScriptChannel;
          return webView.addJavaScriptChannel(javaScriptChannel);
        },
      ),
    );
  }

  @override
  Future<void> removeJavascriptChannels(
    Set<String> javascriptChannelNames,
  ) {
    return Future.wait(
      javascriptChannelNames.where(
        (String channelName) {
          return _javaScriptChannels.containsKey(channelName);
        },
      ).map<Future<void>>(
        (String channelName) {
          final WebViewAndroidJavaScriptChannel javaScriptChannel =
              _javaScriptChannels[channelName]!;
          _javaScriptChannels.remove(channelName);
          return webView.removeJavaScriptChannel(javaScriptChannel);
        },
      ),
    );
  }

  @override
  Future<String?> getTitle() => webView.getTitle();

  @override
  Future<void> scrollTo(int x, int y) => webView.scrollTo(x, y);

  @override
  Future<void> scrollBy(int x, int y) => webView.scrollBy(x, y);

  @override
  Future<int> getScrollX() => webView.getScrollX();

  @override
  Future<int> getScrollY() => webView.getScrollY();

  Future<void> _release() => webView.release();

  void _setCreationParams(CreationParams creationParams) {
    final WebSettings? webSettings = creationParams.webSettings;
    if (webSettings != null) {
      updateSettings(webSettings);
    }

    final String? userAgent = creationParams.userAgent;
    if (userAgent != null) {
      webView.settings.setUserAgentString(userAgent);
    }

    final AutoMediaPlaybackPolicy autoMediaPlaybackPolicy =
        creationParams.autoMediaPlaybackPolicy;
    switch (autoMediaPlaybackPolicy) {
      case AutoMediaPlaybackPolicy.always_allow:
        webView.settings.setMediaPlaybackRequiresUserGesture(false);
        break;
      default:
        webView.settings.setMediaPlaybackRequiresUserGesture(true);
    }

    addJavascriptChannels(creationParams.javascriptChannelNames);
  }

  Future<void> _trySetHasProgressTracking(bool? hasProgressTracking) {
    if (hasProgressTracking == true) {
      webChromeClient._onProgress = callbacksHandler.onProgress;
    } else if (hasProgressTracking == false) {
      webChromeClient._onProgress = null;
    }

    return Future<void>.sync(() => null);
  }

  Future<void> _trySetHasNavigationDelegate(bool? hasNavigationDelegate) {
    if (hasNavigationDelegate == null) return Future<void>.sync(() => null);

    downloadListener._onNavigationRequest =
        callbacksHandler.onNavigationRequest;
    if (hasNavigationDelegate) {
      _webViewClient = WebViewAndroidWebViewClient.handlesNavigation(
        onPageStartedCallback: callbacksHandler.onPageStarted,
        onPageFinishedCallback: callbacksHandler.onPageFinished,
        onWebResourceErrorCallback: callbacksHandler.onWebResourceError,
        loadUrl: loadUrl,
        onNavigationRequestCallback: callbacksHandler.onNavigationRequest,
      );
    } else {
      _webViewClient = WebViewAndroidWebViewClient(
        onPageStartedCallback: callbacksHandler.onPageStarted,
        onPageFinishedCallback: callbacksHandler.onPageFinished,
        onWebResourceErrorCallback: callbacksHandler.onWebResourceError,
      );
    }
    return webView.setWebViewClient(_webViewClient);
  }

  Future<void> _trySetJavaScriptMode(JavascriptMode? mode) async {
    if (mode == null) return Future<void>.sync(() => null);

    switch (mode) {
      case JavascriptMode.disabled:
        return webView.settings.setJavaScriptEnabled(false);
      case JavascriptMode.unrestricted:
        return webView.settings.setJavaScriptEnabled(true);
    }
  }

  Future<void> _trySetDebuggingEnabled(bool? debuggingEnabled) async {
    if (debuggingEnabled == null) return Future<void>.sync(() => null);
    return android_webview.WebView.setWebContentsDebuggingEnabled(
      debuggingEnabled,
    );
  }

  Future<void> _trySetUserAgent(WebSetting<String?> userAgent) {
    if (userAgent.isPresent && userAgent.value != null) {
      return webView.settings.setUserAgentString(userAgent.value!);
    }

    return webView.settings.setUserAgentString('');
  }

  Future<void> _trySetZoomEnabled(bool? zoomEnabled) async {
    if (zoomEnabled == null) return Future<void>.sync(() => null);
    return webView.settings.setSupportZoom(zoomEnabled);
  }
}

/// Exposes a channel to receive calls from javaScript.
class WebViewAndroidJavaScriptChannel
    extends android_webview.JavaScriptChannel {
  /// Creates a [WebViewAndroidJavaScriptChannel].
  WebViewAndroidJavaScriptChannel(
      String channelName, this.javascriptChannelRegistry)
      : super(channelName);

  /// Manages named JavaScript channels and forwarding incoming messages on the correct channel.
  final JavascriptChannelRegistry javascriptChannelRegistry;

  @override
  void postMessage(String message) {
    javascriptChannelRegistry.onJavascriptChannelMessage(channelName, message);
  }
}

/// Receives callbacks when content can not be handled by the rendering engine for [WebViewAndroidPlatformController], and should be downloaded instead.
class WebViewAndroidDownloadListener extends android_webview.DownloadListener {
  /// Creates a [WebViewAndroidDownloadListener].
  WebViewAndroidDownloadListener({required this.loadUrl});

  FutureOr<bool> Function({
  required String url,
  required bool isForMainFrame,
  })? _onNavigationRequest;

  /// Callback to load a URL when a navigation request is approved.
  final Future<void> Function(String url, Map<String, String>? headers) loadUrl;

  @override
  void onDownloadStart(
    String url,
    String userAgent,
    String contentDisposition,
    String mimetype,
    int contentLength,
  ) {
    if (_onNavigationRequest == null) return;

    final FutureOr<bool> returnValue = _onNavigationRequest!(
      url: url,
      isForMainFrame: true,
    );

    if (returnValue is bool && returnValue) {
      loadUrl(url, <String, String>{});
    } else {
      (returnValue as Future<bool>).then((bool shouldLoadUrl) {
        if (shouldLoadUrl) {
          loadUrl(url, <String, String>{});
        }
      });
    }
  }
}

class WebViewAndroidWebViewClient extends android_webview.WebViewClient {
  WebViewAndroidWebViewClient({
    required this.onPageStartedCallback,
    required this.onPageFinishedCallback,
    required this.onWebResourceErrorCallback,
  })  : loadUrl = null,
        onNavigationRequestCallback = null,
        super(shouldOverrideUrlLoading: false);

  WebViewAndroidWebViewClient.handlesNavigation({
    required this.onPageStartedCallback,
    required this.onPageFinishedCallback,
    required this.onWebResourceErrorCallback,
    required FutureOr<bool> Function({
      required String url,
      required bool isForMainFrame,
    })
        onNavigationRequestCallback,
    required Future<void> Function(String url, Map<String, String>? headers)
        loadUrl,
  })  : onNavigationRequestCallback = onNavigationRequestCallback,
        loadUrl = loadUrl,
        super(shouldOverrideUrlLoading: true);

  final void Function(String url) onPageStartedCallback;

  final void Function(String url) onPageFinishedCallback;

  void Function(WebResourceError error) onWebResourceErrorCallback;

  final FutureOr<bool> Function({
    required String url,
    required bool isForMainFrame,
  })? onNavigationRequestCallback;

  final Future<void> Function(String url, Map<String, String>? headers)?
      loadUrl;

  static WebResourceErrorType _errorCodeToErrorType(int errorCode) {
    switch (errorCode) {
      case android_webview.WebViewClient.errorAuthentication:
        return WebResourceErrorType.authentication;
      case android_webview.WebViewClient.errorBadUrl:
        return WebResourceErrorType.badUrl;
      case android_webview.WebViewClient.errorConnect:
        return WebResourceErrorType.connect;
      case android_webview.WebViewClient.errorFailedSslHandshake:
        return WebResourceErrorType.failedSslHandshake;
      case android_webview.WebViewClient.errorFile:
        return WebResourceErrorType.file;
      case android_webview.WebViewClient.errorFileNotFound:
        return WebResourceErrorType.fileNotFound;
      case android_webview.WebViewClient.errorHostLookup:
        return WebResourceErrorType.hostLookup;
      case android_webview.WebViewClient.errorIO:
        return WebResourceErrorType.io;
      case android_webview.WebViewClient.errorProxyAuthentication:
        return WebResourceErrorType.proxyAuthentication;
      case android_webview.WebViewClient.errorRedirectLoop:
        return WebResourceErrorType.redirectLoop;
      case android_webview.WebViewClient.errorTimeout:
        return WebResourceErrorType.timeout;
      case android_webview.WebViewClient.errorTooManyRequests:
        return WebResourceErrorType.tooManyRequests;
      case android_webview.WebViewClient.errorUnknown:
        return WebResourceErrorType.unknown;
      case android_webview.WebViewClient.errorUnsafeResource:
        return WebResourceErrorType.unsafeResource;
      case android_webview.WebViewClient.errorUnsupportedAuthScheme:
        return WebResourceErrorType.unsupportedAuthScheme;
      case android_webview.WebViewClient.errorUnsupportedScheme:
        return WebResourceErrorType.unsupportedScheme;
    }

    throw ArgumentError(
      'Could not find a WebResourceErrorType for errorCode: $errorCode',
    );
  }

  /// Whether this [android_webview.WebViewClient] handles navigation requests.
  bool get handlesNavigation =>
      loadUrl != null && onNavigationRequestCallback != null;

  @override
  void onPageStarted(android_webview.WebView webView, String url) {
    onPageStartedCallback(url);
  }

  @override
  void onPageFinished(android_webview.WebView webView, String url) {
    onPageFinishedCallback(url);
  }

  @override
  void onReceivedError(
    android_webview.WebView webView,
    int errorCode,
    String description,
    String failingUrl,
  ) {
    onWebResourceErrorCallback(WebResourceError(
      errorCode: errorCode,
      description: description,
      failingUrl: failingUrl,
      errorType: _errorCodeToErrorType(errorCode),
    ));
  }

  @override
  void onReceivedRequestError(
    android_webview.WebView webView,
    android_webview.WebResourceRequest request,
    android_webview.WebResourceError error,
  ) {
    if (request.isForMainFrame) {
      onWebResourceErrorCallback(WebResourceError(
        errorCode: error.errorCode,
        description: error.description,
        failingUrl: request.url,
        errorType: _errorCodeToErrorType(error.errorCode),
      ));
    }
  }

  @override
  void urlLoading(android_webview.WebView webView, String url) {
    if (!handlesNavigation) return;

    final FutureOr<bool> returnValue = onNavigationRequestCallback!(
      url: url,
      isForMainFrame: true,
    );

    if (returnValue is bool && returnValue) {
      loadUrl!(url, <String, String>{});
    } else {
      (returnValue as Future<bool>).then((bool shouldLoadUrl) {
        if (shouldLoadUrl) {
          loadUrl!(url, <String, String>{});
        }
      });
    }
  }

  @override
  void requestLoading(
    android_webview.WebView webView,
    android_webview.WebResourceRequest request,
  ) {
    if (!handlesNavigation) return;

    final FutureOr<bool> returnValue = onNavigationRequestCallback!(
      url: request.url,
      isForMainFrame: request.isForMainFrame,
    );

    if (returnValue is bool && returnValue) {
      loadUrl!(request.url, <String, String>{});
    } else {
      (returnValue as Future<bool>).then((bool shouldLoadUrl) {
        if (shouldLoadUrl) {
          loadUrl!(request.url, <String, String>{});
        }
      });
    }
  }
}

/// Handles JavaScript dialogs, favicons, titles, and the progress for [WebViewAndroidPlatformController].
class WebViewAndroidWebChromeClient extends android_webview.WebChromeClient {
  void Function(int progress)? _onProgress;

  @override
  void onProgressChanged(android_webview.WebView webView, int progress) {
    if (_onProgress != null) {
      _onProgress!(progress);
    }
  }
}
