// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.googlemobilemaps;

import android.app.Activity;
import android.app.Application;
import android.os.Bundle;
import com.google.android.gms.maps.CameraUpdate;
import com.google.android.gms.maps.model.MarkerOptions;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;
import java.util.HashMap;
import java.util.Map;
import java.util.concurrent.atomic.AtomicInteger;

public class GoogleMobileMapsPlugin
    implements MethodCallHandler, Application.ActivityLifecycleCallbacks {
  static final int CREATED = 1;
  static final int STARTED = 2;
  static final int RESUMED = 3;
  static final int PAUSED = 4;
  static final int STOPPED = 5;
  static final int DESTROYED = 6;
  private final Map<Long, GoogleMapController> googleMaps = new HashMap<>();
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
          for (GoogleMapController controller : googleMaps.values()) {
            controller.dispose();
          }
          googleMaps.clear();
          result.success(null);
          break;
        }
      case "createMap":
        {
          final int width = Convert.toInt(call.argument("width"));
          final int height = Convert.toInt(call.argument("height"));
          final Map<?, ?> options = Convert.toMap(call.argument("options"));
          final GoogleMapController controller =
              new GoogleMapController(state, registrar, width, height, options, result);
          googleMaps.put(controller.id(), controller);
          controller.init();
          // result.success is called from controller when the GoogleMaps instance is ready
          break;
        }
      case "getMapOptions":
        {
          final GoogleMapController controller = mapsController(call);
          result.success(controller.getMapOptions());
          break;
        }
      case "setMapOptions":
        {
          final GoogleMapController controller = mapsController(call);
          controller.setMapOptions(call.argument("options"));
          result.success(null);
          break;
        }
      case "moveCamera":
        {
          final GoogleMapController controller = mapsController(call);
          final CameraUpdate cameraUpdate = Convert.toCameraUpdate(call.argument("cameraUpdate"));
          controller.moveCamera(cameraUpdate);
          result.success(null);
          break;
        }
      case "animateCamera":
        {
          final GoogleMapController controller = mapsController(call);
          final CameraUpdate cameraUpdate = Convert.toCameraUpdate(call.argument("cameraUpdate"));
          controller.animateCamera(cameraUpdate);
          result.success(null);
          break;
        }
      case "addMarker":
        {
          final GoogleMapController controller = mapsController(call);
          final MarkerOptions markerOptions =
              Convert.toMarkerOptions(call.argument("markerOptions"));
          final String markerId = controller.addMarker(markerOptions);
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
      case "marker#hideInfoWindow":
        {
          final GoogleMapController controller = mapsController(call);
          final String markerId = call.argument("marker");
          controller.hideMarkerInfoWindow(markerId);
          result.success(null);
          break;
        }
      case "marker#showInfoWindow":
        {
          final GoogleMapController controller = mapsController(call);
          final String markerId = call.argument("marker");
          controller.showMarkerInfoWindow(markerId);
          result.success(null);
          break;
        }
      case "marker#update":
        {
          final GoogleMapController controller = mapsController(call);
          final String markerId = call.argument("marker");
          final MarkerOptions markerOptions =
              Convert.toMarkerOptions(call.argument("markerOptions"));
          controller.updateMarker(markerId, markerOptions);
          result.success(null);
          break;
        }
      case "showMapOverlay":
        {
          final GoogleMapController controller = mapsController(call);
          final int x = Convert.toInt(call.argument("x"));
          final int y = Convert.toInt(call.argument("y"));
          controller.showOverlay(x, y);
          result.success(null);
          break;
        }
      case "hideMapOverlay":
        {
          final GoogleMapController controller = mapsController(call);
          controller.hideOverlay();
          result.success(null);
          break;
        }
      case "disposeMap":
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
