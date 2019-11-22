// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.googlemaps;

import android.app.Activity;
import android.app.Application;
import android.os.Bundle;
import androidx.lifecycle.DefaultLifecycleObserver;
import androidx.lifecycle.Lifecycle;
import androidx.lifecycle.LifecycleOwner;
import io.flutter.plugin.common.PluginRegistry.Registrar;
import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding.OnSaveInstanceStateListener;
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.embedding.engine.plugins.FlutterPlugin.FlutterPluginBinding;
//import io.flutter.embedding.engine.plugins.lifecycle.FlutterLifecycleAdapter;
import io.flutter.Log;
import java.lang.reflect.InvocationTargetException;
import java.lang.reflect.Method;
import java.util.concurrent.atomic.AtomicInteger;

/**
 * Plugin for controlling a set of GoogleMap views to be shown as overlays on top of the Flutter
 * view. The overlay should be hidden during transformations or while Flutter is rendering on top of
 * the map. A Texture drawn using GoogleMap bitmap snapshots can then be shown instead of the
 * overlay.
 */
public class GoogleMapsPlugin implements FlutterPlugin, ActivityAware {
  private static final String TAG = "GoogleMapsPlugin";

  static final int CREATED = 1;
  static final int STARTED = 2;
  static final int RESUMED = 3;
  static final int PAUSED = 4;
  static final int STOPPED = 5;
  static final int DESTROYED = 6;

  private final AtomicInteger state = new AtomicInteger(0);
  private FlutterPluginBinding pluginBinding;
//  private final int registrarActivityHashCode;

  public static void registerWith(Registrar registrar) {
    if (registrar.activity() == null) {
      // When a background flutter view tries to register the plugin, the registrar has no activity.
      // We stop the registration process as this plugin is foreground only.
      return;
    }
//    final GoogleMapsPlugin plugin = new GoogleMapsPlugin(registrar);
//    registrar.activity().getApplication().registerActivityLifecycleCallbacks(plugin);
//    registrar
//        .platformViewRegistry()
//        .registerViewFactory(
//            "plugins.flutter.io/google_maps", new GoogleMapFactory(plugin.state, registrar));
  }

  private DefaultLifecycleObserver lifecycleObserver = new DefaultLifecycleObserver() {
    public void onCreate(LifecycleOwner owner) {
      Log.w(TAG, "onCreate()");
      state.set(CREATED);
    }

    public void onStart(LifecycleOwner owner) {
      Log.w(TAG, "onStart()");
      state.set(STARTED);
    }

    public void onResume(LifecycleOwner owner) {
      Log.w(TAG, "onResume()");
      state.set(RESUMED);
    }

    public void onPause(LifecycleOwner owner) {
      Log.w(TAG, "onPause()");
      state.set(PAUSED);
    }

    public void onStop(LifecycleOwner owner) {
      Log.w(TAG, "onStop()");
      state.set(STOPPED);
    }

    public void onDestroy(LifecycleOwner owner) {
      Log.w(TAG, "onDestroy()");
      state.set(DESTROYED);
    }
  };

//  private GoogleMapsPlugin(Registrar registrar) {
//    this.registrarActivityHashCode = registrar.activity().hashCode();
//  }

  private Lifecycle lifecycle;

  public GoogleMapsPlugin() {}

  @Override
  public void onAttachedToEngine(FlutterPluginBinding binding) {
    pluginBinding = binding;
  }

  @Override
  public void onDetachedFromEngine(FlutterPluginBinding binding) {
    pluginBinding = null;
    // TODO(amirh): should the view registry allow deregistration?
  }

  @Override
  public void onAttachedToActivity(ActivityPluginBinding binding) {
    try {
      binding.addOnSaveStateListener(new OnSaveInstanceStateListener() {
        public void onSaveInstanceState(Bundle bundle) {
          Log.w(TAG, "onSaveInstanceState()");
        }

        public void onRestoreInstanceState(Bundle bundle) {
          Log.w(TAG, "onRestoreInstanceState(): " + bundle);
        }
      });

      lifecycle = getLifecycle(binding);
      lifecycle.addObserver(lifecycleObserver);

      pluginBinding.getPlatformViewRegistry().registerViewFactory(
          "plugins.flutter.io/google_maps",
          new GoogleMapFactory(lifecycle, pluginBinding.getBinaryMessenger())
      );
    } catch (ClassNotFoundException
        | NoSuchMethodException
        | IllegalAccessException
        | InvocationTargetException e) {
      throw new RuntimeException(e);
    }
  }

  @Override
  public void onDetachedFromActivityForConfigChanges() {
    lifecycle.removeObserver(lifecycleObserver);
  }

  @Override
  public void onReattachedToActivityForConfigChanges(ActivityPluginBinding binding) {
    try {
      // TODO(amirh): how should we handle config changes? The GoogleMapController takes
      // a Lifecycle in its constructor, so it's currently configured to work with only
      // one Activity in its life span.
      lifecycle = getLifecycle(binding);
      lifecycle.addObserver(lifecycleObserver);
    } catch (ClassNotFoundException
        | NoSuchMethodException
        | IllegalAccessException
        | InvocationTargetException e) {
      throw new RuntimeException(e);
    }
  }

  @Override
  public void onDetachedFromActivity() {
    lifecycle.removeObserver(lifecycleObserver);
  }

  private Lifecycle getLifecycle(ActivityPluginBinding binding)
      throws ClassNotFoundException,
      NoSuchMethodException,
      IllegalAccessException,
      InvocationTargetException {
    Class lifecycleAdapter =
        Class.forName("io.flutter.embedding.engine.plugins.lifecycle.FlutterLifecycleAdapter");
    Method getLifecycle = lifecycleAdapter.getMethod("getActivityLifecycle", ActivityPluginBinding.class);
    return (Lifecycle) getLifecycle.invoke(null, binding);
  }
}
