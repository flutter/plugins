// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.googlemaps;

import com.google.android.gms.maps.model.TileOverlay;
import com.google.android.gms.maps.model.TileOverlayOptions;
import com.google.maps.android.heatmaps.Gradient;
import com.google.maps.android.heatmaps.HeatmapTileProvider;
import com.google.maps.android.heatmaps.WeightedLatLng;
import java.util.List;

/** Receiver of Heatmap configuration options. */
class HeatmapOptions implements HeatmapOptionsSink {

  private final HeatmapTileProvider.Builder mHeatmapTileProviderBuilder;

  private HeatmapTileProvider mHeatmapTileProvider;

  private final TileOverlayOptions mTileOverlayOptions;

  private TileOverlay mTileOverlay;

  public HeatmapOptions() {
    mHeatmapTileProviderBuilder = new HeatmapTileProvider.Builder();
    mTileOverlayOptions = new TileOverlayOptions();
  }

  public void setPoints(List<WeightedLatLng> points) {
    if (null == mHeatmapTileProvider) {
      mHeatmapTileProviderBuilder.weightedData(points);
    } else {
      mHeatmapTileProvider.setWeightedData(points);
    }
  }

  public void setGradient(Gradient gradient) {
    if (null == mHeatmapTileProvider) {
      mHeatmapTileProviderBuilder.gradient(gradient);
    } else {
      mHeatmapTileProvider.setGradient(gradient);
    }
  }

  public void setOpacity(double opacity) {
    if (null == mHeatmapTileProvider) {
      mHeatmapTileProviderBuilder.opacity(opacity);
    } else {
      mHeatmapTileProvider.setOpacity(opacity);
    }
  }

  public void setRadius(int radius) {
    if (null == mHeatmapTileProvider) {
      mHeatmapTileProviderBuilder.radius(radius);
    } else {
      mHeatmapTileProvider.setRadius(radius);
    }
  }

  public void setFadeIn(boolean fadeIn) {
    if (null == mTileOverlay) {
      mTileOverlayOptions.fadeIn(fadeIn);
    } else {
      mTileOverlay.setFadeIn(fadeIn);
    }
  }

  public void setTransparency(float transparency) {
    if (null == mTileOverlay) {
      mTileOverlayOptions.transparency(transparency);
    } else {
      mTileOverlay.setTransparency(transparency);
    }
  }

  public void setVisible(boolean visible) {
    if (null == mTileOverlay) {
      mTileOverlayOptions.visible(visible);
    } else {
      mTileOverlay.setVisible(visible);
    }
  }

  public void setZIndex(float zIndex) {
    if (null == mTileOverlay) {
      mTileOverlayOptions.zIndex(zIndex);
    } else {
      mTileOverlay.setZIndex(zIndex);
    }
  }

  public HeatmapTileProvider.Builder getHeatmapTileProviderBuilder() {
    return mHeatmapTileProviderBuilder;
  }

  public HeatmapTileProvider getHeatmapTileProvider() {
    return mHeatmapTileProvider;
  }

  public void setHeatmapTileProvider(HeatmapTileProvider heatmapTileProvider) {
    mHeatmapTileProvider = heatmapTileProvider;
    mTileOverlayOptions.tileProvider(mHeatmapTileProvider);
  }

  public TileOverlayOptions getTileOverlayOptions() {
    return mTileOverlayOptions;
  }

  public void setTileOverlay(TileOverlay tileOverlay) {
    mTileOverlay = tileOverlay;
  }
}
