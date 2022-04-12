// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:webview_flutter_platform_interface/src/v4/webview_controller_delegate.dart';

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

/// Defines the parameters that can be used to load a page with the [WebViewControllerDelegate].
///
/// Platform specific implementations can add additional fields by extending
/// this class.
///
/// {@tool sample}
/// This example demonstrates how to extend the [LoadRequestParams] to
/// provide additional platform specific parameters.
///
/// When extending [LoadRequestParams] additional parameters should always
/// accept `null` or have a default value to prevent breaking changes.
///
/// ```dart
/// class AndroidLoadRequestParamsDelegate extends LoadRequestParamsDelegate {
///   AndroidLoadRequestParamsDelegate({
///     required Uri uri,
///     required LoadRequestMethod method,
///     required Map<String, String> headers,
///     Uint8List? body,
///     this.historyUrl,
///   }) : super(
///     uri: uri,
///     method: method,
///     body: body,
///   );
///
///   final Uri? historyUrl;
/// }
/// ```
/// {@end-tool}
@immutable
class LoadRequestParams {
  /// Used by the platform implementation to create a new [LoadRequestParams].
  const LoadRequestParams({
    required this.uri,
    required this.method,
    required this.headers,
    this.body,
  });

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
