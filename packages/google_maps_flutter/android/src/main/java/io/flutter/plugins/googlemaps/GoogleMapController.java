// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.googlemaps;

import static io.flutter.plugins.googlemaps.GoogleMapsPlugin.CREATED;
import static io.flutter.plugins.googlemaps.GoogleMapsPlugin.DESTROYED;
import static io.flutter.plugins.googlemaps.GoogleMapsPlugin.PAUSED;
import static io.flutter.plugins.googlemaps.GoogleMapsPlugin.RESUMED;
import static io.flutter.plugins.googlemaps.GoogleMapsPlugin.STARTED;
import static io.flutter.plugins.googlemaps.GoogleMapsPlugin.STOPPED;

import android.Manifest;
import android.app.Activity;
import android.app.Application;
import android.content.Context;
import android.content.pm.PackageManager;
import android.os.Bundle;
import android.support.v4.content.ContextCompat;
import android.util.Log;
import android.view.View;
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
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.PluginRegistry;
import io.flutter.plugin.platform.PlatformView;
import java.util.Collections;
import java.util.HashMap;
import java.util.Map;
import java.util.concurrent.atomic.AtomicInteger;

/** Controller of a single GoogleMaps MapView instance. */
final class GoogleMapController
    implements Application.ActivityLifecycleCallbacks,
        GoogleMap.OnCameraIdleListener,
        GoogleMap.OnCameraMoveListener,
        GoogleMap.OnCameraMoveStartedListener,
        GoogleMap.OnInfoWindowClickListener,
        GoogleMap.OnMarkerClickListener,
        GoogleMapOptionsSink,
        MethodChannel.MethodCallHandler,
        OnMapReadyCallback,
        OnMarkerTappedListener,
        PlatformView {
  private static final String TAG = "GoogleMapController";
  private final int id;
  private final AtomicInteger activityState;
  private final MethodChannel methodChannel;
  private final PluginRegistry.Registrar registrar;
  private final MapView mapView;
  private final Map<String, MarkerController> markers;
  private GoogleMap googleMap;
  private boolean trackCameraPosition = false;
  private boolean myLocationEnabled = false;
  private boolean disposed = false;
  private final float density;
  private MethodChannel.Result mapReadyResult;
  private final int registrarActivityHashCode;
  private final Context context;

  GoogleMapController(
      int id,
      Context context,
      AtomicInteger activityState,
      PluginRegistry.Registrar registrar,
      GoogleMapOptions options) {
    this.id = id;
    this.context = context;
    this.activityState = activityState;
    this.registrar = registrar;
    this.mapView = new MapView(context, options);
    this.markers = new HashMap<>();
    this.density = context.getResources().getDisplayMetrics().density;
    methodChannel =
        new MethodChannel(registrar.messenger(), "plugins.flutter.io/google_maps_" + id);
    methodChannel.setMethodCallHandler(this);
    this.registrarActivityHashCode = registrar.activity().hashCode();
  }

  @Override
  public View getView() {
    return mapView;
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
      case DESTROYED:
        // Nothing to do, the activity has been completely destroyed.
        break;
      default:
        throw new IllegalArgumentException(
            "Cannot interpret " + activityState.get() + " as an activity state");
    }
    registrar.activity().getApplication().registerActivityLifecycleCallbacks(this);
    mapView.getMapAsync(this);
  }

  private void moveCamera(CameraUpdate cameraUpdate) {
    googleMap.moveCamera(cameraUpdate);
  }

  private void animateCamera(CameraUpdate cameraUpdate) {
    googleMap.animateCamera(cameraUpdate);
  }

  private CameraPosition getCameraPosition() {
    return trackCameraPosition ? googleMap.getCameraPosition() : null;
  }

  private MarkerBuilder newMarkerBuilder() {
    return new MarkerBuilder(this);
  }

  Marker addMarker(MarkerOptions markerOptions, boolean consumesTapEvents) {
    final Marker marker = googleMap.addMarker(markerOptions);
    markers.put(marker.getId(), new MarkerController(marker, consumesTapEvents, this));
    return marker;
  }

  private void removeMarker(String markerId) {
    final MarkerController markerController = markers.remove(markerId);
    if (markerController != null) {
      markerController.remove();
    }
  }

  private MarkerController marker(String markerId) {
    final MarkerController marker = markers.get(markerId);
    if (marker == null) {
      throw new IllegalArgumentException("Unknown marker: " + markerId);
    }
    return marker;
  }

  @Override
  public void onMapReady(GoogleMap googleMap) {
    this.googleMap = googleMap;
    googleMap.setOnInfoWindowClickListener(this);
    if (mapReadyResult != null) {
      mapReadyResult.success(null);
      mapReadyResult = null;
    }
    googleMap.setOnCameraMoveStartedListener(this);
    googleMap.setOnCameraMoveListener(this);
    googleMap.setOnCameraIdleListener(this);
    googleMap.setOnMarkerClickListener(this);
    updateMyLocationEnabled();
  }

  @Override
  public void onMethodCall(MethodCall call, MethodChannel.Result result) {
    switch (call.method) {
      case "map#waitForMap":
        if (googleMap != null) {
          result.success(null);
          return;
        }
        mapReadyResult = result;
        break;
      case "map#update":
        {
          Convert.interpretGoogleMapOptions(call.argument("options"), this);
          result.success(Convert.toJson(getCameraPosition()));
          break;
        }
      case "camera#move":
        {
          final CameraUpdate cameraUpdate =
              Convert.toCameraUpdate(call.argument("cameraUpdate"), density);
          moveCamera(cameraUpdate);
          result.success(null);
          break;
        }
      case "camera#animate":
        {
          final CameraUpdate cameraUpdate =
              Convert.toCameraUpdate(call.argument("cameraUpdate"), density);
          animateCamera(cameraUpdate);
          result.success(null);
          break;
        }
      case "marker#add":
        {
          final MarkerBuilder markerBuilder = newMarkerBuilder();
          Convert.interpretMarkerOptions(call.argument("options"), markerBuilder);
          final String markerId = markerBuilder.build();
          result.success(markerId);
          break;
        }
      case "marker#remove":
        {
          final String markerId = call.argument("marker");
          removeMarker(markerId);
          result.success(null);
          break;
        }
      case "marker#update":
        {
          final String markerId = call.argument("marker");
          final MarkerController marker = marker(markerId);
          Convert.interpretMarkerOptions(call.argument("options"), marker);
          result.success(null);
          break;
        }
      default:
        result.notImplemented();
    }
  }

  @Override
  public void onCameraMoveStarted(int reason) {
    final Map<String, Object> arguments = new HashMap<>(2);
    boolean isGesture = reason == GoogleMap.OnCameraMoveStartedListener.REASON_GESTURE;
    arguments.put("isGesture", isGesture);
    methodChannel.invokeMethod("camera#onMoveStarted", arguments);
  }

  @Override
  public void onInfoWindowClick(Marker marker) {
    final Map<String, Object> arguments = new HashMap<>(2);
    arguments.put("marker", marker.getId());
    methodChannel.invokeMethod("infoWindow#onTap", arguments);
  }

  @Override
  public void onCameraMove() {
    if (!trackCameraPosition) {
      return;
    }
    final Map<String, Object> arguments = new HashMap<>(2);
    arguments.put("position", Convert.toJson(googleMap.getCameraPosition()));
    methodChannel.invokeMethod("camera#onMove", arguments);
  }

  @Override
  public void onCameraIdle() {
    methodChannel.invokeMethod("camera#onIdle", Collections.singletonMap("map", id));
  }

  @Override
  public void onMarkerTapped(Marker marker) {
    final Map<String, Object> arguments = new HashMap<>(2);
    arguments.put("marker", marker.getId());
    methodChannel.invokeMethod("marker#onTap", arguments);
  }

  @Override
  public boolean onMarkerClick(Marker marker) {
    final MarkerController markerController = markers.get(marker.getId());
    return (markerController != null && markerController.onTap());
  }

  @Override
  public void dispose() {
    if (disposed) {
      return;
    }
    disposed = true;
    mapView.onDestroy();
    registrar.activity().getApplication().unregisterActivityLifecycleCallbacks(this);
  }

  @Override
  public void onActivityCreated(Activity activity, Bundle savedInstanceState) {
    if (disposed || activity.hashCode() != registrarActivityHashCode) {
      return;
    }
    mapView.onCreate(savedInstanceState);
  }

  @Override
  public void onActivityStarted(Activity activity) {
    if (disposed || activity.hashCode() != registrarActivityHashCode) {
      return;
    }
    mapView.onStart();
  }

  @Override
  public void onActivityResumed(Activity activity) {
    if (disposed || activity.hashCode() != registrarActivityHashCode) {
      return;
    }
    mapView.onResume();
  }

  @Override
  public void onActivityPaused(Activity activity) {
    if (disposed || activity.hashCode() != registrarActivityHashCode) {
      return;
    }
    mapView.onPause();
  }

  @Override
  public void onActivityStopped(Activity activity) {
    if (disposed || activity.hashCode() != registrarActivityHashCode) {
      return;
    }
    mapView.onStop();
  }

  @Override
  public void onActivitySaveInstanceState(Activity activity, Bundle outState) {
    if (disposed || activity.hashCode() != registrarActivityHashCode) {
      return;
    }
    mapView.onSaveInstanceState(outState);
  }

  @Override
  public void onActivityDestroyed(Activity activity) {
    if (disposed || activity.hashCode() != registrarActivityHashCode) {
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

  @Override
  public void setMyLocationEnabled(boolean myLocationEnabled) {
    if (this.myLocationEnabled == myLocationEnabled) {
      return;
    }
    this.myLocationEnabled = myLocationEnabled;
    if (googleMap != null) {
      updateMyLocationEnabled();
    }
  }

  private void updateMyLocationEnabled() {
    if (ContextCompat.checkSelfPermission(context, Manifest.permission.ACCESS_FINE_LOCATION)
            == PackageManager.PERMISSION_GRANTED
        || ContextCompat.checkSelfPermission(context, Manifest.permission.ACCESS_COARSE_LOCATION)
            == PackageManager.PERMISSION_GRANTED) {
      googleMap.setMyLocationEnabled(myLocationEnabled);
    } else {
      // TODO(amirh): Make the options update fail.
      // https://github.com/flutter/flutter/issues/24327
      Log.e(TAG, "Cannot enable MyLocation layer as location permissions are not granted");
    }
  }
}
