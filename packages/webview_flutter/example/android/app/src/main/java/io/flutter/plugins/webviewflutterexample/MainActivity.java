// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.webviewflutterexample;

import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugins.webviewflutter.WebViewFlutterPlugin;

/**
 * THIS PLUGIN CODE PATH DEPENDS ON A NEWER VERSION OF FLUTTER THAN THE ONE DEFINED IN THE
 * PUBSPEC.YAML. Text input will fail on some Android devices unless this is used with at least
 * flutter/flutter@1d4d63ace1f801a022ea9ec737bf8c15395588b9.
 *
 * <p>Use the V1 embedding as seen in {@link EmbeddingV1Activity} to use this plugin on older
 * Flutter versions.
 */
public class MainActivity extends FlutterActivity {
  // TODO(mklim): Remove this once v2 of GeneratedPluginRegistrant rolls to stable. https://github.com/flutter/flutter/issues/42694
  @Override
  public void configureFlutterEngine(FlutterEngine flutterEngine) {
    flutterEngine.getPlugins().add(new WebViewFlutterPlugin());
  }
}
