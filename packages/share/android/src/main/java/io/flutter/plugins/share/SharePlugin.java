// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package com.google.android.flutter.plugins.share;

import android.content.Context;
import android.content.Intent;

import io.flutter.app.FlutterActivity;
import io.flutter.plugin.common.FlutterMethodChannel;
import io.flutter.plugin.common.MethodCall;

/** Plugin method host for presenting a share sheet via Intent */
public class SharePlugin {

  private static final String PLATFORM_CHANNEL = "plugins.flutter.io/share";

  public static void register(FlutterActivity flutterActivity) {
    new FlutterMethodChannel(flutterActivity.getFlutterView(), PLATFORM_CHANNEL)
        .setMethodCallHandler(new ShareMethodHandler(flutterActivity));
  }

  private static class ShareMethodHandler implements FlutterMethodChannel.MethodCallHandler{

    private Context context;

    private ShareMethodHandler(Context context) {
      this.context = context;
    }

    @Override
    public void onMethodCall(MethodCall call, FlutterMethodChannel.Response response) {
      if (call.method.equals("share")) {
        if (!(call.arguments instanceof String)) {
          response.error("ARGUMENT_ERROR", "String argument expected", null);
          return;
        }
        final String text = (String) call.arguments;

        Intent shareIntent = new Intent();
        shareIntent.setAction(Intent.ACTION_SEND);
        shareIntent.putExtra(Intent.EXTRA_TEXT, text);
        shareIntent.setType("text/plain");
        context.startActivity(Intent.createChooser(shareIntent, null /* dialog title optional */));
        response.success(null);
      } else {
        response.error("UNKNOWN_METHOD", "Unknown share method called", null);
      }
    }

  }

}