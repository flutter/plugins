// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.googlemaps;

import android.app.Activity;
import android.app.Application;
import android.os.Bundle;
import com.google.android.gms.maps.CameraUpdate;
import com.google.android.gms.maps.model.CameraPosition;
import com.google.android.gms.maps.model.Marker;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;
import java.util.Collections;
import java.util.HashMap;
import java.util.Map;
import java.util.concurrent.atomic.AtomicInteger;

/**
 * Plugin for controlling a set of GoogleMap views to be shown as overlays on top of the Flutter
 * view. The overlay should be hidden during transformations or while Flutter is rendering on top of
 * the map. A Texture drawn using GoogleMap bitmap snapshots can then be shown instead of the
 * overlay.
 */
public class GoogleMapsPlugin implements MethodCallHandler, Application.ActivityLifecycleCallbacks {
  static final int CREATED = 1;
  static final int STARTED = 2;
  static final int RESUMED = 3;
  static final int PAUSED = 4;
  static final int STOPPED = 5;
  static final int DESTROYED = 6;
  private final Map<Long, GoogleMapController> googleMaps = new HashMap<>();
  private final Registrar registrar;
  private final MethodChannel channel;
  private final float density;
  private final AtomicInteger state = new AtomicInteger(0);

  public static void registerWith(Registrar registrar) {
    final MethodChannel channel =
        new MethodChannel(registrar.messenger(), "plugins.flutter.io/google_maps");
    final GoogleMapsPlugin plugin = new GoogleMapsPlugin(registrar, channel);
    channel.setMethodCallHandler(plugin);
    registrar.activity().getApplication().registerActivityLifecycleCallbacks(plugin);
  }

  private GoogleMapsPlugin(Registrar registrar, MethodChannel channel) {
    this.registrar = registrar;
    this.channel = channel;
    this.density = registrar.context().getResources().getDisplayMetrics().density;
  }

  @Override
  public void onMethodCall(MethodCall call, Result result) {
    switch (call.method) {
      case "init":
        {
          for (GoogleMapController controller : googleMaps.values()) {
            controller.dispose();
          }
          googleMaps.clear();
          result.success(null);
          break;
        }
      case "map#create":
        {
          final int width = Convert.toPixels(call.argument("width"), density);
          final int height = Convert.toPixels(call.argument("height"), density);
          final Map<?, ?> options = Convert.toMap(call.argument("options"));
          final GoogleMapBuilder builder = new GoogleMapBuilder();
          Convert.interpretGoogleMapOptions(options, builder);
          final GoogleMapController controller =
              builder.build(state, registrar, width, height, result);
          googleMaps.put(controller.id(), controller);
          controller.setOnCameraMoveListener(
              new OnCameraMoveListener() {
                @Override
                public void onCameraMoveStarted(boolean isGesture) {
                  final Map<String, Object> arguments = new HashMap<>(2);
                  arguments.put("map", controller.id());
                  arguments.put("isGesture", isGesture);
                  channel.invokeMethod("camera#onMoveStarted", arguments);
                }

                @Override
                public void onCameraMove(CameraPosition position) {
                  final Map<String, Object> arguments = new HashMap<>(2);
                  arguments.put("map", controller.id());
                  arguments.put("position", Convert.toJson(position));
                  channel.invokeMethod("camera#onMove", arguments);
                }

                @Override
                public void onCameraIdle() {
                  channel.invokeMethod(
                      "camera#onIdle", Collections.singletonMap("map", controller.id()));
                }
              });
          controller.setOnMarkerTappedListener(
              new OnMarkerTappedListener() {
                @Override
                public void onMarkerTapped(Marker marker) {
                  final Map<String, Object> arguments = new HashMap<>(2);
                  arguments.put("map", controller.id());
                  arguments.put("marker", marker.getId());
                  channel.invokeMethod("marker#onTap", arguments);
                }
              });
          // result.success is called from controller when the GoogleMaps instance
          // is ready
          break;
        }
      case "map#update":
        {
          final GoogleMapController controller = mapsController(call);
          Convert.interpretGoogleMapOptions(call.argument("options"), controller);
          result.success(Convert.toJson(controller.getCameraPosition()));
          break;
        }
      case "camera#move":
        {
          final GoogleMapController controller = mapsController(call);
          final CameraUpdate cameraUpdate =
              Convert.toCameraUpdate(call.argument("cameraUpdate"), density);
          controller.moveCamera(cameraUpdate);
          result.success(null);
          break;
        }
      case "camera#animate":
        {
          final GoogleMapController controller = mapsController(call);
          final CameraUpdate cameraUpdate =
              Convert.toCameraUpdate(call.argument("cameraUpdate"), density);
          controller.animateCamera(cameraUpdate);
          result.success(null);
          break;
        }
      case "marker#add":
        {
          final GoogleMapController controller = mapsController(call);
          final MarkerBuilder markerBuilder = controller.newMarkerBuilder();
          Convert.interpretMarkerOptions(call.argument("options"), markerBuilder);
          final String markerId = markerBuilder.build();
          result.success(markerId);
          break;
        }
      case "marker#remove":
        {
          final GoogleMapController controller = mapsController(call);
          final String markerId = call.argument("marker");
          controller.removeMarker(markerId);
          result.success(null);
          break;
        }
      case "marker#update":
        {
          final GoogleMapController controller = mapsController(call);
          final String markerId = call.argument("marker");
          final MarkerController marker = controller.marker(markerId);
          Convert.interpretMarkerOptions(call.argument("options"), marker);
          result.success(null);
          break;
        }
      case "map#show":
        {
          final GoogleMapController controller = mapsController(call);
          final int x = Convert.toPixels(call.argument("x"), density);
          final int y = Convert.toPixels(call.argument("y"), density);
          controller.showOverlay(x, y);
          result.success(null);
          break;
        }
      case "map#hide":
        {
          final GoogleMapController controller = mapsController(call);
          controller.hideOverlay();
          result.success(null);
          break;
        }
      case "map#dispose":
        {
          final GoogleMapController controller = mapsController(call);
          controller.dispose();
          result.success(null);
          break;
        }
      default:
        result.notImplemented();
    }
  }

  private GoogleMapController mapsController(MethodCall call) {
    final long id = Convert.toLong(call.argument("map"));
    final GoogleMapController controller = googleMaps.get(id);
    if (controller == null) {
      throw new IllegalArgumentException("Unknown map: " + id);
    }
    return controller;
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
