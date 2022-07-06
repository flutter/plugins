// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:webview_flutter_platform_interface/webview_flutter_platform_interface.dart';

import 'src/android_webview.dart';
import 'src/instance_manager.dart';
import 'webview_android.dart';
import 'webview_android_widget.dart';

/// Android [WebViewPlatform] that uses [AndroidViewSurface] to build the
/// [WebView] widget.
///
/// To use this, set [WebView.platform] to an instance of this class.
///
/// This implementation uses [AndroidViewSurface] to render the [WebView] on
/// Android. It solves multiple issues related to accessibility and interaction
/// with the [WebView] at the cost of some performance on Android versions below
/// 10.
///
/// To support transparent backgrounds, this implementation uses hybrid
/// composition when `CreationParams.backgroundColor` is less than 1.0. See
/// https://github.com/flutter/flutter/wiki/Hybrid-Composition for more
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
    return WebViewAndroidWidget(
      useHybridComposition: true,
      creationParams: creationParams,
      callbacksHandler: webViewPlatformCallbacksHandler,
      javascriptChannelRegistry: javascriptChannelRegistry,
      onBuildWidget: (WebViewAndroidPlatformController controller) {
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
            late final AndroidViewController viewController;

            // On some Android devices, transparent backgrounds can cause
            // rendering issues on the non hybrid composition
            // AndroidViewSurface. This switches the WebView to Hybric
            // Composition when then background color is not 100% opaque.
            final Color? backgroundColor = creationParams.backgroundColor;
            if (backgroundColor != null && backgroundColor.opacity < 1.0) {
              viewController = PlatformViewsService.initExpensiveAndroidView(
                id: params.id,
                viewType: 'plugins.flutter.io/webview',
                // WebView content is not affected by the Android view's layout direction,
                // we explicitly set it here so that the widget doesn't require an ambient
                // directionality.
                layoutDirection:
                    Directionality.maybeOf(context) ?? TextDirection.ltr,
                creationParams:
                    InstanceManager.instance.getInstanceId(controller.webView),
                creationParamsCodec: const StandardMessageCodec(),
              );
            } else {
              viewController = PlatformViewsService.initSurfaceAndroidView(
                id: params.id,
                viewType: 'plugins.flutter.io/webview',
                // WebView content is not affected by the Android view's layout direction,
                // we explicitly set it here so that the widget doesn't require an ambient
                // directionality.
                layoutDirection:
                    Directionality.maybeOf(context) ?? TextDirection.ltr,
                creationParams:
                    InstanceManager.instance.getInstanceId(controller.webView),
                creationParamsCodec: const StandardMessageCodec(),
              );
            }

            return viewController
              ..addOnPlatformViewCreatedListener(params.onPlatformViewCreated)
              ..addOnPlatformViewCreatedListener((int id) {
                if (onWebViewPlatformCreated != null) {
                  onWebViewPlatformCreated(controller);
                }
              })
              ..create();
          },
        );
      },
    );
  }
}
