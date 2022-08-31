// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:webview_flutter_platform_interface/v4/webview_flutter_platform_interface.dart';

/// Displays a native WebView as a Widget.
class WebViewWidget extends StatelessWidget {
  /// Constructs a [WebViewWidget].
  WebViewWidget({
    Key? key,
    required PlatformWebViewController controller,
    TextDirection layoutDirection = TextDirection.ltr,
    Set<Factory<OneSequenceGestureRecognizer>> gestureRecognizers =
        const <Factory<OneSequenceGestureRecognizer>>{},
  }) : this.fromPlatform(
          platform: PlatformWebViewWidget(
            PlatformWebViewWidgetCreationParams(
              key: key,
              controller: controller,
              layoutDirection: layoutDirection,
              gestureRecognizers: gestureRecognizers,
            ),
          ),
        );

  /// Constructs a [WebViewWidget] from creation params for a specific
  /// platform.
  WebViewWidget.fromPlatformCreationParams(
    PlatformWebViewWidgetCreationParams params,
  ) : this.fromPlatform(platform: PlatformWebViewWidget(params));

  /// Constructs a [WebViewWidget] from a specific platform implementation.
  WebViewWidget.fromPlatform({required this.platform})
      : super(key: platform.params.key);

  // TODO: This should be WebViewController! Don't submit.
  /// Implementation of [PlatformWebViewWidget] for the current platform.
  final PlatformWebViewWidget platform;

  @override
  Widget build(BuildContext context) {
    return platform.build(context);
  }
}
