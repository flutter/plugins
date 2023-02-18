// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.webviewflutter;

import android.webkit.WebView;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugins.webviewflutter.GeneratedAndroidWebView.WebViewFlutterApi;

/**
 * Flutter Api implementation for {@link ContentOffsetChangedListener}.
 *
 * <p>Passes arguments of callbacks methods from a {@link ContentOffsetChangedListener} to Dart.
 */
public class WebViewFlutterApiImpl extends WebViewFlutterApi {
  private final InstanceManager instanceManager;

  /**
   * Creates a Flutter api that sends messages to Dart.
   *
   * @param binaryMessenger handles sending messages to Dart
   * @param instanceManager maintains instances stored to communicate with Dart objects
   */
  public WebViewFlutterApiImpl(BinaryMessenger binaryMessenger, InstanceManager instanceManager) {
    super(binaryMessenger);
    this.instanceManager = instanceManager;
  }

  /** Passes arguments from {@link ContentOffsetChangedListener#onContentOffsetChange} to Dart. */
  public void onScrollPosChange(
      WebView webView, long x, long y, long oldX, long oldY, Reply<Void> callback) {
    final Long webViewIdentifier = instanceManager.getIdentifierForStrongReference(webView);
    if (webViewIdentifier == null) {
      throw new IllegalStateException("Could not find identifier for WebView.");
    }
    onScrollPosChange(webViewIdentifier, x, y, oldX, oldY, callback);
  }
}
