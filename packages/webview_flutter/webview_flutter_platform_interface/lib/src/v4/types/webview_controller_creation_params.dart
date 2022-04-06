// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/foundation.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

/// Object specifying creation parameters for creating a [WebViewControllerDelegate].
///
/// Platform specific implementations can add additional fields by extending
/// this class and provide a factory method that takes the
/// [WebViewControllerCreationParams] as a parameter.
///
/// {@tool sample}
/// This example demonstrates how to extend the [WebViewControllerCreationParams] to
/// provide additional platform specific parameters.
///
/// Note that the additional parameters should always accept `null` or have a
/// default value to prevent breaking changes.
///
/// ```dart
/// class IOSWebViewControllerCreationParams extends WebViewControllerCreationParams {
///   IOSWebViewControllerCreationParams._(this.iosParameter) : super();
///
///   factory IOSWebViewControllerCreationParams.fromWebViewControllerCreationParams({
///     String? iosParameter,
///   }) {
///     return IOSWebViewControllerCreationParams._(
///       iosParameter: iosParameter,
///     );
///   }
///
///   final String? iosParameter;
/// }
/// ```
/// {@end-tool}
class WebViewControllerCreationParams extends PlatformInterface {
  /// Creates a new [WebViewControllerCreationParams]
  factory WebViewControllerCreationParams() {
    final WebViewControllerCreationParams params =
        WebViewControllerCreationParams.implementation();
    PlatformInterface.verify(params, _token);
    return params;
  }

  /// Used by the platform implementation to create a new [WebViewControllerCreationParams].
  ///
  /// Should only be used by platform implementations because they can't extend
  /// a class that only contains a factory constructor.
  @protected
  WebViewControllerCreationParams.implementation() : super(token: _token);

  static final Object _token = Object();
}
