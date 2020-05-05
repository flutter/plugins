// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.googlemaps;

import com.google.android.gms.maps.model.TileOverlay;
import com.google.maps.android.heatmaps.Gradient;
import com.google.maps.android.heatmaps.WeightedLatLng;
import java.util.List;

/** Controller of a single Heatmap on the map. */
class HeatmapController implements HeatmapOptionsSink {

  private final HeatmapOptions mHeatmapOptions;

  private final TileOverlay mTileOverlay;

  private final String mGoogleMapsHeatmapId;

  HeatmapController(HeatmapOptions heatmapOptions, TileOverlay tileOverlay) {
    mHeatmapOptions = heatmapOptions;
    mTileOverlay = tileOverlay;
    mGoogleMapsHeatmapId = tileOverlay.getId();
  }

  void remove() {
    mTileOverlay.remove();
  }

  private void clearTileOverlayCache() {
    mTileOverlay.clearTileCache();
  }

  @Override
  public void setPoints(List<WeightedLatLng> points) {
    mHeatmapOptions.setPoints(points);
    clearTileOverlayCache();
  }

  @Override
  public void setGradient(Gradient gradient) {
    mHeatmapOptions.setGradient(gradient);
    clearTileOverlayCache();
  }

  @Override
  public void setOpacity(double opacity) {
    mHeatmapOptions.setOpacity(opacity);
    clearTileOverlayCache();
  }

  @Override
  public void setRadius(int radius) {
    mHeatmapOptions.setRadius(radius);
    clearTileOverlayCache();
  }

  @Override
  public void setFadeIn(boolean fadeIn) {
    mHeatmapOptions.setFadeIn(fadeIn);
  }

  @Override
  public void setTransparency(float transparency) {
    mHeatmapOptions.setTransparency(transparency);
  }

  @Override
  public void setVisible(boolean visible) {
    mHeatmapOptions.setVisible(visible);
  }

  @Override
  public void setZIndex(float zIndex) {
    mHeatmapOptions.setZIndex(zIndex);
  }

  String getGoogleMapsHeatmapId() {
    return mGoogleMapsHeatmapId;
  }
}
