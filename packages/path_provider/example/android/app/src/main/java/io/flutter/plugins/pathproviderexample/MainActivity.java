// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.pathproviderexample;

import dev.flutter.plugins.pathprovider.PathProviderPlugin;
import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;

public class MainActivity extends FlutterActivity {
  @Override
  public void configureFlutterEngine(FlutterEngine flutterEngine) {
    super.configureFlutterEngine(flutterEngine);
    // TODO(jackson): Remove this once v2 of GeneratedPluginRegistrant rolls to stable.
    // https://github.com/flutter/flutter/issues/42694
    flutterEngine.getPlugins().add(new PathProviderPlugin());
  }
}
