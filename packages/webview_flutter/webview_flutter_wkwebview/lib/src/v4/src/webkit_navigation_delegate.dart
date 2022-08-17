// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter_platform_interface/v4/webview_flutter_platform_interface.dart';

import '../../foundation/foundation.dart';
import '../../web_kit/web_kit.dart';
import 'webkit_proxy.dart';

/// An implementation of [WebResourceError] with the WebKit API.
class WebKitWebResourceError extends WebResourceError {
  WebKitWebResourceError._(this._nsError)
      : super(
          errorCode: _nsError.code,
          description: _nsError.localizedDescription,
          errorType: _toWebResourceErrorType(_nsError.code),
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

/// An implementation of [PlatformNavigationDelegate] with the WebKit API.
class WebKitNavigationDelegate extends PlatformNavigationDelegate {
  /// Constructs a [WebKitNavigationDelegate].
  WebKitNavigationDelegate(
    super.params, {
    @visibleForTesting WebKitProxy webKitProxy = const WebKitProxy(),
  }) : super.implementation() {
    final WeakReference<WebKitNavigationDelegate> weakThis =
        WeakReference<WebKitNavigationDelegate>(this);
    navigationDelegate = webKitProxy.createNavigationDelegate(
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
          final bool allow = await weakThis.target!._onNavigationRequest!(
            url: action.request.url,
            isForMainFrame: action.targetFrame.isMainFrame,
          );
          return allow
              ? WKNavigationActionPolicy.allow
              : WKNavigationActionPolicy.cancel;
        }
        return WKNavigationActionPolicy.allow;
      },
      didFailNavigation: (WKWebView webView, NSError error) {
        if (weakThis.target?._onWebResourceError != null) {
          weakThis.target!._onWebResourceError!(
            WebKitWebResourceError._(error),
          );
        }
      },
      didFailProvisionalNavigation: (WKWebView webView, NSError error) {
        if (weakThis.target?._onWebResourceError != null) {
          weakThis.target!._onWebResourceError!(
            WebKitWebResourceError._(error),
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
            ),
          );
        }
      },
    );
  }

  // Used to set `WKWebView.setNavigationDelegate` in `WebKitWebViewController`.
  /// WebKit class that handles navigation changes and tracking navigation
  /// requests.
  late final WKNavigationDelegate navigationDelegate;

  void Function(String url)? _onPageFinished;
  void Function(String url)? _onPageStarted;
  void Function(int progress)? _onProgress;
  void Function(WebResourceError error)? _onWebResourceError;
  FutureOr<bool> Function({required String url, required bool isForMainFrame})?
      _onNavigationRequest;

  // `WKWebView` in `WebKitWebViewController` uses this to track loading
  // progress. This can't be done with `WKNavigationDelegate`.
  /// Callback method that receives progress of a loading page.
  void Function(int progress)? get onProgress => _onProgress;

  @override
  Future<void> setOnPageFinished(
    void Function(String url) onPageFinished,
  ) async {
    _onPageFinished = onPageFinished;
  }

  @override
  Future<void> setOnPageStarted(void Function(String url) onPageStarted) async {
    _onPageStarted = onPageStarted;
  }

  @override
  Future<void> setOnProgress(void Function(int progress) onProgress) async {
    _onProgress = onProgress;
  }

  @override
  Future<void> setOnWebResourceError(
    void Function(WebResourceError error) onWebResourceError,
  ) async {
    _onWebResourceError = onWebResourceError;
  }

  @override
  Future<void> setOnNavigationRequest(
    FutureOr<bool> Function({required String url, required bool isForMainFrame})
        onNavigationRequest,
  ) async {
    _onNavigationRequest = onNavigationRequest;
  }
}
