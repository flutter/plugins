// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.googlemaps;

import com.google.android.gms.maps.model.LatLng;
import com.google.android.gms.maps.model.PolygonOptions;
import java.util.List;

class PolygonBuilder implements PolygonOptionsSink {
  private final PolygonOptions polygonOptions;
  private final float density;
  private boolean consumeTapEvents;

  PolygonBuilder(float density) {
    this.polygonOptions = new PolygonOptions();
    this.density = density;
  }

  PolygonOptions build() {
    return polygonOptions;
  }

  boolean consumeTapEvents() {
    return consumeTapEvents;
  }

  @Override
  public void setFillColor(int color) {
    polygonOptions.fillColor(color);
  }

  @Override
  public void setStrokeColor(int color) {
    polygonOptions.strokeColor(color);
  }

  @Override
  public void setPoints(List<LatLng> points) {
    polygonOptions.addAll(points);
  }

  @Override
  public void setHoles(List<List<LatLng>> holes) {
    for (List<LatLng> hole : holes) {
      polygonOptions.addHole(hole);
    }
  }

  @Override
  public void setConsumeTapEvents(boolean consumeTapEvents) {
    this.consumeTapEvents = consumeTapEvents;
    polygonOptions.clickable(consumeTapEvents);
  }

  @Override
  public void setGeodesic(boolean geodisc) {
    polygonOptions.geodesic(geodisc);
  }

  @Override
  public void setVisible(boolean visible) {
    polygonOptions.visible(visible);
  }

  @Override
  public void setStrokeWidth(float width) {
    polygonOptions.strokeWidth(width * density);
  }

  @Override
  public void setZIndex(float zIndex) {
    polygonOptions.zIndex(zIndex);
  }
}
