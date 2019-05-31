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
<<<<<<< HEAD
import com.google.android.gms.maps.model.LatLngBounds;
import com.google.android.gms.maps.model.Marker;
import com.google.android.gms.maps.model.MarkerOptions;
=======
import com.google.android.gms.maps.model.Circle;
import com.google.android.gms.maps.model.LatLng;
import com.google.android.gms.maps.model.LatLngBounds;
import com.google.android.gms.maps.model.Marker;
import com.google.android.gms.maps.model.Polygon;
import com.google.android.gms.maps.model.Polyline;
import io.flutter.plugin.common.MethodCall;
>>>>>>> 0f80e7380086ceed3c61c05dc431a41d2c32253a
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
<<<<<<< HEAD
=======
        GoogleMap.OnCameraIdleListener,
        GoogleMap.OnCameraMoveListener,
        GoogleMap.OnCameraMoveStartedListener,
        GoogleMap.OnInfoWindowClickListener,
        GoogleMap.OnMarkerClickListener,
        GoogleMap.OnPolygonClickListener,
        GoogleMap.OnPolylineClickListener,
        GoogleMap.OnCircleClickListener,
>>>>>>> 0f80e7380086ceed3c61c05dc431a41d2c32253a
        GoogleMapOptionsSink,
        OnMapReadyCallback,
<<<<<<< HEAD
        GoogleMap.SnapshotReadyCallback,
        GoogleMap.OnInfoWindowClickListener,
        GoogleMap.OnMarkerClickListener,
        GoogleMap.OnCameraMoveStartedListener,
        GoogleMap.OnCameraMoveListener,
        GoogleMap.OnCameraIdleListener {
=======
        GoogleMap.OnMapClickListener,
        GoogleMap.OnMapLongClickListener,
        PlatformView {

  private static final String TAG = "GoogleMapController";
  private final int id;
>>>>>>> 0f80e7380086ceed3c61c05dc431a41d2c32253a
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
<<<<<<< HEAD
  private boolean disposed = false;
=======
  private boolean myLocationEnabled = false;
  private boolean myLocationButtonEnabled = false;
  private boolean disposed = false;
  private final float density;
  private MethodChannel.Result mapReadyResult;
  private final int registrarActivityHashCode;
  private final Context context;
  private final MarkersController markersController;
  private final PolygonsController polygonsController;
  private final PolylinesController polylinesController;
  private final CirclesController circlesController;
  private List<Object> initialMarkers;
  private List<Object> initialPolygons;
  private List<Object> initialPolylines;
  private List<Object> initialCircles;
>>>>>>> 0f80e7380086ceed3c61c05dc431a41d2c32253a

  GoogleMapController(
      AtomicInteger activityState,
      PluginRegistry.Registrar registrar,
      int width,
      int height,
      GoogleMapOptions options,
      MethodChannel.Result result) {
    this.activityState = activityState;
    this.registrar = registrar;
<<<<<<< HEAD
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
=======
    this.mapView = new MapView(context, options);
    this.density = context.getResources().getDisplayMetrics().density;
    methodChannel =
        new MethodChannel(registrar.messenger(), "plugins.flutter.io/google_maps_" + id);
    methodChannel.setMethodCallHandler(this);
    this.registrarActivityHashCode = registrar.activity().hashCode();
    this.markersController = new MarkersController(methodChannel);
    this.polygonsController = new PolygonsController(methodChannel);
    this.polylinesController = new PolylinesController(methodChannel);
    this.circlesController = new CirclesController(methodChannel);
>>>>>>> 0f80e7380086ceed3c61c05dc431a41d2c32253a
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
<<<<<<< HEAD
    // Take snapshots until the dust settles.
    timer.schedule(newSnapshotTask(), 0);
    timer.schedule(newSnapshotTask(), 500);
    timer.schedule(newSnapshotTask(), 1000);
    timer.schedule(newSnapshotTask(), 2000);
    timer.schedule(newSnapshotTask(), 4000);
=======
    googleMap.setOnPolygonClickListener(this);
    googleMap.setOnPolylineClickListener(this);
    googleMap.setOnCircleClickListener(this);
    googleMap.setOnMapClickListener(this);
    googleMap.setOnMapLongClickListener(this);
    updateMyLocationSettings();
    markersController.setGoogleMap(googleMap);
    polygonsController.setGoogleMap(googleMap);
    polylinesController.setGoogleMap(googleMap);
    circlesController.setGoogleMap(googleMap);
    updateInitialMarkers();
    updateInitialPolygons();
    updateInitialPolylines();
    updateInitialCircles();
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
          result.success(Convert.cameraPositionToJson(getCameraPosition()));
          break;
        }
      case "map#getVisibleRegion":
        {
          if (googleMap != null) {
            LatLngBounds latLngBounds = googleMap.getProjection().getVisibleRegion().latLngBounds;
            result.success(Convert.latlngBoundsToJson(latLngBounds));
          } else {
            result.error(
                "GoogleMap uninitialized",
                "getVisibleRegion called prior to map initialization",
                null);
          }
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
      case "markers#update":
        {
          Object markersToAdd = call.argument("markersToAdd");
          markersController.addMarkers((List<Object>) markersToAdd);
          Object markersToChange = call.argument("markersToChange");
          markersController.changeMarkers((List<Object>) markersToChange);
          Object markerIdsToRemove = call.argument("markerIdsToRemove");
          markersController.removeMarkers((List<Object>) markerIdsToRemove);
          result.success(null);
          break;
        }
      case "polygons#update":
        {
          Object polygonsToAdd = call.argument("polygonsToAdd");
          polygonsController.addPolygons((List<Object>) polygonsToAdd);
          Object polygonsToChange = call.argument("polygonsToChange");
          polygonsController.changePolygons((List<Object>) polygonsToChange);
          Object polygonIdsToRemove = call.argument("polygonIdsToRemove");
          polygonsController.removePolygons((List<Object>) polygonIdsToRemove);
          result.success(null);
          break;
        }
      case "polylines#update":
        {
          Object polylinesToAdd = call.argument("polylinesToAdd");
          polylinesController.addPolylines((List<Object>) polylinesToAdd);
          Object polylinesToChange = call.argument("polylinesToChange");
          polylinesController.changePolylines((List<Object>) polylinesToChange);
          Object polylineIdsToRemove = call.argument("polylineIdsToRemove");
          polylinesController.removePolylines((List<Object>) polylineIdsToRemove);
          result.success(null);
          break;
        }
      case "circles#update":
        {
          Object circlesToAdd = call.argument("circlesToAdd");
          circlesController.addCircles((List<Object>) circlesToAdd);
          Object circlesToChange = call.argument("circlesToChange");
          circlesController.changeCircles((List<Object>) circlesToChange);
          Object circleIdsToRemove = call.argument("circleIdsToRemove");
          circlesController.removeCircles((List<Object>) circleIdsToRemove);
          result.success(null);
          break;
        }
      case "map#isCompassEnabled":
        {
          result.success(googleMap.getUiSettings().isCompassEnabled());
          break;
        }
      case "map#getMinMaxZoomLevels":
        {
          List<Float> zoomLevels = new ArrayList<>(2);
          zoomLevels.add(googleMap.getMinZoomLevel());
          zoomLevels.add(googleMap.getMaxZoomLevel());
          result.success(zoomLevels);
          break;
        }
      case "map#isZoomGesturesEnabled":
        {
          result.success(googleMap.getUiSettings().isZoomGesturesEnabled());
          break;
        }
      case "map#isScrollGesturesEnabled":
        {
          result.success(googleMap.getUiSettings().isScrollGesturesEnabled());
          break;
        }
      case "map#isTiltGesturesEnabled":
        {
          result.success(googleMap.getUiSettings().isTiltGesturesEnabled());
          break;
        }
      case "map#isRotateGesturesEnabled":
        {
          result.success(googleMap.getUiSettings().isRotateGesturesEnabled());
          break;
        }
      case "map#isMyLocationButtonEnabled":
        {
          result.success(googleMap.getUiSettings().isMyLocationButtonEnabled());
          break;
        }
      default:
        result.notImplemented();
    }
  }

  @Override
  public void onMapClick(LatLng latLng) {
    final Map<String, Object> arguments = new HashMap<>(2);
    arguments.put("position", Convert.latLngToJson(latLng));
    methodChannel.invokeMethod("map#onTap", arguments);
>>>>>>> 0f80e7380086ceed3c61c05dc431a41d2c32253a
  }

  @Override
  public void onMapLongClick(LatLng latLng) {
    final Map<String, Object> arguments = new HashMap<>(2);
    arguments.put("position", Convert.latLngToJson(latLng));
    methodChannel.invokeMethod("map#onLongPress", arguments);
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
<<<<<<< HEAD
  public void onSnapshotReady(Bitmap bitmap) {
    updateTexture();
  }

  void dispose() {
=======
  public void onPolygonClick(Polygon polygon) {
    polygonsController.onPolygonTap(polygon.getId());
  }

  @Override
  public void onPolylineClick(Polyline polyline) {
    polylinesController.onPolylineTap(polyline.getId());
  }

  @Override
  public void onCircleClick(Circle circle) {
    circlesController.onCircleTap(circle.getId());
  }

  @Override
  public void dispose() {
>>>>>>> 0f80e7380086ceed3c61c05dc431a41d2c32253a
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
<<<<<<< HEAD
=======

  @Override
  public void setMyLocationEnabled(boolean myLocationEnabled) {
    if (this.myLocationEnabled == myLocationEnabled) {
      return;
    }
    this.myLocationEnabled = myLocationEnabled;
    if (googleMap != null) {
      updateMyLocationSettings();
    }
  }

  @Override
  public void setMyLocationButtonEnabled(boolean myLocationButtonEnabled) {
    if (this.myLocationButtonEnabled == myLocationButtonEnabled) {
      return;
    }
    this.myLocationButtonEnabled = myLocationButtonEnabled;
    if (googleMap != null) {
      updateMyLocationSettings();
    }
  }

  @Override
  public void setInitialMarkers(Object initialMarkers) {
    this.initialMarkers = (List<Object>) initialMarkers;
    if (googleMap != null) {
      updateInitialMarkers();
    }
  }

  private void updateInitialMarkers() {
    markersController.addMarkers(initialMarkers);
  }

  @Override
  public void setInitialPolygons(Object initialPolygons) {
    this.initialPolygons = (List<Object>) initialPolygons;
    if (googleMap != null) {
      updateInitialPolygons();
    }
  }

  private void updateInitialPolygons() {
    polygonsController.addPolygons(initialPolygons);
  }

  @Override
  public void setInitialPolylines(Object initialPolylines) {
    this.initialPolylines = (List<Object>) initialPolylines;
    if (googleMap != null) {
      updateInitialPolylines();
    }
  }

  private void updateInitialPolylines() {
    polylinesController.addPolylines(initialPolylines);
  }

  @Override
  public void setInitialCircles(Object initialCircles) {
    this.initialCircles = (List<Object>) initialCircles;
    if (googleMap != null) {
      updateInitialCircles();
    }
  }

  private void updateInitialCircles() {
    circlesController.addCircles(initialCircles);
  }

  @SuppressLint("MissingPermission")
  private void updateMyLocationSettings() {
    if (hasLocationPermission()) {
      // The plugin doesn't add the location permission by default so that apps that don't need
      // the feature won't require the permission.
      // Gradle is doing a static check for missing permission and in some configurations will
      // fail the build if the permission is missing. The following disables the Gradle lint.
      //noinspection ResourceType
      googleMap.setMyLocationEnabled(myLocationEnabled);
      googleMap.getUiSettings().setMyLocationButtonEnabled(myLocationButtonEnabled);
    } else {
      // TODO(amirh): Make the options update fail.
      // https://github.com/flutter/flutter/issues/24327
      Log.e(TAG, "Cannot enable MyLocation layer as location permissions are not granted");
    }
  }

  private boolean hasLocationPermission() {
    return checkSelfPermission(Manifest.permission.ACCESS_FINE_LOCATION)
            == PackageManager.PERMISSION_GRANTED
        || checkSelfPermission(Manifest.permission.ACCESS_COARSE_LOCATION)
            == PackageManager.PERMISSION_GRANTED;
  }

  private int checkSelfPermission(String permission) {
    if (permission == null) {
      throw new IllegalArgumentException("permission is null");
    }
    return context.checkPermission(
        permission, android.os.Process.myPid(), android.os.Process.myUid());
  }
>>>>>>> 0f80e7380086ceed3c61c05dc431a41d2c32253a
}
