// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.googlemaps;

import com.google.android.gms.maps.GoogleMap;
import com.google.android.gms.maps.model.TileOverlay;
import io.flutter.plugin.common.MethodChannel;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

class HeatmapsController {

  private final Map<String, HeatmapController> mHeatmapIdToController;
  private final Map<String, String> mGoogleMapsHeatmapIdToDartHeatmapId;
  private final MethodChannel mMethodChannel;
  private GoogleMap mGoogleMap;

  HeatmapsController(MethodChannel methodChannel) {
    mHeatmapIdToController = new HashMap<>();
    mGoogleMapsHeatmapIdToDartHeatmapId = new HashMap<>();
    mMethodChannel = methodChannel;
  }

  void setGoogleMap(GoogleMap googleMap) {
    mGoogleMap = googleMap;
  }

  void addHeatmaps(List<Object> heatmapsToAdd) {
    if (heatmapsToAdd != null) {
      for (Object heatmapToAdd : heatmapsToAdd) {
        addHeatmap(heatmapToAdd);
      }
    }
  }

  void changeHeatmaps(List<Object> heatmapsToChange) {
    if (heatmapsToChange != null) {
      for (Object heatmapToChange : heatmapsToChange) {
        changeHeatmap(heatmapToChange);
      }
    }
  }

  void removeHeatmaps(List<Object> heatmapIdsToRemove) {
    if (heatmapIdsToRemove == null) {
      return;
    }
    for (Object rawHeatmapId : heatmapIdsToRemove) {
      if (rawHeatmapId == null) {
        continue;
      }
      String heatmapId = (String) rawHeatmapId;
      final HeatmapController heatmapController = mHeatmapIdToController.remove(heatmapId);
      if (heatmapController != null) {
        heatmapController.remove();
        mGoogleMapsHeatmapIdToDartHeatmapId.remove(heatmapController.getGoogleMapsHeatmapId());
      }
    }
  }

  private void addHeatmap(Object heatmap) {
    if (heatmap == null) {
      return;
    }
    HeatmapBuilder heatmapBuilder = new HeatmapBuilder();
    String heatmapId = Convert.interpretHeatmapOptions(heatmap, heatmapBuilder);
    HeatmapOptions options = heatmapBuilder.build();
    addHeatmap(heatmapId, options);
  }

  private void addHeatmap(String heatmapId, HeatmapOptions heatmapOptions) {

    TileOverlay overlay = mGoogleMap.addTileOverlay(heatmapOptions.getTileOverlayOptions());
    heatmapOptions.setTileOverlay(overlay);

    HeatmapController controller = new HeatmapController(heatmapOptions, overlay);
    mHeatmapIdToController.put(heatmapId, controller);
    mGoogleMapsHeatmapIdToDartHeatmapId.put(overlay.getId(), heatmapId);
  }

  private void changeHeatmap(Object heatmap) {
    if (heatmap == null) {
      return;
    }
    String heatmapId = getHeatmapId(heatmap);
    HeatmapController heatmapController = mHeatmapIdToController.get(heatmapId);
    if (heatmapController != null) {
      Convert.interpretHeatmapOptions(heatmap, heatmapController);
    }
  }

  @SuppressWarnings("unchecked")
  private static String getHeatmapId(Object heatmap) {
    Map<String, Object> heatmapMap = (Map<String, Object>) heatmap;
    return (String) heatmapMap.get("heatmapId");
  }
}
