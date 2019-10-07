// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.deviceinfo;

import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.PluginRegistry.Registrar;


/** DeviceInfoPlugin */
public class DeviceInfoPlugin {

  /** Plugin registration. */
  public static void registerWith(Registrar registrar) {
    final MethodChannel channel =
        new MethodChannel(registrar.messenger(), "plugins.flutter.io/device_info");

    final MethodCallHandlerImpl handler = new MethodCallHandlerImpl(registrar.context().getContentResolver());
    channel.setMethodCallHandler(handler);
  }
}
