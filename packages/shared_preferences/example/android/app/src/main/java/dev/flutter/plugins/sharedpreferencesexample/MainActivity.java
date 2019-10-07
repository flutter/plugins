// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package dev.flutter.plugins.sharedpreferencesexample;

import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugins.sharedpreferences.SharedPreferencesPlugin;

public class MainActivity extends FlutterActivity {

  @Override
  public void configureFlutterEngine(FlutterEngine flutterEngine) {
    super.configureFlutterEngine(flutterEngine);
    flutterEngine.getPlugins().add(new SharedPreferencesPlugin());
  }
}
