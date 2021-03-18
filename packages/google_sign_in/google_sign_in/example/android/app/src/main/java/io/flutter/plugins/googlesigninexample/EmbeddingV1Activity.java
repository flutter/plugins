// Copyright 2017 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.googlesigninexample;

import android.os.Bundle;
import io.flutter.plugins.googlesignin.GoogleSignInPlugin;
import io.flutter.view.FlutterMain;

@SuppressWarnings("deprecation")
public class EmbeddingV1Activity extends io.flutter.app.FlutterActivity {
  @Override
  protected void onCreate(Bundle savedInstanceState) {
    FlutterMain.startInitialization(this);
    super.onCreate(savedInstanceState);
    GoogleSignInPlugin.registerWith(registrarFor("io.flutter.plugins.googlesignin"));
  }
}
