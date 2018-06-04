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
import android.graphics.Canvas;
import android.os.Bundle;
import android.support.annotation.NonNull;
import android.view.Surface;
import android.view.View;
import android.widget.FrameLayout;
import android.widget.LinearLayout;

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
import java.util.HashMap;
import java.util.Map;
import java.util.concurrent.atomic.AtomicInteger;

/** Controller of a single GoogleMaps MapView instance. */
final class GoogleMapController
    implements Application.ActivityLifecycleCallbacks,
        GoogleMapOptionsSink,
        OnMapReadyCallback,
        GoogleMap.OnMarkerClickListener,
        GoogleMap.OnCameraMoveStartedListener,
        GoogleMap.OnCameraMoveListener,
        GoogleMap.OnCameraIdleListener {
  private final AtomicInteger activityState;
  private final FrameLayout parent;
  private final PluginRegistry.Registrar registrar;
  private final TextureRegistry.SurfaceTextureEntry textureEntry;
  private final MapView mapView;
  private final int width;
  private final int height;
  private final MethodChannel.Result result;
  private final Map<String, MarkerController> markers;
  private OnMarkerTappedListener onMarkerTappedListener;
  private OnCameraMoveListener onCameraMoveListener;
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
    this.parent = (FrameLayout) registrar.view().getParent();
    this.textureEntry = registrar.textures().createSurfaceTexture();
    this.surface = new Surface(textureEntry.surfaceTexture());
    textureEntry.surfaceTexture().setDefaultBufferSize(width, height);
    this.mapView = new MapView(registrar.activity(), options) {
      private boolean isDrawing = false;

      @Override
      public void draw(Canvas canvas) {
        if (isDrawing) {
          return;
        }
        isDrawing = true;
        try {
          final Canvas surfaceCanvas = surface.lockHardwareCanvas();
          super.draw(surfaceCanvas);
          surface.unlockCanvasAndPost(surfaceCanvas);
        } finally {
          isDrawing = false;
        }
      }

      @Override
      public void onDescendantInvalidated(@NonNull View child, @NonNull View target) {
        super.onDescendantInvalidated(child, target);
        // TODO(mravn): This is not right; we should draw only once per frame.
        // However, invalidate() is not enough here. Possibly because we're drawing off-screen.
        draw(null);
      }
    };
    this.markers = new HashMap<>();
  }

  void setOnCameraMoveListener(OnCameraMoveListener listener) {
    this.onCameraMoveListener = listener;
  }

  void setOnMarkerTappedListener(OnMarkerTappedListener listener) {
    this.onMarkerTappedListener = listener;
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
    final LinearLayout.LayoutParams layoutParams = new LinearLayout.LayoutParams(width, height);
    parent.addView(mapView, 0, layoutParams);
    mapView.getMapAsync(this);
  }

  long id() {
    return textureEntry.id();
  }

  @SuppressWarnings("unused")
  void showOverlay(int x, int y) {
    // ignored
  }

  void hideOverlay() {
    // ignored
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

  @Override
  public void onMapReady(GoogleMap googleMap) {
    this.googleMap = googleMap;
    result.success(id());
    googleMap.setOnCameraMoveStartedListener(this);
    googleMap.setOnCameraMoveListener(this);
    googleMap.setOnCameraIdleListener(this);
    googleMap.setOnMarkerClickListener(this);
  }

  @Override
  public void onCameraMoveStarted(int reason) {
    onCameraMoveListener.onCameraMoveStarted(
        reason == GoogleMap.OnCameraMoveStartedListener.REASON_GESTURE);
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
  }

  @Override
  public boolean onMarkerClick(Marker marker) {
    final MarkerController markerController = markers.get(marker.getId());
    return (markerController != null && markerController.onTap());
  }

  void dispose() {
    if (disposed) {
      return;
    }
    disposed = true;
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
