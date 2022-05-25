// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:webview_flutter_platform_interface/v4/webview_flutter_platform_interface.dart';

import '../android_webview.dart';

/// Exposes a channel to receive calls from javaScript.
///
/// See [AndroidWebViewController.addJavaScriptChannel].
class AndroidWebViewJavaScriptChannel extends JavaScriptChannel {
  /// Creates a new [AndroidWebViewJavaScriptChannel] based the supplied [JavaScriptChannelParams].
  AndroidWebViewJavaScriptChannel.fromJavaScriptChannelParams({
    required JavaScriptChannelParams params,
  })  : _javaScriptChannelParams = params,
        super(params.name);

  final JavaScriptChannelParams _javaScriptChannelParams;

  @override
  void postMessage(String message) {
    _javaScriptChannelParams.onMessageReceived(
      JavaScriptMessage(
        message: message,
      ),
    );
  }
}
