// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:webview_flutter_platform_interface/src/v4/webview_controller_delegate.dart';

import '../webview_platform.dart';

/// Defines the supported HTTP methods for loading a page in
/// [WebViewControllerDelegate].
enum LoadRequestMethod {
  /// HTTP GET method.
  get,

  /// HTTP POST method.
  post,
}

/// Extension methods on the [LoadRequestMethod] enum.
extension LoadRequestMethodExtensions on LoadRequestMethod {
  /// Converts [LoadRequestMethod] to [String] format.
  String serialize() {
    switch (this) {
      case LoadRequestMethod.get:
        return 'get';
      case LoadRequestMethod.post:
        return 'post';
    }
  }
}

/// Defines the parameters that can be used to load a page with the
/// [WebViewControllerDelegate].
///
/// Platform specific implementations can add additional fields by extending this
/// class and provide a factory method that takes the
/// [LoadRequestParamsDelegate] as a parameter.
///
/// {@tool sample}
/// This example demonstrates how to extend the [LoadRequestParamsDelegate] to
/// provide additional platform specific parameters.
///
/// Note that the additional parameters should always accept `null` or have a
/// default value to prevent breaking changes.
///
/// ```dart
/// class AndroidLoadRequestParamsDelegate extends LoadRequestParamsDelegate {
///   AndroidLoadRequestParamsDelegate._(
///     LoadRequestParamsDelegate loadRequestParams,
///     this.historyUrl,
///   ) : super(
///     uri: loadRequestParams.uri,
///     method: loadRequestParams.method,
///     headers: loadRequestParams.headers,
///     body: loadRequestParams.body,
///   );
///
///   factory AndroidLoadRequestParamsDelegate.fromLoadRequestParamsDelegate(
///     LoadRequestParamsDelegate loadRequestParams, {
///     Uri? historyUrl,
///   }) {
///     return AndroidLoadRequestParamsDelegate._(
///       loadRequestParams: loadRequestParams,
///       historyUrl: historyUrl,
///     );
///   }
///
///   final Uri? historyUrl;
/// }
/// ```
/// {@end-tool}
class LoadRequestParamsDelegate extends PlatformInterface {
  /// Creates a new [LoadRequestParamsDelegate].
  factory LoadRequestParamsDelegate({
    required Uri uri,
    required LoadRequestMethod method,
    required Map<String, String> headers,
    Uint8List? body,
  }) {
    final LoadRequestParamsDelegate loadRequestParamsDelegate =
        WebViewPlatform.instance!.createLoadRequestParamsDelegate(
      uri: uri,
      method: method,
      headers: headers,
      body: body,
    );
    PlatformInterface.verify(loadRequestParamsDelegate, _token);
    return loadRequestParamsDelegate;
  }

  /// Used by the platform implementation to create a new
  /// [LoadRequestParamsDelegate].
  ///
  /// Should only be used by platform implementations because they can't extend
  /// a class that only contains a factory constructor.
  @protected
  LoadRequestParamsDelegate.implementation({
    required this.uri,
    required this.method,
    required this.headers,
    this.body,
  }) : super(token: _token);

  static final Object _token = Object();

  /// URI for the request.
  final Uri uri;

  /// HTTP method used to make the request.
  final LoadRequestMethod method;

  /// Headers for the request.
  final Map<String, String> headers;

  /// HTTP body for the request.
  final Uint8List? body;

  /// Serializes the [WebViewRequest] to JSON.
  Map<String, dynamic> toJson() => <String, dynamic>{
        'uri': uri.toString(),
        'method': method.serialize(),
        'headers': headers,
        'body': body,
      };
}
