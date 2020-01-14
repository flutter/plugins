// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.imagepickerexample;

import android.os.Bundle;
import io.flutter.app.FlutterActivity;
import io.flutter.plugins.imagepicker.ImagePickerPlugin;
import io.flutter.plugins.videoplayer.VideoPlayerPlugin;

public class EmbeddingV1Activity extends FlutterActivity {
  @Override
  protected void onCreate(Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);
    ImagePickerPlugin.registerWith(
        registrarFor("io.flutter.plugins.imagepicker.ImagePickerPlugin"));
    VideoPlayerPlugin.registerWith(
        registrarFor("io.flutter.plugins.videoplayer.VideoPlayerPlugin"));
  }
}
