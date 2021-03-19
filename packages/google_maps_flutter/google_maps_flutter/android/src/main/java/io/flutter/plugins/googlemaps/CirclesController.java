// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.googlemaps;

import com.google.android.gms.maps.GoogleMap;
import com.google.android.gms.maps.model.Circle;
import com.google.android.gms.maps.model.CircleOptions;
import io.flutter.plugin.common.MethodChannel;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

class CirclesController {

  private final Map<String, CircleController> circleIdToController;
  private final Map<String, String> googleMapsCircleIdToDartCircleId;
  private final MethodChannel methodChannel;
  private final float density;
  private GoogleMap googleMap;

  CirclesController(MethodChannel methodChannel, float density) {
    this.circleIdToController = new HashMap<>();
    this.googleMapsCircleIdToDartCircleId = new HashMap<>();
    this.methodChannel = methodChannel;
    this.density = density;
  }

  void setGoogleMap(GoogleMap googleMap) {
    this.googleMap = googleMap;
  }

  void addCircles(List<Object> circlesToAdd) {
    if (circlesToAdd != null) {
      for (Object circleToAdd : circlesToAdd) {
        addCircle(circleToAdd);
      }
    }
  }

  void changeCircles(List<Object> circlesToChange) {
    if (circlesToChange != null) {
      for (Object circleToChange : circlesToChange) {
        changeCircle(circleToChange);
      }
    }
  }

  void removeCircles(List<Object> circleIdsToRemove) {
    if (circleIdsToRemove == null) {
      return;
    }
    for (Object rawCircleId : circleIdsToRemove) {
      if (rawCircleId == null) {
        continue;
      }
      String circleId = (String) rawCircleId;
      final CircleController circleController = circleIdToController.remove(circleId);
      if (circleController != null) {
        circleController.remove();
        googleMapsCircleIdToDartCircleId.remove(circleController.getGoogleMapsCircleId());
      }
    }
  }

  boolean onCircleTap(String googleCircleId) {
    String circleId = googleMapsCircleIdToDartCircleId.get(googleCircleId);
    if (circleId == null) {
      return false;
    }
    methodChannel.invokeMethod("circle#onTap", Convert.circleIdToJson(circleId));
    CircleController circleController = circleIdToController.get(circleId);
    if (circleController != null) {
      return circleController.consumeTapEvents();
    }
    return false;
  }

  private void addCircle(Object circle) {
    if (circle == null) {
      return;
    }
    CircleBuilder circleBuilder = new CircleBuilder(density);
    String circleId = Convert.interpretCircleOptions(circle, circleBuilder);
    CircleOptions options = circleBuilder.build();
    addCircle(circleId, options, circleBuilder.consumeTapEvents());
  }

  private void addCircle(String circleId, CircleOptions circleOptions, boolean consumeTapEvents) {
    final Circle circle = googleMap.addCircle(circleOptions);
    CircleController controller = new CircleController(circle, consumeTapEvents, density);
    circleIdToController.put(circleId, controller);
    googleMapsCircleIdToDartCircleId.put(circle.getId(), circleId);
  }

  private void changeCircle(Object circle) {
    if (circle == null) {
      return;
    }
    String circleId = getCircleId(circle);
    CircleController circleController = circleIdToController.get(circleId);
    if (circleController != null) {
      Convert.interpretCircleOptions(circle, circleController);
    }
  }

  @SuppressWarnings("unchecked")
  private static String getCircleId(Object circle) {
    Map<String, Object> circleMap = (Map<String, Object>) circle;
    return (String) circleMap.get("circleId");
  }
}
