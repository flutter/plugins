// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.googlemobilemaps;

import static io.flutter.plugins.googlemobilemaps.GoogleMobileMapsPlugin.CREATED;
import static io.flutter.plugins.googlemobilemaps.GoogleMobileMapsPlugin.PAUSED;
import static io.flutter.plugins.googlemobilemaps.GoogleMobileMapsPlugin.RESUMED;
import static io.flutter.plugins.googlemobilemaps.GoogleMobileMapsPlugin.STARTED;
import static io.flutter.plugins.googlemobilemaps.GoogleMobileMapsPlugin.STOPPED;

import android.app.Activity;
import android.app.Application;
import android.graphics.Bitmap;
import android.graphics.Canvas;
import android.graphics.Paint;
import android.os.Bundle;
import android.view.Surface;
import android.widget.FrameLayout;
import com.google.android.gms.maps.CameraUpdate;
import com.google.android.gms.maps.CameraUpdateFactory;
import com.google.android.gms.maps.GoogleMap;
import com.google.android.gms.maps.MapView;
import com.google.android.gms.maps.OnMapReadyCallback;
import com.google.android.gms.maps.model.LatLng;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;
import io.flutter.view.TextureRegistry;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Timer;
import java.util.TimerTask;
import java.util.concurrent.atomic.AtomicInteger;

public class GoogleMobileMapsPlugin
    implements MethodCallHandler, Application.ActivityLifecycleCallbacks {
  static final int CREATED = 1;
  static final int STARTED = 2;
  static final int RESUMED = 3;
  static final int PAUSED = 4;
  static final int STOPPED = 5;
  private final int DESTROYED = 6;
  private final Map<Long, GoogleMapsEntry> googleMaps = new HashMap<>();
  private final Registrar registrar;
  private final AtomicInteger state = new AtomicInteger(0);

  public static void registerWith(Registrar registrar) {
    final GoogleMobileMapsPlugin plugin = new GoogleMobileMapsPlugin(registrar);
    final MethodChannel channel =
        new MethodChannel(registrar.messenger(), "plugins.flutter.io/google_mobile_maps");
    channel.setMethodCallHandler(plugin);
    registrar.activity().getApplication().registerActivityLifecycleCallbacks(plugin);
  }

  private GoogleMobileMapsPlugin(Registrar registrar) {
    this.registrar = registrar;
  }

  @Override
  public void onMethodCall(MethodCall call, Result result) {
    switch (call.method) {
      case "init":
        {
          for (GoogleMapsEntry entry : googleMaps.values()) {
            entry.dispose();
          }
          googleMaps.clear();
          result.success(null);
          break;
        }
      case "createMap":
        {
          final int width = ((Number) call.argument("width")).intValue();
          final int height = ((Number) call.argument("height")).intValue();
          final GoogleMapsEntry entry = new GoogleMapsEntry(state, registrar, width, height);
          googleMaps.put(entry.id(), entry);
          entry.init();
          result.success(entry.id());
          break;
        }
      case "moveCamera":
        {
          final long id = ((Number) call.argument("id")).longValue();
          final List<Double> location = call.argument("location");
          final float zoom = ((Number) call.argument("zoom")).floatValue();
          final GoogleMapsEntry entry = googleMaps.get(id);
          if (entry == null) {
            result.error("unknown", "Unknown ID " + id, null);
          } else {
            entry.moveCamera(
                CameraUpdateFactory.newLatLngZoom(
                    new LatLng(location.get(0), location.get(1)), zoom));
            result.success(null);
          }
          break;
        }
      case "showMapOverlay":
        {
          final long id = ((Number) call.argument("id")).longValue();
          final int x = ((Number) call.argument("x")).intValue();
          final int y = ((Number) call.argument("y")).intValue();
          final GoogleMapsEntry entry = googleMaps.get(id);
          if (entry == null) {
            result.error("unknown", "Unknown ID " + id, null);
          } else {
            entry.showOverlay(x, y);
            result.success(null);
          }
          break;
        }
      case "hideMapOverlay":
        {
          final long id = ((Number) call.argument("id")).longValue();
          final GoogleMapsEntry entry = googleMaps.get(id);
          if (entry == null) {
            result.error("unknown", "Unknown ID " + id, null);
          } else {
            entry.hideOverlay();
            result.success(null);
          }
          break;
        }
      case "disposeMap":
        {
          final long id = ((Number) call.argument("id")).longValue();
          final GoogleMapsEntry entry = googleMaps.get(id);
          if (entry == null) {
            result.error("unknown", "Unknown ID " + id, null);
          } else {
            entry.dispose();
            result.success(null);
          }
          break;
        }
      default:
        result.notImplemented();
    }
  }

  @Override
  public void onActivityCreated(Activity activity, Bundle savedInstanceState) {
    state.set(CREATED);
  }

  @Override
  public void onActivityStarted(Activity activity) {
    state.set(STARTED);
  }

  @Override
  public void onActivityResumed(Activity activity) {
    state.set(RESUMED);
  }

  @Override
  public void onActivityPaused(Activity activity) {
    state.set(PAUSED);
  }

  @Override
  public void onActivityStopped(Activity activity) {
    state.set(STOPPED);
  }

  @Override
  public void onActivitySaveInstanceState(Activity activity, Bundle outState) {}

  @Override
  public void onActivityDestroyed(Activity activity) {
    state.set(DESTROYED);
  }
}

final class GoogleMapsEntry
    implements Application.ActivityLifecycleCallbacks,
        OnMapReadyCallback,
        GoogleMap.SnapshotReadyCallback,
        GoogleMap.OnCameraMoveStartedListener,
        GoogleMap.OnCameraIdleListener {
  private final AtomicInteger activityState;
  private final FrameLayout parent;
  private final Registrar registrar;
  private final TextureRegistry.SurfaceTextureEntry textureEntry;
  private final MapView mapView;
  private final Bitmap bitmap;
  private final int width;
  private final int height;
  private final Timer timer;
  private GoogleMap googleMap;
  private Surface surface;
  private boolean disposed = false;

  GoogleMapsEntry(AtomicInteger activityState, Registrar registrar, int width, int height) {
    this.activityState = activityState;
    this.registrar = registrar;
    this.width = width;
    this.height = height;
    this.bitmap = Bitmap.createBitmap(width, height, Bitmap.Config.ARGB_8888);
    this.parent = (FrameLayout) registrar.view().getParent();
    this.textureEntry = registrar.textures().createSurfaceTexture();
    this.surface = new Surface(textureEntry.surfaceTexture());
    textureEntry.surfaceTexture().setDefaultBufferSize(width, height);
    this.mapView = new MapView(registrar.activity());
    this.timer = new Timer();
  }

  void init() {
    switch (activityState.get()) {
      case STOPPED:
        mapView.onCreate(null);
        mapView.onStart();
        mapView.onResume();
        mapView.onPause();
        mapView.onStop();
        break;
      case PAUSED:
        mapView.onCreate(null);
        mapView.onStart();
        mapView.onResume();
        mapView.onPause();
        break;
      case RESUMED:
        mapView.onCreate(null);
        mapView.onStart();
        mapView.onResume();
        break;
      case STARTED:
        mapView.onCreate(null);
        mapView.onStart();
        break;
      case CREATED:
        mapView.onCreate(null);
        break;
    }
    registrar.activity().getApplication().registerActivityLifecycleCallbacks(this);
    final FrameLayout.LayoutParams layoutParams = new FrameLayout.LayoutParams(width, height);
    parent.addView(mapView, 0, layoutParams);
    mapView.getMapAsync(this);
  }

  long id() {
    return textureEntry.id();
  }

  void showOverlay(int x, int y) {
    if (disposed) {
      return;
    }
    parent.removeView(mapView);
    final FrameLayout.LayoutParams layout = new FrameLayout.LayoutParams(width, height);
    layout.leftMargin = x;
    layout.topMargin = y;
    parent.addView(mapView, layout);
  }

  void hideOverlay() {
    if (disposed) {
      return;
    }
    googleMap.stopAnimation();
    parent.removeView(mapView);
    parent.addView(mapView, 0);
  }

  void moveCamera(CameraUpdate cameraUpdate) {
    googleMap.animateCamera(cameraUpdate);
  }

  private void updateTexture() {
    if (disposed) {
      return;
    }
    final Canvas canvas = surface.lockCanvas(null);
    canvas.drawBitmap(bitmap, 0, 0, new Paint());
    surface.unlockCanvasAndPost(canvas);
  }

  @Override
  public void onMapReady(GoogleMap googleMap) {
    this.googleMap = googleMap;
    googleMap.setOnCameraMoveStartedListener(this);
    googleMap.setOnCameraIdleListener(this);
    // Take snapshots until the dust settles.
    timer.schedule(newSnapshotTask(), 0);
    timer.schedule(newSnapshotTask(), 500);
    timer.schedule(newSnapshotTask(), 1000);
    timer.schedule(newSnapshotTask(), 2000);
    timer.schedule(newSnapshotTask(), 4000);
  }

  @Override
  public void onCameraMoveStarted(int reason) {
    cancelSnapshotTimerTasks();
  }

  @Override
  public void onCameraIdle() {
    // Take snapshots until the dust settles.
    timer.schedule(newSnapshotTask(), 500);
    timer.schedule(newSnapshotTask(), 1500);
    timer.schedule(newSnapshotTask(), 4000);
  }

  @Override
  public void onSnapshotReady(Bitmap bitmap) {
    updateTexture();
  }

  void dispose() {
    if (disposed) {
      return;
    }
    disposed = true;
    timer.cancel();
    parent.removeView(mapView);
    textureEntry.release();
    mapView.onDestroy();
    registrar.activity().getApplication().unregisterActivityLifecycleCallbacks(this);
  }

  @Override
  public void onActivityCreated(Activity activity, Bundle savedInstanceState) {
    if (disposed) {
      return;
    }
    mapView.onCreate(savedInstanceState);
  }

  @Override
  public void onActivityStarted(Activity activity) {
    if (disposed) {
      return;
    }
    mapView.onStart();
  }

  @Override
  public void onActivityResumed(Activity activity) {
    if (disposed) {
      return;
    }
    mapView.onResume();
  }

  @Override
  public void onActivityPaused(Activity activity) {
    if (disposed) {
      return;
    }
    mapView.onPause();
  }

  @Override
  public void onActivityStopped(Activity activity) {
    if (disposed) {
      return;
    }
    mapView.onStop();
  }

  @Override
  public void onActivitySaveInstanceState(Activity activity, Bundle outState) {
    if (disposed) {
      return;
    }
    mapView.onSaveInstanceState(outState);
  }

  @Override
  public void onActivityDestroyed(Activity activity) {
    if (disposed) {
      return;
    }
    mapView.onDestroy();
  }

  private List<SnapshotTimerTask> snapshotTasks = new ArrayList<>();

  private SnapshotTimerTask newSnapshotTask() {
    final SnapshotTimerTask task = new SnapshotTimerTask();
    snapshotTasks.add(task);
    return task;
  }

  private void cancelSnapshotTimerTasks() {
    for (SnapshotTimerTask task : snapshotTasks) {
      task.cancel();
    }
    snapshotTasks.clear();
  }

  class SnapshotTimerTask extends TimerTask {
    @Override
    public void run() {
      if (disposed || activityState.get() != RESUMED) {
        return;
      }
      googleMap.snapshot(GoogleMapsEntry.this, bitmap);
    }
  }
}
