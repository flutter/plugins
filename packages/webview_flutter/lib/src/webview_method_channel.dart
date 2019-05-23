// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter/services.dart';

import '../platform_interface.dart';

/// A [WebViewPlatform] that uses a method channel to control the webview.
class MethodChannelWebViewPlatform implements WebViewPlatform {
  MethodChannelWebViewPlatform(this._id)
      : _channel = MethodChannel('plugins.flutter.io/webview_$_id');

  final int _id;

  final MethodChannel _channel;

  @override
  Future<void> loadUrl(
    String url,
    Map<String, String> headers,
  ) async {
    assert(url != null);
    // TODO(amirh): remove this on when the invokeMethod update makes it to stable Flutter.
    // https://github.com/flutter/flutter/issues/26431
    // ignore: strong_mode_implicit_dynamic_method
    return _channel.invokeMethod('loadUrl', <String, dynamic>{
      'url': url,
      'headers': headers,
    });
  }

  @override
  int get id => _id;
}
