// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.googlemaps;

import com.google.android.gms.maps.model.LatLng;
import com.google.android.gms.maps.model.Marker;
import com.google.android.gms.maps.model.MarkerOptions;
import com.google.maps.android.collections.MarkerManager;
import io.flutter.plugin.common.MethodChannel;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

class MarkersController {
  private final HashMap<String, MarkerBuilder> markerIdToMarkerBuilder;
  private final HashMap<String, MarkerController> markerIdToController;
  private final HashMap<String, String> googleMapsMarkerIdToDartMarkerId;
  private final MethodChannel methodChannel;
  private MarkerManager.Collection markerCollection;
  private final ClusterManagersController clusterManagersController;

  MarkersController(
      MethodChannel methodChannel, ClusterManagersController clusterManagersController) {
    this.markerIdToMarkerBuilder = new HashMap<>();
    this.markerIdToController = new HashMap<>();
    this.googleMapsMarkerIdToDartMarkerId = new HashMap<>();
    this.methodChannel = methodChannel;
    this.clusterManagersController = clusterManagersController;
  }

  void setCollection(MarkerManager.Collection markerCollection) {
    this.markerCollection = markerCollection;
  }

  void addMarkers(List<Object> markersToAdd) {
    if (markersToAdd != null) {
      for (Object markerToAdd : markersToAdd) {
        addMarker(markerToAdd);
      }
    }
  }

  void changeMarkers(List<Object> markersToChange) {
    if (markersToChange != null) {
      for (Object markerToChange : markersToChange) {
        changeMarker(markerToChange);
      }
    }
  }

  void removeMarkers(List<Object> markerIdsToRemove) {
    if (markerIdsToRemove == null) {
      return;
    }
    for (Object rawMarkerId : markerIdsToRemove) {
      if (rawMarkerId == null) {
        continue;
      }
      String markerId = (String) rawMarkerId;
      removeMarker(markerId);
    }
  }

  private void removeMarker(String markerId) {
    final MarkerBuilder markerBuilder = markerIdToMarkerBuilder.remove(markerId);
    if (markerBuilder == null) {
      return;
    }
    final MarkerController markerController = markerIdToController.remove(markerId);
    final String clusterManagerId = markerBuilder.clusterManagerId();
    if (clusterManagerId != null) {
      // Remove marker from clusterManager
      clusterManagersController.removeItem(markerBuilder);
    } else if (markerController != null && this.markerCollection != null) {
      // Remove marker from map and markerCollection
      markerController.removeFromCollection(markerCollection);
    }

    if (markerController != null) {
      googleMapsMarkerIdToDartMarkerId.remove(markerController.getGoogleMapsMarkerId());
    }
  }

  void showMarkerInfoWindow(String markerId, MethodChannel.Result result) {
    MarkerController markerController = markerIdToController.get(markerId);
    if (markerController != null) {
      markerController.showInfoWindow();
      result.success(null);
    } else {
      result.error("Invalid markerId", "showInfoWindow called with invalid markerId", null);
    }
  }

  void hideMarkerInfoWindow(String markerId, MethodChannel.Result result) {
    MarkerController markerController = markerIdToController.get(markerId);
    if (markerController != null) {
      markerController.hideInfoWindow();
      result.success(null);
    } else {
      result.error(
          "Invalid markerId",
          "hideInfoWindow called with invalid markerId or for hidden cluster marker",
          null);
    }
  }

  void isInfoWindowShown(String markerId, MethodChannel.Result result) {
    MarkerController markerController = markerIdToController.get(markerId);
    if (markerController != null) {
      result.success(markerController.isInfoWindowShown());
    } else {
      result.error(
          "Invalid markerId",
          "isInfoWindowShown called with invalid markerId or for hidden cluster marker",
          null);
    }
  }

  boolean onMapsMarkerTap(String googleMarkerId) {
    String markerId = googleMapsMarkerIdToDartMarkerId.get(googleMarkerId);
    if (markerId == null) {
      return false;
    }
    return onMarkerTap(markerId);
  }

  boolean onMarkerTap(String markerId) {
    methodChannel.invokeMethod("marker#onTap", Convert.markerIdToJson(markerId));
    MarkerController markerController = markerIdToController.get(markerId);
    if (markerController != null) {
      return markerController.consumeTapEvents();
    }
    return false;
  }

  void onMarkerDragStart(String googleMarkerId, LatLng latLng) {
    String markerId = googleMapsMarkerIdToDartMarkerId.get(googleMarkerId);
    if (markerId == null) {
      return;
    }
    final Map<String, Object> data = new HashMap<>();
    data.put("markerId", markerId);
    data.put("position", Convert.latLngToJson(latLng));
    methodChannel.invokeMethod("marker#onDragStart", data);
  }

  void onMarkerDrag(String googleMarkerId, LatLng latLng) {
    String markerId = googleMapsMarkerIdToDartMarkerId.get(googleMarkerId);
    if (markerId == null) {
      return;
    }
    final Map<String, Object> data = new HashMap<>();
    data.put("markerId", markerId);
    data.put("position", Convert.latLngToJson(latLng));
    methodChannel.invokeMethod("marker#onDrag", data);
  }

  void onMarkerDragEnd(String googleMarkerId, LatLng latLng) {
    String markerId = googleMapsMarkerIdToDartMarkerId.get(googleMarkerId);
    if (markerId == null) {
      return;
    }
    final Map<String, Object> data = new HashMap<>();
    data.put("markerId", markerId);
    data.put("position", Convert.latLngToJson(latLng));
    methodChannel.invokeMethod("marker#onDragEnd", data);
  }

  void onInfoWindowTap(String googleMarkerId) {
    String markerId = googleMapsMarkerIdToDartMarkerId.get(googleMarkerId);
    if (markerId == null) {
      return;
    }
    methodChannel.invokeMethod("infoWindow#onTap", Convert.markerIdToJson(markerId));
  }

  // Called each time clusterManager adds new visible marker to the map.
  // Creates markerController for marker for realtime marker updates.
  public void onClusterItemMarker(MarkerBuilder markerBuilder, Marker marker) {
    String markerId = markerBuilder.markerId();
    if (markerIdToMarkerBuilder.get(markerId) == markerBuilder) {
      createControllerForMarker(markerBuilder.markerId(), marker, markerBuilder.consumeTapEvents());
    }
  }

  private void addMarker(Object marker) {
    if (marker == null) {
      return;
    }
    String markerId = getMarkerId(marker);
    if (markerId == null) {
      throw new IllegalArgumentException("markerId was null");
    }
    String clusterManagerId = getClusterManagerId(marker);
    MarkerBuilder markerBuilder = new MarkerBuilder(markerId, clusterManagerId);
    Convert.interpretMarkerOptions(marker, markerBuilder);
    addMarker(markerBuilder);
  }

  private void addMarker(MarkerBuilder markerBuilder) {
    if (markerBuilder == null) {
      return;
    }
    String markerId = markerBuilder.markerId();

    // Store marker builder for future marker rebuilds when used under clusters.
    markerIdToMarkerBuilder.put(markerId, markerBuilder);

    if (markerBuilder.clusterManagerId() == null) {
      addMarkerToCollection(markerId, markerBuilder);
    } else {
      addMarkerBuilderForCluster(markerBuilder);
    }
  }

  private void addMarkerToCollection(String markerId, MarkerBuilder markerBuilder) {
    MarkerOptions options = markerBuilder.build();
    final Marker marker = markerCollection.addMarker(options);
    createControllerForMarker(markerId, marker, markerBuilder.consumeTapEvents());
  }

  private void addMarkerBuilderForCluster(MarkerBuilder markerBuilder) {
    clusterManagersController.addItem(markerBuilder);
  }

  private void createControllerForMarker(String markerId, Marker marker, boolean consumeTapEvents) {
    MarkerController controller = new MarkerController(marker, consumeTapEvents);
    markerIdToController.put(markerId, controller);
    googleMapsMarkerIdToDartMarkerId.put(marker.getId(), markerId);
  }

  private void changeMarker(Object marker) {
    if (marker == null) {
      return;
    }
    String markerId = getMarkerId(marker);

    MarkerBuilder markerBuilder = markerIdToMarkerBuilder.get(markerId);
    if (markerBuilder == null) {
      return;
    }

    String clusterManagerId = getClusterManagerId(marker);
    String oldClusterManagerId = markerBuilder.clusterManagerId();

    // Cluster id on updated marker has changed.
    // Marker need to be removed and added again.
    if (!((clusterManagerId == oldClusterManagerId)
        || (clusterManagerId != null && clusterManagerId.equals(oldClusterManagerId)))) {
      removeMarker(markerId);
      addMarker(marker);
      return;
    }

    // Update marker builder
    Convert.interpretMarkerOptions(marker, markerBuilder);

    // Update existing marker on map
    MarkerController markerController = markerIdToController.get(markerId);
    if (markerController != null) {
      Convert.interpretMarkerOptions(marker, markerController);
    }
  }

  @SuppressWarnings("unchecked")
  private static String getMarkerId(Object marker) {
    Map<String, Object> markerMap = (Map<String, Object>) marker;
    return (String) markerMap.get("markerId");
  }

  @SuppressWarnings("unchecked")
  private static String getClusterManagerId(Object marker) {
    Map<String, Object> markerMap = (Map<String, Object>) marker;
    return (String) markerMap.get("clusterManagerId");
  }
}
