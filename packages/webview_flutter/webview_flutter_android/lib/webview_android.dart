// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:webview_flutter_android/src/instance_manager.dart';
import 'package:webview_flutter_platform_interface/webview_flutter_platform_interface.dart';

import 'src/android_webview.dart' as android_webview;

/// Builds an Android webview.
///
/// This is used as the default implementation for [WebView.platform] on Android. It uses
/// an [AndroidView] to embed the webview in the widget hierarchy, and uses a method channel to
/// communicate with the platform code.
class AndroidWebView implements WebViewPlatform {
  @override
  Widget build({
    required BuildContext context,
    required CreationParams creationParams,
    required WebViewPlatformCallbacksHandler webViewPlatformCallbacksHandler,
    required JavascriptChannelRegistry javascriptChannelRegistry,
    WebViewPlatformCreatedCallback? onWebViewPlatformCreated,
    Set<Factory<OneSequenceGestureRecognizer>>? gestureRecognizers,
  }) {
    // assert(webViewPlatformCallbacksHandler != null);
    // return GestureDetector(
    //   // We prevent text selection by intercepting the long press event.
    //   // This is a temporary stop gap due to issues with text selection on Android:
    //   // https://github.com/flutter/flutter/issues/24585 - the text selection
    //   // dialog is not responding to touch events.
    //   // https://github.com/flutter/flutter/issues/24584 - the text selection
    //   // handles are not showing.
    //   // TODO(amirh): remove this when the issues above are fixed.
    //   onLongPress: () {},
    //   excludeFromSemantics: true,
    //   child: AndroidView(
    //     viewType: 'plugins.flutter.io/webview',
    //     onPlatformViewCreated: (int id) {
    //       if (onWebViewPlatformCreated == null) {
    //         return;
    //       }
    //       onWebViewPlatformCreated(MethodChannelWebViewPlatform(
    //         id,
    //         webViewPlatformCallbacksHandler,
    //         javascriptChannelRegistry,
    //       ));
    //     },
    //     gestureRecognizers: gestureRecognizers,
    //     layoutDirection: Directionality.maybeOf(context) ?? TextDirection.rtl,
    //     creationParams:
    //         MethodChannelWebViewPlatform.creationParamsToMap(creationParams),
    //     creationParamsCodec: const StandardMessageCodec(),
    //   ),
    // );
    return _AndroidWebViewWidget(
      creationParams: creationParams,
      webViewPlatformCallbacksHandler: webViewPlatformCallbacksHandler,
      javascriptChannelRegistry: javascriptChannelRegistry,
      onWebViewPlatformCreated: onWebViewPlatformCreated,
      gestureRecognizers: gestureRecognizers,
    );
  }

  @override
  Future<bool> clearCookies() => MethodChannelWebViewPlatform.clearCookies();
}

class _AndroidWebViewWidget extends StatefulWidget {
  _AndroidWebViewWidget({
    required this.creationParams,
    required this.webViewPlatformCallbacksHandler,
    required this.javascriptChannelRegistry,
    this.onWebViewPlatformCreated,
    this.gestureRecognizers,
  });

  final CreationParams creationParams;
  final WebViewPlatformCallbacksHandler webViewPlatformCallbacksHandler;
  final JavascriptChannelRegistry javascriptChannelRegistry;
  final WebViewPlatformCreatedCallback? onWebViewPlatformCreated;
  final Set<Factory<OneSequenceGestureRecognizer>>? gestureRecognizers;

  @override
  State<StatefulWidget> createState() => _AndroidWebViewWidgetState();
}

class _AndroidWebViewWidgetState extends State<_AndroidWebViewWidget> {
  late android_webview.WebView webView;
  late _AndroidWebViewPlatformController platformController;

  @override
  void initState() {
    super.initState();
    webView = android_webview.WebView(useHybridComposition: false);
    webView.settings.setDomStorageEnabled(true);
    webView.settings.setJavaScriptCanOpenWindowsAutomatically(true);
    webView.settings.setSupportMultipleWindows(true);

    platformController = _AndroidWebViewPlatformController(
      webView: webView,
      callbacksHandler: widget.webViewPlatformCallbacksHandler,
      javascriptChannelRegistry: widget.javascriptChannelRegistry,
      hasNavigationDelegate:
          widget.creationParams.webSettings?.hasNavigationDelegate ?? false,
    );

    setCreationParams(widget.creationParams);
  }

  void setCreationParams(CreationParams creationParams) {
    final WebSettings? webSettings = creationParams.webSettings;
    if (webSettings != null) {
      platformController.updateSettings(webSettings);
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

    platformController.addJavascriptChannels(
      creationParams.javascriptChannelNames,
    );

    final String? initialUrl = creationParams.initialUrl;
    if (initialUrl != null) {
      platformController.loadUrl(initialUrl, <String, String>{});
    }
  }

  @override
  void dispose() {
    super.dispose();
    platformController.webView.release();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // We prevent text selection by intercepting the long press event.
      // This is a temporary stop gap due to issues with text selection on Android:
      // https://github.com/flutter/flutter/issues/24585 - the text selection
      // dialog is not responding to touch events.
      // https://github.com/flutter/flutter/issues/24584 - the text selection
      // handles are not showing.
      // TODO(amirh): remove this when the issues above are fixed.
      onLongPress: () {},
      excludeFromSemantics: true,
      child: AndroidView(
        viewType: 'plugins.flutter.io/webview',
        onPlatformViewCreated: (int id) {
          final WebViewPlatformCreatedCallback? createdCallback =
              widget.onWebViewPlatformCreated;
          if (createdCallback != null) {
            createdCallback(platformController);
          }
        },
        gestureRecognizers: widget.gestureRecognizers,
        layoutDirection: Directionality.maybeOf(context) ?? TextDirection.rtl,
        creationParams:
            InstanceManager.instance.getInstanceId(platformController.webView),
        creationParamsCodec: const StandardMessageCodec(),
      ),
    );
  }
}

class _AndroidWebViewPlatformController extends WebViewPlatformController {
  _AndroidWebViewPlatformController({
    required this.webView,
    required this.callbacksHandler,
    required this.javascriptChannelRegistry,
    required bool hasNavigationDelegate,
  }) : super(callbacksHandler) {
    webViewClient = _WebViewClientImpl(
      callbacksHandler: callbacksHandler,
      loadUrl: loadUrl,
      hasNavigationDelegate: hasNavigationDelegate,
    );
    downloadListener = _DownloadListenerImpl(
      callbacksHandler: callbacksHandler,
      loadUrl: loadUrl,
    );
    webChromeClient = _WebChromeClientImpl(callbacksHandler: callbacksHandler);
    webView.setWebViewClient(webViewClient);
    webView.setDownloadListener(downloadListener);
    webView.setWebChromeClient(webChromeClient);
  }

  final Map<String, _JavaScriptChannelImpl> javaScriptChannels =
      <String, _JavaScriptChannelImpl>{};

  final android_webview.WebView webView;
  final WebViewPlatformCallbacksHandler callbacksHandler;
  final JavascriptChannelRegistry javascriptChannelRegistry;

  late final _DownloadListenerImpl downloadListener;
  late final _WebChromeClientImpl webChromeClient;
  late _WebViewClientImpl webViewClient;

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
    final bool? hasProgressTracking = settings.hasProgressTracking;
    if (hasProgressTracking != null) {
      webChromeClient.hasProgressTracking = hasProgressTracking;
    }

    return Future.wait(<Future<void>>[
      _trySetHasNavigationDelegate(settings.hasNavigationDelegate),
      _trySetJavaScriptMode(settings.javascriptMode),
      _trySetDebuggingEnabled(settings.debuggingEnabled),
      _trySetUserAgent(settings.userAgent),
    ]);
  }

  @override
  Future<String> evaluateJavascript(String javascriptString) async {
    return await webView.evaluateJavascript(javascriptString) ?? '';
  }

  @override
  Future<void> addJavascriptChannels(Set<String> javascriptChannelNames) {
    return Future.wait(
      javascriptChannelNames.where(
        (String channelName) {
          return javaScriptChannels.containsKey(channelName);
        },
      ).map<Future<void>>(
        (String channelName) {
          final _JavaScriptChannelImpl javaScriptChannel =
              _JavaScriptChannelImpl(channelName, javascriptChannelRegistry);
          javaScriptChannels[channelName] = javaScriptChannel;
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
          return javaScriptChannels.containsKey(channelName);
        },
      ).map<Future<void>>(
        (String channelName) {
          final _JavaScriptChannelImpl javaScriptChannel =
              javaScriptChannels[channelName]!;
          javaScriptChannels.remove(channelName);
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

  Future<void> _trySetHasNavigationDelegate(bool? hasNavigationDelegate) async {
    if (hasNavigationDelegate != null) {
      downloadListener.hasNavigationDelegate = hasNavigationDelegate;
      webViewClient = _WebViewClientImpl(
        callbacksHandler: callbacksHandler,
        loadUrl: loadUrl,
        hasNavigationDelegate: hasNavigationDelegate,
      );
      return webView.setWebViewClient(webViewClient);
    }
  }

  Future<void> _trySetJavaScriptMode(JavascriptMode? mode) async {
    if (mode != null) {
      switch (mode) {
        case JavascriptMode.disabled:
          return webView.settings.setJavaScriptEnabled(false);
        case JavascriptMode.unrestricted:
          return webView.settings.setJavaScriptEnabled(true);
      }
    }
  }

  Future<void> _trySetDebuggingEnabled(bool? debuggingEnabled) async {
    if (debuggingEnabled != null) {
      return android_webview.WebView.setWebContentsDebuggingEnabled(
        debuggingEnabled,
      );
    }
  }

  Future<void> _trySetUserAgent(WebSetting<String?> userAgent) async {
    if (userAgent.isPresent) {
      return webView.settings.setUserAgentString(userAgent.value!);
    }
  }
}

class _JavaScriptChannelImpl extends android_webview.JavaScriptChannel {
  _JavaScriptChannelImpl(String channelName, this.javascriptChannelRegistry)
      : super(channelName);

  final JavascriptChannelRegistry javascriptChannelRegistry;

  @override
  void postMessage(String message) {
    javascriptChannelRegistry.onJavascriptChannelMessage(channelName, message);
  }
}

class _DownloadListenerImpl extends android_webview.DownloadListener {
  _DownloadListenerImpl({
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

class _WebViewClientImpl extends android_webview.WebViewClient {
  _WebViewClientImpl({
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
    callbacksHandler.onWebResourceError(WebResourceError(
      errorCode: error.errorCode,
      description: error.description,
      failingUrl: request.url,
      errorType: _errorCodeToErrorType(error.errorCode),
    ));
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

class _WebChromeClientImpl extends android_webview.WebChromeClient {
  _WebChromeClientImpl({required this.callbacksHandler});

  final WebViewPlatformCallbacksHandler callbacksHandler;
  bool hasProgressTracking = false;

  @override
  void onProgressChanged(android_webview.WebView webView, int progress) {
    if (hasProgressTracking) callbacksHandler.onProgress(progress);
  }
}
