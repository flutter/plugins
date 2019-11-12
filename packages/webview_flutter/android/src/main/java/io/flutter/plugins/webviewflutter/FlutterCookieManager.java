// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.webviewflutter;

import android.net.Uri;
import android.os.Build;
import android.os.Build.VERSION_CODES;
import android.webkit.CookieManager;
import android.webkit.ValueCallback;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import java.net.HttpCookie;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

class FlutterCookieManager implements MethodCallHandler {
  private final MethodChannel methodChannel;

  FlutterCookieManager(BinaryMessenger messenger) {
    methodChannel = new MethodChannel(messenger, "plugins.flutter.io/cookie_manager");
    methodChannel.setMethodCallHandler(this);
  }

  @Override
  public void onMethodCall(MethodCall methodCall, Result result) {
    switch (methodCall.method) {
      case "clearCookies":
        clearCookies(result);
        break;
      case "getCookies":
        getCookies(methodCall, result);
        break;
      case "setCookies":
        setCookies(methodCall, result);
        break;
      default:
        result.notImplemented();
    }
  }

  void dispose() {
    methodChannel.setMethodCallHandler(null);
  }

  private static void clearCookies(final Result result) {
    CookieManager cookieManager = CookieManager.getInstance();
    final boolean hasCookies = cookieManager.hasCookies();
    if (Build.VERSION.SDK_INT >= VERSION_CODES.LOLLIPOP) {
      cookieManager.removeAllCookies(
          new ValueCallback<Boolean>() {
            @Override
            public void onReceiveValue(Boolean value) {
              result.success(hasCookies);
            }
          });
    } else {
      cookieManager.removeAllCookie();
      result.success(hasCookies);
    }
  }

  private static void getCookies(final MethodCall methodCall, final Result result) {
    if (!(methodCall.arguments() instanceof Map)) {
      result.error(
          "Invalid argument. Expected Map<String,String>, received "
              + (methodCall.arguments().getClass().getSimpleName()),
          null,
          null);
      return;
    }

    final Map<String, String> arguments = methodCall.arguments();

    CookieManager cookieManager = CookieManager.getInstance();

    final String url = arguments.get("url");
    final String allCookiesString = cookieManager.getCookie(url);
    final ArrayList<String> individualCookieStrings =
        new ArrayList<>(Arrays.asList(allCookiesString.split(";")));

    ArrayList<Map<String, Object>> serializedCookies = new ArrayList<>();
    for (String cookieString : individualCookieStrings) {
      try {
        final HttpCookie cookie = HttpCookie.parse(cookieString).get(0);
        if (cookie.getDomain() == null) {
          cookie.setDomain(Uri.parse(url).getHost());
        }
        if (cookie.getPath() == null) {
          cookie.setPath("/");
        }
        serializedCookies.add(cookieToMap(cookie));
      } catch (IllegalArgumentException e) {
        // Cookie is invalid. Ignoring.
      }
    }

    result.success(serializedCookies);
  }

  private static void setCookies(final MethodCall methodCall, final Result result) {
    if (!(methodCall.arguments() instanceof List)) {
      result.error(
          "Invalid argument. Expected List<Map<String,String>>, received "
              + (methodCall.arguments().getClass().getSimpleName()),
          null,
          null);
      return;
    }

    final List<Map<String, Object>> serializedCookies = methodCall.arguments();

    CookieManager cookieManager = CookieManager.getInstance();

    for (Map<String, Object> cookieMap : serializedCookies) {
      cookieManager.setCookie(
          cookieMap.get("domain").toString(), cookieMap.get("asString").toString());
    }

    result.success(null);
  }

  private static Map<String, Object> cookieToMap(HttpCookie cookie) {
    final HashMap<String, Object> output = new HashMap<>();
    output.put("name", cookie.getName());
    output.put("value", cookie.getValue());
    output.put("path", cookie.getPath());
    output.put("domain", cookie.getDomain());
    output.put("secure", cookie.getSecure());
    if (Build.VERSION.SDK_INT >= VERSION_CODES.N) {
      output.put("httpOnly", cookie.isHttpOnly());
    }

    return output;
  }
}
