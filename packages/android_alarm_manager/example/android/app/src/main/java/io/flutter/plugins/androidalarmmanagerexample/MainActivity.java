// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.androidalarmmanagerexample;

import dev.flutter.plugins.e2e.E2EPlugin;
import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.embedding.engine.plugins.shim.ShimPluginRegistry;
import io.flutter.plugins.androidalarmmanager.AndroidAlarmManagerPlugin;
import io.flutter.plugins.pathprovider.PathProviderPlugin;
import io.flutter.plugins.sharedpreferences.SharedPreferencesPlugin;

public class MainActivity extends FlutterActivity {
  // TODO(bkonyi): Remove this once v2 of GeneratedPluginRegistrant rolls to stable. https://github.com/flutter/flutter/issues/42694
  @Override
  public void configureFlutterEngine(FlutterEngine flutterEngine) {
    ShimPluginRegistry shimPluginRegistry = new ShimPluginRegistry(flutterEngine);
    flutterEngine.getPlugins().add(new AndroidAlarmManagerPlugin());
    flutterEngine.getPlugins().add(new E2EPlugin());
    flutterEngine.getPlugins().add(new SharedPreferencesPlugin());
    PathProviderPlugin.registerWith(
        shimPluginRegistry.registrarFor("io.flutter.plugins.pathprovider.PathProviderPlugin"));
  }
}
