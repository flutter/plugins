// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/foundation.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import '../webview_platform.dart';
import 'web_resource_error_type.dart';

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
    required String errorCode,
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
  ///
  /// On Android, the error code will be a constant from a
  /// [WebViewClient](https://developer.android.com/reference/android/webkit/WebViewClient#summary) and
  /// will have a corresponding [errorType].
  ///
  /// On iOS, the error code will be a constant from `NSError.code` in
  /// Objective-C. See
  /// https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/ErrorHandlingCocoa/ErrorObjectsDomains/ErrorObjectsDomains.html
  /// for more information on error handling on iOS. Some possible error codes
  /// can be found at https://developer.apple.com/documentation/webkit/wkerrorcode?language=objc.
  final int errorCode;

  /// Description of the error that can be used to communicate the problem to the user.
  final String description;

  /// The type this error can be categorized as.
  ///
  /// This will never be `null` on Android, but can be `null` on iOS.
  final WebResourceErrorType? errorType;
}
