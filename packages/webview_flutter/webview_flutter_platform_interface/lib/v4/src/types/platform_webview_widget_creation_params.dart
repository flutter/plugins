// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';

import '../platform_webview_controller.dart';

/// Object specifying creation parameters for creating a [WebViewWidgetDelegate].
///
/// Platform specific implementations can add additional fields by extending
/// this class.
///
/// {@tool sample}
/// This example demonstrates how to extend the [PlatformWebViewWidgetCreationParams] to
/// provide additional platform specific parameters.
///
/// When extending [PlatformWebViewWidgetCreationParams] additional parameters
/// should always accept `null` or have a default value to prevent breaking
/// changes.
///
/// ```dart
/// class WKWebViewWidgetCreationParams extends PlatformWebViewWidgetCreationParams {
///   WKWebViewWidgetCreationParams._(
///     // This parameter prevents breaking changes later.
///     // ignore: avoid_unused_constructor_parameters
///     PlatformWebViewWidgetCreationParams params, {
///     this.domain,
///   }) : super(
///           key: params.key,
///           controller: params.controller,
///           gestureRecognizers: params.gestureRecognizers,
///         );
///
///   factory WKWebViewWidgetCreationParams.fromPlatformWebViewWidgetCreationParams(
///     PlatformWebViewWidgetCreationParams params, {
///     String? domain,
///   }) {
///     return WKWebViewWidgetCreationParams._(params, domain: domain);
///   }
///
///   final String? domain;
/// }
/// ```
/// {@end-tool}
@immutable
class PlatformWebViewWidgetCreationParams {
  /// Used by the platform implementation to create a new [PlatformWebViewWidget].
  const PlatformWebViewWidgetCreationParams({
    this.key,
    required this.controller,
    this.gestureRecognizers = const <Factory<OneSequenceGestureRecognizer>>{},
  });

  /// Controls how one widget replaces another widget in the tree.
  ///
  /// See also:
  ///
  ///  * The discussions at [Key] and [GlobalKey].
  final Key? key;

  /// The [PlatformWebViewController] that allows controlling the native web
  /// view.
  final PlatformWebViewController controller;

  /// The `gestureRecognizers` specifies which gestures should be consumed by the
  /// web view.
  ///
  /// It is possible for other gesture recognizers to be competing with the web
  /// view on pointer events, e.g if the web view is inside a [ListView] the
  /// [ListView] will want to handle vertical drags. The web view will claim
  /// gestures that are recognized by any of the recognizers on this list.
  ///
  /// When `gestureRecognizers` is empty (default), the web view will only handle
  /// pointer events for gestures that were not claimed by any other gesture
  /// recognizer.
  final Set<Factory<OneSequenceGestureRecognizer>> gestureRecognizers;
}
