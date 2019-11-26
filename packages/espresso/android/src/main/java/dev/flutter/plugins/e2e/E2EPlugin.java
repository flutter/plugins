// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package dev.flutter.plugins.espresso;

import android.content.Context;
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;
import java.util.Map;
import java.util.concurrent.CompletableFuture;

/** espressoPlugin */
public class espressoPlugin implements MethodCallHandler, FlutterPlugin {
  private MethodChannel methodChannel;

  public static CompletableFuture<Map<String, String>> testResults = new CompletableFuture<>();

  private static final String CHANNEL = "plugins.flutter.io/espresso";

  /** Plugin registration. */
  public static void registerWith(Registrar registrar) {
    final espressoPlugin instance = new espressoPlugin();
    instance.onAttachedToEngine(registrar.context(), registrar.messenger());
  }

  @Override
  public void onAttachedToEngine(FlutterPluginBinding binding) {
    onAttachedToEngine(
        binding.getApplicationContext(), binding.getFlutterEngine().getDartExecutor());
  }

  private void onAttachedToEngine(Context applicationContext, BinaryMessenger messenger) {
    methodChannel = new MethodChannel(messenger, "plugins.flutter.io/espresso");
    methodChannel.setMethodCallHandler(this);
  }

  @Override
  public void onDetachedFromEngine(FlutterPluginBinding binding) {
    methodChannel.setMethodCallHandler(null);
    methodChannel = null;
  }

  @Override
  public void onMethodCall(MethodCall call, Result result) {
    if (call.method.equals("allTestsFinished")) {
      Map<String, String> results = call.argument("results");
      testResults.complete(results);
      result.success(null);
    } else {
      result.notImplemented();
    }
  }
}
