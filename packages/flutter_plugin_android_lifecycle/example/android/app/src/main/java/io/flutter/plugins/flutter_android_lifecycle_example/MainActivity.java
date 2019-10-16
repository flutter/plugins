// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.flutter_android_lifecycle_example;

import android.util.Log;
import androidx.lifecycle.Lifecycle;
import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.embedding.engine.plugins.lifecycle.FlutterLifecycleAdapter;

public class MainActivity extends FlutterActivity {
  private static final String TAG = "MainActivity";

  @Override
  public void configureFlutterEngine(FlutterEngine flutterEngine) {
    flutterEngine.getPlugins().add(new TestPlugin());
  }

  private static class TestPlugin implements FlutterPlugin {

    @Override
    public void onAttachedToEngine(FlutterPluginBinding flutterPluginBinding) {
      Lifecycle lifecycle = FlutterLifecycleAdapter.getLifecycle(flutterPluginBinding);

      if (lifecycle == null) {
        Log.d(TAG, "Couldn't obtained Lifecycle!");
        return;
        // TODO(amirh): make this throw once the lifecycle API is available on stable.
        // https://github.com/flutter/flutter/issues/42875
        // throw new RuntimeException(
        //     "The FlutterLifecycleAdapter did not correctly provide a Lifecycle instance. Source reference: "
        //         + flutterPluginBinding.getLifecycle());
      }
      Log.d(TAG, "Successfully obtained Lifecycle: " + lifecycle);
    }

    @Override
    public void onDetachedFromEngine(FlutterPluginBinding flutterPluginBinding) {}
  }
}
