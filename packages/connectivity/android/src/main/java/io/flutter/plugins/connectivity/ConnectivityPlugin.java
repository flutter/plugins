// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.connectivity;

import android.app.Activity;
import android.content.Context;
import android.net.ConnectivityManager;
import android.net.NetworkInfo;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;

/** ConnectivityPlugin */
public class ConnectivityPlugin implements MethodCallHandler {
  private final ConnectivityManager manager;

  /** Plugin registration. */
  public static void registerWith(Registrar registrar) {
    final MethodChannel channel =
        new MethodChannel(registrar.messenger(), "plugins.flutter.io/connectivity");
    channel.setMethodCallHandler(new ConnectivityPlugin(registrar.activity()));
  }

  private ConnectivityPlugin(Activity activity) {
    manager = (ConnectivityManager) activity.getSystemService(Context.CONNECTIVITY_SERVICE);
  }

  @Override
  public void onMethodCall(MethodCall call, Result result) {
    if (call.method.equals("check")) {
      NetworkInfo info = manager.getActiveNetworkInfo();
      if (info != null && info.isConnected()) {
        switch (info.getType()) {
          case ConnectivityManager.TYPE_ETHERNET:
          case ConnectivityManager.TYPE_WIFI:
          case ConnectivityManager.TYPE_WIMAX:
            result.success("wifi");
            break;
          case ConnectivityManager.TYPE_MOBILE:
          case ConnectivityManager.TYPE_MOBILE_DUN:
            result.success("mobile");
            break;
          default:
            result.success("none");
            break;
        }
      } else {
        result.success("none");
      }
    } else {
      result.notImplemented();
    }
  }
}
