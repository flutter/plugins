// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter_platform_interface/v4/webview_flutter_platform_interface.dart';

import '../../common/instance_manager.dart';
import '../../foundation/foundation.dart';
import '../webview_flutter_wkwebview.dart';

class WebKitWebViewWidgetCreationParams
    extends PlatformWebViewWidgetCreationParams {
  WebKitWebViewWidgetCreationParams({
    super.key,
    required super.controller,
    super.layoutDirection,
    super.gestureRecognizers,
    InstanceManager? instanceManager,
  }) : instanceManager = instanceManager ?? NSObject.globalInstanceManager;

  WebKitWebViewWidgetCreationParams.fromPlatformWebViewWidgetCreationParams(
    PlatformWebViewWidgetCreationParams params, {
    InstanceManager? instanceManager,
  }) : this(
          key: params.key,
          controller: params.controller,
          layoutDirection: params.layoutDirection,
          gestureRecognizers: params.gestureRecognizers,
          instanceManager: instanceManager,
        );

  final InstanceManager instanceManager;
}

/// An implementation of [PlatformWebViewWidget] with the WebKit api.
class WebKitWebViewWidget extends PlatformWebViewWidget {
  /// Constructs a [WebKitWebViewWidget].
  WebKitWebViewWidget(PlatformWebViewWidgetCreationParams params)
      : super.implementation(
          params is WebKitWebViewWidgetCreationParams
              ? params
              : WebKitWebViewWidgetCreationParams
                  .fromPlatformWebViewWidgetCreationParams(params),
        );

  WebKitWebViewWidgetCreationParams get _webKitParams =>
      params as WebKitWebViewWidgetCreationParams;

  @override
  Widget build(BuildContext context) {
    return UiKitView(
      viewType: 'plugins.flutter.io/webview',
      onPlatformViewCreated: (_) {},
      layoutDirection: params.layoutDirection,
      gestureRecognizers: params.gestureRecognizers,
      creationParams: _webKitParams.instanceManager.getIdentifier(
          (params.controller as WebKitWebViewController).webView),
      creationParamsCodec: const StandardMessageCodec(),
    );
  }
}
