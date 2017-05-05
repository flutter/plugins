// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.share;

import android.content.Context;
import android.content.Intent;

import io.flutter.app.FlutterActivity;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.MethodCall;

/** Plugin method host for presenting a share sheet via Intent */
public class SharePlugin implements MethodChannel.MethodCallHandler {

  private static final String PLATFORM_CHANNEL = "plugins.flutter.io/share";

  public static SharePlugin register(FlutterActivity flutterActivity) {
    return new SharePlugin(flutterActivity);
  }

  private Context context;

  private SharePlugin(FlutterActivity flutterActivity) {
    context = flutterActivity;
    new MethodChannel(flutterActivity.getFlutterView(), PLATFORM_CHANNEL)
        .setMethodCallHandler(this);
  }

  @Override
  public void onMethodCall(MethodCall call, MethodChannel.Result result) {
    if (call.method.equals("share")) {
      if (!(call.arguments instanceof String)) {
        result.error("ARGUMENT_ERROR", "String argument expected", null);
        return;
      }
      final String text = (String) call.arguments;

      Intent shareIntent = new Intent();
      shareIntent.setAction(Intent.ACTION_SEND);
      shareIntent.putExtra(Intent.EXTRA_TEXT, text);
      shareIntent.setType("text/plain");
      context.startActivity(Intent.createChooser(shareIntent, null /* dialog title optional */));
      result.success(null);
    } else {
      result.error("UNKNOWN_METHOD", "Unknown share method called", null);
    }
  }

}