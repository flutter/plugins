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
import android.graphics.Point;
import android.os.Bundle;
import android.view.Surface;
import android.widget.FrameLayout;
import com.google.android.gms.maps.CameraUpdate;
import com.google.android.gms.maps.CameraUpdateFactory;
import com.google.android.gms.maps.GoogleMap;
import com.google.android.gms.maps.MapView;
import com.google.android.gms.maps.OnMapReadyCallback;
import com.google.android.gms.maps.model.BitmapDescriptor;
import com.google.android.gms.maps.model.BitmapDescriptorFactory;
import com.google.android.gms.maps.model.CameraPosition;
import com.google.android.gms.maps.model.LatLng;
import com.google.android.gms.maps.model.LatLngBounds;
import com.google.android.gms.maps.model.Marker;
import com.google.android.gms.maps.model.MarkerOptions;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;
import io.flutter.view.FlutterMain;
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
          final GoogleMapsEntry entry =
              new GoogleMapsEntry(state, registrar, width, height, result);
          googleMaps.put(entry.id(), entry);
          entry.init();
          // result.success is called from entry when the GoogleMaps instance is ready
          break;
        }
      case "moveCamera":
        {
          final GoogleMapsEntry entry = mapsEntry(call);
          final CameraUpdate cameraUpdate = toCameraUpdate(call.argument("cameraUpdate"));
          entry.moveCamera(cameraUpdate);
          result.success(null);
          break;
        }
      case "animateCamera":
        {
          final GoogleMapsEntry entry = mapsEntry(call);
          final CameraUpdate cameraUpdate = toCameraUpdate(call.argument("cameraUpdate"));
          entry.animateCamera(cameraUpdate);
          result.success(null);
          break;
        }
      case "addMarker":
        {
          final GoogleMapsEntry entry = mapsEntry(call);
          final MarkerOptions markerOptions = toMarkerOptions(call.argument("markerOptions"));
          final String markerId = entry.addMarker(markerOptions);
          result.success(markerId);
          break;
        }
      case "marker#remove":
        {
          final GoogleMapsEntry entry = mapsEntry(call);
          final String markerId = call.argument("marker");
          entry.removeMarker(markerId);
          result.success(null);
          break;
        }
      case "marker#hideInfoWindow":
        {
          final GoogleMapsEntry entry = mapsEntry(call);
          final String markerId = call.argument("marker");
          entry.hideMarkerInfoWindow(markerId);
          result.success(null);
          break;
        }
      case "marker#showInfoWindow":
        {
          final GoogleMapsEntry entry = mapsEntry(call);
          final String markerId = call.argument("marker");
          entry.showMarkerInfoWindow(markerId);
          result.success(null);
          break;
        }
      case "marker#update":
        {
          final GoogleMapsEntry entry = mapsEntry(call);
          final String markerId = call.argument("marker");
          final MarkerOptions markerOptions = toMarkerOptions(call.argument("markerOptions"));
          entry.updateMarker(markerId, markerOptions);
          result.success(null);
          break;
        }
      case "showMapOverlay":
        {
          final GoogleMapsEntry entry = mapsEntry(call);
          final int x = ((Number) call.argument("x")).intValue();
          final int y = ((Number) call.argument("y")).intValue();
          entry.showOverlay(x, y);
          result.success(null);
          break;
        }
      case "hideMapOverlay":
        {
          final GoogleMapsEntry entry = mapsEntry(call);
          entry.hideOverlay();
          result.success(null);
          break;
        }
      case "disposeMap":
        {
          final GoogleMapsEntry entry = mapsEntry(call);
          entry.dispose();
          result.success(null);
          break;
        }
      default:
        result.notImplemented();
    }
  }

  private GoogleMapsEntry mapsEntry(MethodCall call) {
    final long id = toLong(call.argument("map"));
    final GoogleMapsEntry entry = googleMaps.get(id);
    if (entry == null) {
      throw new IllegalArgumentException("Unknown map: " + id);
    }
    return entry;
  }

  private static BitmapDescriptor toBitmapDescriptor(Object o) {
    final List<?> data = toList(o);
    switch (toString(data.get(0))) {
      case "defaultMarker":
        if (data.size() == 1) {
          return BitmapDescriptorFactory.defaultMarker();
        } else {
          return BitmapDescriptorFactory.defaultMarker(toFloat(data.get(1)));
        }
      case "fromAsset":
        if (data.size() == 2) {
          return BitmapDescriptorFactory.fromAsset(
              FlutterMain.getLookupKeyForAsset(toString(data.get(1))));
        } else {
          return BitmapDescriptorFactory.fromAsset(
              FlutterMain.getLookupKeyForAsset(toString(data.get(1)), toString(data.get(2))));
        }
      case "fromFile":
        return BitmapDescriptorFactory.fromFile(toString(data.get(1)));
      case "fromPath":
        return BitmapDescriptorFactory.fromPath(toString(data.get(1)));
    }
    throw new IllegalArgumentException("Cannot interpret " + o + " as BitmapDescriptor");
  }

  private static boolean toBoolean(Object o) {
    return (Boolean) o;
  }

  private static CameraPosition toCameraPosition(Object o) {
    final Map<?, ?> data = toMap(o);
    final CameraPosition.Builder builder = CameraPosition.builder();
    builder.bearing(toFloat(data.get("bearing")));
    builder.target(toLatLng(data.get("target")));
    builder.tilt(toFloat(data.get("tilt")));
    builder.zoom(toFloat(data.get("zoom")));
    return builder.build();
  }

  private static CameraUpdate toCameraUpdate(Object o) {
    final List<?> data = toList(o);
    switch (toString(data.get(0))) {
      case "newCameraPosition":
        return CameraUpdateFactory.newCameraPosition(toCameraPosition(data.get(1)));
      case "newLatLng":
        return CameraUpdateFactory.newLatLng(toLatLng(data.get(1)));
      case "newLatLngBounds":
        return CameraUpdateFactory.newLatLngBounds(toLatLngBounds(data.get(1)), toInt(data.get(2)));
      case "newLatLngZoom":
        return CameraUpdateFactory.newLatLngZoom(toLatLng(data.get(1)), toFloat(data.get(2)));
      case "scrollBy":
        return CameraUpdateFactory.scrollBy(toFloat(data.get(1)), toFloat(data.get(2)));
      case "zoomBy":
        if (data.size() == 2) {
          return CameraUpdateFactory.zoomBy(toFloat(data.get(1)));
        } else {
          return CameraUpdateFactory.zoomBy(toFloat(data.get(1)), toPoint(data.get(2)));
        }
      case "zoomIn":
        return CameraUpdateFactory.zoomIn();
      case "zoomOut":
        return CameraUpdateFactory.zoomOut();
      case "zoomTo":
        return CameraUpdateFactory.zoomTo(toFloat(data.get(1)));
    }
    throw new IllegalArgumentException("Cannot interpret " + o + " as CameraUpdate");
  }

  private static double toDouble(Object o) {
    return ((Number) o).doubleValue();
  }

  private static float toFloat(Object o) {
    return ((Number) o).floatValue();
  }

  private static int toInt(Object o) {
    return ((Number) o).intValue();
  }

  private static LatLng toLatLng(Object o) {
    final List<?> data = toList(o);
    return new LatLng(toDouble(data.get(0)), toDouble(data.get(1)));
  }

  private static LatLngBounds toLatLngBounds(Object o) {
    final List<?> data = toList(o);
    return new LatLngBounds(toLatLng(data.get(0)), toLatLng(data.get(1)));
  }

  private static List<?> toList(Object o) {
    return (List<?>) o;
  }

  private static long toLong(Object o) {
    return ((Number) o).longValue();
  }

  private static Map<?, ?> toMap(Object o) {
    return (Map<?, ?>) o;
  }

  private static MarkerOptions toMarkerOptions(Object o) {
    final Map<?, ?> data = toMap(o);
    final List<?> anchor = toList(data.get("anchor"));
    final List<?> infoWindowAnchor = toList(data.get("infoWindowAnchor"));
    return new MarkerOptions()
        .position(toLatLng(data.get("position")))
        .alpha(toFloat(data.get("alpha")))
        .anchor(toFloat(anchor.get(0)), toFloat(anchor.get(1)))
        .draggable(toBoolean(data.get("draggable")))
        .flat(toBoolean(data.get("flat")))
        .icon(toBitmapDescriptor(data.get("icon")))
        .infoWindowAnchor(toFloat(infoWindowAnchor.get(0)), toFloat(infoWindowAnchor.get(1)))
        .rotation(toFloat(data.get("rotation")))
        .snippet(toString(data.get("snippet")))
        .title(toString(data.get("title")))
        .visible(toBoolean(data.get("visible")))
        .zIndex(toFloat(data.get("zIndex")));
  }

  private static Point toPoint(Object o) {
    final List<?> data = toList(o);
    return new Point(toInt(data.get(0)), toInt(data.get(1)));
  }

  private static String toString(Object o) {
    return (String) o;
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
  private final Result result;
  private final Timer timer;
  private final Map<String, Marker> markers;
  private GoogleMap googleMap;
  private Surface surface;
  private boolean disposed = false;

  GoogleMapsEntry(
      AtomicInteger activityState, Registrar registrar, int width, int height, Result result) {
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
    this.mapView = new MapView(registrar.activity());
    this.timer = new Timer();
    this.markers = new HashMap<>();
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
      googleMap.snapshot(GoogleMapsEntry.this, bitmap);
    }
  }
}
