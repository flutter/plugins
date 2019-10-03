// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.androidintent;

import dev.flutter.plugins.androidintent.IntentSender;
import dev.flutter.plugins.androidintent.MethodCallHandlerImpl;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.PluginRegistry.Registrar;

/** AndroidIntentPlugin */
public class AndroidIntentPlugin {
  /** Plugin registration. */
  public static void registerWith(Registrar registrar) {
    final MethodChannel channel =
        new MethodChannel(registrar.messenger(), "plugins.flutter.io/android_intent");
    IntentSender sender = new IntentSender(registrar.activity(), registrar.context());
    channel.setMethodCallHandler(new MethodCallHandlerImpl(sender));
  }
}
