// Copyright 2019 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.share;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import java.io.*;
import java.util.Map;
import com.google.gson.Gson;
import com.google.gson.JsonSyntaxException;

/** Handles the method calls for the plugin. */
class MethodCallHandler implements MethodChannel.MethodCallHandler {

  private Share share;
  private Gson gson = new Gson();

  MethodCallHandler(Share share) {
    this.share = share;
  }

  @Override
  public void onMethodCall(MethodCall call, MethodChannel.Result result) {
    ShareMap shareMap;
    switch (call.method) {
      case "share":
        expectMapArguments(call);
        // Android does not support showing the share sheet at a particular point on screen.
        try {
          // Avoiding uses unchecked or unsafe Object Type Casting by converting Map to Object using Gson
          shareMap = getShareMap(call);
          share.share(shareMap.getText(), shareMap.getSubject());
          result.success(null);
        } catch (JsonSyntaxException e) {
          result.error(e.getMessage(), null, null);
        }
        break;
      case "shareFiles":
        expectMapArguments(call);

        // Android does not support showing the share sheet at a particular point on screen.
        try {
          // Avoiding uses unchecked or unsafe Object Type Casting by converting Map to Object using Gson
          shareMap = getShareMap(call);
          share.shareFiles(
                  shareMap.getPaths(),
                  shareMap.getMimeTypes(),
                  shareMap.getText(),
                  shareMap.getSubject());
          result.success(null);
        } catch (IOException | JsonSyntaxException e) {
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

  private ShareMap getShareMap(MethodCall call){
    String jsonData = gson.toJson(call.arguments);
    return gson.fromJson(jsonData, ShareMap.class);
  }
}