// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
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
    assert(webViewPlatformCallbacksHandler != null);
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
          if (onWebViewPlatformCreated == null) {
            return;
          }
          onWebViewPlatformCreated(MethodChannelWebViewPlatform(
            id,
            webViewPlatformCallbacksHandler,
            javascriptChannelRegistry,
          ));
        },
        gestureRecognizers: gestureRecognizers,
        layoutDirection: Directionality.maybeOf(context) ?? TextDirection.rtl,
        creationParams:
            MethodChannelWebViewPlatform.creationParamsToMap(creationParams),
        creationParamsCodec: const StandardMessageCodec(),
      ),
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
  late _AndroidWebViewPlatformController platformController;

  @override
  void initState() {
    super.initState();
    final android_webview.WebView webView = android_webview.WebView(
      useHybridComposition: false,
    );
    android_webview.WebView.api.createFromInstance(webView);

    webView.settings.setDomStorageEnabled(true);
    webView.settings.setJavaScriptCanOpenWindowsAutomatically(true);
    webView.settings.setSupportMultipleWindows(true);

    platformController = _AndroidWebViewPlatformController(
        webView, widget.webViewPlatformCallbacksHandler);

    final WebSettings? webSettings = widget.creationParams.webSettings;
    if (webSettings != null) {
      platformController.updateSettings(webSettings);
    }

    final AutoMediaPlaybackPolicy autoMediaPlaybackPolicy =
        widget.creationParams.autoMediaPlaybackPolicy;
    switch (autoMediaPlaybackPolicy) {
      case AutoMediaPlaybackPolicy.always_allow:
        webView.settings.setMediaPlaybackRequiresUserGesture(false);
        break;
      default:
        webView.settings.setMediaPlaybackRequiresUserGesture(true);
    }

    platformController.addJavascriptChannels(
      widget.creationParams.javascriptChannelNames,
    );

    final String? userAgent = widget.creationParams.userAgent;
    if (userAgent != null) {
      webView.settings.setUserAgentString(userAgent);
    }

    final String? initialUrl = widget.creationParams.initialUrl;
    if (initialUrl != null) {
      platformController.loadUrl(initialUrl, <String, String>{});
    }
  }

  @override
  void dispose() {
    super.dispose();
    //android_webview.WebView.api.disposeFromInstance(webView);
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
          // if (createdCallback != null) {
          //   createdCallback(MethodChannelWebViewPlatform(
          //     id,
          //     webViewPlatformCallbacksHandler,
          //     javascriptChannelRegistry,
          //   ));
          // }
        },
        gestureRecognizers: widget.gestureRecognizers,
        layoutDirection: Directionality.maybeOf(context) ?? TextDirection.rtl,
        // creationParams:
        //     MethodChannelWebViewPlatform.creationParamsToMap(creationParams),
        // creationParamsCodec: const StandardMessageCodec(),
      ),
    );
  }
}

class _AndroidWebViewPlatformController extends WebViewPlatformController {
  _AndroidWebViewPlatformController(
    this.webView,
    WebViewPlatformCallbacksHandler handler,
  ) : super(handler) {
    webViewClient = _WebViewClientImpl(handler);
    downloadListener = _DownloadListenerImpl(handler);
    webView.setWebViewClient(webViewClient);
    webView.setDownloadListener(downloadListener);
  }

  final android_webview.WebView webView;
  late final android_webview.WebViewClient webViewClient;
  late final android_webview.DownloadListener downloadListener;

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
  Future<void> updateSettings(WebSettings settings) async {}

  @override
  Future<String> evaluateJavascript(String javascriptString) async {
    return await webView.evaluateJavascript(javascriptString) ?? '';
  }

  @override
  Future<void> addJavascriptChannels(Set<String> javascriptChannelNames) {
    return Future.wait(
      javascriptChannelNames.map<Future<void>>(
        (String channelName) {
          return webView
              .addJavaScriptChannel(_JavaScriptChannelImpl(channelName));
        },
      ),
    );
  }

  @override
  Future<void> removeJavascriptChannels(
      Set<String> javascriptChannelNames) async {
    // return _channel.invokeMethod<void>(
    //     'removeJavascriptChannels', javascriptChannelNames.toList());
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
}

class _JavaScriptChannelImpl extends android_webview.JavaScriptChannel {
  _JavaScriptChannelImpl(String channelName) : super(channelName);

  @override
  void postMessage(String message) {
    super.postMessage(message);
  }
}

class _DownloadListenerImpl extends android_webview.DownloadListener {
  _DownloadListenerImpl(this.callbacksHandler);

  final WebViewPlatformCallbacksHandler callbacksHandler;

  @override
  void onDownloadStart(
    String url,
    String userAgent,
    String contentDisposition,
    String mimetype,
    int contentLength,
  ) {
    callbacksHandler.onNavigationRequest(url: url, isForMainFrame: true);
  }
}

class _WebViewClientImpl extends android_webview.WebViewClient {
  _WebViewClientImpl(this.callbacksHandler);

  final WebViewPlatformCallbacksHandler callbacksHandler;

  @override
  void onPageStarted(android_webview.WebView webView, String url) {
    callbacksHandler.onPageStarted(url);
  }

  @override
  void onPageFinished(android_webview.WebView webView, String url) {
    callbacksHandler.onPageFinished(url);
  }

  @override
  void urlLoading(android_webview.WebView webView, String url) {
    final FutureOr<bool> returnValue = callbacksHandler.onNavigationRequest(
      url: url,
      isForMainFrame: true,
    );
  }

  @override
  void requestLoading(android_webview.WebView webView,
      android_webview.WebResourceRequest request) {
    callbacksHandler.onNavigationRequest(
      url: request.url,
      isForMainFrame: request.isForMainFrame,
    );
  }
}
