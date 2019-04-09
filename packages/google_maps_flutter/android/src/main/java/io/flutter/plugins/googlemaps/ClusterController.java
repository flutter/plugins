// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.googlemaps;

import android.util.Log;
import android.widget.Toast;

import com.google.android.gms.maps.GoogleMap;
import com.google.android.gms.maps.model.LatLng;
import com.google.android.gms.maps.model.Marker;
import com.google.android.gms.maps.model.MarkerOptions;
import io.flutter.plugin.common.MethodChannel;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import com.google.maps.android.clustering.Cluster;
import com.google.maps.android.clustering.ClusterItem;
import com.google.maps.android.clustering.ClusterManager;

class ClusterController implements ClusterManager.OnClusterItemClickListener, ClusterManager.OnClusterClickListener, ClusterManager.OnClusterInfoWindowClickListener, ClusterManager.OnClusterItemInfoWindowClickListener {

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

    private void addClusterItem(String markerId, MarkerOptions markerOptions, boolean consumeTapEvents) {
        LatLng latLng = markerOptions.getPosition();
        ClusterItemController clusterItem = new ClusterItemController(latLng.latitude, latLng.longitude, markerId);
        this.mClusterManager.addItem(clusterItem);
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
        //TODO:  check it
//        if (clusterItemController != null) {
//            Convert.interpretMarkerOptions(clusterItem, clusterItemController);
//        }
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
            final ClusterItemController clusterItemController = clusterItemIdToController.remove(clusterItemId);
            if (clusterItemController != null) {
                //TODO: check it
                //clusterItemController.remove();
                googleMapsClusterItemIdToDartMarkerId.remove(clusterItemController.getGoogleMapsClusterItemId());
            }
        }
    }
/*
    boolean onMarkerTap(String googleMarkerId) {
        String markerId = googleMapsMarkerIdToDartMarkerId.get(googleMarkerId);
        if (markerId == null) {
            return false;
        }
        methodChannel.invokeMethod("marker#onTap", Convert.toJson(markerId));
        MarkerController markerController = markerIdToController.get(markerId);
        if (markerController != null) {
            return markerController.consumeTapEvents();
        }
        return false;
    }

    void onInfoWindowTap(String googleMarkerId) {
        String markerId = googleMapsMarkerIdToDartMarkerId.get(googleMarkerId);
        if (markerId == null) {
            return;
        }
        methodChannel.invokeMethod("infoWindow#onTap", Convert.toJson(markerId));
    }

    */

    @SuppressWarnings("unchecked")
    private static String getClusterItemId(Object clusterItem) {
        Map<String, Object> clusterItemMap = (Map<String, Object>) clusterItem;
        return (String) clusterItemMap.get("markerId");
    }

    @Override
    public boolean onClusterItemClick(ClusterItem clusterItem) {
        Log.d("ClusterController", "onClusterItemClick: ");
        return false;
    }

    @Override
    public boolean onClusterClick(Cluster cluster) {
        Log.d("ClusterController", "onClusterClick: ");
        return false;
    }

    @Override
    public void onClusterInfoWindowClick(Cluster cluster) {
        Log.d("ClusterController", "onClusterInfoWindowClick: ");

    }

    @Override
    public void onClusterItemInfoWindowClick(ClusterItem clusterItem) {
        Log.d("ClusterController", "onClusterItemInfoWindowClick: ");

    }
}
