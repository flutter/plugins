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
import com.google.android.gms.maps.GoogleMap;
import com.google.android.gms.maps.MapView;
import com.google.android.gms.maps.OnMapReadyCallback;
import com.google.android.gms.maps.model.Marker;
import com.google.android.gms.maps.model.MarkerOptions;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.PluginRegistry;
import io.flutter.view.TextureRegistry;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Timer;
import java.util.TimerTask;
import java.util.concurrent.atomic.AtomicInteger;

/** Controller of a single GoogleMaps MapView instance. */
final class GoogleMapController
    implements Application.ActivityLifecycleCallbacks,
        OnMapReadyCallback,
        GoogleMap.SnapshotReadyCallback,
        GoogleMap.OnCameraMoveStartedListener,
        GoogleMap.OnCameraIdleListener {
  private final AtomicInteger activityState;
  private final FrameLayout parent;
  private final PluginRegistry.Registrar registrar;
  private final TextureRegistry.SurfaceTextureEntry textureEntry;
  private final MapView mapView;
  private final Bitmap bitmap;
  private final int width;
  private final int height;
  private final MethodChannel.Result result;
  private final Timer timer;
  private final Map<String, Marker> markers;
  private final Map<String, Object> optionsStorage;
  private GoogleMap googleMap;
  private Surface surface;
  private boolean disposed = false;

  GoogleMapController(
      AtomicInteger activityState,
      PluginRegistry.Registrar registrar,
      int width,
      int height,
      Object options,
      MethodChannel.Result result) {
    this.activityState = activityState;
    this.registrar = registrar;
    this.width = width;
    this.height = height;
    this.result = result;
    this.bitmap = Bitmap.createBitmap(width, height, Bitmap.Config.ARGB_8888);
    this.parent = (FrameLayout) registrar.view().getParent();
    this.textureEntry = registrar.textures().createSurfaceTexture();
    this.surface = new Surface(textureEntry.surfaceTexture());
    textureEntry.surfaceTexture().setDefaultBufferSize(width, height);
    this.mapView = new MapView(registrar.activity(), Convert.toGoogleMapOptions(options));
    this.timer = new Timer();
    this.markers = new HashMap<>();
    this.optionsStorage = new HashMap<>();
    Convert.setMapOptionsWithNoGetters(options, optionsStorage);
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

  void setMapOptions(Object json) {
    Convert.setMapOptions(json, googleMap);
    Convert.setMapOptionsWithNoGetters(json, optionsStorage);
  }

  Object getMapOptions() {
    return Convert.getMapOptions(googleMap, optionsStorage);
  }

  void moveCamera(CameraUpdate cameraUpdate) {
    googleMap.moveCamera(cameraUpdate);
  }

  void animateCamera(CameraUpdate cameraUpdate) {
    googleMap.animateCamera(cameraUpdate);
  }

  String addMarker(MarkerOptions options) {
    final Marker marker = googleMap.addMarker(options);
    markers.put(marker.getId(), marker);
    return marker.getId();
  }

  void removeMarker(String markerId) {
    final Marker marker = markers.remove(markerId);
    if (marker != null) {
      marker.remove();
    }
  }

  void showMarkerInfoWindow(String markerId) {
    final Marker marker = marker(markerId);
    marker.showInfoWindow();
  }

  void hideMarkerInfoWindow(String markerId) {
    final Marker marker = marker(markerId);
    marker.hideInfoWindow();
  }

  void updateMarker(String markerId, MarkerOptions options) {
    final Marker marker = marker(markerId);
    marker.setPosition(options.getPosition());
    marker.setAlpha(options.getAlpha());
    marker.setAnchor(options.getAnchorU(), options.getAnchorV());
    marker.setDraggable(options.isDraggable());
    marker.setFlat(options.isFlat());
    marker.setIcon(options.getIcon());
    marker.setInfoWindowAnchor(options.getInfoWindowAnchorU(), options.getInfoWindowAnchorV());
    marker.setRotation(options.getRotation());
    marker.setSnippet(options.getSnippet());
    marker.setTitle(options.getTitle());
    marker.setVisible(options.isVisible());
    marker.setZIndex(options.getZIndex());
  }

  private Marker marker(String markerId) {
    final Marker marker = markers.get(markerId);
    if (marker == null) {
      throw new IllegalArgumentException("Unknown marker: " + markerId);
    }
    return marker;
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
    result.success(id());
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
      googleMap.snapshot(GoogleMapController.this, bitmap);
    }
  }
}
