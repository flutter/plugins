// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.googlemaps;

import android.app.Activity;
import android.app.Application.ActivityLifecycleCallbacks;
import android.os.Bundle;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.lifecycle.Lifecycle;
import androidx.lifecycle.Lifecycle.Event;
import androidx.lifecycle.LifecycleOwner;
import androidx.lifecycle.LifecycleRegistry;
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.embedding.engine.plugins.lifecycle.FlutterLifecycleAdapter;

/**
 * Plugin for controlling a set of GoogleMap views to be shown as overlays on top of the Flutter
 * view. The overlay should be hidden during transformations or while Flutter is rendering on top of
 * the map. A Texture drawn using GoogleMap bitmap snapshots can then be shown instead of the
 * overlay.
 */
public class GoogleMapsPlugin implements FlutterPlugin, ActivityAware {

  @Nullable private Lifecycle lifecycle;

  private static final String VIEW_TYPE = "plugins.flutter.io/google_maps";

  @SuppressWarnings("deprecation")
  public static void registerWith(
      final io.flutter.plugin.common.PluginRegistry.Registrar registrar) {
    final Activity activity = registrar.activity();
    if (activity == null) {
      // When a background flutter view tries to register the plugin, the registrar has no activity.
      // We stop the registration process as this plugin is foreground only.
      return;
    }
    if (activity instanceof LifecycleOwner) {
      registrar
          .platformViewRegistry()
          .registerViewFactory(
              VIEW_TYPE,
              new GoogleMapFactory(
                  registrar.messenger(),
                  new LifecycleProvider() {
                    @Override
                    public Lifecycle getLifecycle() {
                      return ((LifecycleOwner) activity).getLifecycle();
                    }
                  }));
    } else {
      registrar
          .platformViewRegistry()
          .registerViewFactory(
              VIEW_TYPE,
              new GoogleMapFactory(registrar.messenger(), new ProxyLifecycleProvider(activity)));
    }
  }

  public GoogleMapsPlugin() {}

  // FlutterPlugin

  @Override
  public void onAttachedToEngine(FlutterPluginBinding binding) {
    binding
        .getPlatformViewRegistry()
        .registerViewFactory(
            VIEW_TYPE,
            new GoogleMapFactory(
                binding.getBinaryMessenger(),
                new LifecycleProvider() {
                  @Nullable
                  @Override
                  public Lifecycle getLifecycle() {
                    return lifecycle;
                  }
                }));
  }

  @Override
  public void onDetachedFromEngine(FlutterPluginBinding binding) {}

  // ActivityAware

  @Override
  public void onAttachedToActivity(ActivityPluginBinding binding) {
    lifecycle = FlutterLifecycleAdapter.getActivityLifecycle(binding);
  }

  @Override
  public void onDetachedFromActivity() {
    lifecycle = null;
  }

  @Override
  public void onReattachedToActivityForConfigChanges(ActivityPluginBinding binding) {
    onAttachedToActivity(binding);
  }

  @Override
  public void onDetachedFromActivityForConfigChanges() {
    onDetachedFromActivity();
  }

  /**
   * This class provides a {@link LifecycleOwner} for the activity driven by {@link
   * ActivityLifecycleCallbacks}.
   *
   * <p>This is used in the case where a direct Lifecycle/Owner is not available.
   */
  private static final class ProxyLifecycleProvider
      implements ActivityLifecycleCallbacks, LifecycleOwner, LifecycleProvider {

    private final LifecycleRegistry lifecycle = new LifecycleRegistry(this);
    private final int registrarActivityHashCode;

    private ProxyLifecycleProvider(Activity activity) {
      this.registrarActivityHashCode = activity.hashCode();
      activity.getApplication().registerActivityLifecycleCallbacks(this);
    }

    @Override
    public void onActivityCreated(Activity activity, Bundle savedInstanceState) {
      if (activity.hashCode() != registrarActivityHashCode) {
        return;
      }
      lifecycle.handleLifecycleEvent(Event.ON_CREATE);
    }

    @Override
    public void onActivityStarted(Activity activity) {
      if (activity.hashCode() != registrarActivityHashCode) {
        return;
      }
      lifecycle.handleLifecycleEvent(Event.ON_START);
    }

    @Override
    public void onActivityResumed(Activity activity) {
      if (activity.hashCode() != registrarActivityHashCode) {
        return;
      }
      lifecycle.handleLifecycleEvent(Event.ON_RESUME);
    }

    @Override
    public void onActivityPaused(Activity activity) {
      if (activity.hashCode() != registrarActivityHashCode) {
        return;
      }
      lifecycle.handleLifecycleEvent(Event.ON_PAUSE);
    }

    @Override
    public void onActivityStopped(Activity activity) {
      if (activity.hashCode() != registrarActivityHashCode) {
        return;
      }
      lifecycle.handleLifecycleEvent(Event.ON_STOP);
    }

    @Override
    public void onActivitySaveInstanceState(Activity activity, Bundle outState) {}

    @Override
    public void onActivityDestroyed(Activity activity) {
      if (activity.hashCode() != registrarActivityHashCode) {
        return;
      }
      activity.getApplication().unregisterActivityLifecycleCallbacks(this);
      lifecycle.handleLifecycleEvent(Event.ON_DESTROY);
    }

    @NonNull
    @Override
    public Lifecycle getLifecycle() {
      return lifecycle;
    }
  }
}
