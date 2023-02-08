// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.webviewflutter;

import android.webkit.WebView;

import androidx.annotation.Nullable;

import io.flutter.embedding.engine.FlutterEngine;

/**
 * App and package facing native API provided by the `webview_flutter_android` plugin.
 *
 * This class follows the convention of breaking changes of the Dart API, which means that any
 * changes to the class that are not backwards compatible will only be done with a major version
 * change of the plugin.
 */
@SuppressWarnings("unused")
public interface WebViewFlutterAndroidExternalApi {
  /**
   * Retrieves the {@link WebView} that is associated with `identifier`.
   *
   * <p>See the Dart method `AndroidWebViewController.webViewIdentifier` to get the identifier of an
   * underlying `WebView`.
   *
   * @param engine the execution environment the {@link WebViewFlutterPlugin} should belong to. If
   *     the engine doesn't contain an attached instance of {@link WebViewFlutterPlugin}, this
   *     method returns null.
   * @param identifier the associated identifier of the `WebView`.
   * @return the `WebView` associated with `identifier` or null if a `WebView` instance associated
   *     with `identifier` could not be found.
   */
  @Nullable
  static WebView getWebView(FlutterEngine engine, long identifier) {
    final WebViewFlutterPlugin webViewPlugin =
        (WebViewFlutterPlugin) engine.getPlugins().get(WebViewFlutterPlugin.class);

    if (webViewPlugin != null && webViewPlugin.getInstanceManager() != null) {
      final Object instance = webViewPlugin.getInstanceManager().getInstance(identifier);
      if (instance instanceof WebView) {
        return (WebView) instance;
      }
    }

    return null;
  }
}
