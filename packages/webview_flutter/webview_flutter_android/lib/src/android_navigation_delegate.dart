// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:webview_flutter_platform_interface/webview_flutter_platform_interface.dart';

import 'android_proxy.dart';
import 'android_webview.dart' as android_webview;

/// Signature for the `loadRequest` callback responsible for loading the [url]
/// after a navigation request has been approved.
typedef LoadRequestCallback = Future<void> Function(LoadRequestParams params);

/// Error returned in `WebView.onWebResourceError` when a web resource loading error has occurred.
@immutable
class AndroidWebResourceError extends WebResourceError {
  /// Creates a new [AndroidWebResourceError].
  AndroidWebResourceError._({
    required super.errorCode,
    required super.description,
    super.isForMainFrame,
    this.failingUrl,
  }) : super(
          errorType: _errorCodeToErrorType(errorCode),
        );

  /// Gets the URL for which the failing resource request was made.
  final String? failingUrl;

  static WebResourceErrorType? _errorCodeToErrorType(int errorCode) {
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
}

/// Object specifying creation parameters for creating a [AndroidNavigationDelegate].
///
/// When adding additional fields make sure they can be null or have a default
/// value to avoid breaking changes. See [PlatformNavigationDelegateCreationParams] for
/// more information.
@immutable
class AndroidNavigationDelegateCreationParams
    extends PlatformNavigationDelegateCreationParams {
  /// Creates a new [AndroidNavigationDelegateCreationParams] instance.
  const AndroidNavigationDelegateCreationParams._({
    @visibleForTesting this.androidWebViewProxy = const AndroidWebViewProxy(),
  }) : super();

  /// Creates a [AndroidNavigationDelegateCreationParams] instance based on [PlatformNavigationDelegateCreationParams].
  factory AndroidNavigationDelegateCreationParams.fromPlatformNavigationDelegateCreationParams(
    // Recommended placeholder to prevent being broken by platform interface.
    // ignore: avoid_unused_constructor_parameters
    PlatformNavigationDelegateCreationParams params, {
    @visibleForTesting
        AndroidWebViewProxy androidWebViewProxy = const AndroidWebViewProxy(),
  }) {
    return AndroidNavigationDelegateCreationParams._(
      androidWebViewProxy: androidWebViewProxy,
    );
  }

  /// Handles constructing objects and calling static methods for the Android WebView
  /// native library.
  @visibleForTesting
  final AndroidWebViewProxy androidWebViewProxy;
}

/// A place to register callback methods responsible to handle navigation events
/// triggered by the [android_webview.WebView].
class AndroidNavigationDelegate extends PlatformNavigationDelegate {
  /// Creates a new [AndroidNavigationkDelegate].
  AndroidNavigationDelegate(PlatformNavigationDelegateCreationParams params)
      : super.implementation(params is AndroidNavigationDelegateCreationParams
            ? params
            : AndroidNavigationDelegateCreationParams
                .fromPlatformNavigationDelegateCreationParams(params)) {
    final WeakReference<AndroidNavigationDelegate> weakThis =
        WeakReference<AndroidNavigationDelegate>(this);

    _webChromeClient = (this.params as AndroidNavigationDelegateCreationParams)
        .androidWebViewProxy
        .createAndroidWebChromeClient(
            onProgressChanged: (android_webview.WebView webView, int progress) {
      if (weakThis.target?._onProgress != null) {
        weakThis.target!._onProgress!(progress);
      }
    });

    _webViewClient = (this.params as AndroidNavigationDelegateCreationParams)
        .androidWebViewProxy
        .createAndroidWebViewClient(
      onPageFinished: (android_webview.WebView webView, String url) {
        if (weakThis.target?._onPageFinished != null) {
          weakThis.target!._onPageFinished!(url);
        }
      },
      onPageStarted: (android_webview.WebView webView, String url) {
        if (weakThis.target?._onPageStarted != null) {
          weakThis.target!._onPageStarted!(url);
        }
      },
      onReceivedRequestError: (
        android_webview.WebView webView,
        android_webview.WebResourceRequest request,
        android_webview.WebResourceError error,
      ) {
        if (weakThis.target?._onWebResourceError != null) {
          weakThis.target!._onWebResourceError!(AndroidWebResourceError._(
            errorCode: error.errorCode,
            description: error.description,
            failingUrl: request.url,
            isForMainFrame: request.isForMainFrame,
          ));
        }
      },
      onReceivedError: (
        android_webview.WebView webView,
        int errorCode,
        String description,
        String failingUrl,
      ) {
        if (weakThis.target?._onWebResourceError != null) {
          weakThis.target!._onWebResourceError!(AndroidWebResourceError._(
            errorCode: errorCode,
            description: description,
            failingUrl: failingUrl,
            isForMainFrame: true,
          ));
        }
      },
      requestLoading: (
        android_webview.WebView webView,
        android_webview.WebResourceRequest request,
      ) {
        if (weakThis.target != null) {
          weakThis.target!._handleNavigation(
            request.url,
            headers: request.requestHeaders,
            isForMainFrame: request.isForMainFrame,
          );
        }
      },
      urlLoading: (
        android_webview.WebView webView,
        String url,
      ) {
        if (weakThis.target != null) {
          weakThis.target!._handleNavigation(url, isForMainFrame: true);
        }
      },
    );

    _downloadListener = (this.params as AndroidNavigationDelegateCreationParams)
        .androidWebViewProxy
        .createDownloadListener(
      onDownloadStart: (
        String url,
        String userAgent,
        String contentDisposition,
        String mimetype,
        int contentLength,
      ) {
        if (weakThis.target != null) {
          weakThis.target?._handleNavigation(url, isForMainFrame: true);
        }
      },
    );
  }

  late final android_webview.WebChromeClient _webChromeClient;

  /// Gets the native [android_webview.WebChromeClient] that is bridged by this [AndroidNavigationDelegate].
  ///
  /// Used by the [AndroidWebViewController] to set the `android_webview.WebView.setWebChromeClient`.
  android_webview.WebChromeClient get androidWebChromeClient =>
      _webChromeClient;

  late final android_webview.WebViewClient _webViewClient;

  /// Gets the native [android_webview.WebViewClient] that is bridged by this [AndroidNavigationDelegate].
  ///
  /// Used by the [AndroidWebViewController] to set the `android_webview.WebView.setWebViewClient`.
  android_webview.WebViewClient get androidWebViewClient => _webViewClient;

  late final android_webview.DownloadListener _downloadListener;

  /// Gets the native [android_webview.DownloadListener] that is bridged by this [AndroidNavigationDelegate].
  ///
  /// Used by the [AndroidWebViewController] to set the `android_webview.WebView.setDownloadListener`.
  android_webview.DownloadListener get androidDownloadListener =>
      _downloadListener;

  PageEventCallback? _onPageFinished;
  PageEventCallback? _onPageStarted;
  ProgressCallback? _onProgress;
  WebResourceErrorCallback? _onWebResourceError;
  NavigationRequestCallback? _onNavigationRequest;
  LoadRequestCallback? _onLoadRequest;

  void _handleNavigation(
    String url, {
    required bool isForMainFrame,
    Map<String, String> headers = const <String, String>{},
  }) {
    final LoadRequestCallback? onLoadRequest = _onLoadRequest;
    final NavigationRequestCallback? onNavigationRequest = _onNavigationRequest;

    if (onNavigationRequest == null || onLoadRequest == null) {
      return;
    }

    final FutureOr<NavigationDecision> returnValue = onNavigationRequest(
      NavigationRequest(
        url: url,
        isMainFrame: isForMainFrame,
      ),
    );

    if (returnValue is NavigationDecision &&
        returnValue == NavigationDecision.navigate) {
      onLoadRequest(LoadRequestParams(
        uri: Uri.parse(url),
        headers: headers,
      ));
    } else if (returnValue is Future<NavigationDecision>) {
      returnValue.then((NavigationDecision shouldLoadUrl) {
        if (shouldLoadUrl == NavigationDecision.navigate) {
          onLoadRequest(LoadRequestParams(
            uri: Uri.parse(url),
            headers: headers,
          ));
        }
      });
    }
  }

  /// Invoked when loading the url after a navigation request is approved.
  Future<void> setOnLoadRequest(
    LoadRequestCallback onLoadRequest,
  ) async {
    _onLoadRequest = onLoadRequest;
  }

  @override
  Future<void> setOnNavigationRequest(
    NavigationRequestCallback onNavigationRequest,
  ) async {
    _onNavigationRequest = onNavigationRequest;
    _webViewClient.setSynchronousReturnValueForShouldOverrideUrlLoading(true);
  }

  @override
  Future<void> setOnPageStarted(
    PageEventCallback onPageStarted,
  ) async {
    _onPageStarted = onPageStarted;
  }

  @override
  Future<void> setOnPageFinished(
    PageEventCallback onPageFinished,
  ) async {
    _onPageFinished = onPageFinished;
  }

  @override
  Future<void> setOnProgress(
    ProgressCallback onProgress,
  ) async {
    _onProgress = onProgress;
  }

  @override
  Future<void> setOnWebResourceError(
    WebResourceErrorCallback onWebResourceError,
  ) async {
    _onWebResourceError = onWebResourceError;
  }
}
