// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.androidalarmmanagerexample;

import android.os.Bundle;
import io.flutter.app.FlutterActivity;
import io.flutter.plugins.androidalarmmanager.AndroidAlarmManagerPlugin;

public class EmbeddingV1Activity extends FlutterActivity {
  public static final String TAG = "AlarmExampleMainActivity";

  @Override
  protected void onCreate(Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);
    AndroidAlarmManagerPlugin.registerWith(
        registrarFor("io.flutter.plugins.androidalarmmanager.AndroidAlarmManagerPlugin"));
  }
}
