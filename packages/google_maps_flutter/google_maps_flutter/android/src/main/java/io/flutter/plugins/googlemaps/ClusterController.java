// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.googlemaps;

import android.util.Log;
import com.google.android.gms.maps.GoogleMap;
import com.google.android.gms.maps.model.LatLng;
import com.google.android.gms.maps.model.MarkerOptions;
import com.google.maps.android.clustering.Cluster;
import com.google.maps.android.clustering.ClusterItem;
import com.google.maps.android.clustering.ClusterManager;
import io.flutter.plugin.common.MethodChannel;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

class ClusterController
    implements ClusterManager.OnClusterItemClickListener,
        ClusterManager.OnClusterClickListener,
        ClusterManager.OnClusterInfoWindowClickListener,
        ClusterManager.OnClusterItemInfoWindowClickListener {

  private final Map<String, ClusterItemController> clusterItemIdToController;
  private final Map<String, String> googleMapsClusterItemIdToDartMarkerId;
  private ClusterManager<ClusterItemController> mClusterManager;

  private final MethodChannel methodChannel;
  private GoogleMap googleMap;

  ClusterController(MethodChannel methodChannel) {
    this.clusterItemIdToController = new HashMap<>();
    this.googleMapsClusterItemIdToDartMarkerId = new HashMap<>();
    this.methodChannel = methodChannel;
  }

  void setGoogleMap(GoogleMap googleMap) {
    this.googleMap = googleMap;
  }

  void setClusterManager(ClusterManager<ClusterItemController> mClusterManager) {
    this.mClusterManager = mClusterManager;
  }

  void addClusterItems(List<Object> itemsToAdd) {
    if (itemsToAdd != null) {
      for (Object itemToAdd : itemsToAdd) {
        addClusterItem(itemToAdd);
      }
      this.mClusterManager.cluster();
    }
  }

  private void addClusterItem(Object item) {
    if (item == null) {
      return;
    }
    MarkerBuilder markerBuilder = new MarkerBuilder();
    String markerId = Convert.interpretMarkerOptions(item, markerBuilder);
    MarkerOptions options = markerBuilder.build();
    addClusterItem(markerId, options, markerBuilder.consumeTapEvents());
  }

  private void addClusterItem(
      String markerId, MarkerOptions markerOptions, boolean consumeTapEvents) {
    LatLng latLng = markerOptions.getPosition();
    ClusterItemController clusterItem =
        new ClusterItemController(
            latLng.latitude,
            latLng.longitude,
            markerOptions.getTitle(),
            markerOptions.getSnippet(),
            markerId,
            consumeTapEvents,
            markerOptions.getIcon());
    this.mClusterManager.addItem(clusterItem);

    clusterItemIdToController.put(markerId, clusterItem);
  }

  void changeClusterItems(List<Object> ClusterItemToChange) {
    if (ClusterItemToChange != null) {
      for (Object clusterItemToChange : ClusterItemToChange) {
        changeClusterItem(clusterItemToChange);
      }
    }
  }

  private void changeClusterItem(Object clusterItem) {
    if (clusterItem == null) {
      return;
    }
    String markerId = getClusterItemId(clusterItem);
    ClusterItemController clusterItemController = clusterItemIdToController.get(markerId);
    // TODO: to be done
    // if (clusterItemController != null) {
    // Convert.interpretMarkerOptions(clusterItem, clusterItemController);
    // }
  }

  void removeClusterItems(List<Object> clusterItemIdsToRemove) {
    if (clusterItemIdsToRemove == null) {
      return;
    }
    for (Object rawClusterItemId : clusterItemIdsToRemove) {
      if (rawClusterItemId == null) {
        continue;
      }
      String clusterItemId = (String) rawClusterItemId;
      final ClusterItemController clusterItemController =
          clusterItemIdToController.remove(clusterItemId);
      if (clusterItemController != null) {
        googleMapsClusterItemIdToDartMarkerId.remove(
            clusterItemController.getGoogleMapsClusterItemId());
        mClusterManager.removeItem(clusterItemController);
        mClusterManager.cluster();
      }
    }
  }

  @SuppressWarnings("unchecked")
  private static String getClusterItemId(Object clusterItem) {
    Map<String, Object> clusterItemMap = (Map<String, Object>) clusterItem;
    return (String) clusterItemMap.get("markerId");
  }

  @Override
  public boolean onClusterItemClick(ClusterItem clusterItem) {
    String clusterItemId =
        ((ClusterItemController) clusterItem)
            .getGoogleMapsClusterItemId(); // googleMapsClusterItemIdToDartMarkerId.get(googleMarkerId);
    if (clusterItemId == null) {
      return false;
    }
    methodChannel.invokeMethod("clusterItem#onTap", Convert.markerIdToJson(clusterItemId));
    ClusterItemController clusterController = clusterItemIdToController.get(clusterItemId);
    if (clusterController != null) {
      return clusterController
          .consumeTapEvents(); // TODO: check it, for now this events is constant.
    }
    return false;
  }

  @Override
  public boolean onClusterClick(Cluster cluster) {
    // TODO: to be done
    Log.d("ClusterController", "onClusterClick: ");
    return false;
  }

  @Override
  public void onClusterInfoWindowClick(Cluster cluster) {
    // TODO: to be done
    Log.d("ClusterController", "onClusterInfoWindowClick: ");
  }

  @Override
  public void onClusterItemInfoWindowClick(ClusterItem clusterItem) {
    String clusterItemId =
        ((ClusterItemController) clusterItem)
            .getGoogleMapsClusterItemId(); // googleMapsClusterItemIdToDartMarkerId.get(googleMarkerId);
    if (clusterItemId == null) {
      return;
    }
    methodChannel.invokeMethod("custerItemInfoWindow#onTap", Convert.markerIdToJson(clusterItemId));
  }
}
