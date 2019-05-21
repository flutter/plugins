// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../platform_interface.dart';
import 'webview_method_channel.dart';

/// Builds an iOS webview.
///
/// This is used as the default implementation for [WebView.platformBuilder] on iOS. It uses
/// a [UiKitView] to embed the webview in the widget hierarchy, and uses a method channel to
/// communicate with the platform code.
class CupertinoWebViewBuilder implements WebViewBuilder {
  @override
  Widget build({
    BuildContext context,
    Map<String, dynamic> creationParams,
    WebViewPlatformCreatedCallback onWebViewPlatformCreated,
    Set<Factory<OneSequenceGestureRecognizer>> gestureRecognizers,
  }) {
    return UiKitView(
      viewType: 'plugins.flutter.io/webview',
      onPlatformViewCreated: (int id) {
        if (onWebViewPlatformCreated == null) {
          return;
        }
        onWebViewPlatformCreated(MethodChannelWebViewPlatform(id));
      },
      gestureRecognizers: gestureRecognizers,
      creationParams: creationParams,
      creationParamsCodec: const StandardMessageCodec(),
    );
  }
}
