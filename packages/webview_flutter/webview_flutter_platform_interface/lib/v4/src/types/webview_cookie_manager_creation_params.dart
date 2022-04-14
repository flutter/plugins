// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/// Object specifying creation parameters for creating a [WebViewCookieManagerDelegate].
///
/// Platform specific implementations can add additional fields by extending
/// this class.
///
/// {@tool sample}
/// This example demonstrates how to extend the [WebViewCookieManagerCreationParams] to
/// provide additional platform specific parameters.
///
/// When extending [WebViewCookieManagerCreationParams] additional
/// parameters should always accept `null` or have a default value to prevent
/// breaking changes.
///
/// ```dart
/// class WKWebViewCookieManagerCreationParams extends WebViewCookieManagerCreationParams {
///   WKWebViewCookieManagerCreationParams({
///     this.uri,
///   }) : super();
///
///   final Uri? uri;
/// }
/// ```
/// {@end-tool}
class WebViewCookieManagerCreationParams {
  /// Used by the platform implementation to create a new [WebViewCookieManagerDelegate].
  WebViewCookieManagerCreationParams();
}
