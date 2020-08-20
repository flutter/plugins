// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.sharedpreferencesexample;

import android.os.Bundle;
import dev.flutter.plugins.integration_test.IntegrationTestPlugin;
import io.flutter.app.FlutterActivity;
import io.flutter.plugins.sharedpreferences.SharedPreferencesPlugin;

public class EmbeddingV1Activity extends FlutterActivity {

  @Override
  protected void onCreate(Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);
    IntegrationTestPlugin.registerWith(
        registrarFor("dev.flutter.plugins.integration_test.IntegrationTestPlugin"));
    SharedPreferencesPlugin.registerWith(
        registrarFor("io.flutter.plugins.sharedpreferences.SharedPreferencesPlugin"));
  }
}
