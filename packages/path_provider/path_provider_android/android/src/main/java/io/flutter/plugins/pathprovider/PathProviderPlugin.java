// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.pathprovider;

import android.content.Context;
import android.os.Build.VERSION;
import android.os.Build.VERSION_CODES;
import android.os.Handler;
import android.os.Looper;
import android.util.Log;
import androidx.annotation.NonNull;
import com.google.common.util.concurrent.FutureCallback;
import com.google.common.util.concurrent.Futures;
import com.google.common.util.concurrent.SettableFuture;
import com.google.common.util.concurrent.ThreadFactoryBuilder;
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.MethodCodec;
import io.flutter.plugin.common.StandardMethodCodec;
import io.flutter.util.PathUtils;
import java.io.File;
import java.lang.reflect.Constructor;
import java.lang.reflect.Method;
import java.util.ArrayList;
import java.util.List;
import java.util.concurrent.Callable;
import java.util.concurrent.Executor;
import java.util.concurrent.Executors;

public class PathProviderPlugin implements FlutterPlugin, MethodCallHandler {
  static final String TAG = "PathProviderPlugin";
  private Context context;
  private MethodChannel channel;
  private PathProviderImpl impl;

  /**
   * An abstraction over how to access the paths in a thread-safe manner.
   *
   * <p>We need this so on versions of Flutter that support Background Platform Channels this plugin
   * can take advantage of it.
   *
   * <p>This can be removed after https://github.com/flutter/engine/pull/29147 becomes available on
   * the stable branch.
   */
  private interface PathProviderImpl {
    void getTemporaryDirectory(@NonNull Result result);

    void getApplicationDocumentsDirectory(@NonNull Result result);

    void getStorageDirectory(@NonNull Result result);

    void getExternalCacheDirectories(@NonNull Result result);

    void getExternalStorageDirectories(@NonNull String directoryName, @NonNull Result result);

    void getApplicationSupportDirectory(@NonNull Result result);
  }

  /** The implementation for getting system paths that executes from the platform */
  private class PathProviderPlatformThread implements PathProviderImpl {
    private final Executor uiThreadExecutor = new UiThreadExecutor();
    private final Executor executor =
        Executors.newSingleThreadExecutor(
            new ThreadFactoryBuilder()
                .setNameFormat("path-provider-background-%d")
                .setPriority(Thread.NORM_PRIORITY)
                .build());

    public void getTemporaryDirectory(@NonNull Result result) {
      executeInBackground(() -> getPathProviderTemporaryDirectory(), result);
    }

    public void getApplicationDocumentsDirectory(@NonNull Result result) {
      executeInBackground(() -> getPathProviderApplicationDocumentsDirectory(), result);
    }

    public void getStorageDirectory(@NonNull Result result) {
      executeInBackground(() -> getPathProviderStorageDirectory(), result);
    }

    public void getExternalCacheDirectories(@NonNull Result result) {
      executeInBackground(() -> getPathProviderExternalCacheDirectories(), result);
    }

    public void getExternalStorageDirectories(
        @NonNull String directoryName, @NonNull Result result) {
      executeInBackground(() -> getPathProviderExternalStorageDirectories(directoryName), result);
    }

    public void getApplicationSupportDirectory(@NonNull Result result) {
      executeInBackground(() -> PathProviderPlugin.this.getApplicationSupportDirectory(), result);
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
  }

  /** The implementation for getting system paths that executes from a background thread. */
  private class PathProviderBackgroundThread implements PathProviderImpl {
    public void getTemporaryDirectory(@NonNull Result result) {
      result.success(getPathProviderTemporaryDirectory());
    }

    public void getApplicationDocumentsDirectory(@NonNull Result result) {
      result.success(getPathProviderApplicationDocumentsDirectory());
    }

    public void getStorageDirectory(@NonNull Result result) {
      result.success(getPathProviderStorageDirectory());
    }

    public void getExternalCacheDirectories(@NonNull Result result) {
      result.success(getPathProviderExternalCacheDirectories());
    }

    public void getExternalStorageDirectories(
        @NonNull String directoryName, @NonNull Result result) {
      result.success(getPathProviderExternalStorageDirectories(directoryName));
    }

    public void getApplicationSupportDirectory(@NonNull Result result) {
      result.success(PathProviderPlugin.this.getApplicationSupportDirectory());
    }
  }

  public PathProviderPlugin() {}

  private void setup(BinaryMessenger messenger, Context context) {
    String channelName = "plugins.flutter.io/path_provider_android";
    // TODO(gaaclarke): Remove reflection guard when https://github.com/flutter/engine/pull/29147
    // becomes available on the stable branch.
    try {
      Class methodChannelClass = Class.forName("io.flutter.plugin.common.MethodChannel");
      Class taskQueueClass = Class.forName("io.flutter.plugin.common.BinaryMessenger$TaskQueue");
      Method makeBackgroundTaskQueue = messenger.getClass().getMethod("makeBackgroundTaskQueue");
      Object taskQueue = makeBackgroundTaskQueue.invoke(messenger);
      Constructor<MethodChannel> constructor =
          methodChannelClass.getConstructor(
              BinaryMessenger.class, String.class, MethodCodec.class, taskQueueClass);
      channel =
          constructor.newInstance(messenger, channelName, StandardMethodCodec.INSTANCE, taskQueue);
      impl = new PathProviderBackgroundThread();
      Log.d(TAG, "Use TaskQueues.");
    } catch (Exception ex) {
      channel = new MethodChannel(messenger, channelName);
      impl = new PathProviderPlatformThread();
      Log.d(TAG, "Don't use TaskQueues.");
    }
    this.context = context;
    channel.setMethodCallHandler(this);
  }

  @SuppressWarnings("deprecation")
  public static void registerWith(io.flutter.plugin.common.PluginRegistry.Registrar registrar) {
    PathProviderPlugin instance = new PathProviderPlugin();
    instance.setup(registrar.messenger(), registrar.context());
  }

  @Override
  public void onAttachedToEngine(@NonNull FlutterPluginBinding binding) {
    setup(binding.getBinaryMessenger(), binding.getApplicationContext());
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
        impl.getTemporaryDirectory(result);
        break;
      case "getApplicationDocumentsDirectory":
        impl.getApplicationDocumentsDirectory(result);
        break;
      case "getStorageDirectory":
        impl.getStorageDirectory(result);
        break;
      case "getExternalCacheDirectories":
        impl.getExternalCacheDirectories(result);
        break;
      case "getExternalStorageDirectories":
        final Integer type = call.argument("type");
        final String directoryName = StorageDirectoryMapper.androidType(type);
        impl.getExternalStorageDirectories(directoryName, result);
        break;
      case "getApplicationSupportDirectory":
        impl.getApplicationSupportDirectory(result);
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
    final List<String> paths = new ArrayList<String>();

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
    final List<String> paths = new ArrayList<String>();

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
