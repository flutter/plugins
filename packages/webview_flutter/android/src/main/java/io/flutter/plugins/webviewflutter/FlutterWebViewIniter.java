// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.webviewflutter;

import android.webkit.WebView;

/**
 * Interface to initialize Flutter WebView in native Android code.
 *
 * <p>Why? In most cases, an APP has custom COMMON WebView initialization logic, like {@link
 * android.webkit.WebSettings#setBuiltInZoomControls(boolean)}, {@link
 * android.webkit.WebSettings#setMixedContentMode(int)}, {@link
 * android.webkit.WebSettings#setTextZoom(int)} etc.
 *
 * <p>Adding all these settings to Flutter WebView params is tedious, and unnecessary mostly, so we
 * can put these initialization on our APP's self native code as you like.
 */
public interface FlutterWebViewIniter {
  /** How to initialize WebView */
  void initWebView(WebView webView);
}
