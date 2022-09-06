// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:webview_flutter_platform_interface/v4/webview_flutter_platform_interface.dart';

import 'webview_controller.dart';

/// Displays a native WebView as a Widget.
class WebViewWidget extends StatelessWidget {
  /// Constructs a [WebViewWidget].
  WebViewWidget({
    Key? key,
    required WebViewController controller,
    TextDirection layoutDirection = TextDirection.ltr,
    Set<Factory<OneSequenceGestureRecognizer>> gestureRecognizers =
        const <Factory<OneSequenceGestureRecognizer>>{},
  }) : this.fromPlatformCreationParams(
          key: key,
          params: PlatformWebViewWidgetCreationParams(
            controller: controller.platform,
            layoutDirection: layoutDirection,
            gestureRecognizers: gestureRecognizers,
          ),
        );

  /// Constructs a [WebViewWidget] from creation params for a specific
  /// platform.
  WebViewWidget.fromPlatformCreationParams({
    Key? key,
    required PlatformWebViewWidgetCreationParams params,
  }) : this.fromPlatform(key: key, platform: PlatformWebViewWidget(params));

  /// Constructs a [WebViewWidget] from a specific platform implementation.
  WebViewWidget.fromPlatform({Key? key, required this.platform})
      : super(key: key);

  /// Implementation of [PlatformWebViewWidget] for the current platform.
  final PlatformWebViewWidget platform;

  /// The layout direction to use for the embedded WebView.
  late final TextDirection layoutDirection = platform.params.layoutDirection;

  /// Specifies which gestures should be consumed by the web view.
  ///
  /// It is possible for other gesture recognizers to be competing with the web
  /// view on pointer events, e.g if the web view is inside a [ListView] the
  /// [ListView] will want to handle vertical drags. The web view will claim
  /// gestures that are recognized by any of the recognizers on this list.
  ///
  /// When `gestureRecognizers` is empty (default), the web view will only
  /// handle pointer events for gestures that were not claimed by any other
  /// gesture recognizer.
  late final Set<Factory<OneSequenceGestureRecognizer>> gestureRecognizers =
      platform.params.gestureRecognizers;

  @override
  Widget build(BuildContext context) {
    return platform.build(context);
  }
}
