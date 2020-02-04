// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.deviceinfo;

import android.content.ContentResolver;
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.PluginRegistry.Registrar;

/** DeviceInfoPlugin */
public class DeviceInfoPlugin implements FlutterPlugin {

  MethodChannel channel;

  /** Plugin registration. */
  public static void registerWith(Registrar registrar) {
    DeviceInfoPlugin plugin = new DeviceInfoPlugin();
    plugin.setupMethodChannel(registrar.messenger(), registrar.context().getContentResolver());
  }

  @Override
  public void onAttachedToEngine(FlutterPlugin.FlutterPluginBinding binding) {
    setupMethodChannel(
        binding.getFlutterEngine().getDartExecutor(),
        binding.getApplicationContext().getContentResolver());
  }

  @Override
  public void onDetachedFromEngine(FlutterPlugin.FlutterPluginBinding binding) {
    tearDownChannel();
  }

  private void setupMethodChannel(BinaryMessenger messenger, ContentResolver contentResolver) {
    channel = new MethodChannel(messenger, "plugins.flutter.io/device_info");
    final MethodCallHandlerImpl handler = new MethodCallHandlerImpl(contentResolver);
    channel.setMethodCallHandler(handler);
  }

  private void tearDownChannel() {
    channel.setMethodCallHandler(null);
    channel = null;
  }
}
