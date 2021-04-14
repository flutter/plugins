// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.pathprovider;

import android.content.Context;
import android.os.Build.VERSION;
import android.os.Build.VERSION_CODES;
import android.os.Handler;
import android.os.Looper;
import androidx.annotation.NonNull;
import com.google.common.util.concurrent.FutureCallback;
import com.google.common.util.concurrent.Futures;
import com.google.common.util.concurrent.SettableFuture;
import com.google.common.util.concurrent.ThreadFactoryBuilder;
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.util.PathUtils;
import java.io.File;
import java.util.ArrayList;
import java.util.List;
import java.util.concurrent.Callable;
import java.util.concurrent.Executor;
import java.util.concurrent.Executors;

public class PathProviderPlugin implements FlutterPlugin, MethodCallHandler {

  private Context context;
  private MethodChannel channel;
  private final Executor uiThreadExecutor = new UiThreadExecutor();
  private final Executor executor =
      Executors.newSingleThreadExecutor(
          new ThreadFactoryBuilder()
              .setNameFormat("path-provider-background-%d")
              .setPriority(Thread.NORM_PRIORITY)
              .build());

  public PathProviderPlugin() {}

  @SuppressWarnings("deprecation")
  public static void registerWith(io.flutter.plugin.common.PluginRegistry.Registrar registrar) {
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

  private <T> void executeInBackground(Callable<T> task, Result result) {
    final SettableFuture<T> future = SettableFuture.create();
    Futures.addCallback(
        future,
        new FutureCallback<T>() {
          public void onSuccess(T answer) {
            result.success(answer);
          }

          public void onFailure(Throwable t) {
            result.error(t.getClass().getName(), t.getMessage(), null);
          }
        },
        uiThreadExecutor);
    executor.execute(
        () -> {
          try {
            future.set(task.call());
          } catch (Throwable t) {
            future.setException(t);
          }
        });
  }

  @Override
  public void onMethodCall(MethodCall call, @NonNull Result result) {
    switch (call.method) {
      case "getTemporaryDirectory":
        executeInBackground(() -> getPathProviderTemporaryDirectory(), result);
        break;
      case "getApplicationDocumentsDirectory":
        executeInBackground(() -> getPathProviderApplicationDocumentsDirectory(), result);
        break;
      case "getStorageDirectory":
        executeInBackground(() -> getPathProviderStorageDirectory(), result);
        break;
      case "getExternalCacheDirectories":
        executeInBackground(() -> getPathProviderExternalCacheDirectories(), result);
        break;
      case "getExternalStorageDirectories":
        final Integer type = call.argument("type");
        final String directoryName = StorageDirectoryMapper.androidType(type);
        executeInBackground(() -> getPathProviderExternalStorageDirectories(directoryName), result);
        break;
      case "getApplicationSupportDirectory":
        executeInBackground(() -> getApplicationSupportDirectory(), result);
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

  private static class UiThreadExecutor implements Executor {
    private final Handler handler = new Handler(Looper.getMainLooper());

    @Override
    public void execute(Runnable command) {
      handler.post(command);
    }
  }
}
