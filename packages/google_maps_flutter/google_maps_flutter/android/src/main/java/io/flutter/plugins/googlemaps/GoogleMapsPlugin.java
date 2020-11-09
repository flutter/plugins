// Copyright 2018 The Chromium Authors. All rights reserved.
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
import androidx.lifecycle.LifecycleEventObserver;
import androidx.lifecycle.LifecycleOwner;
import androidx.lifecycle.LifecycleRegistry;
import androidx.savedstate.SavedStateRegistry;
import androidx.savedstate.SavedStateRegistryController;
import androidx.savedstate.SavedStateRegistryOwner;
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding.OnSaveInstanceStateListener;
import io.flutter.embedding.engine.plugins.lifecycle.FlutterLifecycleAdapter;

/**
 * Plugin for controlling a set of GoogleMap views to be shown as overlays on top of the Flutter
 * view. The overlay should be hidden during transformations or while Flutter is rendering on top of
 * the map. A Texture drawn using GoogleMap bitmap snapshots can then be shown instead of the
 * overlay.
 */
public class GoogleMapsPlugin implements FlutterPlugin, ActivityAware {

  @Nullable private DelegatingSavedStateRegistryOwner lifecycleOwner;

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
    if (activity instanceof SavedStateRegistryOwner) {
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
                    return lifecycleOwner == null ? null : lifecycleOwner.lifecycle;
                  }
                }));
  }

  @Override
  public void onDetachedFromEngine(FlutterPluginBinding binding) {}

  // ActivityAware

  @Override
  public void onAttachedToActivity(ActivityPluginBinding binding) {
    lifecycleOwner = new DelegatingSavedStateRegistryOwner(binding);
  }

  @Override
  public void onDetachedFromActivity() {
    lifecycleOwner = null;
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
      implements ActivityLifecycleCallbacks, SavedStateRegistryOwner, LifecycleProvider {

    private final LifecycleRegistry lifecycle = new LifecycleRegistry(this);
    private final SavedStateRegistryController savedStateRegistryController =
        SavedStateRegistryController.create(this);
    private final int registrarActivityHashCode;

    private ProxyLifecycleProvider(Activity activity) {
      this.registrarActivityHashCode = activity.hashCode();
      activity.getApplication().registerActivityLifecycleCallbacks(this);
    }

    @Override
    public void onActivityCreated(Activity activity, @Nullable Bundle savedInstanceState) {
      if (activity.hashCode() != registrarActivityHashCode) {
        return;
      }
      savedStateRegistryController.performRestore(savedInstanceState);
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
    public void onActivitySaveInstanceState(Activity activity, Bundle outState) {
      if (activity.hashCode() != registrarActivityHashCode) {
        return;
      }
      savedStateRegistryController.performSave(outState);
    }

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

    @NonNull
    @Override
    public SavedStateRegistry getSavedStateRegistry() {
      return savedStateRegistryController.getSavedStateRegistry();
    }
  }

  /**
   * This logic enables accurate state-saving behavior for the plugin regardless of usage. It is
   * incredibly hacky, in order to address multiple problems with the Flutter embedding library.
   *
   * <p>Ideally, every {@link LifecycleOwner} that drives this plugin would also implement {@link
   * SavedStateRegistryOwner}. This would make this class completely unnecessary. However, {@link
   * io.flutter.embedding.android.FlutterActivity} does not (at the time of this writing) do this.
   *
   * <p>Given that, ideally, every LifecycleOwner that drives this plugin would restore state at the
   * correct time. This would allow us to consistently drive state restoration via {@link
   * OnSaveInstanceStateListener} rather than possibly needing to delegate to the LifecycleOwner.
   * Unfortunately, {@link io.flutter.embedding.android.FlutterFragment} (at the time of this
   * writing) restores state in {@link androidx.fragment.app.Fragment#onActivityCreated(Bundle)}
   * rather than in {@link androidx.fragment.app.Fragment#onCreate(Bundle)}. Note that this is a
   * pretty serious bug in FlutterFragment.
   *
   * <p>Given that, ideally, the {@link ActivityPluginBinding} would provide access to the
   * LifecycleOwner instead of the underlying {@link Lifecycle}. This would allow the plugin to do
   * the instanceof check for {@link SavedStateRegistryOwner} directly in {@link
   * #onAttachedToActivity(ActivityPluginBinding)} and decide to use that Lifecycle/Owner directly
   * if possible. Instead, the plugin has to always use this delegate to wait for the first call to
   * {@link #onStateChanged(LifecycleOwner, Event)} to choose which {@link SavedStateRegistry} to
   * use.
   *
   * <p>This logic is safe despite {@link #getSavedStateRegistry()} being {@link NonNull} because
   * the only caller of that method is {@link GoogleMapController}, which can be guaranteed to
   * perform the call in its lifecycle observer callback, which necessarily happens after {@link
   * #onStateChanged(LifecycleOwner, Event)}.
   */
  private static final class DelegatingSavedStateRegistryOwner
      implements LifecycleEventObserver, SavedStateRegistryOwner, OnSaveInstanceStateListener {

    private final LifecycleRegistry lifecycle = new LifecycleRegistry(this);
    private final SavedStateRegistryController savedStateRegistryController =
        SavedStateRegistryController.create(this);

    private SavedStateRegistry savedStateRegistry;

    private DelegatingSavedStateRegistryOwner(ActivityPluginBinding binding) {
      binding.addOnSaveStateListener(this);
      FlutterLifecycleAdapter.getActivityLifecycle(binding).addObserver(this);
    }

    @Override
    public void onStateChanged(@NonNull LifecycleOwner source, @NonNull Event event) {
      if (savedStateRegistry == null) {
        savedStateRegistry =
            source instanceof SavedStateRegistryOwner
                ? ((SavedStateRegistryOwner) source).getSavedStateRegistry()
                : savedStateRegistryController.getSavedStateRegistry();
      }
      lifecycle.handleLifecycleEvent(event);
    }

    @Override
    public void onSaveInstanceState(@NonNull Bundle bundle) {
      savedStateRegistryController.performSave(bundle);
    }

    @Override
    public void onRestoreInstanceState(@Nullable Bundle bundle) {
      savedStateRegistryController.performRestore(bundle);
    }

    @NonNull
    @Override
    public SavedStateRegistry getSavedStateRegistry() {
      return savedStateRegistry;
    }

    @NonNull
    @Override
    public Lifecycle getLifecycle() {
      return lifecycle;
    }
  }
}
