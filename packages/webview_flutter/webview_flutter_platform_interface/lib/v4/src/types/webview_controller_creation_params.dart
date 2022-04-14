// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';

/// Object specifying creation parameters for creating a [WebViewControllerDelegate].
///
/// Platform specific implementations can add additional fields by extending
/// this class.
///
/// {@tool sample}
/// This example demonstrates how to extend the [WebViewControllerCreationParams] to
/// provide additional platform specific parameters.
///
/// When extending [WebViewControllerCreationParams] additional parameters
/// should always accept `null` or have a default value to prevent breaking
/// changes.
///
/// ```dart
/// class WKWebViewControllerCreationParams
///     extends WebViewControllerCreationParams {
///   WKWebViewControllerCreationParams._(
///     // This parameter prevents breaking changes later.
///     // ignore: avoid_unused_constructor_parameters
///     WebViewControllerCreationParams params, {
///     this.domain,
///   }) : super();
///
///   factory WKWebViewControllerCreationParams.fromWebViewControllerCreationParams(
///     WebViewControllerCreationParams params, {
///     String? domain,
///   }) {
///     return WKWebViewControllerCreationParams._(params, domain: domain);
///   }
///
///   final String? domain;
/// }
/// ```
/// {@end-tool}
@immutable
class WebViewControllerCreationParams {
  /// Used by the platform implementation to create a new [WebViewControllerCreationParams].
  const WebViewControllerCreationParams();
}
