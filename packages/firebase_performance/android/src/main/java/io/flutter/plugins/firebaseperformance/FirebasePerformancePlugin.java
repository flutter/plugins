// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.firebaseperformance;

import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.PluginRegistry.Registrar;

/** FirebasePerformancePlugin */
public class FirebasePerformancePlugin {
  private static final String CHANNEL_NAME = "plugins.flutter.io/firebase_performance";

  public static void registerWith(Registrar registrar) {
    final MethodChannel channel = new MethodChannel(registrar.messenger(), CHANNEL_NAME);
    channel.setMethodCallHandler(FlutterFirebasePerformance.getInstance(registrar.messenger()));
  }
}
