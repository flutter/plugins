// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.googlemaps;

import android.os.Build;
import com.google.android.gms.maps.GoogleMap;
import com.google.android.gms.maps.model.LatLng;
import com.google.android.gms.maps.model.Marker;
import com.google.android.gms.maps.model.MarkerOptions;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugins.googlemaps.BuildConfig;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

class RoutesController {

  private final Map<String, RouteController> routeIdToController;
  private final Map<String, String> googleMapsRouteIdToDartRouteId;
  private final MethodChannel methodChannel;
  private GoogleMap googleMap;

  RoutesController(MethodChannel methodChannel) {
    this.routeIdToController = new HashMap<>();
    this.googleMapsRouteIdToDartRouteId = new HashMap<>();
    this.methodChannel = methodChannel;
  }

  void setGoogleMap(GoogleMap googleMap) {
    this.googleMap = googleMap;
  }

  private static double toDouble(Object o) {
    return ((Number) o).doubleValue();
  }

  private static List<?> toList(Object o) {
    return (List<?>) o;
  }

  private static LatLng toLatLng(Object o) {
    final List<?> data = toList(o);
    return new LatLng(toDouble(data.get(0)), toDouble(data.get(1)));
  }

  private static Map<?, ?> toMap(Object o) {
    return (Map<?, ?>) o;
  }

  void routeAnimation(RouteController routeController, float durationInMs, boolean rotateThenTranslate) {
      if (routeController == null) {
        return;
      }
      List<LatLng> route = routeController.getRoute();
      MarkerController markerController = routeController.getMarkerController();
      Marker marker = markerController.getMarker();
      LatLngInterpolator interpolator = new LatLngInterpolator.Linear();
      if (BuildConfig.VERSION_CODE == Build.VERSION_CODES.HONEYCOMB) {
        RouteAnimation.animateMarkerToHC(marker, route, interpolator, durationInMs, rotateThenTranslate);
      }
      else if (BuildConfig.VERSION_CODE == Build.VERSION_CODES.ICE_CREAM_SANDWICH) {
        RouteAnimation.animateMarkerToICS(marker, route, interpolator, durationInMs, rotateThenTranslate);
      }
      else {
        RouteAnimation.animateMarkerToGB(marker, route, interpolator, durationInMs, rotateThenTranslate);
      }
  }

  void addRoutes(List<Object> routesToAdd, float durationInMs, boolean rotateThenTranslate) {
    if (routesToAdd == null) {
      return;
    }
    for (Object routeToAdd : routesToAdd) {
      if (routeToAdd == null) continue;
      RouteController routeController = null;
      final Map<?, ?> data = toMap(routeToAdd);
      final List<?> markersToAdd = toList(data.get("markers"));
      for (Object markerToAdd : markersToAdd) {
          if (markerToAdd != null) {
              if (routeController == null) {
                  routeController = addMarker(markerToAdd);
              }
              else {
                  final Map<?, ?> markerData = toMap(markerToAdd);
                  final Object position = markerData.get("position");
                  if (position != null) {
                      routeController.addPosition(toLatLng(position));
                  }
              }
          }
      }
      routeAnimation(routeController, durationInMs, rotateThenTranslate);
    }
  }

  private RouteController addMarker(Object marker) {
    MarkerBuilder markerBuilder = new MarkerBuilder();
    String markerId = Convert.interpretMarkerOptions(marker, markerBuilder);
    MarkerOptions options = markerBuilder.build();
    return addMarker(markerId, options, markerBuilder.consumeTapEvents());
  }

  private RouteController addMarker(String markerId, MarkerOptions markerOptions, boolean consumeTapEvents) {
    final Marker marker = googleMap.addMarker(markerOptions);
    MarkerController markerController = new MarkerController(marker, consumeTapEvents);
    RouteController routeController = new RouteController(markerController);
    routeIdToController.put(markerId, routeController);
    googleMapsRouteIdToDartRouteId.put(marker.getId(), markerId);
    return routeController;
  }

  void changeRoutes(List<Object> routesToChange, float durationInMs, boolean rotateThenTranslate) {
    if (routesToChange == null) {
      return;
    }
    for (Object routeToChange : routesToChange) {
      if (routeToChange == null) continue;
      final String routeId = getRouteId(routeToChange);
      RouteController routeController = routeIdToController.get(routeId);
      final Map<?, ?> data = toMap(routeToChange);
      final Object rawMarkers = data.get("markers");
      if (rawMarkers == null) continue;
      List<?> markersToChange = toList(rawMarkers);
      if (durationInMs < 0) {
          final Object markerToChange = markersToChange.get(markersToChange.size()-1);
          changeMarker(markerToChange);
      }
      else {
          routeController.clearPosition();
          for (Object markerToChange : markersToChange) {
              if (markerToChange != null) {
                  final Map<?, ?> markerData = toMap(markerToChange);
                  final Object position = markerData.get("position");
                  if (position != null) {
                      routeController.addPosition(toLatLng(position));
                  }
              }
          }
          routeAnimation(routeController, durationInMs, rotateThenTranslate);
      }
    }
  }

  private void changeMarker(Object marker) {
    if (marker == null) {
      return;
    }
    String routeId = getRouteId(marker);
    RouteController routeController = routeIdToController.get(routeId);
    if (routeController != null) {
        MarkerController markerController = routeController.getMarkerController();
        if (markerController != null) {
            Convert.interpretMarkerOptions(marker, markerController);
        }
    }
    else {
        routeController = addMarker(marker);
    }
  }

  void removeRoutes(List<Object> routeIdsToRemove) {
    if (routeIdsToRemove == null) {
      return;
    }
    for (Object rawRouteId : routeIdsToRemove) {
      if (rawRouteId == null) {
        continue;
      }
      String routeId = (String) rawRouteId;
      final RouteController routeController = routeIdToController.remove(routeId);
      if (routeController != null) {
        routeController.remove();
        googleMapsRouteIdToDartRouteId.remove(routeController.getMarkerController().getGoogleMapsMarkerId());
      }
    }
  }

  boolean onRouteTap(String googleMarkerId) {
    String routeId = googleMapsRouteIdToDartRouteId.get(googleMarkerId);
    if (routeId == null) {
      return false;
    }
    methodChannel.invokeMethod("marker#onTap", Convert.markerIdToJson(routeId));
    RouteController routeController = routeIdToController.get(routeId);
    MarkerController markerController = routeController.getMarkerController();
    if (markerController != null) {
      return markerController.consumeTapEvents();
    }
    return false;
  }

  void onInfoWindowTap(String googleMarkerId) {
    String routeId = googleMapsRouteIdToDartRouteId.get(googleMarkerId);
    if (routeId == null) {
      return;
    }
    methodChannel.invokeMethod("infoWindow#onTap", Convert.markerIdToJson(routeId));
  }

  @SuppressWarnings("unchecked")
  private static String getRouteId(Object route) {
    Map<String, Object> routeMap = (Map<String, Object>) route;
    return (String) routeMap.get("routeId");
  }
}
