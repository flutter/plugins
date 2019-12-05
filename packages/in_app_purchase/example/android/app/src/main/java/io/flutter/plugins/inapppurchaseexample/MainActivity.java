// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.inapppurchaseexample;

import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.embedding.engine.plugins.shim.ShimPluginRegistry;
import io.flutter.plugins.inapppurchase.InAppPurchasePlugin;
import io.flutter.plugins.sharedpreferences.SharedPreferencesPlugin;

public class MainActivity extends FlutterActivity {

  @Override
  public void configureFlutterEngine(FlutterEngine flutterEngine) {
    super.configureFlutterEngine(flutterEngine);
    flutterEngine.getPlugins().add(new InAppPurchasePlugin());

    ShimPluginRegistry shimPluginRegistry = new ShimPluginRegistry(flutterEngine);
    SharedPreferencesPlugin.registerWith(
        shimPluginRegistry.registrarFor(
            "io.flutter.plugins.sharedpreferences.SharedPreferencesPlugin"));
  }
}
