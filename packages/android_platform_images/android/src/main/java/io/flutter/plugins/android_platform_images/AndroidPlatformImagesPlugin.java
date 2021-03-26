// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
package io.flutter.plugins.android_platform_images;

import android.os.Handler;
import android.util.Log;

import java.util.HashMap;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;

import androidx.annotation.NonNull;
import io.flutter.BuildConfig;
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;

/**
 * AndroidPlatformImagesPlugin
 * 
 * Share drawable/assets/mipmap of Android Host to Flutter.
 */
public class AndroidPlatformImagesPlugin implements FlutterPlugin, MethodCallHandler {
  static final String TAG = "AndroidPlatformImages";
  private static final String CHANNEL_NAME = "plugins.flutter.io/android_platform_images";
  
  // method name
  private static final String DRAWABLE = "drawable";
  private static final String ASSETS = "assets";
  
  // entrance for register drawable&mipmap id with custom name.
  // a solution for drawable proguard tool(AndResGuard).
  public static final HashMap<String, Integer> resourceMap = new HashMap<>();
  
  // loader for drawable & mipmap
  DrawableImageLoader drawableImageLoader;
  // loader for assets image
  AssetsImageLoader assetsImageLoader;
  private MethodChannel channel;

  // speed up with multi thread loading, which also avoid ANR in main thread.
  private ExecutorService fixedThreadPool;
  private Handler mainHandler;
  
  // key for Flutter
  // name for drawable&mipmap or full path for assets images.
  private static final String ARG_ID = "id";
  private static final String ARG_QUALITY = "quality";

  @Override
  public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
    channel = new MethodChannel(flutterPluginBinding.getBinaryMessenger(), CHANNEL_NAME);
    channel.setMethodCallHandler(this);

    drawableImageLoader = new DrawableImageLoader(flutterPluginBinding.getApplicationContext());
    assetsImageLoader = new AssetsImageLoader(flutterPluginBinding.getApplicationContext());

    mainHandler = new Handler(flutterPluginBinding.getApplicationContext().getMainLooper());
    int THREAD_POOL_SIZE = 5;
    fixedThreadPool = Executors.newFixedThreadPool(THREAD_POOL_SIZE);
  }

  @Override
  public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
    final MethodCall methodCall = call;
    final Result finalResult = result;
    fixedThreadPool.submit(new Runnable() {
      @Override
      public void run() {
        asyncLoadImage(methodCall, finalResult);
      }
    });
  }

  private void asyncLoadImage(final MethodCall call, final Result result) {
    String id = call.argument(ARG_ID);
    int quality = call.argument(ARG_QUALITY);
    byte[] ret = null;
    long start = 0L;
    if (BuildConfig.DEBUG) {
      start = System.currentTimeMillis();
    }
    if (DRAWABLE.equals(call.method) && drawableImageLoader != null) {
      ret = drawableImageLoader.loadBitmapDrawable(id, quality);
    } else if (ASSETS.equals(call.method) && assetsImageLoader != null) {
      ret = assetsImageLoader.loadImage(id);
    }
    if (ret == null) {
      if (BuildConfig.DEBUG) {
        Log.d(TAG, "load fail:" +call.method + "/" + call.arguments);
      }
      return;
    }

    if (BuildConfig.DEBUG) {
      String builder = "Image Size:" + ret.length/1000 + "kb\t" +
              "Time Used:" + (System.currentTimeMillis() - start) + "ms\t" +
              "Image Info:" + call.method + '/' + call.arguments;
      Log.d(TAG, builder);
    }
    final byte[] finalRet = ret;
    mainHandler.post(new Runnable() {
      @Override
      public void run() {
        result.success(finalRet);
      }
    });
  }

  @Override
  public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
    channel.setMethodCallHandler(null);

    drawableImageLoader.dispose();
    assetsImageLoader.dispose();

    fixedThreadPool.shutdown();
    fixedThreadPool = null;
    mainHandler = null;
  }
}
