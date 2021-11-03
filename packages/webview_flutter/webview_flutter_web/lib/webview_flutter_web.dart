// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:html';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_web_plugins/src/plugin_registry.dart';
import 'package:webview_flutter_platform_interface/webview_flutter_platform_interface.dart';
import 'shims/dart_ui.dart' as ui;

/// Builds an iframe based WebView.
///
/// This is used as the default implementation for [WebView.platform] on web.
class WebWebViewPlatform implements WebViewPlatform {
  WebWebViewPlatform() {
    ui.platformViewRegistry.registerViewFactory(
        'webview-iframe',
        (int viewId) => IFrameElement()
          ..id = 'webview-$viewId'
          ..width = '100%'
          ..height = '100%'
          ..style.border = 'none');
  }

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
    return HtmlElementView(
      viewType: 'webview-iframe',
      onPlatformViewCreated: (int viewId) {
        if (onWebViewPlatformCreated == null) {
          return;
        }
        IFrameElement element =
            document.getElementById('webview-$viewId') as IFrameElement;
        if (creationParams.initialUrl != null) {
          element.src = creationParams.initialUrl;
        }
        onWebViewPlatformCreated(WebWebViewPlatformController(
          viewId,
          webViewPlatformCallbacksHandler,
        ));
      },
    );
  }

  @override
  Future<bool> clearCookies() => MethodChannelWebViewPlatform.clearCookies();

  static void registerWith(Registrar registrar) {}
}

class WebWebViewPlatformController implements WebViewPlatformController {
  final int viewId;
  final WebViewPlatformCallbacksHandler webViewPlatformCallbacksHandler;

  WebWebViewPlatformController(
      this.viewId, this.webViewPlatformCallbacksHandler);

  @override
  Future<void> addJavascriptChannels(Set<String> javascriptChannelNames) {
    // TODO: implement addJavascriptChannels
    throw UnimplementedError();
  }

  @override
  Future<bool> canGoBack() {
    // TODO: implement canGoBack
    throw UnimplementedError();
  }

  @override
  Future<bool> canGoForward() {
    // TODO: implement canGoForward
    throw UnimplementedError();
  }

  @override
  Future<void> clearCache() {
    // TODO: implement clearCache
    throw UnimplementedError();
  }

  @override
  Future<String?> currentUrl() {
    // TODO: implement currentUrl
    throw UnimplementedError();
  }

  @override
  Future<String> evaluateJavascript(String javascript) {
    // TODO: implement evaluateJavascript
    throw UnimplementedError();
  }

  @override
  Future<int> getScrollX() {
    // TODO: implement getScrollX
    throw UnimplementedError();
  }

  @override
  Future<int> getScrollY() {
    // TODO: implement getScrollY
    throw UnimplementedError();
  }

  @override
  Future<String?> getTitle() {
    // TODO: implement getTitle
    throw UnimplementedError();
  }

  @override
  Future<void> goBack() {
    // TODO: implement goBack
    throw UnimplementedError();
  }

  @override
  Future<void> goForward() {
    // TODO: implement goForward
    throw UnimplementedError();
  }

  @override
  Future<void> loadUrl(String url, Map<String, String>? headers) {
    // TODO: implement loadUrl
    throw UnimplementedError();
  }

  @override
  Future<void> reload() {
    // TODO: implement reload
    throw UnimplementedError();
  }

  @override
  Future<void> removeJavascriptChannels(Set<String> javascriptChannelNames) {
    // TODO: implement removeJavascriptChannels
    throw UnimplementedError();
  }

  @override
  Future<void> runJavascript(String javascript) {
    // TODO: implement runJavascript
    throw UnimplementedError();
  }

  @override
  Future<String> runJavascriptReturningResult(String javascript) {
    // TODO: implement runJavascriptReturningResult
    throw UnimplementedError();
  }

  @override
  Future<void> scrollBy(int x, int y) {
    // TODO: implement scrollBy
    throw UnimplementedError();
  }

  @override
  Future<void> scrollTo(int x, int y) {
    // TODO: implement scrollTo
    throw UnimplementedError();
  }

  @override
  Future<void> updateSettings(WebSettings setting) {
    // TODO: implement updateSettings
    throw UnimplementedError();
  }
}
