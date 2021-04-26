// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.googlemapsexample;

import android.os.Bundle;
import dev.flutter.plugins.integration_test.IntegrationTestPlugin;
import io.flutter.plugins.googlemaps.GoogleMapsPlugin;

@SuppressWarnings("deprecation")
public class EmbeddingV1Activity extends io.flutter.app.FlutterActivity {
  @Override
  protected void onCreate(Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);
    GoogleMapsPlugin.registerWith(registrarFor("io.flutter.plugins.googlemaps.GoogleMapsPlugin"));
    IntegrationTestPlugin.registerWith(
        registrarFor("dev.flutter.plugins.integration_test.IntegrationTestPlugin"));
  }
}
