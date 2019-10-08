// Copyright 2019 The Chromium Authors. All rights reserved.	// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be	// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.	// found in the LICENSE file.

package io.flutter.plugins.quickactionsexample;

import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugins.quickactions.QuickActionsPlugin;

public class MainActivity extends FlutterActivity {

  @Override
  public void configureFlutterEngine(FlutterEngine flutterEngine) {
    super.configureFlutterEngine(flutterEngine);
    flutterEngine.getPlugins().add(new QuickActionsPlugin());
  }
}
