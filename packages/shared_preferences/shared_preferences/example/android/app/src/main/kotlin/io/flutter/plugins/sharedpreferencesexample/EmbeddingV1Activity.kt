// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.sharedpreferencesexample;

import android.os.Bundle;
import io.flutter.embedding.android.FlutterActivity
import io.flutter.plugin.common.PluginRegistry.Registrar
import dev.flutter.plugins.integration_test.IntegrationTestPlugin;
import io.flutter.plugins.sharedpreferences.SharedPreferencesPlugin;

@SuppressWarnings("deprecation")
class EmbeddingV1Activity : FlutterActivity() {
   override fun onCreate(savedInstanceState: Bundle?) {
    super.onCreate(savedInstanceState);
    /// TODO: CHECK WHY THE ACTIVITY WON'T RECOGNIZE THE METHOD registrarFor, it works as planned without those 2 sections.
    /*IntegrationTestPlugin.registerWith(
        registrarFor("dev.flutter.plugins.integration_test.IntegrationTestPlugin"));
    SharedPreferencesPlugin.registerWith(
        registrarFor("io.flutter.plugins.sharedpreferences.SharedPreferencesPlugin"));*/
  }
}