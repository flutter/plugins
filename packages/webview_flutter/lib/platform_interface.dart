// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';

/// Interface for talking to the webview controller on the platform side.
///
/// An instance implementing this interface is passed to the `onWebViewCreated` callback that is
/// passed to [WebViewPlatformInterface#onWebViewCreated].
abstract class WebViewPlatform {
  Future<void> loadUrl(
    String url,
    Map<String, String> headers,
  ) {
    throw UnimplementedError(
        "WebView loadUrl is not implemented on the current platform");
  }

  // As the PR currently focus about the wiring I've only moved loadUrl to the new way, so
  // the discussion is more focused.
  // In this temporary state WebViewController still uses a method channel directly for all other
  // method calls so we need to expose the webview ID.
  // TODO(amirh): remove this before submitting this PR(after getting an LGTM for the overall approach).
  int get id;
}

typedef WebViewPlatformCreatedCallback = void Function(
    WebViewPlatform webViewPlatform);

/// Interface for a platform specific webview implementation.
///
/// [WebView#iplatformBuilder] controls the platform interface that is used by [WebView].
/// [WebViewAndroidImplementation] and [WebViewIosImplementation] are the default implementations
/// for Android and iOS respectively.
abstract class WebViewBuilder {
  Widget build({
    BuildContext context,
    Map<String, dynamic> creationParams,
    WebViewPlatformCreatedCallback onWebViewPlatformCreated,
    Set<Factory<OneSequenceGestureRecognizer>> gestureRecognizers,
  });
}
