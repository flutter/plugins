// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.deviceinfoexample;

import android.os.Bundle;
import io.flutter.app.FlutterActivity;
import io.flutter.plugins.deviceinfo.DeviceInfoPlugin;

public class EmbeddingV1Activity extends FlutterActivity {
  @Override
  protected void onCreate(Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);
    DeviceInfoPlugin.registerWith(registrarFor("io.flutter.plugins.deviceinfo.DeviceInfoPlugin"));
  }
}
