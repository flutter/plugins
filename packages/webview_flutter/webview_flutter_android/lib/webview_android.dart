// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:webview_flutter_platform_interface/webview_flutter_platform_interface.dart';

import 'src/webview_widget.dart';
import 'src/instance_manager.dart';

/// Builds an Android webview.
///
/// This is used as the default implementation for [WebView.platform] on Android. It uses
/// an [AndroidView] to embed the webview in the widget hierarchy, and uses a method channel to
/// communicate with the platform code.
class AndroidWebView implements WebViewPlatform {
  @override
  Widget build({
    required BuildContext context,
    required CreationParams creationParams,
    required WebViewPlatformCallbacksHandler webViewPlatformCallbacksHandler,
    required JavascriptChannelRegistry javascriptChannelRegistry,
    WebViewPlatformCreatedCallback? onWebViewPlatformCreated,
    Set<Factory<OneSequenceGestureRecognizer>>? gestureRecognizers,
  }) {
    return AndroidWebViewWidget(
      onBuildWidget: (AndroidWebViewPlatformController platformController) {
        return GestureDetector(
          // We prevent text selection by intercepting the long press event.
          // This is a temporary stop gap due to issues with text selection on Android:
          // https://github.com/flutter/flutter/issues/24585 - the text selection
          // dialog is not responding to touch events.
          // https://github.com/flutter/flutter/issues/24584 - the text selection
          // handles are not showing.
          // TODO(amirh): remove this when the issues above are fixed.
          onLongPress: () {},
          excludeFromSemantics: true,
          child: AndroidView(
            viewType: 'plugins.flutter.io/webview',
            onPlatformViewCreated: (int id) {
              if (onWebViewPlatformCreated != null) {
                onWebViewPlatformCreated(platformController);
              }
            },
            gestureRecognizers: gestureRecognizers,
            layoutDirection:
                Directionality.maybeOf(context) ?? TextDirection.rtl,
            creationParams: InstanceManager.instance
                .getInstanceId(platformController.webView),
            creationParamsCodec: const StandardMessageCodec(),
          ),
        );
      },
      creationParams: creationParams,
      webViewPlatformCallbacksHandler: webViewPlatformCallbacksHandler,
      javascriptChannelRegistry: javascriptChannelRegistry,
      useHybridComposition: false,
    );
  }

  @override
  Future<bool> clearCookies() => MethodChannelWebViewPlatform.clearCookies();
}
