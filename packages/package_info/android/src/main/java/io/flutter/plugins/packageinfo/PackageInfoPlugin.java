// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.packageinfo;

import android.content.Context;
import android.content.pm.PackageInfo;
import android.content.pm.PackageManager;
import android.os.Build;

import androidx.annotation.NonNull;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;

import java.util.HashMap;
import java.util.Map;

/**
 * PackageInfoPlugin
 */
public class PackageInfoPlugin implements MethodCallHandler, FlutterPlugin {
    private Context applicationContext;
    private MethodChannel methodChannel;

    /**
     * Plugin registration.
     */
    @SuppressWarnings("deprecation")
    public static void registerWith(io.flutter.plugin.common.PluginRegistry.Registrar registrar) {
        final PackageInfoPlugin instance = new PackageInfoPlugin();
        instance.onAttachedToEngine(registrar.context(), registrar.messenger());
    }

    @Override
    public void onAttachedToEngine(FlutterPluginBinding binding) {
        onAttachedToEngine(binding.getApplicationContext(), binding.getBinaryMessenger());
    }

    private void onAttachedToEngine(Context applicationContext, BinaryMessenger messenger) {
        this.applicationContext = applicationContext;
        methodChannel = new MethodChannel(messenger, "plugins.flutter.io/package_info");
        methodChannel.setMethodCallHandler(this);
    }

    @Override
    public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
        applicationContext = null;
        methodChannel.setMethodCallHandler(null);
        methodChannel = null;
    }

    @Override
    public void onMethodCall(MethodCall call, @NonNull Result result) {
        try {
            switch (call.method) {
                case "getAll": {
                    String packageName = applicationContext.getPackageName();
                    assert packageName != null;
                    Map<String, String> map = getApplicationInfoByPackageName(packageName);
                    result.success(map);
                    break;
                }
                case "getAllByPackageName": {
                    String packageName = call.argument("packageName");
                    assert packageName != null;
                    Map<String, String> map = getApplicationInfoByPackageName(packageName);
                    result.success(map);
                    break;
                }
                default:
                    result.notImplemented();
            }
        } catch (PackageManager.NameNotFoundException ex) {
            result.error("Name not found", ex.getMessage(), null);
        }
    }

    private Map<String, String> getApplicationInfoByPackageName(@NonNull String packageName) throws PackageManager.NameNotFoundException {
        PackageManager pm = applicationContext.getPackageManager();
        PackageInfo info = pm.getPackageInfo(packageName, 0);
        Map<String, String> map = new HashMap<>();
        map.put("appName", info.applicationInfo.loadLabel(pm).toString());
        map.put("packageName", applicationContext.getPackageName());
        map.put("version", info.versionName);
        map.put("buildNumber", String.valueOf(getLongVersionCode(info)));
        return map;
    }

    @SuppressWarnings("deprecation")
    private static long getLongVersionCode(PackageInfo info) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
            return info.getLongVersionCode();
        }
        return info.versionCode;
    }
}
