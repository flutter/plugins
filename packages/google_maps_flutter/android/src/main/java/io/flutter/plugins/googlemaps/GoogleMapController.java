// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.googlemaps;

import static io.flutter.plugins.googlemaps.GoogleMapsPlugin.CREATED;
import static io.flutter.plugins.googlemaps.GoogleMapsPlugin.PAUSED;
import static io.flutter.plugins.googlemaps.GoogleMapsPlugin.RESUMED;
import static io.flutter.plugins.googlemaps.GoogleMapsPlugin.STARTED;
import static io.flutter.plugins.googlemaps.GoogleMapsPlugin.STOPPED;

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
import com.google.android.gms.maps.GoogleMapOptions;
import com.google.android.gms.maps.MapView;
import com.google.android.gms.maps.OnMapReadyCallback;
import com.google.android.gms.maps.model.CameraPosition;
import com.google.android.gms.maps.model.LatLngBounds;
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
        GoogleMapOptionsSink,
        OnMapReadyCallback,
        GoogleMap.SnapshotReadyCallback,
        GoogleMap.OnInfoWindowClickListener,
        GoogleMap.OnMarkerClickListener,
        GoogleMap.OnCameraMoveStartedListener,
        GoogleMap.OnCameraMoveListener,
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
  private final Map<String, MarkerController> markers;
  private OnMarkerTappedListener onMarkerTappedListener;
  private OnCameraMoveListener onCameraMoveListener;
  private OnInfoWindowTappedListener onInfoWindowTappedListener;
  private GoogleMap googleMap;
  private Surface surface;
  private boolean trackCameraPosition = false;
  private boolean disposed = false;

  GoogleMapController(
      AtomicInteger activityState,
      PluginRegistry.Registrar registrar,
      int width,
      int height,
      GoogleMapOptions options,
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
    this.mapView = new MapView(registrar.activity(), options);
    this.timer = new Timer();
    this.markers = new HashMap<>();
  }

  void setOnCameraMoveListener(OnCameraMoveListener listener) {
    this.onCameraMoveListener = listener;
  }

  void setOnMarkerTappedListener(OnMarkerTappedListener listener) {
    this.onMarkerTappedListener = listener;
  }

  void setOnInfoWindowTappedListener(OnInfoWindowTappedListener listener) {
    this.onInfoWindowTappedListener = listener;
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
    googleMap.moveCamera(cameraUpdate);
  }

  void animateCamera(CameraUpdate cameraUpdate) {
    googleMap.animateCamera(cameraUpdate);
  }

  CameraPosition getCameraPosition() {
    return trackCameraPosition ? googleMap.getCameraPosition() : null;
  }

  MarkerBuilder newMarkerBuilder() {
    return new MarkerBuilder(this);
  }

  Marker addMarker(MarkerOptions markerOptions, boolean consumesTapEvents) {
    final Marker marker = googleMap.addMarker(markerOptions);
    markers.put(
        marker.getId(), new MarkerController(marker, consumesTapEvents, onMarkerTappedListener));
    return marker;
  }

  void removeMarker(String markerId) {
    final MarkerController markerController = markers.remove(markerId);
    if (markerController != null) {
      markerController.remove();
    }
  }

  MarkerController marker(String markerId) {
    final MarkerController marker = markers.get(markerId);
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
    googleMap.setOnInfoWindowClickListener(this);
    googleMap.setOnCameraMoveStartedListener(this);
    googleMap.setOnCameraMoveListener(this);
    googleMap.setOnCameraIdleListener(this);
    googleMap.setOnMarkerClickListener(this);
    // Take snapshots until the dust settles.
    timer.schedule(newSnapshotTask(), 0);
    timer.schedule(newSnapshotTask(), 500);
    timer.schedule(newSnapshotTask(), 1000);
    timer.schedule(newSnapshotTask(), 2000);
    timer.schedule(newSnapshotTask(), 4000);
  }

  @Override
  public void onCameraMoveStarted(int reason) {
    onCameraMoveListener.onCameraMoveStarted(
        reason == GoogleMap.OnCameraMoveStartedListener.REASON_GESTURE);
    cancelSnapshotTimerTasks();
  }

  @Override
  public void onInfoWindowClick(Marker marker) {
    onInfoWindowTappedListener.onInfoWindowTapped(marker);
  }

  @Override
  public void onCameraMove() {
    if (trackCameraPosition && onCameraMoveListener != null) {
      onCameraMoveListener.onCameraMove(googleMap.getCameraPosition());
    }
  }

  @Override
  public void onCameraIdle() {
    onCameraMoveListener.onCameraIdle();
    // Take snapshots until the dust settles.
    timer.schedule(newSnapshotTask(), 500);
    timer.schedule(newSnapshotTask(), 1500);
    timer.schedule(newSnapshotTask(), 4000);
  }

  @Override
  public boolean onMarkerClick(Marker marker) {
    final MarkerController markerController = markers.get(marker.getId());
    return (markerController != null && markerController.onTap());
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

  // GoogleMapOptionsSink methods

  @Override
  public void setCameraPosition(CameraPosition position) {
    googleMap.moveCamera(CameraUpdateFactory.newCameraPosition(position));
  }

  @Override
  public void setCameraTargetBounds(LatLngBounds bounds) {
    googleMap.setLatLngBoundsForCameraTarget(bounds);
  }

  @Override
  public void setCompassEnabled(boolean compassEnabled) {
    googleMap.getUiSettings().setCompassEnabled(compassEnabled);
  }

  @Override
  public void setMapType(int mapType) {
    googleMap.setMapType(mapType);
  }

  @Override
  public void setTrackCameraPosition(boolean trackCameraPosition) {
    this.trackCameraPosition = trackCameraPosition;
  }

  @Override
  public void setRotateGesturesEnabled(boolean rotateGesturesEnabled) {
    googleMap.getUiSettings().setRotateGesturesEnabled(rotateGesturesEnabled);
  }

  @Override
  public void setScrollGesturesEnabled(boolean scrollGesturesEnabled) {
    googleMap.getUiSettings().setScrollGesturesEnabled(scrollGesturesEnabled);
  }

  @Override
  public void setTiltGesturesEnabled(boolean tiltGesturesEnabled) {
    googleMap.getUiSettings().setTiltGesturesEnabled(tiltGesturesEnabled);
  }

  @Override
  public void setMinMaxZoomPreference(Float min, Float max) {
    googleMap.resetMinMaxZoomPreference();
    if (min != null) {
      googleMap.setMinZoomPreference(min);
    }
    if (max != null) {
      googleMap.setMaxZoomPreference(max);
    }
  }

  @Override
  public void setZoomGesturesEnabled(boolean zoomGesturesEnabled) {
    googleMap.getUiSettings().setZoomGesturesEnabled(zoomGesturesEnabled);
  }
}
