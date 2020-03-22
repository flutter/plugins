// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.googlemaps;

import com.google.android.gms.maps.GoogleMap;
import com.google.android.gms.maps.model.Polyline;
import com.google.android.gms.maps.model.PolylineOptions;
import io.flutter.plugin.common.MethodChannel;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

class PolylinesController {

  private final Map<String, PolylineController> polylineIdToController;
  private final Map<String, String> googleMapsPolylineIdToDartPolylineId;
  private final MethodChannel methodChannel;
  private GoogleMap googleMap;
  private final float density;

  PolylinesController(MethodChannel methodChannel, float density) {
    this.polylineIdToController = new HashMap<>();
    this.googleMapsPolylineIdToDartPolylineId = new HashMap<>();
    this.methodChannel = methodChannel;
    this.density = density;
  }

  void setGoogleMap(GoogleMap googleMap) {
    this.googleMap = googleMap;
  }

  void addPolylines(List<Object> polylinesToAdd) {
    if (polylinesToAdd != null) {
      for (Object polylineToAdd : polylinesToAdd) {
        addPolyline(polylineToAdd);
      }
    }
  }

  void changePolylines(List<Object> polylinesToChange) {
    if (polylinesToChange != null) {
      for (Object polylineToChange : polylinesToChange) {
        changePolyline(polylineToChange);
      }
    }
  }

  void removePolylines(List<Object> polylineIdsToRemove) {
    if (polylineIdsToRemove == null) {
      return;
    }
    for (Object rawPolylineId : polylineIdsToRemove) {
      if (rawPolylineId == null) {
        continue;
      }
      String polylineId = (String) rawPolylineId;
      final PolylineController polylineController = polylineIdToController.remove(polylineId);
      if (polylineController != null) {
        polylineController.remove();
        googleMapsPolylineIdToDartPolylineId.remove(polylineController.getGoogleMapsPolylineId());
      }
    }
  }

  boolean onPolylineTap(String googlePolylineId) {
    String polylineId = googleMapsPolylineIdToDartPolylineId.get(googlePolylineId);
    if (polylineId == null) {
      return false;
    }
    methodChannel.invokeMethod("polyline#onTap", Convert.polylineIdToJson(polylineId));
    PolylineController polylineController = polylineIdToController.get(polylineId);
    if (polylineController != null) {
      return polylineController.consumeTapEvents();
    }
    return false;
  }

  private void addPolyline(Object polyline) {
    if (polyline == null) {
      return;
    }
    PolylineBuilder polylineBuilder = new PolylineBuilder(density);
    String polylineId = Convert.interpretPolylineOptions(polyline, polylineBuilder);
    PolylineOptions options = polylineBuilder.build();
    addPolyline(polylineId, options, polylineBuilder.consumeTapEvents());
  }

  private void addPolyline(
      String polylineId, PolylineOptions polylineOptions, boolean consumeTapEvents) {
    final Polyline polyline = googleMap.addPolyline(polylineOptions);
    PolylineController controller = new PolylineController(polyline, consumeTapEvents, density);
    polylineIdToController.put(polylineId, controller);
    googleMapsPolylineIdToDartPolylineId.put(polyline.getId(), polylineId);
  }

  private void changePolyline(Object polyline) {
    if (polyline == null) {
      return;
    }
    String polylineId = getPolylineId(polyline);
    PolylineController polylineController = polylineIdToController.get(polylineId);
    if (polylineController != null) {
      Convert.interpretPolylineOptions(polyline, polylineController);
    }
  }

  @SuppressWarnings("unchecked")
  private static String getPolylineId(Object polyline) {
    Map<String, Object> polylineMap = (Map<String, Object>) polyline;
    return (String) polylineMap.get("polylineId");
  }
}
