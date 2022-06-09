// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:webview_flutter_platform_interface/v4/webview_flutter_platform_interface.dart';

import '../android_webview.dart' as android_webview;
import 'types/android_navigation_delegate_creation_params.dart';
import 'types/android_web_resource_error.dart';

/// A place to register callback methods responsible to handle navigation events
/// triggered by the [android_webview.WebView].
class AndroidNavigationDelegate extends PlatformNavigationDelegate {
  /// Creates a new [AndroidNavigationkDelegate].
  AndroidNavigationDelegate(AndroidNavigationDelegateCreationParams params)
      : this.fromNativeApi(
          params,
        );

  /// Creates a new [AndroidNavigationDelegate] using the Android native [android_webview.WebView] implementation.
  ///
  /// This constructor is only used for testing. An instance should be obtained
  /// with the default [AndroidNavigationDelegate] constructor.
  @visibleForTesting
  AndroidNavigationDelegate.fromNativeApi(
    AndroidNavigationDelegateCreationParams params,
  )   : _androidWebViewClient = params.androidWebViewClient,
        _androidWebChromeClient = params.androidWebChromeClient,
        _loadUrl = params.loadUrl,
        super.implementation(params);

  final AndroidWebViewClient _androidWebViewClient;

  final AndroidWebChromeClient _androidWebChromeClient;

  final Future<void> Function(String url, Map<String, String>? headers)?
      _loadUrl;

  @override
  Future<void> setOnNavigationRequest(
    FutureOr<bool> Function({required String url, required bool isForMainFrame})
        onNavigationRequest,
  ) async {
    _androidWebViewClient.onLoadUrlCallback = _loadUrl;
    _androidWebViewClient.onNavigationRequestCallback = onNavigationRequest;
  }

  @override
  Future<void> setOnPageStarted(
    void Function(String url) onPageStarted,
  ) async {
    _androidWebViewClient.onPageStartedCallback = onPageStarted;
  }

  @override
  Future<void> setOnPageFinished(
    void Function(String url) onPageFinished,
  ) async {
    _androidWebViewClient.onPageFinishedCallback = onPageFinished;
  }

  @override
  Future<void> setOnProgress(
    void Function(int progress) onProgress,
  ) async {
    _androidWebChromeClient.onProgress = onProgress;
  }

  @override
  Future<void> setOnWebResourceError(
    void Function(WebResourceError error) onWebResourceError,
  ) async {
    _androidWebViewClient.onWebResourceErrorCallback = onWebResourceError;
  }
}

/// Receives various navigation requests and errors for [AndroidNavigationDelegate].
class AndroidWebViewClient extends android_webview.WebViewClient {
  /// Callback when [android_webview.WebViewClient] receives a callback from [android_webview.WebViewClient.onPageStarted].
  void Function(String url)? onPageStartedCallback;

  /// Callback when [android_webview.WebViewClient] receives a callback from [android_webview.WebViewClient.onPageFinished].
  void Function(String url)? onPageFinishedCallback;

  /// Callback when [android_webview.WebViewClient] receives an error callback.
  void Function(WebResourceError error)? onWebResourceErrorCallback;

  /// Checks whether a navigation request should be approved or disaproved.
  FutureOr<bool> Function({
    required String url,
    required bool isForMainFrame,
  })? onNavigationRequestCallback;

  /// Callback when a navigation request is approved.
  Future<void> Function(String url, Map<String, String>? headers)?
      onLoadUrlCallback;

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
      onLoadUrlCallback != null && onNavigationRequestCallback != null;

  @override
  void onPageStarted(android_webview.WebView webView, String url) {
    if (onPageStartedCallback != null) {
      onPageStartedCallback!(url);
    }
  }

  @override
  void onPageFinished(android_webview.WebView webView, String url) {
    if (onPageFinishedCallback != null) {
      onPageFinishedCallback!(url);
    }
  }

  @override
  void onReceivedError(
    android_webview.WebView webView,
    int errorCode,
    String description,
    String failingUrl,
  ) {
    if (onWebResourceErrorCallback != null) {
      onWebResourceErrorCallback!(AndroidWebResourceError(
        errorCode: errorCode,
        description: description,
        failingUrl: failingUrl,
        errorType: _errorCodeToErrorType(errorCode),
      ));
    }
  }

  @override
  void onReceivedRequestError(
    android_webview.WebView webView,
    android_webview.WebResourceRequest request,
    android_webview.WebResourceError error,
  ) {
    if (request.isForMainFrame && onWebResourceErrorCallback != null) {
      onWebResourceErrorCallback!(AndroidWebResourceError(
        errorCode: error.errorCode,
        description: error.description,
        failingUrl: request.url,
        errorType: _errorCodeToErrorType(error.errorCode),
      ));
    }
  }

  @override
  void urlLoading(
    android_webview.WebView webView,
    String url,
  ) {
    if (!handlesNavigation) {
      return;
    }

    final FutureOr<bool> returnValue = onNavigationRequestCallback!(
      url: url,
      isForMainFrame: true,
    );

    if (returnValue is bool && returnValue) {
      onLoadUrlCallback!(url, <String, String>{});
    } else if (returnValue is Future<bool>) {
      returnValue.then((bool shouldLoadUrl) {
        if (shouldLoadUrl) {
          onLoadUrlCallback!(url, <String, String>{});
        }
      });
    }
  }

  @override
  void requestLoading(
    android_webview.WebView webView,
    android_webview.WebResourceRequest request,
  ) {
    if (!handlesNavigation) {
      return;
    }

    final FutureOr<bool> returnValue = onNavigationRequestCallback!(
      url: request.url,
      isForMainFrame: request.isForMainFrame,
    );

    if (returnValue is bool && returnValue) {
      onLoadUrlCallback!(request.url, <String, String>{});
    } else if (returnValue is Future<bool>) {
      returnValue.then((bool shouldLoadUrl) {
        if (shouldLoadUrl) {
          onLoadUrlCallback!(request.url, <String, String>{});
        }
      });
    }
  }
}

/// Handles JavaScript dialogs, favicons, titles, and the progress for [WebViewAndroidPlatformController].
class AndroidWebChromeClient extends android_webview.WebChromeClient {
  /// Callback when [android_webview.WebChromeClient] receives a callback from [android_webview.WebChromeClient.onProgressChanged].
  void Function(int progress)? onProgress;

  @override
  void onProgressChanged(android_webview.WebView webView, int progress) {
    if (onProgress != null) {
      onProgress!(progress);
    }
  }
}
