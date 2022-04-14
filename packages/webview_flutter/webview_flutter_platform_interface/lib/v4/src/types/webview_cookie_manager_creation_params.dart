// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';

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
/// class WKWebViewCookieManagerCreationParams
///     extends WebViewCookieManagerCreationParams {
///   WKWebViewCookieManagerCreationParams._(
///     // This parameter prevents breaking changes later.
///     // ignore: avoid_unused_constructor_parameters
///     WebViewCookieManagerCreationParams params, {
///     this.uri,
///   }) : super();
///
///   factory WKWebViewCookieManagerCreationParams.fromWebViewCookieManagerCreationParams(
///     WebViewCookieManagerCreationParams params, {
///     Uri? uri,
///   }) {
///     return WKWebViewCookieManagerCreationParams._(params, uri: uri);
///   }
///
///   final Uri? uri;
/// }
/// ```
/// {@end-tool}
@immutable
class WebViewCookieManagerCreationParams {
  /// Used by the platform implementation to create a new [WebViewCookieManagerDelegate].
  const WebViewCookieManagerCreationParams();
}
