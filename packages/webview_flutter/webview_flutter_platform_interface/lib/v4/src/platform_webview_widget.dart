// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:webview_flutter_platform_interface/v4/src/platform_webview_controller.dart';

import 'webview_platform.dart';

/// Interface for a platform implementation of a web view widget.
abstract class PlatformWebViewWidget extends PlatformInterface {
  /// Creates a new [PlatformWebViewWidget]
  factory PlatformWebViewWidget(PlatformWebViewWidgetCreationParams params) {
    final PlatformWebViewWidget webViewWidgetDelegate =
        WebViewPlatform.instance!.createPlatformWebViewWidget(params);
    PlatformInterface.verify(webViewWidgetDelegate, _token);
    return webViewWidgetDelegate;
  }

  /// Used by the platform implementation to create a new
  /// [PlatformWebViewWidget].
  ///
  /// Should only be used by platform implementations because they can't extend
  /// a class that only contains a factory constructor.
  @protected
  PlatformWebViewWidget.implementation(this.params) : super(token: _token);

  static final Object _token = Object();

  /// The parameters used to initialize the [PlatformWebViewWidget].
  final PlatformWebViewWidgetCreationParams params;

  /// Builds a new WebView.
  ///
  /// Returns a Widget tree that embeds the created web view.
  Widget build(BuildParams params);
}

/// Describes the parameters necessary for displaying the platform WebView.
///
/// Platform specific implementations can add additional fields by extending
/// this class.
///
/// {@tool sample}
/// This example demonstrates how to extend the [BuildParams] to provide
/// additional platform specific parameters.
///
/// When extending [BuildParams], additional parameters should always accept
/// `null` or have a default value to prevent breaking changes.
///
/// ```dart
/// @immutable
/// class WebKitBuildParams extends BuildParams {
///   WebKitBuildParams(
///     super.context, {
///     required super.controller,
///     super.layoutDirection,
///     super.gestureRecognizers,
///     this.platformSpecificFieldExample,
///   });
///
///   WebKitBuildParams.fromBuildParams(
///     BuildParams params, {
///     Object? platformSpecificFieldExample,
///   }) : this(
///           params.context,
///           controller: params.controller,
///           layoutDirection: params.layoutDirection,
///           gestureRecognizers: params.gestureRecognizers,
///           platformSpecificFieldExample: platformSpecificFieldExample,
///         );
///
///   final Object? platformSpecificFieldExample;
/// }
/// ```
/// {@end-tool}
@immutable
class BuildParams {
  /// Constructs a [BuildParams].
  const BuildParams(
    this.context, {
    required this.controller,
    this.layoutDirection = TextDirection.ltr,
    this.gestureRecognizers = const <Factory<OneSequenceGestureRecognizer>>{},
  });

  /// Describes the part of the user interface represented by the returned
  /// widget.
  final BuildContext context;

  /// Controls the embedded WebView for the current platform.
  final PlatformWebViewController controller;

  /// The layout direction to use for the embedded WebView.
  final TextDirection layoutDirection;

  /// Specifies which gestures should be consumed by the web view.
  ///
  /// It is possible for other gesture recognizers to be competing with the web
  /// view on pointer events, e.g if the web view is inside a [ListView] the
  /// [ListView] will want to handle vertical drags. The web view will claim
  /// gestures that are recognized by any of the recognizers on this list.
  ///
  /// When this is empty, the web view will only handle pointer events for
  /// gestures that were not claimed by any other gesture recognizer.
  final Set<Factory<OneSequenceGestureRecognizer>> gestureRecognizers;
}
