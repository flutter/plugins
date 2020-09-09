// Copyright 2019 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.share;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import java.io.*;
import java.util.List;
import java.util.Map;

/** Handles the method calls for the plugin. */
class MethodCallHandler implements MethodChannel.MethodCallHandler {

  private Share share;

  MethodCallHandler(Share share) {
    this.share = share;
  }

  @Override
  public void onMethodCall(MethodCall call, MethodChannel.Result result) {
    switch (call.method) {
      case "share":
        expectMapArguments(call);
        // Android does not support showing the share sheet at a particular point on screen.
        share.share((String) call.argument("text"), (String) call.argument("subject"));
        result.success(null);
        break;
      case "shareFiles":
        expectMapArguments(call);

        // Android does not support showing the share sheet at a particular point on screen.
        try {
          share.shareFiles(
              (List<String>) call.argument("paths"),
              (List<String>) call.argument("mimeTypes"),
              (String) call.argument("text"),
              (String) call.argument("subject"));
          result.success(null);
        } catch (IOException e) {
          result.error(e.getMessage(), null, null);
        }
        break;
      default:
        result.notImplemented();
        break;
    }
  }

  private void expectMapArguments(MethodCall call) throws IllegalArgumentException {
    if (!(call.arguments instanceof Map)) {
      throw new IllegalArgumentException("Map argument expected");
    }
  }
}
