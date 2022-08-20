// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter_platform_interface/v4/src/platform_webview_widget.dart';

import '../../foundation/foundation.dart';
import '../webview_flutter_wkwebview.dart';

/// An implementation of [PlatformWebViewWidget] with the WebKit api.
class WebKitWebViewWidget extends PlatformWebViewWidget {
  /// Constructs a [WebKitWebViewWidget].
  WebKitWebViewWidget(super.params) : super.implementation();

  @override
  Widget build(BuildParams params) {
    return UiKitView(
      viewType: 'plugins.flutter.io/webview',
      onPlatformViewCreated: (_) {},
      layoutDirection: params.layoutDirection,
      gestureRecognizers: params.gestureRecognizers,
      creationParams: NSObject.globalInstanceManager.getIdentifier(
          (params.controller as WebKitWebViewController).webView),
      creationParamsCodec: const StandardMessageCodec(),
    );
  }
}
