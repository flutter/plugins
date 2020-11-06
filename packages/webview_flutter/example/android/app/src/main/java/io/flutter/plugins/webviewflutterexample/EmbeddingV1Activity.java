// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.webviewflutterexample;

import android.content.Intent;
import android.os.Build;
import android.os.Bundle;
import android.webkit.WebChromeClient;
import androidx.annotation.Nullable;
import dev.flutter.plugins.integration_test.IntegrationTestPlugin;
import io.flutter.plugins.webviewflutter.FlutterWebView;
import io.flutter.plugins.webviewflutter.WebViewFlutterPlugin;

@SuppressWarnings("deprecation")
public class EmbeddingV1Activity extends io.flutter.app.FlutterActivity {
  @Override
  protected void onCreate(Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);
    IntegrationTestPlugin.registerWith(
        registrarFor("dev.flutter.plugins.integration_test.IntegrationTestPlugin"));
    WebViewFlutterPlugin.registerWith(
        registrarFor("io.flutter.plugins.webviewflutter.WebViewFlutterPlugin"));
  }

  @Override
  protected void onActivityResult(int requestCode, int resultCode, @Nullable Intent data) {
    super.onActivityResult(requestCode, resultCode, data);

    if (requestCode == FlutterWebView.ACTIVITY_RESULT_FILE) {
      if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP
          && FlutterWebView.filePathCallbackLollipop != null) {
        if (data != null) {
          FlutterWebView.filePathCallbackLollipop.onReceiveValue(
              WebChromeClient.FileChooserParams.parseResult(resultCode, data));
        }

        FlutterWebView.filePathCallbackLollipop = null;
      } else if (FlutterWebView.filePathCallback4 != null) {
        if (data != null) {
          FlutterWebView.filePathCallback4.onReceiveValue(data.getData());
        }

        FlutterWebView.filePathCallback4 = null;
      }
    }
  }
}
