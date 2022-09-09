// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.webviewflutterexample;

import android.webkit.WebView;

import androidx.annotation.NonNull;
import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugins.webviewflutter.GeneratedAndroidWebView;
import io.flutter.plugins.webviewflutter.WebViewFlutterPlugin;
import io.flutter.plugins.webviewflutter.WebViewHostApiImpl;

public class DriverExtensionActivity extends FlutterActivity {
  @Override
  @NonNull
  public String getDartEntrypointFunctionName() {
    return "appMain";
  }

  @Override
  public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
    super.configureFlutterEngine(flutterEngine);

    final WebViewFlutterPlugin webViewPlugin = (WebViewFlutterPlugin) flutterEngine.getPlugins().get(WebViewFlutterPlugin.class);

    final WebViewHostApiImpl apiImpl = new WebViewHostApiImpl(webViewPlugin.getInstanceManager(),
        new WebViewHostApiImpl.WebViewProxy(), this, null) {
      @Override
      public void create(Long instanceId, Boolean useHybridComposition) {
        super.create(instanceId, useHybridComposition);
        final WebView webView = getInstanceManager().getInstance(instanceId);
        MobileAds.registerWebView(webView);
      }
    };
    
    GeneratedAndroidWebView.WebViewHostApi.setup(flutterEngine.getDartExecutor(), apiImpl);
  }
}
