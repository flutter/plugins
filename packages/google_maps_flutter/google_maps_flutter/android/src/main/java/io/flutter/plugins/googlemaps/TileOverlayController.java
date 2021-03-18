// Copyright 2018 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.googlemaps;

import com.google.android.gms.maps.model.TileOverlay;
import com.google.android.gms.maps.model.TileProvider;
import java.util.HashMap;
import java.util.Map;

class TileOverlayController implements TileOverlaySink {

  private final TileOverlay tileOverlay;

  TileOverlayController(TileOverlay tileOverlay) {
    this.tileOverlay = tileOverlay;
  }

  void remove() {
    tileOverlay.remove();
  }

  void clearTileCache() {
    tileOverlay.clearTileCache();
  }

  Map<String, Object> getTileOverlayInfo() {
    Map<String, Object> tileOverlayInfo = new HashMap<>();
    tileOverlayInfo.put("fadeIn", tileOverlay.getFadeIn());
    tileOverlayInfo.put("transparency", tileOverlay.getTransparency());
    tileOverlayInfo.put("id", tileOverlay.getId());
    tileOverlayInfo.put("zIndex", tileOverlay.getZIndex());
    tileOverlayInfo.put("visible", tileOverlay.isVisible());
    return tileOverlayInfo;
  }

  @Override
  public void setFadeIn(boolean fadeIn) {
    tileOverlay.setFadeIn(fadeIn);
  }

  @Override
  public void setTransparency(float transparency) {
    tileOverlay.setTransparency(transparency);
  }

  @Override
  public void setZIndex(float zIndex) {
    tileOverlay.setZIndex(zIndex);
  }

  @Override
  public void setVisible(boolean visible) {
    tileOverlay.setVisible(visible);
  }

  @Override
  public void setTileProvider(TileProvider tileProvider) {
    // You can not change tile provider after creation
  }
}
