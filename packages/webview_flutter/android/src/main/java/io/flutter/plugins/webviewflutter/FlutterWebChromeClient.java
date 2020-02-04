// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.webviewflutter;

import android.webkit.JsPromptResult;
import android.webkit.JsResult;
import android.webkit.WebChromeClient;
import android.webkit.WebView;

import java.util.HashMap;
import java.util.Map;

import io.flutter.plugin.common.MethodChannel;

class FlutterWebChromeClient {
  private static final String TAG = "FlutterWebViewClient";
  private final MethodChannel methodChannel;

  FlutterWebChromeClient(MethodChannel methodChannel) {
    this.methodChannel = methodChannel;
  }

  WebChromeClient createWebChromeClient() {
    return new WebChromeClient() {

      @Override
      public boolean onJsAlert(WebView view, String url, String message, final JsResult result) {
        Map<String, Object> args = new HashMap<>();
        args.put("url", url);
        args.put("message", message);
        methodChannel.invokeMethod("onJsAlert", args, new MethodChannel.Result() {
          @Override
          public void success(Object o) {
            if (result != null) {
              result.confirm();
            }
          }

          @Override
          public void error(String errorCode, String errorMessage, Object errorDetails) {
            System.out.println("error");
          }

          @Override
          public void notImplemented() {
            System.out.println("notImplemented");
          }
        });
        return true;
      }

      @Override
      public boolean onJsConfirm(WebView view, String url, String message, final JsResult result) {
        Map<String, Object> args = new HashMap<>();
        args.put("url", url);
        args.put("message", message);
        methodChannel.invokeMethod("onJsConfirm", args, new MethodChannel.Result() {
          @Override
          public void success(Object o) {
            if (o instanceof Boolean) {
              boolean boolResult = (Boolean) o;
              if (result != null) {
                if (boolResult) {
                  result.confirm();
                } else {
                  result.cancel();
                }
              }
            }
          }

          @Override
          public void error(String errorCode, String errorMessage, Object errorDetails) {
            System.out.println("error");
          }

          @Override
          public void notImplemented() {
            System.out.println("notImplemented");
          }
        });
        return true;
      }

      @Override
      public boolean onJsPrompt(WebView view, String url, String message, String defaultValue, final JsPromptResult result) {
        Map<String, Object> args = new HashMap<>();
        args.put("url", url);
        args.put("message", message);
        args.put("defaultText", defaultValue);
        methodChannel.invokeMethod("onJsPrompt", args, new MethodChannel.Result() {
          @Override
          public void success(Object o) {
            if (o instanceof String) {
              String str = (String) o;
              if (result != null) {
                if (!str.isEmpty()) {
                  result.confirm(str);
                } else {
                  result.confirm("");
                }
              }
            }
          }

          @Override
          public void error(String errorCode, String errorMessage, Object errorDetails) {
            System.out.println("error");
          }

          @Override
          public void notImplemented() {
            System.out.println("notImplemented");
          }
        });
        return true;
      }
    };
  }
}

