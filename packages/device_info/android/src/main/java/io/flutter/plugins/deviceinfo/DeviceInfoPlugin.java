// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.deviceinfo;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.PluginRegistry.Registrar;

/** DeviceInfoPlugin */
public class DeviceInfoPlugin implements FlutterPlugin {

  /** Plugin registration. */
  public static void registerWith(Registrar registrar) {
    final MethodChannel channel =
        new MethodChannel(registrar.messenger(), "plugins.flutter.io/device_info");

    final MethodCallHandlerImpl handler =
        new MethodCallHandlerImpl(registrar.context().getContentResolver());
    channel.setMethodCallHandler(handler);
  }

  @Override
  public void onAttachedToEngine(FlutterPlugin.FlutterPluginBinding binding) {
    final MethodChannel channel =
        new MethodChannel(
            binding.getFlutterEngine().getDartExecutor(), "plugins.flutter.io/device_info");

    final MethodCallHandlerImpl handler =
        new MethodCallHandlerImpl(binding.getApplicationContext().getContentResolver());
    channel.setMethodCallHandler(handler);
  }

  @Override
  public void onDetachedFromEngine(FlutterPlugin.FlutterPluginBinding binding) {}
}
