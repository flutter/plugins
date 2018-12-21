// Copyright (c) 2014, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of webview_flutter;

/// An exception caused by an error in a pkg/http client.
class WebViewError extends Error {
  WebViewError(this.url, this.code, this.description) : assert(url != null);

  /// The URL of the HTTP request or response that failed.
  final String url;

  /// The error code of the HTTP request or response that failed.
  final int code;

  /// The error description of the HTTP request or response that failed.
  final String description;
}
