// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.googlemaps;

import com.google.maps.android.heatmaps.Gradient;
import com.google.maps.android.heatmaps.HeatmapTileProvider;
import com.google.maps.android.heatmaps.WeightedLatLng;
import java.util.List;

class HeatmapBuilder implements HeatmapOptionsSink {
  private final HeatmapOptions heatmapOptions;

  HeatmapBuilder() {
    heatmapOptions = new HeatmapOptions();
  }

  HeatmapOptions build() {
    HeatmapTileProvider heatmapTileProvider =
        heatmapOptions.getHeatmapTileProviderBuilder().build();
    heatmapOptions.setHeatmapTileProvider(heatmapTileProvider);
    return heatmapOptions;
  }

  @Override
  public void setPoints(List<WeightedLatLng> points) {
    heatmapOptions.setPoints(points);
  }

  @Override
  public void setGradient(Gradient gradient) {
    heatmapOptions.setGradient(gradient);
  }

  @Override
  public void setOpacity(double opacity) {
    heatmapOptions.setOpacity(opacity);
  }

  @Override
  public void setRadius(int radius) {
    heatmapOptions.setRadius(radius);
  }

  @Override
  public void setFadeIn(boolean fadeIn) {
    heatmapOptions.setFadeIn(fadeIn);
  }

  @Override
  public void setTransparency(float transparency) {
    heatmapOptions.setTransparency(transparency);
  }

  @Override
  public void setVisible(boolean visible) {
    heatmapOptions.setVisible(visible);
  }

  @Override
  public void setZIndex(float zIndex) {
    heatmapOptions.setZIndex(zIndex);
  }
}
