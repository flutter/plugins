// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
//
package io.flutter.plugins.flutter_plugin_android_lifecycle;

import androidx.annotation.NonNull;
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.PluginRegistry.Registrar;

/**
 * Plugin class that exists because the Flutter tool expects such a class to exist for every Android
 * plugin.
 *
 * <p><strong>DO NOT USE THIS CLASS.</strong>
 */
public class FlutterAndroidLifecyclePlugin implements FlutterPlugin {
  public static void registerWith(Registrar registrar) {
    // no-op
  }

  @Override
  public void onAttachedToEngine(@NonNull FlutterPluginBinding binding) {
    // no-op
  }

  @Override
  public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
    // no-op
  }
}
