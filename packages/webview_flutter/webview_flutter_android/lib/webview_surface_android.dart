// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:webview_flutter_platform_interface/webview_flutter_platform_interface.dart';

import 'webview_android.dart';

/// Android [WebViewPlatform] that uses [AndroidViewSurface] to build the [WebView] widget.
///
/// To use this, set [WebView.platform] to an instance of this class.
///
/// This implementation uses hybrid composition to render the [WebView] on
/// Android. It solves multiple issues related to accessibility and interaction
/// with the [WebView] at the cost of some performance on Android versions below
/// 10. See https://github.com/flutter/flutter/wiki/Hybrid-Composition for more
/// information.
class SurfaceAndroidWebView extends AndroidWebView {
  @override
  Widget build({
    required BuildContext context,
    required CreationParams creationParams,
    required JavascriptChannelRegistry javascriptChannelRegistry,
    WebViewPlatformCreatedCallback? onWebViewPlatformCreated,
    Set<Factory<OneSequenceGestureRecognizer>>? gestureRecognizers,
    required WebViewPlatformCallbacksHandler webViewPlatformCallbacksHandler,
  }) {
    assert(webViewPlatformCallbacksHandler != null);
    return PlatformViewLink(
      viewType: 'plugins.flutter.io/webview',
      surfaceFactory: (
        BuildContext context,
        PlatformViewController controller,
      ) {
        return AndroidViewSurface(
          controller: controller as AndroidViewController,
          gestureRecognizers: gestureRecognizers ??
              const <Factory<OneSequenceGestureRecognizer>>{},
          hitTestBehavior: PlatformViewHitTestBehavior.opaque,
        );
      },
      onCreatePlatformView: (PlatformViewCreationParams params) {
        return PlatformViewsService.initSurfaceAndroidView(
          id: params.id,
          viewType: 'plugins.flutter.io/webview',
          // WebView content is not affected by the Android view's layout direction,
          // we explicitly set it here so that the widget doesn't require an ambient
          // directionality.
          layoutDirection: TextDirection.rtl,
          creationParams: MethodChannelWebViewPlatform.creationParamsToMap(
            creationParams,
            usesHybridComposition: true,
          ),
          creationParamsCodec: const StandardMessageCodec(),
        )
          ..addOnPlatformViewCreatedListener(params.onPlatformViewCreated)
          ..addOnPlatformViewCreatedListener((int id) {
            if (onWebViewPlatformCreated == null) {
              return;
            }
            onWebViewPlatformCreated(
              MethodChannelWebViewPlatform(
                id,
                webViewPlatformCallbacksHandler,
                javascriptChannelRegistry,
              ),
            );
          })
          ..create();
      },
    );
  }
}
