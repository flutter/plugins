// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.imagepickerexample;

import android.os.Build;
import android.os.Bundle;
import io.flutter.app.FlutterActivity;
import io.flutter.plugins.GeneratedPluginRegistrant;

public class MainActivity extends FlutterActivity {

  @Override
  protected void onCreate(Bundle savedInstanceState) {

    // https://github.com/flutter/flutter/issues/8610#issuecomment-459047906
    if (Build.VERSION.SDK_INT <= 20) {
      // use software rendering (ideally only when you need to)
      getIntent().putExtra("enable-software-rendering", true);
    }
    super.onCreate(savedInstanceState);
    GeneratedPluginRegistrant.registerWith(this);
  }
}
