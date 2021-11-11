// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter/widgets.dart';

import 'package:webview_flutter_platform_interface/webview_flutter_platform_interface.dart';

import 'src/android_webview.dart' as android_webview;

/// Creates a [Widget] with a [android_webview.WebView].
class AndroidWebViewWidget extends StatefulWidget {
  /// Constructs a [AndroidWebViewWidget].
  AndroidWebViewWidget({required this.controller, required this.onBuildWidget});

  final WebViewAndroidPlatformController controller;

  /// Callback to build a widget once [android_webview.WebView] has been initialized.
  final Widget Function() onBuildWidget;

  @override
  State<StatefulWidget> createState() => _AndroidWebViewWidgetState();
}

class _AndroidWebViewWidgetState extends State<AndroidWebViewWidget> {
  @override
  void dispose() {
    super.dispose();
    widget.controller.release();
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
    WebViewAndroidWebViewClient? webViewClient,
    WebViewAndroidDownloadListener? downloadListener,
    WebViewAndroidWebChromeClient? webChromeClient,
    required this.creationParams,
    required this.callbacksHandler,
    required this.javascriptChannelRegistry,
  }) : super(callbacksHandler) {
    webView.settings.setDomStorageEnabled(true);
    webView.settings.setJavaScriptCanOpenWindowsAutomatically(true);
    webView.settings.setSupportMultipleWindows(true);
    webView.settings.setLoadWithOverviewMode(true);
    webView.settings.setUseWideViewPort(true);
    webView.settings.setDisplayZoomControls(false);
    webView.settings.setBuiltInZoomControls(true);

    _webViewClient = webViewClient ??
        WebViewAndroidWebViewClient(
          callbacksHandler: callbacksHandler,
          loadUrl: loadUrl,
          hasNavigationDelegate:
              creationParams.webSettings?.hasNavigationDelegate ?? false,
        );

    this.downloadListener = downloadListener ??
        WebViewAndroidDownloadListener(
          callbacksHandler: callbacksHandler,
          loadUrl: loadUrl,
        );

    this.webChromeClient =
        WebViewAndroidWebChromeClient(callbacksHandler: callbacksHandler);

    webView.setWebViewClient(this.webViewClient);
    webView.setDownloadListener(this.downloadListener);
    webView.setWebChromeClient(this.webChromeClient);

    _setCreationParams(creationParams);
  }

  /// Initial parameters used to setup the WebView.
  final CreationParams creationParams;

  /// Represents the WebView maintained by platform code.
  final android_webview.WebView webView;

  /// Handles callbacks that are made by [android_webview.WebViewClient], [android_webview.DownloadListener], and [android_webview.WebChromeClient].
  final WebViewPlatformCallbacksHandler callbacksHandler;

  /// Manages named JavaScript channels and forwarding incoming messages on the correct channel.
  final JavascriptChannelRegistry javascriptChannelRegistry;

  final Map<String, WebViewAndroidJavaScriptChannel> _javaScriptChannels =
      <String, WebViewAndroidJavaScriptChannel>{};

  late final WebViewAndroidDownloadListener downloadListener;

  late final WebViewAndroidWebChromeClient webChromeClient;

  late WebViewAndroidWebViewClient _webViewClient;

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

  Future<void> release() => webView.release();

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

    final String? initialUrl = creationParams.initialUrl;
    if (initialUrl != null) {
      loadUrl(initialUrl, <String, String>{});
    }
  }

  Future<void> _trySetHasProgressTracking(bool? hasProgressTracking) {
    if (hasProgressTracking != null) {
      webChromeClient.hasProgressTracking = hasProgressTracking;
    }

    return Future<void>.sync(() => null);
  }

  Future<void> _trySetHasNavigationDelegate(bool? hasNavigationDelegate) {
    if (hasNavigationDelegate == null) return Future<void>.sync(() => null);

    downloadListener.hasNavigationDelegate = hasNavigationDelegate;
    if (_webViewClient.hasNavigationDelegate != hasNavigationDelegate) {
      _webViewClient = WebViewAndroidWebViewClient(
        callbacksHandler: callbacksHandler,
        loadUrl: loadUrl,
        hasNavigationDelegate: hasNavigationDelegate,
      );
      return webView.setWebViewClient(_webViewClient);
    }

    return Future<void>.sync(() => null);
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

class WebViewAndroidJavaScriptChannel
    extends android_webview.JavaScriptChannel {
  WebViewAndroidJavaScriptChannel(
      String channelName, this.javascriptChannelRegistry)
      : super(channelName);

  final JavascriptChannelRegistry javascriptChannelRegistry;

  @override
  void postMessage(String message) {
    javascriptChannelRegistry.onJavascriptChannelMessage(channelName, message);
  }
}

class WebViewAndroidDownloadListener extends android_webview.DownloadListener {
  WebViewAndroidDownloadListener({
    required this.callbacksHandler,
    required this.loadUrl,
  });

  final WebViewPlatformCallbacksHandler callbacksHandler;
  final Future<void> Function(String url, Map<String, String>? headers) loadUrl;
  bool hasNavigationDelegate = false;

  @override
  void onDownloadStart(
    String url,
    String userAgent,
    String contentDisposition,
    String mimetype,
    int contentLength,
  ) {
    if (!hasNavigationDelegate) return;

    final FutureOr<bool> returnValue = callbacksHandler.onNavigationRequest(
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
    required this.callbacksHandler,
    required this.loadUrl,
    required this.hasNavigationDelegate,
  }) : super(shouldOverrideUrlLoading: hasNavigationDelegate);

  final WebViewPlatformCallbacksHandler callbacksHandler;
  final Future<void> Function(String url, Map<String, String>? headers) loadUrl;
  final bool hasNavigationDelegate;

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

  @override
  void onPageStarted(android_webview.WebView webView, String url) {
    callbacksHandler.onPageStarted(url);
  }

  @override
  void onPageFinished(android_webview.WebView webView, String url) {
    callbacksHandler.onPageFinished(url);
  }

  @override
  void onReceivedError(
    android_webview.WebView webView,
    int errorCode,
    String description,
    String failingUrl,
  ) {
    callbacksHandler.onWebResourceError(WebResourceError(
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
      callbacksHandler.onWebResourceError(WebResourceError(
        errorCode: error.errorCode,
        description: error.description,
        failingUrl: request.url,
        errorType: _errorCodeToErrorType(error.errorCode),
      ));
    }
  }

  @override
  void urlLoading(android_webview.WebView webView, String url) {
    if (!hasNavigationDelegate) return;

    final FutureOr<bool> returnValue = callbacksHandler.onNavigationRequest(
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

  @override
  void requestLoading(
    android_webview.WebView webView,
    android_webview.WebResourceRequest request,
  ) {
    if (!hasNavigationDelegate) return;

    final FutureOr<bool> returnValue = callbacksHandler.onNavigationRequest(
      url: request.url,
      isForMainFrame: request.isForMainFrame,
    );

    if (returnValue is bool && returnValue) {
      loadUrl(request.url, <String, String>{});
    } else {
      (returnValue as Future<bool>).then((bool shouldLoadUrl) {
        if (shouldLoadUrl) {
          loadUrl(request.url, <String, String>{});
        }
      });
    }
  }
}

class WebViewAndroidWebChromeClient extends android_webview.WebChromeClient {
  WebViewAndroidWebChromeClient({required this.callbacksHandler});

  final WebViewPlatformCallbacksHandler callbacksHandler;
  bool hasProgressTracking = false;

  @override
  void onProgressChanged(android_webview.WebView webView, int progress) {
    if (hasProgressTracking) callbacksHandler.onProgress(progress);
  }
}
