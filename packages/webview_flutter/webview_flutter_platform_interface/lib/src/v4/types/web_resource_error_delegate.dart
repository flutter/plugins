// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/foundation.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import '../webview_platform.dart';

// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/// Possible error type categorizations used by [WebResourceError].
enum WebResourceErrorType {
  /// User authentication failed on server.
  authentication,

  /// Malformed URL.
  badUrl,

  /// Failed to connect to the server.
  connect,

  /// Failed to perform SSL handshake.
  failedSslHandshake,

  /// Generic file error.
  file,

  /// File not found.
  fileNotFound,

  /// Server or proxy hostname lookup failed.
  hostLookup,

  /// Failed to read or write to the server.
  io,

  /// User authentication failed on proxy.
  proxyAuthentication,

  /// Too many redirects.
  redirectLoop,

  /// Connection timed out.
  timeout,

  /// Too many requests during this load.
  tooManyRequests,

  /// Generic error.
  unknown,

  /// Resource load was canceled by Safe Browsing.
  unsafeResource,

  /// Unsupported authentication scheme (not basic or digest).
  unsupportedAuthScheme,

  /// Unsupported URI scheme.
  unsupportedScheme,

  /// The web content process was terminated.
  webContentProcessTerminated,

  /// The web view was invalidated.
  webViewInvalidated,

  /// A JavaScript exception occurred.
  javaScriptExceptionOccurred,

  /// The result of JavaScript execution could not be returned.
  javaScriptResultTypeIsUnsupported,
}

/// Error returned in `WebView.onWebResourceError` when a web resource loading
/// error has occurred.
///
/// Platform specific implementations can add additional fields by extending
/// this class and provide a factory method that takes the
/// [WebResourceErrorDelegate] as a parameter.
///
/// {@tool sample}
/// This example demonstrates how to extend the [WebResourceErrorDelegate] to
/// provide additional platform specific parameters.
///
/// Note that the additional parameters should always accept `null` or have a
/// default value to prevent breaking changes.
///
/// ```dart
/// class IOSWebResourceError extends WebResourceErrorDelegate {
///   IOSWebResourceError._(
///     WebResourceErrorDelegate webResourceError,
///     this.domain,
///   ) : super(
///     errorCode: webResourceError.errorCode,
///     description: webResourceError.description,
///     errorType: webResourceError.errorType,
///   );
///
///   factory IOSWebResourceError.fromWebResourceError(
///     WebResourceErrorDelegate webResourceError, {
///     String? domain,
///   }) {
///     return IOSWebResourceError._(
///       webResourceError: webResourceError,
///       domain: domain,
///     );
///   }
///
///   final String? domain;
/// }
/// ```
/// {@end-tool}
class WebResourceErrorDelegate extends PlatformInterface {
  /// Creates a new [WebResourceError]
  ///
  /// A user should not need to instantiate this class, but will receive one in
  /// [WebResourceErrorCallback].
  factory WebResourceErrorDelegate({
    required int errorCode,
    required String description,
    WebResourceErrorType? errorType,
  }) {
    final WebResourceErrorDelegate webResourceErrorDelegate =
        WebViewPlatform.instance!.createWebResourceErrorDelegate(
      errorCode: errorCode,
      description: description,
      errorType: errorType,
    );
    PlatformInterface.verify(webResourceErrorDelegate, _token);
    return webResourceErrorDelegate;
  }

  /// Used by the platform implementation to create a new
  /// [WebResourceErrorDelegate].
  ///
  /// Should only be used by platform implementations because they can't extend
  /// a class that only contains a factory constructor.
  @protected
  WebResourceErrorDelegate.implementation({
    required this.errorCode,
    required this.description,
    this.errorType,
  }) : super(token: _token);

  static final Object _token = Object();

  /// Raw code of the error from the respective platform.
  final int errorCode;

  /// Description of the error that can be used to communicate the problem to the user.
  final String description;

  /// The type this error can be categorized as.
  ///
  /// This will never be `null` on Android, but can be `null` on iOS.
  final WebResourceErrorType? errorType;
}
