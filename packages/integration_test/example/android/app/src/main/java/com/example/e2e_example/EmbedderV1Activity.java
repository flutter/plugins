// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package com.example.integration_test_example;

import android.os.Bundle;
import dev.flutter.plugins.integrationTest.IntegrationTestPlugin;
import io.flutter.app.FlutterActivity;

public class EmbedderV1Activity extends FlutterActivity {
  @Override
  protected void onCreate(Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);
    IntegrationTestPlugin.registerWith(
        registrarFor("dev.flutter.plugins.integrationTest.IntegrationTestPlugin"));
  }
}
