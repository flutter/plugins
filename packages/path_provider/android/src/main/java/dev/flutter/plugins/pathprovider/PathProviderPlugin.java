// Copyright 2019 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package dev.flutter.plugins.pathprovider;

import androidx.annotation.NonNull;
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugins.pathprovider.PathProviderMethodCallHandler;

public class PathProviderPlugin implements FlutterPlugin {
  @Override
  public void onAttachedToEngine(@NonNull FlutterPluginBinding binding) {
    MethodChannel channel =
        new MethodChannel(
            binding.getFlutterEngine().getDartExecutor(), "plugins.flutter.io/path_provider");
    PathProviderMethodCallHandler handler =
        new PathProviderMethodCallHandler(binding.getApplicationContext());
    channel.setMethodCallHandler(handler);
  }

  @Override
  public void onDetachedFromEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {}
}
