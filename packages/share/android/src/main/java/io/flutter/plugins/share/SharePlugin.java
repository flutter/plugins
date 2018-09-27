// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.share;

import android.content.Intent;
import android.net.Uri;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.PluginRegistry.Registrar;
import java.util.Map;

/** Plugin method host for presenting a share sheet via Intent */
public class SharePlugin implements MethodChannel.MethodCallHandler {

  private static final String CHANNEL = "plugins.flutter.io/share";

  public static void registerWith(Registrar registrar) {
    MethodChannel channel = new MethodChannel(registrar.messenger(), CHANNEL);
    SharePlugin instance = new SharePlugin(registrar);
    channel.setMethodCallHandler(instance);
  }

  private final Registrar mRegistrar;

  private SharePlugin(Registrar registrar) {
    this.mRegistrar = registrar;
  }

  @Override
  public void onMethodCall(MethodCall call, MethodChannel.Result result) {
    // Android does not support showing the share sheet at a particular point on screen.
    if ("share".equals(call.method)) {
      share((String) call.argument("text"));
      result.success(null);

    } else if ("shareFile".equals(call.method)) {
      Uri uri = Uri.parse((String) call.argument("uri"));
      String mimeType = call.argument("mimeType");
      shareFile(uri, mimeType);
      result.success(null);

    } else {
      result.notImplemented();
    }
  }

  private void sendIntent(Intent intent) {
    if (mRegistrar.activity() != null) {
      mRegistrar.activity().startActivity(intent);
    } else {
      intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
      mRegistrar.context().startActivity(intent);
    }
  }

  private void share(String text) {
    Intent shareIntent = new Intent();
    shareIntent.setAction(Intent.ACTION_SEND);
    shareIntent.putExtra(Intent.EXTRA_TEXT, text);
    shareIntent.setType("text/plain");
    sendIntent(Intent.createChooser(shareIntent, null /* dialog title optional */));
  }

  private void shareFile(Uri uri, String mimeType) {
    Intent shareIntent = new Intent();
    shareIntent.setAction(Intent.ACTION_SEND);
    shareIntent.putExtra(Intent.EXTRA_STREAM, uri);
    shareIntent.setType(mimeType);
    sendIntent(Intent.createChooser(shareIntent, null /* dialog title optional */));
  }
}
