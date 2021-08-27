// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:typed_data';

/// Defines the supported HTTP methods for loading a page in the [WebView].
enum WebViewLoadMethod {
  /// HTTP GET method.
  get,

  /// HTTP POST method.
  post,
}

/// Extension methods on the [WebViewLoadMethod] enum.
extension WebViewLoadMethodExtensions on WebViewLoadMethod {
  /// Converts [WebViewLoadMethod] to [String] format.
  String serialize() {
    switch (this) {
      case WebViewLoadMethod.get:
        return 'get';
      case WebViewLoadMethod.post:
        return 'post';
    }
  }
}

/// Defines the parameters that can be used to load a page in the [WebView].
class WebViewRequest {
  /// Creates the [WebViewRequest].
  WebViewRequest({
    required this.uri,
    required this.method,
    this.headers = const {},
    this.body,
  });

  /// HTTP URL for the request.
  final Uri uri;

  /// HTTP method used to load the page.
  final WebViewLoadMethod method;

  /// HTTP headers for the request.
  final Map<String, String> headers;

  /// HTTP body for the request.
  final Uint8List? body;

  /// Serializes the [WebViewRequest] to JSON.
  Map<String, dynamic> toJson() => {
        'url': this.uri.toString(),
        'method': this.method.serialize(),
        'headers': this.headers,
        'body': this.body,
      };
}
