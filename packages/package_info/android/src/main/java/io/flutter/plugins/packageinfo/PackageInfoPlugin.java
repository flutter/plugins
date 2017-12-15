// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.packageinfo;

import android.content.Context;
import android.content.pm.PackageInfo;
import android.content.pm.PackageManager;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;

/** PackageInfoPlugin */
public class PackageInfoPlugin implements MethodCallHandler {
  private final Registrar mRegistrar;

  /** Plugin registration. */
  public static void registerWith(Registrar registrar) {
    final MethodChannel channel =
        new MethodChannel(registrar.messenger(), "plugins.flutter.io/package_info");
    channel.setMethodCallHandler(new PackageInfoPlugin(registrar));
  }

  private PackageInfoPlugin(Registrar registrar) {
    this.mRegistrar = registrar;
  }

  @Override
  public void onMethodCall(MethodCall call, Result result) {
    try {
      Context context = mRegistrar.context();
      PackageInfo info = context.getPackageManager().getPackageInfo(context.getPackageName(), 0);
      switch (call.method) {
        case "getVersion":
          result.success(info.versionName);
          break;
        case "getBuildNumber":
          result.success(String.valueOf(info.versionCode));
          break;
        default:
          result.notImplemented();
      }
    } catch (PackageManager.NameNotFoundException ex) {
      result.error("Name not found", ex.getMessage(), null);
    }
  }
}
