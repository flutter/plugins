// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.googlemaps;

import com.google.android.gms.maps.model.TileOverlay;
import com.google.maps.android.heatmaps.Gradient;
import com.google.maps.android.heatmaps.HeatmapTileProvider;
import com.google.maps.android.heatmaps.WeightedLatLng;
import java.util.List;
import java.util.Map;

public class HeatmapController implements HeatmapOptionsSink {
  private final HeatmapTileProvider heatmap;
  private final TileOverlay heatmapTileOverlay;

  HeatmapController(HeatmapTileProvider heatmap, TileOverlay heatmapTileOverlay) {
    this.heatmap = heatmap;
    this.heatmapTileOverlay = heatmapTileOverlay;
  }

  void remove() {
    heatmapTileOverlay.remove();
  }

  void clearTileCache() {
    heatmapTileOverlay.clearTileCache();
  }

  Map<String, Object> getHeatmapInfo() {
    try {
      return Convert.heatmapToJson(heatmap);
    } catch (Exception e) {
      return null;
    }
  }

  @Override
  public void setWeightedData(List<WeightedLatLng> weightedData) {
    heatmap.setWeightedData(weightedData);
  }

  @Override
  public void setGradient(Gradient gradient) {
    heatmap.setGradient(gradient);
  }

  @Override
  public void setMaxIntensity(double maxIntensity) {
    heatmap.setMaxIntensity(maxIntensity);
  }

  @Override
  public void setOpacity(double opacity) {
    heatmap.setOpacity(opacity);
  }

  @Override
  public void setRadius(int radius) {
    heatmap.setRadius(radius);
  }
}
