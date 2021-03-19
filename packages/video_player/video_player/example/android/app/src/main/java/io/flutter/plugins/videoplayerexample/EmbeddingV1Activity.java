// Copyright 2019 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.videoplayerexample;

import android.os.Bundle;
import dev.flutter.plugins.integration_test.IntegrationTestPlugin;
import io.flutter.plugins.videoplayer.VideoPlayerPlugin;

@SuppressWarnings("deprecation")
public class EmbeddingV1Activity extends io.flutter.app.FlutterActivity {
  @Override
  protected void onCreate(Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);
    IntegrationTestPlugin.registerWith(
        registrarFor("dev.flutter.plugins.integration_test.IntegrationTestPlugin"));
    VideoPlayerPlugin.registerWith(
        registrarFor("io.flutter.plugins.videoplayer.VideoPlayerPlugin"));
  }
}
