// Copyright 2019 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.pathprovider;

import android.content.Context;
import android.os.Build.VERSION;
import android.os.Build.VERSION_CODES;
import androidx.annotation.NonNull;
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;
import io.flutter.util.PathUtils;
import java.io.File;
import java.util.ArrayList;
import java.util.List;

public class PathProviderPlugin implements FlutterPlugin, MethodCallHandler {

  private Context context;
  private MethodChannel channel;

  public PathProviderPlugin() {}

  public static void registerWith(Registrar registrar) {
    PathProviderPlugin instance = new PathProviderPlugin();
    instance.channel = new MethodChannel(registrar.messenger(), "plugins.flutter.io/path_provider");
    instance.context = registrar.context();
    instance.channel.setMethodCallHandler(instance);
  }

  @Override
  public void onAttachedToEngine(@NonNull FlutterPluginBinding binding) {
    channel = new MethodChannel(binding.getBinaryMessenger(), "plugins.flutter.io/path_provider");
    context = binding.getApplicationContext();
    channel.setMethodCallHandler(this);
  }

  @Override
  public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
    channel.setMethodCallHandler(null);
    channel = null;
  }

  @Override
  public void onMethodCall(MethodCall call, @NonNull Result result) {
    switch (call.method) {
      case "getTemporaryDirectory":
        result.success(getPathProviderTemporaryDirectory());
        break;
      case "getApplicationDocumentsDirectory":
        result.success(getPathProviderApplicationDocumentsDirectory());
        break;
      case "getStorageDirectory":
        result.success(getPathProviderStorageDirectory());
        break;
      case "getExternalCacheDirectories":
        result.success(getPathProviderExternalCacheDirectories());
        break;
      case "getExternalStorageDirectories":
        final Integer type = call.argument("type");
        final String directoryName = StorageDirectoryMapper.androidType(type);
        result.success(getPathProviderExternalStorageDirectories(directoryName));
        break;
      case "getApplicationSupportDirectory":
        result.success(getApplicationSupportDirectory());
        break;
      default:
        result.notImplemented();
    }
  }

  private String getPathProviderTemporaryDirectory() {
    return context.getCacheDir().getPath();
  }

  private String getApplicationSupportDirectory() {
    return PathUtils.getFilesDir(context);
  }

  private String getPathProviderApplicationDocumentsDirectory() {
    return PathUtils.getDataDirectory(context);
  }

  private String getPathProviderStorageDirectory() {
    final File dir = context.getExternalFilesDir(null);
    if (dir == null) {
      return null;
    }
    return dir.getAbsolutePath();
  }

  private List<String> getPathProviderExternalCacheDirectories() {
    final List<String> paths = new ArrayList<>();

    if (VERSION.SDK_INT >= VERSION_CODES.KITKAT) {
      for (File dir : context.getExternalCacheDirs()) {
        if (dir != null) {
          paths.add(dir.getAbsolutePath());
        }
      }
    } else {
      File dir = context.getExternalCacheDir();
      if (dir != null) {
        paths.add(dir.getAbsolutePath());
      }
    }

    return paths;
  }

  private List<String> getPathProviderExternalStorageDirectories(String type) {
    final List<String> paths = new ArrayList<>();

    if (VERSION.SDK_INT >= VERSION_CODES.KITKAT) {
      for (File dir : context.getExternalFilesDirs(type)) {
        if (dir != null) {
          paths.add(dir.getAbsolutePath());
        }
      }
    } else {
      File dir = context.getExternalFilesDir(type);
      if (dir != null) {
        paths.add(dir.getAbsolutePath());
      }
    }

    return paths;
  }
}
