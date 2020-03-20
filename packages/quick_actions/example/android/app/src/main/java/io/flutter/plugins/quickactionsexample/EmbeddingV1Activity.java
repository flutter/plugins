// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.quickactionsexample;

import android.os.Bundle;
import io.flutter.app.FlutterActivity;
import io.flutter.plugins.quickactions.QuickActionsPlugin;

public class EmbeddingV1Activity extends FlutterActivity {
  @Override
  protected void onCreate(Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);
    QuickActionsPlugin.registerWith(
        registrarFor("io.flutter.plugins.quickactions.QuickActionsPlugin"));
  }
}
